-- Price history tracking + original listing price + smart-alert price-drop rematch.

-- ---------------------------------------------------------------------------
-- original_price on listings
-- ---------------------------------------------------------------------------
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS original_price BIGINT;

UPDATE public.listings
SET original_price = COALESCE(price_iqd, price, 0)
WHERE original_price IS NULL;

CREATE OR REPLACE FUNCTION public.set_original_price()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.original_price := COALESCE(NEW.price_iqd, NEW.price, 0);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_insert_set_original ON public.listings;
CREATE TRIGGER on_listing_insert_set_original
  BEFORE INSERT ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_original_price();

-- ---------------------------------------------------------------------------
-- price_history
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.price_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  old_price BIGINT NOT NULL CHECK (old_price >= 0),
  new_price BIGINT NOT NULL CHECK (new_price >= 0),
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS price_history_listing_changed_idx
  ON public.price_history (listing_id, changed_at ASC);

ALTER TABLE public.price_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read price history for visible listings" ON public.price_history;
CREATE POLICY "Public read price history for visible listings"
  ON public.price_history FOR SELECT
  TO anon, authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id = listing_id
        AND l.status = 'approved'
        AND l.availability IN ('active', 'sold')
    )
  );

GRANT SELECT ON public.price_history TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.record_price_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  old_p BIGINT;
  new_p BIGINT;
BEGIN
  old_p := COALESCE(OLD.price_iqd, OLD.price, 0);
  new_p := COALESCE(NEW.price_iqd, NEW.price, 0);

  IF old_p IS DISTINCT FROM new_p THEN
    INSERT INTO public.price_history (listing_id, old_price, new_price)
    VALUES (OLD.id, old_p, new_p);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_price_update ON public.listings;
CREATE TRIGGER on_listing_price_update
  AFTER UPDATE OF price, price_iqd ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.record_price_change();

-- ---------------------------------------------------------------------------
-- Smart alerts: also notify when price drop brings listing into alert range
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.listing_matches_price_range(
  p_price BIGINT,
  p_min BIGINT,
  p_max BIGINT
)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT (p_min IS NULL OR p_price >= p_min)
     AND (p_max IS NULL OR p_price <= p_max);
$$;

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

  IF app_id IS NULL OR api_key IS NULL OR api_key = 'YOUR_ONESIGNAL_REST_API_KEY' THEN
    RETURN NEW;
  END IF;

  FOR alert IN
    SELECT sa.*, p.onesignal_player_id
    FROM public.smart_alerts sa
    INNER JOIN public.profiles p ON p.id = sa.user_id
    WHERE sa.is_active = TRUE
      AND sa.user_id <> NEW.user_id
      AND p.onesignal_player_id IS NOT NULL
      AND btrim(p.onesignal_player_id) <> ''
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

    player_ids := jsonb_build_array(alert.onesignal_player_id);

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

    PERFORM net.http_post(
      url := 'https://onesignal.com/api/v1/notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Basic ' || api_key
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
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_notify_smart_alerts ON public.listings;
DROP TRIGGER IF EXISTS on_listing_update_notify_alerts ON public.listings;
CREATE TRIGGER on_listing_notify_smart_alerts
  AFTER INSERT OR UPDATE OF status, availability, price, price_iqd ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_smart_alerts();
