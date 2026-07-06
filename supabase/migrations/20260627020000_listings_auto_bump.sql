-- ============================================================
-- Auto-bump: adds bumped_at to listings and schedules
-- Pro (weekly) + Premium (daily) refresh via pg_cron.
-- ============================================================

-- 1. Add bumped_at column; back-fill from created_at so existing
--    listings aren't penalised when the column first appears.
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS bumped_at TIMESTAMPTZ;

UPDATE public.listings
  SET bumped_at = created_at
  WHERE bumped_at IS NULL;

ALTER TABLE public.listings
  ALTER COLUMN bumped_at SET DEFAULT NOW();

ALTER TABLE public.listings
  ALTER COLUMN bumped_at SET NOT NULL;

-- 2. Index for the feed sort (bumped_at DESC keeps it fast).
CREATE INDEX IF NOT EXISTS listings_bumped_at_idx
  ON public.listings (bumped_at DESC)
  WHERE status = 'approved' AND availability = 'active';

-- 3. Prevent direct bumped_at manipulation from the client.
--    Only service-role or this function may write it.
CREATE OR REPLACE FUNCTION public.guard_bumped_at()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Non-service roles may not advance bumped_at by more than 1 second
  -- (prevents users from manually bumping their own listings).
  IF current_setting('role') NOT IN ('service_role', 'supabase_admin') THEN
    NEW.bumped_at := OLD.bumped_at;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS listings_guard_bumped_at ON public.listings;
CREATE TRIGGER listings_guard_bumped_at
  BEFORE UPDATE OF bumped_at ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.guard_bumped_at();

-- 4. The bump function — idempotent, safe to call hourly.
--    Pro: bump once every 7 days.
--    Premium: bump once every 1 day.
CREATE OR REPLACE FUNCTION public.auto_bump_listings()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Premium daily
  UPDATE public.listings
  SET bumped_at = NOW()
  WHERE status    = 'approved'
    AND availability = 'active'
    AND (
      is_featured = TRUE
      OR (metadata->>'listing_package') IN ('premium', 'مميز', 'featured')
    )
    AND bumped_at < NOW() - INTERVAL '1 day';

  -- Pro weekly
  UPDATE public.listings
  SET bumped_at = NOW()
  WHERE status    = 'approved'
    AND availability = 'active'
    AND (
      is_boosted = TRUE
      OR (metadata->>'listing_package') IN ('pro', 'برو')
    )
    AND bumped_at < NOW() - INTERVAL '7 days';
END;
$$;

-- 5. Schedule via pg_cron (Supabase enables this extension by default).
--    Runs every hour; the function only touches rows that are due.
SELECT cron.schedule(
  'auto-bump-listings',
  '0 * * * *',
  'SELECT public.auto_bump_listings()'
) WHERE NOT EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'auto-bump-listings'
);
