-- Lightweight support chat: user <-> admin, independent of the peer-to-peer
-- listing conversations system (no listing_id, no second real auth account
-- needed for "admin" — the admin dashboard writes rows with sender_role='admin').
CREATE TABLE IF NOT EXISTS public.support_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sender_role TEXT NOT NULL CHECK (sender_role IN ('user', 'admin')),
  body TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS support_messages_user_created_idx
  ON public.support_messages (user_id, created_at);

ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE ON public.support_messages TO authenticated;

DROP POLICY IF EXISTS "Users read own support thread" ON public.support_messages;
CREATE POLICY "Users read own support thread"
  ON public.support_messages FOR SELECT
  USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS "Users send their own support messages" ON public.support_messages;
CREATE POLICY "Users send their own support messages"
  ON public.support_messages FOR INSERT
  WITH CHECK (
    (user_id = auth.uid() AND sender_role = 'user')
    OR public.is_admin()
  );

DROP POLICY IF EXISTS "Users mark own support thread read" ON public.support_messages;
CREATE POLICY "Users mark own support thread read"
  ON public.support_messages FOR UPDATE
  USING (user_id = auth.uid() OR public.is_admin())
  WITH CHECK (user_id = auth.uid() OR public.is_admin());

ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;
