-- Fix: guard_listing_privileged_columns was overwritten in 20260724 to use
-- is_admin() only, which returns FALSE when the service role key is used by
-- the admin dashboard (auth.uid() is NULL with service_role JWT).
-- Restore is_privileged_backend_caller() so admin server actions can update status.

CREATE OR REPLACE FUNCTION public.guard_listing_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Allow admins logged in via the app AND service_role (Next.js admin dashboard).
  IF public.is_privileged_backend_caller() THEN
    RETURN NEW;
  END IF;

  -- Allow the approve_pending_purchase() function to update package fields only.
  IF current_setting('sello.trusted_package_update', true) = '1' THEN
    IF TG_OP = 'UPDATE' THEN
      NEW.status      := OLD.status;
      NEW.views_count := OLD.views_count;
      NEW.contact_count := OLD.contact_count;
      NEW.reference_no  := OLD.reference_no;
      NEW.user_id       := OLD.user_id;
      NEW.created_at    := OLD.created_at;
      NEW.reviewed_at   := OLD.reviewed_at;
      NEW.rejection_reason := OLD.rejection_reason;
      RETURN NEW;
    END IF;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.status             := 'pending';
    NEW.is_featured        := FALSE;
    NEW.is_boosted         := FALSE;
    NEW.is_verified_seller := FALSE;
    NEW.views_count        := 0;
    NEW.contact_count      := 0;
    NEW.reviewed_at        := NULL;
    NEW.rejection_reason   := NULL;
    NEW.metadata := jsonb_set(
      COALESCE(NEW.metadata, '{}'::jsonb),
      '{listing_package}',
      '"standard"'::jsonb,
      true
    );
    RETURN NEW;
  END IF;

  -- UPDATE from non-admin, non-trusted caller: revert all privileged columns.
  NEW.status             := OLD.status;
  NEW.is_featured        := OLD.is_featured;
  NEW.is_boosted         := OLD.is_boosted;
  NEW.is_verified_seller := OLD.is_verified_seller;
  NEW.views_count        := OLD.views_count;
  NEW.contact_count      := OLD.contact_count;
  NEW.reference_no       := OLD.reference_no;
  NEW.user_id            := OLD.user_id;
  NEW.created_at         := OLD.created_at;
  NEW.reviewed_at        := OLD.reviewed_at;
  NEW.rejection_reason   := OLD.rejection_reason;

  -- Non-admins cannot escalate listing_package via metadata edits.
  NEW.metadata := jsonb_set(
    COALESCE(NEW.metadata, OLD.metadata, '{}'::jsonb),
    '{listing_package}',
    COALESCE(OLD.metadata->'listing_package', '"standard"'::jsonb),
    true
  );

  RETURN NEW;
END;
$$;
