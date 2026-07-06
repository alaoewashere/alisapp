-- Launch-week promo: unlimited free standard-listing posts for every user
-- until this timestamp, after which the normal 2/month quota resumes.
-- Adjustable any time by updating this row (no app release needed).
GRANT SELECT ON public.app_settings TO anon, authenticated;

DROP POLICY IF EXISTS "Anyone reads app settings" ON public.app_settings;
CREATE POLICY "Anyone reads app settings"
  ON public.app_settings FOR SELECT USING (true);

INSERT INTO public.app_settings (key, value) VALUES
  ('free_posts_unlimited_until', (now() + interval '7 days')::text)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now();
