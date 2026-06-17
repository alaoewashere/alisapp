-- Profile phone verification (WhatsApp OTP).

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN public.profiles.phone_verified IS
  'True after the user completes WhatsApp OTP verification for profiles.phone.';

CREATE TABLE IF NOT EXISTS public.phone_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  phone TEXT NOT NULL,
  otp TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS phone_verifications_user_phone_idx
  ON public.phone_verifications (user_id, phone, created_at DESC);

CREATE INDEX IF NOT EXISTS phone_verifications_expires_idx
  ON public.phone_verifications (expires_at)
  WHERE used = false;

ALTER TABLE public.phone_verifications ENABLE ROW LEVEL SECURITY;

-- Users may read their own verification rows (optional audit); writes via edge functions only.
CREATE POLICY "Users read own phone verifications"
  ON public.phone_verifications
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

GRANT SELECT ON public.phone_verifications TO authenticated;
