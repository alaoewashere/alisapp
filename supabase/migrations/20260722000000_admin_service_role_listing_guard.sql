-- Allow service_role (admin dashboard server actions) to update moderated columns.
-- Without this, guard_listing_privileged_columns reverts status when auth.uid() is NULL.

CREATE OR REPLACE FUNCTION public.is_privileged_backend_caller()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT public.is_admin()
      OR coalesce(auth.jwt() ->> 'role', '') = 'service_role';
$$;

GRANT EXECUTE ON FUNCTION public.is_privileged_backend_caller() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_privileged_backend_caller() TO service_role;

CREATE OR REPLACE FUNCTION public.guard_listing_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_privileged_backend_caller() THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.status := 'pending';
    NEW.is_featured := FALSE;
    NEW.is_boosted := FALSE;
    NEW.is_verified_seller := FALSE;
    NEW.views_count := 0;
    NEW.contact_count := 0;
    NEW.reviewed_at := NULL;
    NEW.rejection_reason := NULL;
    RETURN NEW;
  END IF;

  NEW.status := OLD.status;
  NEW.is_featured := OLD.is_featured;
  NEW.is_boosted := OLD.is_boosted;
  NEW.is_verified_seller := OLD.is_verified_seller;
  NEW.views_count := OLD.views_count;
  NEW.contact_count := OLD.contact_count;
  NEW.reference_no := OLD.reference_no;
  NEW.user_id := OLD.user_id;
  NEW.created_at := OLD.created_at;
  NEW.reviewed_at := OLD.reviewed_at;
  NEW.rejection_reason := OLD.rejection_reason;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.guard_profile_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_privileged_backend_caller() THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.is_verified := FALSE;
    NEW.verification_status := COALESCE(NEW.verification_status, 'unverified');
    IF NEW.verification_status NOT IN ('unverified', 'pending') THEN
      NEW.verification_status := 'unverified';
    END IF;
    NEW.avg_rating := 0;
    NEW.rating_count := 0;
    NEW.is_suspended := FALSE;
    NEW.suspended_reason := NULL;
    NEW.suspended_at := NULL;
    RETURN NEW;
  END IF;

  NEW.is_verified := OLD.is_verified;
  NEW.verification_status := OLD.verification_status;
  NEW.verification_submitted_at := OLD.verification_submitted_at;
  NEW.verification_reviewed_at := OLD.verification_reviewed_at;
  NEW.rejection_reason := OLD.rejection_reason;
  NEW.avg_rating := OLD.avg_rating;
  NEW.rating_count := OLD.rating_count;
  NEW.is_suspended := OLD.is_suspended;
  NEW.suspended_reason := OLD.suspended_reason;
  NEW.suspended_at := OLD.suspended_at;
  NEW.email := OLD.email;
  NEW.id := OLD.id;
  RETURN NEW;
END;
$$;
