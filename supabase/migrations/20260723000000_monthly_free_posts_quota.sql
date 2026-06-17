-- Monthly free standard-tier listing quota (2 per calendar month per user).

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS free_posts_this_month INT NOT NULL DEFAULT 0
    CHECK (free_posts_this_month >= 0),
  ADD COLUMN IF NOT EXISTS free_posts_month_reset_at TIMESTAMPTZ NOT NULL DEFAULT now();

INSERT INTO public.app_settings (key, value) VALUES
  ('standard_listing_price_iqd', '99')
ON CONFLICT (key) DO NOTHING;

-- Allow paid standard listing purchases (over free quota).
ALTER TABLE public.listing_purchases
  DROP CONSTRAINT IF EXISTS listing_purchases_package_type_check;

ALTER TABLE public.listing_purchases
  ADD CONSTRAINT listing_purchases_package_type_check
  CHECK (package_type IN ('standard', 'pro', 'premium'));

ALTER TABLE public.pending_purchases
  DROP CONSTRAINT IF EXISTS pending_purchases_package_type_check;

ALTER TABLE public.pending_purchases
  ADD CONSTRAINT pending_purchases_package_type_check
  CHECK (package_type IN ('standard', 'pro', 'premium'));

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

  IF date_trunc('month', v_reset_at) < date_trunc('month', v_now) THEN
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

CREATE OR REPLACE FUNCTION public.approve_pending_purchase(p_pending_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pending public.pending_purchases%ROWTYPE;
  v_purchase_id UUID;
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'admin_required';
  END IF;

  SELECT * INTO v_pending
  FROM public.pending_purchases
  WHERE id = p_pending_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'pending_purchase_not_found';
  END IF;

  IF v_pending.status <> 'pending' THEN
    RAISE EXCEPTION 'pending_purchase_not_pending';
  END IF;

  INSERT INTO public.listing_purchases (
    user_id,
    listing_id,
    package_type,
    price,
    user_name,
    user_phone,
    user_email
  )
  VALUES (
    v_pending.user_id,
    v_pending.listing_id,
    v_pending.package_type,
    v_pending.price,
    v_pending.user_name,
    v_pending.user_phone,
    v_pending.user_email
  )
  RETURNING id INTO v_purchase_id;

  IF v_pending.package_type IN ('pro', 'premium') THEN
    INSERT INTO public.boosts (listing_id, user_id, type, expires_at, amount_paid)
    VALUES (
      v_pending.listing_id,
      v_pending.user_id,
      CASE WHEN v_pending.package_type = 'premium' THEN 'featured'::public.boost_type ELSE 'boosted'::public.boost_type END,
      now() + interval '30 days',
      v_pending.price::bigint
    );
  END IF;

  UPDATE public.pending_purchases
  SET status = 'approved',
      reviewed_at = now(),
      reviewed_by = auth.uid()
  WHERE id = p_pending_id;

  RETURN v_purchase_id;
END;
$$;
