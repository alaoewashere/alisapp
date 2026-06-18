-- Listing neighborhood density: area_name column, reference centers, backfill, RPC.

-- ---------------------------------------------------------------------------
-- Optional geocoded address (migration existed locally but was not on remote).
-- ---------------------------------------------------------------------------
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS location_address TEXT;

-- ---------------------------------------------------------------------------
-- Neighborhood label on listings (nullable — does not block create flow).
-- ---------------------------------------------------------------------------
ALTER TABLE public.listings
  ADD COLUMN IF NOT EXISTS area_name TEXT;

CREATE INDEX IF NOT EXISTS listings_area_name_active_idx
  ON public.listings (area_name)
  WHERE status = 'approved'
    AND availability = 'active'
    AND area_name IS NOT NULL
    AND btrim(area_name) <> '';

-- ---------------------------------------------------------------------------
-- Static neighborhood centers for map plotting and GPS backfill.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.listing_area_centers (
  slug TEXT PRIMARY KEY,
  name_ar TEXT NOT NULL,
  governorate_slug TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);

ALTER TABLE public.listing_area_centers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Listing area centers are publicly readable"
  ON public.listing_area_centers;
CREATE POLICY "Listing area centers are publicly readable"
  ON public.listing_area_centers FOR SELECT
  TO anon, authenticated
  USING (true);

INSERT INTO public.listing_area_centers
  (slug, name_ar, governorate_slug, latitude, longitude, display_order)
VALUES
  -- بغداد
  ('baghdad_karrada', 'الكرادة', 'baghdad', 33.3152, 44.4560, 1),
  ('baghdad_mansour', 'المنصور', 'baghdad', 33.3128, 44.3375, 2),
  ('baghdad_jadriya', 'الجادرية', 'baghdad', 33.2778, 44.4000, 3),
  ('baghdad_zayona', 'زيونة', 'baghdad', 33.3050, 44.4450, 4),
  ('baghdad_dora', 'الدورة', 'baghdad', 33.2380, 44.3850, 5),
  ('baghdad_kadhimiya', 'الكاظمية', 'baghdad', 33.3808, 44.3403, 6),
  ('baghdad_adhamiya', 'الأعظمية', 'baghdad', 33.3614, 44.3842, 7),
  ('baghdad_sadr_city', 'مدينة الصدر', 'baghdad', 33.3667, 44.4167, 8),
  ('baghdad_shuala', 'الشعلة', 'baghdad', 33.3950, 44.3600, 9),
  ('baghdad_hurriya', 'الحرية', 'baghdad', 33.3300, 44.4200, 10),
  ('baghdad_ghazaliya', 'الغزالية', 'baghdad', 33.3150, 44.2800, 11),
  ('baghdad_rusafa', 'الرصافة', 'baghdad', 33.3400, 44.4100, 12),
  ('baghdad_karkh', 'الكرخ', 'baghdad', 33.3200, 44.3700, 13),
  ('baghdad_bab_al_muadham', 'باب المعظم', 'baghdad', 33.3520, 44.3920, 14),
  ('baghdad_amriya', 'العامرية', 'baghdad', 33.2680, 44.3180, 15),
  ('baghdad_yarmouk', 'اليرموك', 'baghdad', 33.2980, 44.3580, 16),
  ('baghdad_bayaa', 'البياع', 'baghdad', 33.2550, 44.3680, 17),
  ('baghdad_shaab', 'الشعب', 'baghdad', 33.3780, 44.4320, 18),
  -- البصرة
  ('basra_ashar', 'العشار', 'basra', 30.5085, 47.7804, 30),
  ('basra_jumhuriya', 'الجمهورية', 'basra', 30.5250, 47.8150, 31),
  ('basra_zubair', 'الزبير', 'basra', 30.3890, 47.7080, 32),
  ('basra_tanuma', 'التنومة', 'basra', 30.5450, 47.8350, 33),
  -- أربيل
  ('erbil_center', 'مركز أربيل', 'erbil', 36.1911, 44.0092, 40),
  ('erbil_ankawa', 'عنكاوا', 'erbil', 36.2380, 44.0080, 41),
  ('erbil_italian_village', 'القرية الإيطالية', 'erbil', 36.1750, 44.0450, 42),
  -- نينوى / الموصل
  ('nineveh_mosul_center', 'مركز الموصل', 'nineveh', 36.3450, 43.1450, 50),
  ('nineveh_tel_afar', 'تلعفر', 'nineveh', 36.3790, 42.4470, 51),
  -- النجف وكربلاء
  ('najaf_center', 'مركز النجف', 'najaf', 32.0000, 44.3330, 60),
  ('karbala_center', 'مركز كربلاء', 'karbala', 32.6160, 44.0240, 61)
ON CONFLICT (slug) DO UPDATE SET
  name_ar = EXCLUDED.name_ar,
  governorate_slug = EXCLUDED.governorate_slug,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  display_order = EXCLUDED.display_order;

-- ---------------------------------------------------------------------------
-- One-time backfill: nearest neighborhood center for rows with GPS.
-- ---------------------------------------------------------------------------
UPDATE public.listings AS l
SET area_name = matched.name_ar
FROM (
  SELECT
    l2.id,
    nearest.name_ar
  FROM public.listings AS l2
  CROSS JOIN LATERAL (
    SELECT ac.name_ar
    FROM public.listing_area_centers AS ac
    ORDER BY
      POWER(l2.latitude - ac.latitude, 2)
      + POWER(l2.longitude - ac.longitude, 2)
    LIMIT 1
  ) AS nearest
  WHERE l2.latitude IS NOT NULL
    AND l2.longitude IS NOT NULL
    AND (l2.area_name IS NULL OR btrim(l2.area_name) = '')
) AS matched
WHERE l.id = matched.id
  AND matched.name_ar IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Aggregate active approved listings per neighborhood (optional category tree).
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_listing_density(
  p_category_slug TEXT DEFAULT NULL
)
RETURNS TABLE (
  area_name TEXT,
  listing_count BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF p_category_slug IS NULL OR btrim(p_category_slug) = '' THEN
    RETURN QUERY
    SELECT
      l.area_name,
      COUNT(*)::BIGINT AS listing_count
    FROM public.listings AS l
    WHERE l.status = 'approved'
      AND l.availability = 'active'
      AND l.area_name IS NOT NULL
      AND btrim(l.area_name) <> ''
    GROUP BY l.area_name
    ORDER BY listing_count DESC, l.area_name;
    RETURN;
  END IF;

  RETURN QUERY
  WITH RECURSIVE cat_tree AS (
    SELECT c.id
    FROM public.categories AS c
    WHERE c.slug = p_category_slug
    UNION ALL
    SELECT child.id
    FROM public.categories AS child
    INNER JOIN cat_tree AS parent ON child.parent_id = parent.id
  )
  SELECT
    l.area_name,
    COUNT(*)::BIGINT AS listing_count
  FROM public.listings AS l
  WHERE l.status = 'approved'
    AND l.availability = 'active'
    AND l.area_name IS NOT NULL
    AND btrim(l.area_name) <> ''
    AND l.category_id IN (SELECT id FROM cat_tree)
  GROUP BY l.area_name
  ORDER BY listing_count DESC, l.area_name;
END;
$$;

REVOKE ALL ON FUNCTION public.get_listing_density(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_listing_density(TEXT) TO anon, authenticated;
