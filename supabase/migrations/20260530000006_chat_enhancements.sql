-- Chat enhancements: last_message preview, delete policy, OneSignal player id

ALTER TABLE public.conversations
  ADD COLUMN IF NOT EXISTS last_message TEXT;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onesignal_player_id TEXT;

CREATE INDEX IF NOT EXISTS profiles_onesignal_player_id_idx
  ON public.profiles (onesignal_player_id)
  WHERE onesignal_player_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.update_conversation_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.conversations
  SET
    last_message_at = NEW.created_at,
    last_message = COALESCE(NEW.content, NEW.body)
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP POLICY IF EXISTS "Participants delete conversations" ON public.conversations;
CREATE POLICY "Participants delete conversations"
  ON public.conversations FOR DELETE
  USING (buyer_id = auth.uid() OR seller_id = auth.uid());
