-- OTP rate limiting table (service-role writes from edge functions).

CREATE TABLE IF NOT EXISTS public.otp_throttle (
  id BIGSERIAL PRIMARY KEY,
  phone TEXT NOT NULL,
  ip_address TEXT,
  action TEXT NOT NULL CHECK (action IN ('send', 'verify')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS otp_throttle_phone_action_idx
  ON public.otp_throttle (phone, action, created_at DESC);

CREATE INDEX IF NOT EXISTS otp_throttle_ip_action_idx
  ON public.otp_throttle (ip_address, action, created_at DESC);

ALTER TABLE public.otp_throttle ENABLE ROW LEVEL SECURITY;

-- No client policies — edge functions use service role.

-- Targeted phone lookup for OTP verify (replaces paginated listUsers).
CREATE OR REPLACE FUNCTION public.get_auth_user_id_by_phone(p_phone TEXT)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id
  FROM auth.users
  WHERE phone = p_phone
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.get_auth_user_id_by_phone(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_auth_user_id_by_phone(TEXT) TO service_role;
