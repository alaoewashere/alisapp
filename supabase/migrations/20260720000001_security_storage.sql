-- Security hardening: storage write policies scoped to owners / admins.

-- listing-images: INSERT must use auth.uid() as first path segment
DROP POLICY IF EXISTS "Authenticated users upload listing images" ON storage.objects;
CREATE POLICY "Authenticated users upload listing images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'listing-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- listing-videos: CRUD only when user owns the listing folder (listing id)
DROP POLICY IF EXISTS "Authenticated upload listing videos" ON storage.objects;
CREATE POLICY "Authenticated upload listing videos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'listing-videos'
    AND EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id::text = (storage.foldername(name))[1]
        AND l.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Authenticated update listing videos" ON storage.objects;
CREATE POLICY "Authenticated update listing videos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'listing-videos'
    AND EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id::text = (storage.foldername(name))[1]
        AND l.user_id = auth.uid()
    )
  )
  WITH CHECK (
    bucket_id = 'listing-videos'
    AND EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id::text = (storage.foldername(name))[1]
        AND l.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Authenticated delete listing videos" ON storage.objects;
CREATE POLICY "Authenticated delete listing videos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'listing-videos'
    AND EXISTS (
      SELECT 1
      FROM public.listings l
      WHERE l.id::text = (storage.foldername(name))[1]
        AND l.user_id = auth.uid()
    )
  );

-- brand-logos: admin-only writes; public read unchanged
DROP POLICY IF EXISTS "Authenticated upload brand logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated update brand logos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated delete brand logos" ON storage.objects;

CREATE POLICY "Admins upload brand logos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'brand-logos'
    AND public.is_admin()
  );

CREATE POLICY "Admins update brand logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'brand-logos' AND public.is_admin())
  WITH CHECK (bucket_id = 'brand-logos' AND public.is_admin());

CREATE POLICY "Admins delete brand logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'brand-logos' AND public.is_admin());
