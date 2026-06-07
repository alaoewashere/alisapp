-- Storage bucket + policies for listing images
-- Run after creating bucket "listing-images" (public) in Supabase Dashboard

INSERT INTO storage.buckets (id, name, public)
VALUES ('listing-images', 'listing-images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public read listing images"
ON storage.objects FOR SELECT
USING (bucket_id = 'listing-images');

CREATE POLICY "Authenticated users upload listing images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'listing-images'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Users delete own listing images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'listing-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users update own listing images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'listing-images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
