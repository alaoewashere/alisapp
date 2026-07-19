-- Users can swipe-to-delete their own notifications from the inbox; only a
-- SELECT/UPDATE policy existed before, so DELETE was silently blocked by RLS.
DROP POLICY IF EXISTS "Users delete own notifications" ON public.notifications;
CREATE POLICY "Users delete own notifications"
  ON public.notifications FOR DELETE
  USING (user_id = auth.uid());
