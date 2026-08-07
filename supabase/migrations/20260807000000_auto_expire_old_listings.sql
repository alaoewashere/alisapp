-- Soft-delete listings older than 30 days — same pattern as auto-bump
-- (pg_cron + a SECURITY DEFINER function). "Delete" here means
-- availability = 'deleted', matching the existing soft-delete convention
-- (see listings_repository.dart's 'sold'/'deleted' availability values) —
-- rows are never hard-deleted so history/reports/purchases stay intact.

CREATE OR REPLACE FUNCTION public.auto_expire_old_listings()
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.listings
  SET availability = 'deleted'
  WHERE availability = 'active'
    AND created_at < NOW() - INTERVAL '30 days';
END;
$$;

-- Runs daily at 03:00 UTC (low-traffic window).
SELECT cron.schedule(
  'auto-expire-old-listings',
  '0 3 * * *',
  'SELECT public.auto_expire_old_listings()'
) WHERE NOT EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'auto-expire-old-listings'
);
