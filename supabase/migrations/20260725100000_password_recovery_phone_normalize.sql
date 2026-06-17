-- Normalize phone digits for recovery checks (DB often stores 9647... without +).

CREATE OR REPLACE FUNCTION public.normalize_phone_digits(p_phone TEXT)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT regexp_replace(trim(p_phone), '\D', '', 'g');
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
      AND length(trim(phone)) > 0
      AND public.normalize_phone_digits(phone) = public.normalize_phone_digits(p_phone)
  )
  OR EXISTS (
    SELECT 1
    FROM auth.users
    WHERE phone IS NOT NULL
      AND public.normalize_phone_digits(phone) = public.normalize_phone_digits(p_phone)
  );
$$;

REVOKE ALL ON FUNCTION public.normalize_phone_digits(TEXT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.check_registered_phone(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.normalize_phone_digits(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.check_registered_phone(TEXT) TO anon, authenticated;
