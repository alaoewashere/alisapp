-- Match phones by digits only (auth.users / profiles may omit + prefix).

CREATE OR REPLACE FUNCTION public.get_auth_user_id_by_phone(p_phone TEXT)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (
      SELECT id
      FROM auth.users
      WHERE phone IS NOT NULL
        AND public.normalize_phone_digits(phone) =
            public.normalize_phone_digits(p_phone)
      LIMIT 1
    ),
    (
      SELECT id
      FROM public.profiles
      WHERE phone IS NOT NULL
        AND length(trim(phone)) > 0
        AND public.normalize_phone_digits(phone) =
            public.normalize_phone_digits(p_phone)
      LIMIT 1
    )
  );
$$;

REVOKE ALL ON FUNCTION public.get_auth_user_id_by_phone(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_auth_user_id_by_phone(TEXT) TO service_role;
