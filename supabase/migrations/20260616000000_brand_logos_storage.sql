-- Public bucket for car/motorcycle brand SVG logos (uploaded via scripts/upload_logos.dart)
INSERT INTO storage.buckets (id, name, public)
VALUES ('brand-logos', 'brand-logos', true)
ON CONFLICT (id) DO UPDATE SET public = true;

CREATE POLICY "Public read brand logos"
ON storage.objects FOR SELECT
USING (bucket_id = 'brand-logos');

-- Service role uploads via scripts/upload_logos.dart (bypasses RLS).
-- Authenticated users may replace logos for admin tooling.
CREATE POLICY "Authenticated upload brand logos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'brand-logos'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated update brand logos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'brand-logos'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Authenticated delete brand logos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'brand-logos'
  AND auth.role() = 'authenticated'
);
