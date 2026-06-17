-- Public listing reads: approved only; admins unrestricted SELECT.

DROP POLICY IF EXISTS "Public read approved listings" ON public.listings;
CREATE POLICY "Public read approved listings"
  ON public.listings FOR SELECT
  USING (status = 'approved');

DROP POLICY IF EXISTS "Admins read all listings" ON public.listings;
CREATE POLICY "Admins read all listings"
  ON public.listings FOR SELECT
  TO authenticated
  USING (public.is_admin());
