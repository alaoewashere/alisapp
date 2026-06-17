-- Server-verified purchases: pending queue + admin approval; revoke client INSERT.

CREATE TABLE IF NOT EXISTS public.pending_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  package_type TEXT NOT NULL CHECK (package_type IN ('pro', 'premium')),
  price NUMERIC NOT NULL CHECK (price >= 0),
  payment_reference TEXT,
  user_name TEXT NOT NULL DEFAULT '',
  user_phone TEXT,
  user_email TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  admin_note TEXT
);

CREATE INDEX IF NOT EXISTS pending_purchases_user_idx
  ON public.pending_purchases (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS pending_purchases_status_idx
  ON public.pending_purchases (status, created_at DESC);

ALTER TABLE public.pending_purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own pending purchases" ON public.pending_purchases;
CREATE POLICY "Users read own pending purchases"
  ON public.pending_purchases FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins manage pending purchases" ON public.pending_purchases;
CREATE POLICY "Admins manage pending purchases"
  ON public.pending_purchases FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Revoke direct client writes to purchases / boosts
DROP POLICY IF EXISTS "Users insert own listing purchases" ON public.listing_purchases;
DROP POLICY IF EXISTS "Listing owners purchase boosts" ON public.boosts;

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

GRANT EXECUTE ON FUNCTION public.approve_pending_purchase(UUID) TO authenticated;
