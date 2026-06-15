-- Unique public username on profiles (case-insensitive)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_username_unique
  ON public.profiles (lower(username))
  WHERE username IS NOT NULL AND username <> '';
