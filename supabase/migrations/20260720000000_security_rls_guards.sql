-- Security hardening: column guards, public profile view, tighter profile SELECT.

-- ---------------------------------------------------------------------------
-- public_profiles — seller/public reads without email or push identifiers
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.public_profiles AS
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

-- ---------------------------------------------------------------------------
-- profiles SELECT — own row or admin only (no full-table public read)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "Public can read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;

DROP POLICY IF EXISTS "Users read own profile" ON public.profiles;
CREATE POLICY "Users read own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins read all profiles" ON public.profiles;
CREATE POLICY "Admins read all profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- ---------------------------------------------------------------------------
-- Username availability (SECURITY DEFINER — no broad profile SELECT)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_username_available(
  p_username TEXT,
  p_exclude_user_id UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE lower(trim(username)) = lower(trim(p_username))
      AND is_deleted = false
      AND (p_exclude_user_id IS NULL OR id <> p_exclude_user_id)
  );
$$;

GRANT EXECUTE ON FUNCTION public.check_username_available(TEXT, UUID) TO authenticated;

-- ---------------------------------------------------------------------------
-- listings — guard privileged columns for non-admins
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.guard_listing_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_admin() THEN
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

DROP TRIGGER IF EXISTS listings_guard_privileged_columns ON public.listings;
CREATE TRIGGER listings_guard_privileged_columns
  BEFORE INSERT OR UPDATE ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_listing_privileged_columns();

-- ---------------------------------------------------------------------------
-- profiles — guard admin / verification / rating fields for non-admins
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.guard_profile_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_admin() THEN
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

DROP TRIGGER IF EXISTS profiles_guard_privileged_columns ON public.profiles;
CREATE TRIGGER profiles_guard_privileged_columns
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_profile_privileged_columns();

-- ---------------------------------------------------------------------------
-- messages — participants may only update read receipts
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.guard_message_updates()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF public.is_admin() THEN
    RETURN NEW;
  END IF;

  NEW.id := OLD.id;
  NEW.conversation_id := OLD.conversation_id;
  NEW.sender_id := OLD.sender_id;
  NEW.body := OLD.body;
  NEW.content := OLD.content;
  NEW.created_at := OLD.created_at;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS messages_guard_updates ON public.messages;
CREATE TRIGGER messages_guard_updates
  BEFORE UPDATE ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_message_updates();

-- ---------------------------------------------------------------------------
-- Harden legacy SECURITY DEFINER triggers (search_path)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  resolved_name TEXT;
BEGIN
  resolved_name := COALESCE(
    NEW.raw_user_meta_data->>'display_name',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name',
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''),
    ''
  );

  INSERT INTO public.profiles (id, phone, display_name, full_name)
  VALUES (NEW.id, NEW.phone, resolved_name, resolved_name)
  ON CONFLICT (id) DO UPDATE
    SET full_name = COALESCE(public.profiles.full_name, EXCLUDED.full_name),
        display_name = CASE
          WHEN public.profiles.display_name = '' THEN EXCLUDED.display_name
          ELSE public.profiles.display_name
        END;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_conversation_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.apply_listing_boost_flags()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.type = 'featured' THEN
    UPDATE public.listings SET is_featured = TRUE WHERE id = NEW.listing_id;
  ELSIF NEW.type IN ('boosted', 'urgent') THEN
    UPDATE public.listings SET is_boosted = TRUE WHERE id = NEW.listing_id;
  END IF;
  RETURN NEW;
END;
$$;
