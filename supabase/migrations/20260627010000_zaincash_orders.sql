-- ZainCash payment orders.
--
-- The app NEVER signs ZainCash JWTs or decides payment outcomes. The
-- `zaincash-init` edge function (service role) creates rows here as `pending`,
-- and the `zaincash-callback` edge function (service role) flips them to
-- `paid` / `failed` after verifying the gateway's signed redirect token.
-- Clients may only READ their own orders — the status here is the source of truth.

CREATE TABLE IF NOT EXISTS public.zaincash_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  order_id TEXT NOT NULL UNIQUE,            -- our reference sent to ZainCash
  listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
  amount NUMERIC NOT NULL CHECK (amount >= 250),
  currency TEXT NOT NULL DEFAULT 'IQD',
  service_type TEXT NOT NULL DEFAULT '',
  transaction_id TEXT,                      -- ZainCash transaction id
  operation_id TEXT,                        -- ZainCash operation id (on success)
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'paid', 'failed', 'cancelled')),
  gateway_payload JSONB,                    -- last verified payload from gateway
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS zaincash_orders_user_id_idx
  ON public.zaincash_orders (user_id);

CREATE INDEX IF NOT EXISTS zaincash_orders_order_id_idx
  ON public.zaincash_orders (order_id);

CREATE INDEX IF NOT EXISTS zaincash_orders_created_at_idx
  ON public.zaincash_orders (created_at DESC);

ALTER TABLE public.zaincash_orders ENABLE ROW LEVEL SECURITY;

-- Owners may read their own orders. There is intentionally NO insert/update
-- policy for `authenticated`: only the service role (which bypasses RLS) may
-- write, so a client can never mark its own order as paid.
DROP POLICY IF EXISTS "Users read own zaincash orders" ON public.zaincash_orders;
CREATE POLICY "Users read own zaincash orders"
  ON public.zaincash_orders FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = user_id);

DROP POLICY IF EXISTS "Admins read all zaincash orders" ON public.zaincash_orders;
CREATE POLICY "Admins read all zaincash orders"
  ON public.zaincash_orders FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- Keep updated_at fresh on every write.
CREATE OR REPLACE FUNCTION public.touch_zaincash_orders_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS zaincash_orders_set_updated_at ON public.zaincash_orders;
CREATE TRIGGER zaincash_orders_set_updated_at
  BEFORE UPDATE ON public.zaincash_orders
  FOR EACH ROW EXECUTE FUNCTION public.touch_zaincash_orders_updated_at();
