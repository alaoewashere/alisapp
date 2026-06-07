-- Souq IQ — Admin Dashboard backend
-- Adds: admin_users, app_settings, notifications + columns for moderation
-- (reports.status, profiles suspend, categories.display_order) and RLS.
-- Safe to re-run (IF NOT EXISTS / DROP POLICY IF EXISTS guards).

-- ---------------------------------------------------------------------------
-- admin_users — accounts allowed into the dashboard (created manually)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.admin_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SECURITY DEFINER helpers bypass RLS internally (no policy recursion).
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid());
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public;

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins read own admin row" ON public.admin_users;
CREATE POLICY "Admins read own admin row"
  ON public.admin_users FOR SELECT
  USING (id = auth.uid());

DROP POLICY IF EXISTS "Super admins manage admins" ON public.admin_users;
CREATE POLICY "Super admins manage admins"
  ON public.admin_users FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- ---------------------------------------------------------------------------
-- app_settings — key/value config edited from the dashboard
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO public.app_settings (key, value) VALUES
  ('app_name', 'سوق العراق'),
  ('support_email', 'support@souqiq.com'),
  ('max_images_per_listing', '10'),
  ('max_listing_duration_days', '60'),
  ('max_featured_listings', '20'),
  ('featured_listing_price_iqd', '5000'),
  ('tpl_otp', 'رمز التحقق الخاص بك في سوق العراق هو: {code}'),
  ('tpl_new_message', 'لديك رسالة جديدة في سوق العراق'),
  ('tpl_listing_approved', 'تمت الموافقة على إعلانك: {title}'),
  ('tpl_listing_rejected', 'تم رفض إعلانك: {title}. السبب: {reason}'),
  ('tpl_account_warning', 'تحذير من إدارة سوق العراق: {reason}')
ON CONFLICT (key) DO NOTHING;

ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins read settings" ON public.app_settings;
CREATE POLICY "Admins read settings"
  ON public.app_settings FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins write settings" ON public.app_settings;
CREATE POLICY "Admins write settings"
  ON public.app_settings FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------------
-- notifications — admin "warn seller" + listing approved/rejected messages
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL,
  type TEXT NOT NULL DEFAULT 'info'
    CHECK (type IN ('info', 'warning', 'listing_approved', 'listing_rejected')),
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS notifications_user_idx
  ON public.notifications (user_id, created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own notifications" ON public.notifications;
CREATE POLICY "Users read own notifications"
  ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users update own notifications" ON public.notifications;
CREATE POLICY "Users update own notifications"
  ON public.notifications FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins insert notifications" ON public.notifications;
CREATE POLICY "Admins insert notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------------
-- reports — add moderation workflow columns (table created in 000003)
-- ---------------------------------------------------------------------------
ALTER TABLE public.reports
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'resolved', 'dismissed')),
  ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS resolved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS admin_note TEXT;

CREATE INDEX IF NOT EXISTS reports_status_idx
  ON public.reports (status, created_at DESC);

-- ---------------------------------------------------------------------------
-- profiles — admin suspend (table created in 000000 / extended in 000003)
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS suspended_reason TEXT,
  ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ;

-- ---------------------------------------------------------------------------
-- categories — display ordering for admin reorder (table created in 000000)
-- ---------------------------------------------------------------------------
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS display_order INT NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS categories_display_order_idx
  ON public.categories (parent_id, display_order);

-- ---------------------------------------------------------------------------
-- Bootstrap the first administrator (run once, then remove the comment):
--   INSERT INTO public.admin_users (id, email, role)
--   SELECT id, email, 'super_admin' FROM auth.users WHERE email = 'you@example.com'
--   ON CONFLICT (id) DO UPDATE SET role = 'super_admin';
-- ---------------------------------------------------------------------------
