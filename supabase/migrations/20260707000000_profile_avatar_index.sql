-- Preset avatar picker index (0–7) when avatar_url is null.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS avatar_index integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.profiles.avatar_index IS
  'Index into app preset avatar list when avatar_url is null; default 0.';
