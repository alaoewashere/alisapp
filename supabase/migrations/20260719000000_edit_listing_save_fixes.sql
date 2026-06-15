-- Fix price_history inserts from listing price-update trigger (RLS blocked INSERT).
-- Also consolidate listing UPDATE policy for owners.

CREATE OR REPLACE FUNCTION public.record_price_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
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

DROP POLICY IF EXISTS "Owners insert price history for own listings" ON public.price_history;
CREATE POLICY "Owners insert price history for own listings"
  ON public.price_history FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id = listing_id
        AND l.user_id = auth.uid()
    )
  );

-- Drop legacy restrictive policy name if still present; keep owner update access.
DROP POLICY IF EXISTS "Owners update own listings" ON public.listings;

DROP POLICY IF EXISTS "Owners can update own listings" ON public.listings;
CREATE POLICY "Owners can update own listings"
  ON public.listings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS is_negotiable BOOLEAN NOT NULL DEFAULT FALSE;
