-- Store signup email on profiles for account recovery and admin visibility.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

CREATE INDEX IF NOT EXISTS profiles_email_idx
  ON public.profiles (lower(email))
  WHERE email IS NOT NULL;

COMMENT ON COLUMN public.profiles.email IS
  'User email copied from auth at signup; not used for auth itself.';
