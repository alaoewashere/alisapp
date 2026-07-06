-- ============================================================
-- Premium features:
--   1. listing_events — hourly analytics (views / contacts)
--   2. notify_premium_listing — push to category-interested users
-- ============================================================

-- -------------------------------------------------------
-- 1. Listing events table for advanced analytics
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.listing_events (
  id          BIGSERIAL PRIMARY KEY,
  listing_id  UUID    NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  event_type  TEXT    NOT NULL CHECK (event_type IN ('view', 'contact')),
  hour_of_day SMALLINT NOT NULL CHECK (hour_of_day BETWEEN 0 AND 23),
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS listing_events_listing_id_idx
  ON public.listing_events (listing_id, created_at DESC);

CREATE INDEX IF NOT EXISTS listing_events_type_hour_idx
  ON public.listing_events (listing_id, event_type, hour_of_day);

-- RLS: owners read their own, no client writes
ALTER TABLE public.listing_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners read their listing events"
  ON public.listing_events FOR SELECT
  TO authenticated
  USING (
    listing_id IN (
      SELECT id FROM public.listings WHERE user_id = auth.uid()
    )
  );

-- 1a. Extend increment_listing_views to also log an event
CREATE OR REPLACE FUNCTION public.increment_listing_views(listing_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.listings
  SET views_count = views_count + 1
  WHERE id = listing_id;

  INSERT INTO public.listing_events (listing_id, event_type, hour_of_day, day_of_week)
  VALUES (
    listing_id,
    'view',
    EXTRACT(HOUR FROM NOW())::SMALLINT,
    EXTRACT(DOW  FROM NOW())::SMALLINT
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.increment_listing_views(UUID) TO anon, authenticated;

-- 1b. Log contact events (called when buyer taps "message seller")
--     Same signature as the original so existing app code keeps working.
CREATE OR REPLACE FUNCTION public.increment_listing_contacts(listing_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.listings
  SET contact_count = contact_count + 1
  WHERE id = listing_id;

  INSERT INTO public.listing_events (listing_id, event_type, hour_of_day, day_of_week)
  VALUES (
    listing_id,
    'contact',
    EXTRACT(HOUR FROM NOW())::SMALLINT,
    EXTRACT(DOW  FROM NOW())::SMALLINT
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.increment_listing_contacts(UUID) TO anon, authenticated;

-- 1c. Analytics summary RPC for the owner
CREATE OR REPLACE FUNCTION public.get_listing_analytics(p_listing_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_listing_user UUID;
  v_result JSON;
BEGIN
  -- Verify caller owns the listing
  SELECT user_id INTO v_listing_user
  FROM public.listings WHERE id = p_listing_id;

  IF v_listing_user IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'not_owner';
  END IF;

  SELECT json_build_object(
    'total_views',    COALESCE(l.views_count, 0),
    'total_contacts', COALESCE(l.contact_count, 0),
    'views_7d',       (
      SELECT COUNT(*) FROM public.listing_events
      WHERE listing_id = p_listing_id
        AND event_type = 'view'
        AND created_at >= NOW() - INTERVAL '7 days'
    ),
    'views_30d',      (
      SELECT COUNT(*) FROM public.listing_events
      WHERE listing_id = p_listing_id
        AND event_type = 'view'
        AND created_at >= NOW() - INTERVAL '30 days'
    ),
    'peak_hour',      (
      SELECT hour_of_day FROM public.listing_events
      WHERE listing_id = p_listing_id AND event_type = 'view'
      GROUP BY hour_of_day ORDER BY COUNT(*) DESC LIMIT 1
    ),
    'hourly_views',   (
      SELECT json_agg(row_to_json(t)) FROM (
        SELECT hour_of_day AS hour, COUNT(*) AS views
        FROM public.listing_events
        WHERE listing_id = p_listing_id AND event_type = 'view'
          AND created_at >= NOW() - INTERVAL '7 days'
        GROUP BY hour_of_day ORDER BY hour_of_day
      ) t
    )
  ) INTO v_result
  FROM public.listings l WHERE l.id = p_listing_id;

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_listing_analytics(UUID) TO authenticated;

-- -------------------------------------------------------
-- 2. Push notification to category-interested users
--    when a PREMIUM listing goes live
-- -------------------------------------------------------
CREATE OR REPLACE FUNCTION public.notify_premium_listing_publish()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_premium  BOOLEAN;
  v_identity    RECORD;
  v_title       TEXT;
  v_app_id      TEXT;
  v_api_key     TEXT;
  r             RECORD;
BEGIN
  -- Only fire when listing transitions to approved + active
  IF NEW.status IS DISTINCT FROM 'approved'
     OR NEW.availability IS DISTINCT FROM 'active' THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.status = 'approved'
     AND OLD.availability = 'active' THEN
    RETURN NEW;
  END IF;

  -- Only for premium tier
  v_is_premium :=
    NEW.is_featured = TRUE
    OR (NEW.metadata->>'listing_package') IN ('premium', 'مميز', 'featured');

  IF NOT v_is_premium THEN
    RETURN NEW;
  END IF;

  SELECT value INTO v_app_id FROM public.push_config WHERE key = 'onesignal_app_id';
  SELECT value INTO v_api_key FROM public.push_config WHERE key = 'onesignal_rest_api_key';

  IF v_app_id IS NULL OR v_api_key IS NULL
     OR v_api_key = 'YOUR_ONESIGNAL_REST_API_KEY' THEN
    RETURN NEW;
  END IF;

  SELECT * INTO v_identity FROM public.listing_alert_identity(NEW.category_id);
  v_title := COALESCE(NULLIF(NEW.title_ar, ''), NEW.title, 'إعلان مميز جديد');

  -- Notify all users who have a smart alert for this root category
  FOR r IN
    SELECT DISTINCT p.onesignal_player_id
    FROM public.smart_alerts sa
    INNER JOIN public.profiles p ON p.id = sa.user_id
    WHERE sa.is_active = TRUE
      AND sa.user_id <> NEW.user_id
      AND p.onesignal_player_id IS NOT NULL
      AND btrim(p.onesignal_player_id) <> ''
      AND (sa.category IS NULL
           OR LOWER(sa.category) = LOWER(COALESCE(v_identity.root_category, '')))
  LOOP
    PERFORM net.http_post(
      url     := 'https://onesignal.com/api/v1/notifications',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Basic ' || v_api_key
      ),
      body := jsonb_build_object(
        'app_id',              v_app_id,
        'include_player_ids',  jsonb_build_array(r.onesignal_player_id),
        'headings',            jsonb_build_object('ar', 'إعلان مميز جديد ⭐'),
        'contents',            jsonb_build_object(
          'ar',
          'إعلان مميز جديد في فئتك: ' || v_title
        ),
        'data',                jsonb_build_object(
          'type',         'premium_listing',
          'listing_id',   NEW.id,
          'reference_no', NEW.reference_no
        ),
        'android_channel_id',  'smart_alerts',
        'ios_sound',           'default'
      )
    );
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_premium_listing_notify ON public.listings;
CREATE TRIGGER on_premium_listing_notify
  AFTER INSERT OR UPDATE OF status, availability, is_featured, metadata
  ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_premium_listing_publish();
