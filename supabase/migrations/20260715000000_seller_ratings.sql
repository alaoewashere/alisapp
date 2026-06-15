-- Seller / buyer ratings after completed deals
-- Safe to re-run (IF NOT EXISTS / DROP POLICY IF EXISTS guards).

-- ---------------------------------------------------------------------------
-- profiles — denormalized rating aggregates
-- ---------------------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS avg_rating NUMERIC(2,1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS rating_count INTEGER NOT NULL DEFAULT 0;

-- ---------------------------------------------------------------------------
-- ratings
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id UUID NOT NULL REFERENCES public.listings(id) ON DELETE CASCADE,
  reviewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reviewed_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  review_text TEXT,
  hidden BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (listing_id, reviewer_id),
  CHECK (reviewer_id <> reviewed_id)
);

CREATE INDEX IF NOT EXISTS ratings_reviewed_idx
  ON public.ratings (reviewed_id, created_at DESC)
  WHERE hidden = FALSE;

CREATE INDEX IF NOT EXISTS ratings_listing_reviewer_idx
  ON public.ratings (listing_id, reviewer_id);

CREATE INDEX IF NOT EXISTS ratings_reviewer_created_idx
  ON public.ratings (reviewer_id, created_at DESC);

-- ---------------------------------------------------------------------------
-- Recompute profile aggregates (visible ratings only)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.update_profile_rating()
RETURNS TRIGGER AS $$
DECLARE
  target_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    target_id := OLD.reviewed_id;
  ELSE
    target_id := NEW.reviewed_id;
  END IF;

  UPDATE public.profiles
  SET
    avg_rating = COALESCE((
      SELECT ROUND(AVG(stars)::numeric, 1)
      FROM public.ratings
      WHERE reviewed_id = target_id AND hidden = FALSE
    ), 0),
    rating_count = (
      SELECT COUNT(*)::integer
      FROM public.ratings
      WHERE reviewed_id = target_id AND hidden = FALSE
    )
  WHERE id = target_id;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS after_rating_insert ON public.ratings;
DROP TRIGGER IF EXISTS after_rating_change ON public.ratings;
CREATE TRIGGER after_rating_change
  AFTER INSERT OR UPDATE OR DELETE ON public.ratings
  FOR EACH ROW EXECUTE FUNCTION public.update_profile_rating();

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT ON public.ratings TO authenticated;
GRANT SELECT ON public.ratings TO anon;

DROP POLICY IF EXISTS "Anyone reads visible ratings" ON public.ratings;
CREATE POLICY "Anyone reads visible ratings"
  ON public.ratings FOR SELECT
  USING (hidden = FALSE);

DROP POLICY IF EXISTS "Reviewers read own hidden ratings" ON public.ratings;
CREATE POLICY "Reviewers read own hidden ratings"
  ON public.ratings FOR SELECT
  TO authenticated
  USING (reviewer_id = auth.uid());

DROP POLICY IF EXISTS "Users insert own ratings" ON public.ratings;
CREATE POLICY "Users insert own ratings"
  ON public.ratings FOR INSERT
  TO authenticated
  WITH CHECK (
    reviewer_id = auth.uid()
    AND reviewed_id <> auth.uid()
  );

DROP POLICY IF EXISTS "Admins manage ratings" ON public.ratings;
CREATE POLICY "Admins manage ratings"
  ON public.ratings FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------------
-- notifications — allow rating_request type + seller notify RPC
-- ---------------------------------------------------------------------------
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    'info',
    'warning',
    'listing_approved',
    'listing_rejected',
    'rating_request'
  ));

CREATE OR REPLACE FUNCTION public.send_rating_request_notification(
  p_user_id UUID,
  p_listing_id UUID,
  p_title TEXT,
  p_body TEXT
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, listing_id, type, title, body)
  VALUES (p_user_id, p_listing_id, 'rating_request', p_title, p_body);
END;
$$;

REVOKE ALL ON FUNCTION public.send_rating_request_notification(UUID, UUID, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.send_rating_request_notification(UUID, UUID, TEXT, TEXT) TO authenticated;
