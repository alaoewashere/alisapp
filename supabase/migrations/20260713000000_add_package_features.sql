-- Listing package features: contacts, auto-renew, verified seller, view/contact RPCs
-- expires_at and views_count already exist on public.listings

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS contact_count INT NOT NULL DEFAULT 0 CHECK (contact_count >= 0),
  ADD COLUMN IF NOT EXISTS auto_renew BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_verified_seller BOOLEAN NOT NULL DEFAULT FALSE;

CREATE OR REPLACE FUNCTION public.increment_listing_views(listing_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.listings
  SET views_count = views_count + 1
  WHERE id = listing_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.increment_listing_contacts(listing_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.listings
  SET contact_count = contact_count + 1
  WHERE id = listing_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.increment_listing_views(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.increment_listing_contacts(UUID) TO anon, authenticated;
