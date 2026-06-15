-- Vehicle and category-specific listing fields (JSONB).
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS listings_metadata_gin_idx
  ON public.listings USING gin (metadata);
