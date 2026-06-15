-- Seller identity verification (توثيق الحساب)

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'unverified',
  ADD COLUMN IF NOT EXISTS verification_submitted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS verification_reviewed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_verification_status_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_verification_status_check
  CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected'));

-- Keep legacy is_verified in sync for existing queries.
UPDATE public.profiles
SET verification_status = 'verified'
WHERE is_verified = TRUE
  AND verification_status = 'unverified';

CREATE TABLE IF NOT EXISTS public.verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  front_image_url TEXT NOT NULL,
  back_image_url TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  status TEXT NOT NULL DEFAULT 'pending',
  reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  rejection_reason TEXT,
  CONSTRAINT verification_requests_document_type_check
    CHECK (document_type IN ('national_id', 'passport', 'drivers_license')),
  CONSTRAINT verification_requests_status_check
    CHECK (status IN ('pending', 'verified', 'rejected'))
);

CREATE INDEX IF NOT EXISTS idx_verification_requests_user_id
  ON public.verification_requests(user_id);

CREATE INDEX IF NOT EXISTS idx_verification_requests_status_pending
  ON public.verification_requests(status)
  WHERE status = 'pending';

ALTER TABLE public.verification_requests ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON public.verification_requests TO authenticated;

CREATE POLICY "Users read own verification requests"
  ON public.verification_requests
  FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

CREATE POLICY "Users insert own verification requests"
  ON public.verification_requests
  FOR INSERT
  TO authenticated
  WITH CHECK ((SELECT auth.uid()) = user_id);

-- Private bucket for ID documents (admin reads via service role).
INSERT INTO storage.buckets (id, name, public)
VALUES ('verification-docs', 'verification-docs', false)
ON CONFLICT (id) DO UPDATE SET public = false;

CREATE POLICY "Users upload own verification docs"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'verification-docs'
    AND (SELECT auth.uid())::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users read own verification docs"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'verification-docs'
    AND (SELECT auth.uid())::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users update own verification docs"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'verification-docs'
    AND (SELECT auth.uid())::text = (storage.foldername(name))[1]
  )
  WITH CHECK (
    bucket_id = 'verification-docs'
    AND (SELECT auth.uid())::text = (storage.foldername(name))[1]
  );
