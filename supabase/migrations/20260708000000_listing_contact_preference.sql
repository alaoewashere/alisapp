-- Per-listing contact preference for buyer outreach.
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS contact_preference TEXT
  CHECK (
    contact_preference IS NULL
    OR contact_preference IN (
      'phone_and_messages',
      'phone_only',
      'messages_only'
    )
  );
