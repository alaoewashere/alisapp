-- Fix Supabase advisor 0010 (security definer view): run as querying user, not view owner.
-- Add RLS so anon/authenticated can read non-deleted seller rows through the view.
-- Revoke direct SELECT on private columns (email, push id) from API roles.

DROP VIEW IF EXISTS public.public_profiles;

CREATE VIEW public.public_profiles
WITH (security_invoker = true)
AS
SELECT
  id,
  phone,
  display_name,
  full_name,
  username,
  avatar_url,
  avatar_seed,
  avatar_index,
  city,
  governorate,
  is_verified,
  verification_status,
  verification_submitted_at,
  verification_reviewed_at,
  rejection_reason,
  is_deleted,
  avg_rating,
  rating_count,
  is_suspended,
  created_at,
  updated_at
FROM public.profiles
WHERE is_deleted = false;

GRANT SELECT ON public.public_profiles TO anon, authenticated;

DROP POLICY IF EXISTS "Public read seller profiles" ON public.profiles;
CREATE POLICY "Public read seller profiles"
  ON public.profiles
  FOR SELECT
  TO anon, authenticated
  USING (
    NOT is_deleted
    AND NOT COALESCE(is_suspended, false)
  );

-- Column-level: keep email and push tokens off the Data API surface.
REVOKE SELECT (email, onesignal_player_id) ON public.profiles FROM anon;
REVOKE SELECT (email, onesignal_player_id) ON public.profiles FROM authenticated;

COMMENT ON VIEW public.public_profiles IS
  'Seller/public profile card fields. security_invoker=true — RLS on profiles applies to callers.';
