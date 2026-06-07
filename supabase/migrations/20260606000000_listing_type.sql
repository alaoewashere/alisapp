-- listing_type: sale vs rent (سيارات / سيارات للإيجار share brand tree)

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS listing_type TEXT NOT NULL DEFAULT 'sale'
    CHECK (listing_type IN ('sale', 'rent'));

CREATE INDEX IF NOT EXISTS listings_listing_type_idx
  ON public.listings (listing_type);

CREATE OR REPLACE FUNCTION public.category_listing_counts(p_listing_type TEXT DEFAULT NULL)
RETURNS TABLE(category_id INT, listing_count BIGINT)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT l.category_id, COUNT(*)::BIGINT
  FROM public.listings l
  WHERE l.status = 'approved'
    AND l.availability = 'active'
    AND (p_listing_type IS NULL OR l.listing_type = p_listing_type)
  GROUP BY l.category_id;
$$;

GRANT EXECUTE ON FUNCTION public.category_listing_counts(TEXT) TO anon, authenticated;
