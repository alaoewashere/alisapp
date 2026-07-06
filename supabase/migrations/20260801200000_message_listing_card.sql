-- Chat previously pinned a single frozen listing (from conversations.listing_id)
-- at the top of the screen forever, even after the same two people moved on to
-- discussing a different listing. Instead, "listing share" becomes its own
-- message type embedded in the timeline — one per listing actually introduced,
-- historically accurate, and never stale.
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS listing_id UUID REFERENCES public.listings(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS messages_listing_id_idx
  ON public.messages (conversation_id, listing_id) WHERE listing_id IS NOT NULL;
