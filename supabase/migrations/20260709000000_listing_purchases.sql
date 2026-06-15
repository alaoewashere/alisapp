-- Paid listing package purchases (Pro / Premium).
CREATE TABLE IF NOT EXISTS public.listing_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  package_type TEXT NOT NULL CHECK (package_type IN ('pro', 'premium')),
  price NUMERIC NOT NULL CHECK (price >= 0),
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_name TEXT NOT NULL DEFAULT '',
  user_phone TEXT,
  user_email TEXT
);

CREATE INDEX IF NOT EXISTS listing_purchases_user_id_idx
  ON public.listing_purchases (user_id);

CREATE INDEX IF NOT EXISTS listing_purchases_listing_id_idx
  ON public.listing_purchases (listing_id);

CREATE INDEX IF NOT EXISTS listing_purchases_purchased_at_idx
  ON public.listing_purchases (purchased_at DESC);

ALTER TABLE public.listing_purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users insert own listing purchases" ON public.listing_purchases;
CREATE POLICY "Users insert own listing purchases"
  ON public.listing_purchases FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users read own listing purchases" ON public.listing_purchases;
CREATE POLICY "Users read own listing purchases"
  ON public.listing_purchases FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Admins read all listing purchases" ON public.listing_purchases;
CREATE POLICY "Admins read all listing purchases"
  ON public.listing_purchases FOR SELECT
  TO authenticated
  USING (public.is_admin());
