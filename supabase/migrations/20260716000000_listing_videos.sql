-- Listing walkthrough videos (Pro / Premium)
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS video_url TEXT,
  ADD COLUMN IF NOT EXISTS video_thumbnail_url TEXT;

-- Public bucket for listing videos (max 200MB, mp4/mov/m4v)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'listing-videos',
  'listing-videos',
  true,
  209715200,
  ARRAY['video/mp4', 'video/quicktime', 'video/x-m4v']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public read listing videos" ON storage.objects;
CREATE POLICY "Public read listing videos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'listing-videos');

DROP POLICY IF EXISTS "Authenticated upload listing videos" ON storage.objects;
CREATE POLICY "Authenticated upload listing videos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'listing-videos');

DROP POLICY IF EXISTS "Authenticated update listing videos" ON storage.objects;
CREATE POLICY "Authenticated update listing videos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'listing-videos')
  WITH CHECK (bucket_id = 'listing-videos');

DROP POLICY IF EXISTS "Authenticated delete listing videos" ON storage.objects;
CREATE POLICY "Authenticated delete listing videos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'listing-videos');
