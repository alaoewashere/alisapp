-- Security hardening: RPC authorization + search_logs INSERT tightening.

CREATE OR REPLACE FUNCTION public.increment_listing_views(listing_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.listings
  SET views_count = views_count + 1
  WHERE id = listing_id
    AND status = 'approved'
    AND availability = 'active';
END;
$$;

CREATE OR REPLACE FUNCTION public.increment_listing_contacts(listing_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.listings
  SET contact_count = contact_count + 1
  WHERE id = listing_id
    AND status = 'approved'
    AND availability = 'active';
END;
$$;

CREATE OR REPLACE FUNCTION public.send_rating_request_notification(
  p_user_id UUID,
  p_listing_id UUID,
  p_title TEXT,
  p_body TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner UUID;
BEGIN
  SELECT user_id INTO v_owner
  FROM public.listings
  WHERE id = p_listing_id;

  IF v_owner IS NULL THEN
    RAISE EXCEPTION 'listing_not_found';
  END IF;

  IF auth.uid() IS NULL OR auth.uid() <> v_owner THEN
    RAISE EXCEPTION 'not_listing_owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.conversations c
    WHERE c.listing_id = p_listing_id
      AND (
        (c.buyer_id = p_user_id AND c.seller_id = auth.uid())
        OR (c.seller_id = p_user_id AND c.buyer_id = auth.uid())
      )
  ) THEN
    RAISE EXCEPTION 'not_conversation_counterparty';
  END IF;

  INSERT INTO public.notifications (user_id, listing_id, type, title, body)
  VALUES (p_user_id, p_listing_id, 'rating_request', p_title, p_body);
END;
$$;

DROP POLICY IF EXISTS "Anyone can insert search logs" ON public.search_logs;
CREATE POLICY "Anyone can insert search logs"
  ON public.search_logs FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    user_id IS NULL
    OR user_id = auth.uid()
  );
