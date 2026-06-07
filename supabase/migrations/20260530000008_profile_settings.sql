-- Profile soft-delete + RLS hardening for profile/settings feature

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_deleted boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS profiles_is_deleted_idx ON public.profiles (is_deleted)
  WHERE is_deleted = false;

-- Hide soft-deleted profiles from public reads
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (is_deleted = false OR auth.uid() = id);

-- Owners update own profile (including is_deleted for account deletion)
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Listing owners can update/delete their listings
DROP POLICY IF EXISTS "Owners can update own listings" ON public.listings;
CREATE POLICY "Owners can update own listings"
  ON public.listings FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Owners can delete own listings" ON public.listings;
CREATE POLICY "Owners can delete own listings"
  ON public.listings FOR DELETE
  USING (auth.uid() = user_id);
