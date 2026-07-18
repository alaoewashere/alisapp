-- Fixes two regressions in public.notify_smart_alerts() introduced by later
-- migrations (20260717000000_smart_alerts.sql, 20260718000000_price_history.sql)
-- that silently dropped fixes from 20260629000000_smart_alerts_feed_inbox.sql:
--
-- 1. The OneSignal auth header was hardcoded to "Basic " + api_key. The
--    project's actual REST key is an os_v2_ key, which OneSignal requires
--    "Key " for, not "Basic " — every push send was failing auth silently
--    (net.http_post fires-and-forgets; no response is checked).
-- 2. There was no in-app notifications fallback, so a user whose push
--    delivery fails for ANY reason (auth, missing player id, OneSignal
--    downtime) never finds out their alert matched anything at all.
--
-- This version always writes an in-app notification row (the reliable path)
-- and additionally attempts a push when config allows it.
CREATE OR REPLACE FUNCTION public.notify_smart_alerts()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  alert RECORD;
  identity RECORD;
  listing_price BIGINT;
  old_listing_price BIGINT;
  listing_condition TEXT;
  listing_title TEXT;
  app_id TEXT;
  api_key TEXT;
  player_ids JSONB;
  price_changed BOOLEAN;
  notification_body TEXT;
  is_price_rematch BOOLEAN;
  push_ready BOOLEAN;
BEGIN
  IF NEW.status IS DISTINCT FROM 'approved'
     OR NEW.availability IS DISTINCT FROM 'active' THEN
    RETURN NEW;
  END IF;

  old_listing_price := COALESCE(OLD.price_iqd, OLD.price, 0);
  listing_price := COALESCE(NEW.price_iqd, NEW.price, 0);
  price_changed := old_listing_price IS DISTINCT FROM listing_price;

  is_price_rematch := TG_OP = 'UPDATE'
    AND price_changed
    AND OLD.status = 'approved'
    AND OLD.availability = 'active';

  IF TG_OP = 'UPDATE'
     AND OLD.status = 'approved'
     AND OLD.availability = 'active'
     AND NOT is_price_rematch THEN
    RETURN NEW;
  END IF;

  SELECT * INTO identity FROM public.listing_alert_identity(NEW.category_id);

  listing_condition := COALESCE(NEW.condition::TEXT, '');
  listing_title := COALESCE(NULLIF(NEW.title_ar, ''), NEW.title, 'إعلان جديد');

  SELECT value INTO app_id FROM public.push_config WHERE key = 'onesignal_app_id';
  SELECT value INTO api_key FROM public.push_config WHERE key = 'onesignal_rest_api_key';

  push_ready := app_id IS NOT NULL
    AND api_key IS NOT NULL
    AND api_key <> 'YOUR_ONESIGNAL_REST_API_KEY';

  FOR alert IN
    SELECT sa.*, p.onesignal_player_id
    FROM public.smart_alerts sa
    INNER JOIN public.profiles p ON p.id = sa.user_id
    WHERE sa.is_active = TRUE
      AND sa.user_id <> NEW.user_id
      AND (sa.category IS NULL OR LOWER(sa.category) = LOWER(identity.root_category))
      AND (
        sa.subcategory IS NULL
        OR LOWER(sa.subcategory) = LOWER(COALESCE(identity.subcategory, ''))
      )
      AND (sa.make IS NULL OR LOWER(sa.make) = LOWER(COALESCE(identity.make_name, '')))
      AND (sa.model IS NULL OR LOWER(sa.model) = LOWER(COALESCE(identity.model_name, '')))
      AND (sa.year_min IS NULL OR identity.model_year IS NULL OR identity.model_year >= sa.year_min)
      AND (sa.year_max IS NULL OR identity.model_year IS NULL OR identity.model_year <= sa.year_max)
      AND public.listing_matches_price_range(listing_price, sa.price_min, sa.price_max)
      AND (
        NOT is_price_rematch
        OR NOT public.listing_matches_price_range(old_listing_price, sa.price_min, sa.price_max)
      )
      AND (
        sa.location IS NULL
        OR LOWER(sa.location) = LOWER(COALESCE(NEW.city, ''))
        OR LOWER(sa.location) = LOWER(COALESCE(NEW.governorate, ''))
      )
      AND (
        sa.condition IS NULL
        OR sa.condition = listing_condition
        OR (sa.condition = 'جديد' AND listing_condition = 'new')
        OR (sa.condition = 'مستعمل' AND listing_condition = 'used')
      )
  LOOP
    UPDATE public.smart_alerts
    SET
      last_triggered_at = NOW(),
      trigger_count = trigger_count + 1
    WHERE id = alert.id;

    IF is_price_rematch AND listing_price < old_listing_price THEN
      notification_body :=
        'انخفض سعر إعلان يناسب تنبيهك! '
        || listing_title
        || ' — الآن بـ '
        || listing_price::TEXT
        || ' د.ع';
    ELSE
      notification_body :=
        'وجدنا إعلاناً يناسب تنبيهك: '
        || listing_title
        || ' — '
        || listing_price::TEXT
        || ' د.ع';
    END IF;

    -- Always create the in-app notification — this is the reliable path
    -- that doesn't depend on push config, player id presence, or OneSignal
    -- being reachable.
    INSERT INTO public.notifications (user_id, listing_id, type, title, body)
    VALUES (
      alert.user_id,
      NEW.id,
      'smart_alert',
      'تنبيه ذكي 🔔',
      notification_body
    );

    -- Best-effort push on top, only when config + player id both allow it.
    IF push_ready
       AND alert.onesignal_player_id IS NOT NULL
       AND btrim(alert.onesignal_player_id) <> '' THEN
      player_ids := jsonb_build_array(alert.onesignal_player_id);

      PERFORM net.http_post(
        url := 'https://onesignal.com/api/v1/notifications',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          -- os_v2_ REST keys require "Key ", legacy keys require "Basic ".
          'Authorization',
          (CASE WHEN api_key LIKE 'os_v2_%' THEN 'Key ' ELSE 'Basic ' END) || api_key
        ),
        body := jsonb_build_object(
          'app_id', app_id,
          'include_player_ids', player_ids,
          'headings', jsonb_build_object('ar', 'تنبيه ذكي 🔔'),
          'contents', jsonb_build_object('ar', notification_body),
          'data', jsonb_build_object(
            'type', 'smart_alert',
            'listing_id', NEW.id,
            'reference_no', NEW.reference_no
          ),
          'android_channel_id', 'smart_alerts',
          'ios_sound', 'default'
        )
      );
    END IF;
  END LOOP;

  RETURN NEW;
END;
$$;
