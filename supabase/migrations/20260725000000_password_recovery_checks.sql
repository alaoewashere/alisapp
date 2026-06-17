-- Account recovery: check registered email/phone without exposing profile data.

CREATE OR REPLACE FUNCTION public.check_registered_email(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE email IS NOT NULL
      AND lower(trim(email)) = lower(trim(p_email))
  )
  OR EXISTS (
    SELECT 1
    FROM auth.users
    WHERE lower(trim(email)) = lower(trim(p_email))
  );
$$;

CREATE OR REPLACE FUNCTION public.check_registered_phone(p_phone TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE phone IS NOT NULL
      AND trim(phone) = trim(p_phone)
  )
  OR EXISTS (
    SELECT 1
    FROM auth.users
    WHERE phone IS NOT NULL
      AND trim(phone) = trim(p_phone)
  );
$$;

REVOKE ALL ON FUNCTION public.check_registered_email(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.check_registered_phone(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_registered_email(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_registered_phone(TEXT) TO anon, authenticated;
