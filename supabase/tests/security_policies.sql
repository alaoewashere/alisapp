-- Security policy verification (run after `supabase db reset` or on staging).
-- Usage: psql $DATABASE_URL -f supabase/tests/security_policies.sql

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_views WHERE schemaname = 'public' AND viewname = 'public_profiles'
  ) THEN
    RAISE EXCEPTION 'missing public_profiles view';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Public can read profiles'
  ) THEN
    RAISE EXCEPTION 'Public can read profiles policy still present';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'listings_guard_privileged_columns'
  ) THEN
    RAISE EXCEPTION 'missing listings_guard_privileged_columns trigger';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'check_username_available'
  ) THEN
    RAISE EXCEPTION 'missing check_username_available function';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'phone_verifications'
  ) THEN
    RAISE EXCEPTION 'missing phone_verifications table';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'phone_verified'
  ) THEN
    RAISE EXCEPTION 'missing profiles.phone_verified column';
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'listing_purchases'
      AND cmd = 'INSERT'
      AND roles::text LIKE '%authenticated%'
  ) THEN
    RAISE EXCEPTION 'listing_purchases still allows client INSERT';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'listings'
      AND policyname = 'Admins read all listings'
  ) THEN
    RAISE EXCEPTION 'missing Admins read all listings policy';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'listings'
      AND policyname = 'Public read approved listings'
  ) THEN
    RAISE EXCEPTION 'missing Public read approved listings policy';
  END IF;

  RAISE NOTICE 'security_policies.sql: all checks passed';
END $$;
