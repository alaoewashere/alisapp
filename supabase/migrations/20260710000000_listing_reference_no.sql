-- Unique Sahibinden-style listing reference numbers (auto-assigned on insert).
CREATE SEQUENCE IF NOT EXISTS public.listing_reference_no_seq
  START WITH 1000001
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS reference_no INTEGER UNIQUE;

-- Backfill existing listings in chronological order.
WITH numbered AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at ASC, id ASC) AS rn
  FROM public.listings
  WHERE reference_no IS NULL
)
UPDATE public.listings AS l
SET reference_no = numbered.rn + 1000000
FROM numbered
WHERE l.id = numbered.id;

SELECT setval(
  'public.listing_reference_no_seq',
  GREATEST(
    COALESCE((SELECT MAX(reference_no) FROM public.listings), 1000000) + 1,
    1000001
  ),
  false
);

CREATE OR REPLACE FUNCTION public.set_listing_reference_no()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.reference_no IS NULL THEN
    NEW.reference_no := nextval('public.listing_reference_no_seq');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS listings_set_reference_no ON public.listings;
CREATE TRIGGER listings_set_reference_no
  BEFORE INSERT ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_listing_reference_no();

ALTER TABLE public.listings
  ALTER COLUMN reference_no SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS listings_reference_no_idx
  ON public.listings (reference_no);
