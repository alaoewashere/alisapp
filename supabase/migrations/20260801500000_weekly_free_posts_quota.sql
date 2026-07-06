-- Ongoing free-listing policy changes from 2/calendar-month to 1/calendar-week
-- (the one-time launch-week unlimited promo is separate and unaffected —
-- see app_settings.free_posts_unlimited_until). Function/column names are
-- kept as-is to avoid touching every call site; only the reset cadence changes.
CREATE OR REPLACE FUNCTION public.get_or_reset_monthly_free_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
  v_reset_at TIMESTAMPTZ;
  v_now TIMESTAMPTZ := now();
BEGIN
  IF auth.uid() IS NOT NULL AND auth.uid() IS DISTINCT FROM p_user_id THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  SELECT free_posts_this_month, free_posts_month_reset_at
  INTO v_count, v_reset_at
  FROM public.profiles
  WHERE id = p_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN 0;
  END IF;

  IF date_trunc('week', v_reset_at) < date_trunc('week', v_now) THEN
    UPDATE public.profiles
    SET free_posts_this_month = 0,
        free_posts_month_reset_at = v_now
    WHERE id = p_user_id;
    RETURN 0;
  END IF;

  RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION public.increment_monthly_free_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  v_count := public.get_or_reset_monthly_free_count(p_user_id);
  UPDATE public.profiles
  SET free_posts_this_month = v_count + 1
  WHERE id = p_user_id;
  RETURN v_count + 1;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_reset_monthly_free_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.increment_monthly_free_count(UUID) TO authenticated;

UPDATE public.app_settings
SET value = '5000', updated_at = now()
WHERE key = 'standard_listing_price_iqd';
