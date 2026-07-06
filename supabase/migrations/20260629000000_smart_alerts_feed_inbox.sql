-- Smart alerts currently only send a OneSignal push, and bail out entirely when
-- the push key is unset — so matching alerts notify nobody. Make the trigger
-- ALSO write into the in-app notifications inbox (works without push), and send
-- push only as an extra when it's actually configured.

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
  listing_condition TEXT;
  listing_title TEXT;
  app_id TEXT;
  api_key TEXT;
  push_ready BOOLEAN;
BEGIN
  IF NEW.status IS DISTINCT FROM 'approved'
     OR NEW.availability IS DISTINCT FROM 'active' THEN
    RETURN NEW;
  END IF;

  -- Only fire when the listing first becomes publicly visible.
  IF TG_OP = 'UPDATE'
     AND OLD.status = 'approved'
     AND OLD.availability = 'active' THEN
    RETURN NEW;
  END IF;

  SELECT * INTO identity FROM public.listing_alert_identity(NEW.category_id);

  listing_price := COALESCE(NEW.price_iqd, NEW.price::BIGINT, 0);
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
      AND (sa.price_min IS NULL OR listing_price >= sa.price_min)
      AND (sa.price_max IS NULL OR listing_price <= sa.price_max)
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
    SET last_triggered_at = NOW(),
        trigger_count = trigger_count + 1
    WHERE id = alert.id;

    -- Always land in the in-app inbox (works even without push configured).
    -- Uses 'info' (allowed by notifications_type_check). To show a dedicated
    -- smart-alert icon, extend that CHECK to include 'smart_alert' and swap here.
    INSERT INTO public.notifications (user_id, listing_id, type, title, body)
    VALUES (
      alert.user_id,
      NEW.id,
      'info',
      'تنبيه ذكي 🔔',
      'وجدنا إعلاناً يناسب تنبيهك: '
        || listing_title || ' — ' || listing_price::TEXT || ' د.ع'
    );

    -- Push is a bonus on top of the inbox entry.
    IF push_ready
       AND alert.onesignal_player_id IS NOT NULL
       AND btrim(alert.onesignal_player_id) <> '' THEN
      PERFORM net.http_post(
        url := 'https://onesignal.com/api/v1/notifications',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          -- New OneSignal keys (os_v2_app_…) use "Key", legacy keys use "Basic".
          'Authorization',
          (CASE WHEN api_key LIKE 'os_v2_%' THEN 'Key ' ELSE 'Basic ' END)
            || api_key
        ),
        body := jsonb_build_object(
          'app_id', app_id,
          'include_player_ids', jsonb_build_array(alert.onesignal_player_id),
          'headings', jsonb_build_object('ar', 'تنبيه ذكي 🔔'),
          'contents', jsonb_build_object(
            'ar',
            'وجدنا إعلاناً يناسب تنبيهك: '
              || listing_title || ' — ' || listing_price::TEXT || ' د.ع'
          ),
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
