-- Smart Alerts (تنبيه ذكي) — saved search criteria with push notifications.
-- Requires pg_net extension (Database → Extensions → pg_net).

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ---------------------------------------------------------------------------
-- smart_alerts
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.smart_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  category TEXT,
  subcategory TEXT,
  make TEXT,
  model TEXT,
  year_min INTEGER,
  year_max INTEGER,
  price_min BIGINT,
  price_max BIGINT,
  location TEXT,
  condition TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_triggered_at TIMESTAMPTZ,
  trigger_count INTEGER NOT NULL DEFAULT 0 CHECK (trigger_count >= 0)
);

CREATE INDEX IF NOT EXISTS smart_alerts_user_active_idx
  ON public.smart_alerts (user_id, is_active);

CREATE INDEX IF NOT EXISTS smart_alerts_active_idx
  ON public.smart_alerts (is_active)
  WHERE is_active = TRUE;

ALTER TABLE public.smart_alerts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own smart alerts" ON public.smart_alerts;
CREATE POLICY "Users read own smart alerts"
  ON public.smart_alerts FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users insert own smart alerts" ON public.smart_alerts;
CREATE POLICY "Users insert own smart alerts"
  ON public.smart_alerts FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users update own smart alerts" ON public.smart_alerts;
CREATE POLICY "Users update own smart alerts"
  ON public.smart_alerts FOR UPDATE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id)
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users delete own smart alerts" ON public.smart_alerts;
CREATE POLICY "Users delete own smart alerts"
  ON public.smart_alerts FOR DELETE
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.smart_alerts TO authenticated;

-- profiles.onesignal_player_id added in 20260530000006_chat_enhancements.sql

-- Server-only push credentials (no RLS policies = blocked from Data API).
CREATE TABLE IF NOT EXISTS public.push_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

ALTER TABLE public.push_config ENABLE ROW LEVEL SECURITY;

INSERT INTO public.push_config (key, value) VALUES
  ('onesignal_app_id', '7b9d845a-aece-4b67-a812-6ce17be8bd7d'),
  ('onesignal_rest_api_key', 'YOUR_ONESIGNAL_REST_API_KEY')
ON CONFLICT (key) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Resolve listing category identity for alert matching
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.listing_alert_identity(p_category_id INT)
RETURNS TABLE (
  root_category TEXT,
  subcategory TEXT,
  make_name TEXT,
  model_name TEXT,
  model_year INT
)
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  WITH RECURSIVE chain AS (
    SELECT c.id, c.parent_id, c.name_ar, c.icon, 0 AS depth
    FROM public.categories c
    WHERE c.id = p_category_id
    UNION ALL
    SELECT c.id, c.parent_id, c.name_ar, c.icon, chain.depth + 1
    FROM public.categories c
    INNER JOIN chain ON c.id = chain.parent_id
  )
  SELECT
    (SELECT ch.name_ar FROM chain ch ORDER BY ch.depth DESC LIMIT 1),
    (
      SELECT ch.name_ar
      FROM chain ch
      WHERE ch.depth = (
        SELECT MAX(c2.depth) - 1 FROM chain c2
      )
      LIMIT 1
    ),
    (SELECT ch.name_ar FROM chain ch WHERE ch.icon = 'brand' LIMIT 1),
    (SELECT ch.name_ar FROM chain ch WHERE ch.icon = 'model' LIMIT 1),
    (
      SELECT (regexp_match(ch.name_ar, '^(19|20)\d{2}$'))[1]::INT
      FROM chain ch
      WHERE ch.name_ar ~ '^(19|20)\d{2}$'
      LIMIT 1
    );
$$;

-- ---------------------------------------------------------------------------
-- Notify matching smart alerts when a listing becomes publicly visible
-- ---------------------------------------------------------------------------
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
  player_ids JSONB;
BEGIN
  IF NEW.status IS DISTINCT FROM 'approved'
     OR NEW.availability IS DISTINCT FROM 'active' THEN
    RETURN NEW;
  END IF;

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
    SET
      last_triggered_at = NOW(),
      trigger_count = trigger_count + 1
    WHERE id = alert.id;

    player_ids := jsonb_build_array(alert.onesignal_player_id);

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
        'contents', jsonb_build_object(
          'ar',
          'وجدنا إعلاناً يناسب تنبيهك: '
            || listing_title
            || ' — '
            || listing_price::TEXT
            || ' د.ع'
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
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_listing_insert_notify_alerts ON public.listings;
DROP TRIGGER IF EXISTS on_listing_notify_smart_alerts ON public.listings;
CREATE TRIGGER on_listing_notify_smart_alerts
  AFTER INSERT OR UPDATE OF status, availability ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_smart_alerts();
