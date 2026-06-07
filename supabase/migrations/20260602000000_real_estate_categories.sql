-- العقارات — full Arabic category tree (Sahibinden-style)
-- Safe to re-run: ON CONFLICT (slug) upserts; descendants refreshed via slug.

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS color_hex TEXT;

-- Root label (seed used "عقارات" without ال)
UPDATE public.categories
SET name_ar = 'العقارات', display_order = COALESCE(display_order, 0)
WHERE slug = 'real_estate';

-- Remove previous real-estate subtree (keep root row)
DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id
    FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'real_estate')
    UNION ALL
    SELECT c.id
    FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

-- Helper: upsert one category row
CREATE OR REPLACE FUNCTION public._seed_re_category(
  p_slug TEXT,
  p_name_ar TEXT,
  p_parent_slug TEXT,
  p_icon TEXT DEFAULT 'category',
  p_display_order INT DEFAULT 0,
  p_color_hex TEXT DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
  v_parent_id INT;
BEGIN
  IF p_parent_slug IS NULL THEN
    v_parent_id := NULL;
  ELSE
    SELECT id INTO v_parent_id FROM public.categories WHERE slug = p_parent_slug;
    IF v_parent_id IS NULL THEN
      RAISE EXCEPTION 'Parent category not found: %', p_parent_slug;
    END IF;
  END IF;

  INSERT INTO public.categories (slug, name_ar, name_ku, name_en, icon, parent_id, display_order, color_hex)
  VALUES (p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id, p_display_order, p_color_hex)
  ON CONFLICT (slug) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_ku = NULL,
    name_en = NULL,
    icon = EXCLUDED.icon,
    parent_id = EXCLUDED.parent_id,
    display_order = EXCLUDED.display_order,
    color_hex = EXCLUDED.color_hex;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- Level 1 — main branches under العقارات
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_residential', 'سكني', 'real_estate', '🏠', 1, '#FF9800');
SELECT public._seed_re_category('re_tourism', 'منشآت سياحية', 'real_estate', '🏖️', 2, '#26A69A');
SELECT public._seed_re_category('re_shared', 'ملكية مشتركة', 'real_estate', '🏢', 3, '#7E57C2');
SELECT public._seed_re_category('re_land', 'أراضي', 'real_estate', '🌳', 4, '#8D6E63');
SELECT public._seed_re_category('re_projects', 'مشاريع سكنية', 'real_estate', '🏗️', 5, '#42A5F5');
SELECT public._seed_re_category('re_commercial', 'عقارات تجارية', 'real_estate', '🏬', 6, '#5C6BC0');

-- ---------------------------------------------------------------------------
-- Level 2 — سكني
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_residential_sale', 'للبيع', 're_residential', 'category', 1);
SELECT public._seed_re_category('re_residential_rent', 'للإيجار', 're_residential', 'category', 2);

SELECT public._seed_re_category('re_residential_sale_apartment', 'شقة', 're_residential_sale', 'category', 1);
SELECT public._seed_re_category('re_residential_sale_villa', 'فيلا', 're_residential_sale', 'category', 2);
SELECT public._seed_re_category('re_residential_sale_house', 'بيت مستقل', 're_residential_sale', 'category', 3);
SELECT public._seed_re_category('re_residential_sale_duplex', 'دوبلكس', 're_residential_sale', 'category', 4);
SELECT public._seed_re_category('re_residential_sale_palace', 'قصر', 're_residential_sale', 'category', 5);
SELECT public._seed_re_category('re_residential_sale_studio', 'استوديو', 're_residential_sale', 'category', 6);

SELECT public._seed_re_category('re_residential_rent_apartment', 'شقة', 're_residential_rent', 'category', 1);
SELECT public._seed_re_category('re_residential_rent_villa', 'فيلا', 're_residential_rent', 'category', 2);
SELECT public._seed_re_category('re_residential_rent_house', 'بيت مستقل', 're_residential_rent', 'category', 3);
SELECT public._seed_re_category('re_residential_rent_duplex', 'دوبلكس', 're_residential_rent', 'category', 4);
SELECT public._seed_re_category('re_residential_rent_room', 'غرفة', 're_residential_rent', 'category', 5);
SELECT public._seed_re_category('re_residential_rent_studio', 'استوديو', 're_residential_rent', 'category', 6);

-- ---------------------------------------------------------------------------
-- Level 2 — منشآت سياحية
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_tourism_sale', 'للبيع', 're_tourism', 'category', 1);
SELECT public._seed_re_category('re_tourism_rent', 'للإيجار', 're_tourism', 'category', 2);

SELECT public._seed_re_category('re_tourism_sale_hotel', 'فندق', 're_tourism_sale', 'category', 1);
SELECT public._seed_re_category('re_tourism_sale_resort', 'منتجع', 're_tourism_sale', 'category', 2);
SELECT public._seed_re_category('re_tourism_sale_chalet', 'شاليه', 're_tourism_sale', 'category', 3);
SELECT public._seed_re_category('re_tourism_sale_resthouse', 'استراحة', 're_tourism_sale', 'category', 4);
SELECT public._seed_re_category('re_tourism_sale_motel', 'موتيل', 're_tourism_sale', 'category', 5);

SELECT public._seed_re_category('re_tourism_rent_hotel', 'فندق', 're_tourism_rent', 'category', 1);
SELECT public._seed_re_category('re_tourism_rent_resort', 'منتجع', 're_tourism_rent', 'category', 2);
SELECT public._seed_re_category('re_tourism_rent_chalet', 'شاليه', 're_tourism_rent', 'category', 3);
SELECT public._seed_re_category('re_tourism_rent_resthouse', 'استراحة', 're_tourism_rent', 'category', 4);
SELECT public._seed_re_category('re_tourism_rent_motel', 'موتيل', 're_tourism_rent', 'category', 5);

-- ---------------------------------------------------------------------------
-- Level 2 — ملكية مشتركة (leaves)
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_shared_sale', 'للبيع', 're_shared', 'category', 1);
SELECT public._seed_re_category('re_shared_rent', 'للإيجار', 're_shared', 'category', 2);

-- ---------------------------------------------------------------------------
-- Level 2 — أراضي (leaves)
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_land_residential', 'سكنية', 're_land', 'category', 1);
SELECT public._seed_re_category('re_land_commercial', 'تجارية', 're_land', 'category', 2);
SELECT public._seed_re_category('re_land_agricultural', 'زراعية', 're_land', 'category', 3);
SELECT public._seed_re_category('re_land_industrial', 'صناعية', 're_land', 'category', 4);
SELECT public._seed_re_category('re_land_tourism', 'سياحية', 're_land', 'category', 5);

-- ---------------------------------------------------------------------------
-- Level 2 — مشاريع سكنية (leaves)
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_projects_new', 'مشروع سكني جديد', 're_projects', 'category', 1);
SELECT public._seed_re_category('re_projects_complex', 'مجمع سكني', 're_projects', 'category', 2);
SELECT public._seed_re_category('re_projects_compound', 'كومباوند', 're_projects', 'category', 3);

-- ---------------------------------------------------------------------------
-- Level 2 — عقارات تجارية
-- ---------------------------------------------------------------------------
SELECT public._seed_re_category('re_commercial_sale', 'للبيع', 're_commercial', 'category', 1);
SELECT public._seed_re_category('re_commercial_rent', 'للإيجار', 're_commercial', 'category', 2);

SELECT public._seed_re_category('re_commercial_sale_office', 'مكتب', 're_commercial_sale', 'category', 1);
SELECT public._seed_re_category('re_commercial_sale_shop', 'محل', 're_commercial_sale', 'category', 2);
SELECT public._seed_re_category('re_commercial_sale_warehouse', 'مستودع', 're_commercial_sale', 'category', 3);
SELECT public._seed_re_category('re_commercial_sale_factory', 'مصنع', 're_commercial_sale', 'category', 4);
SELECT public._seed_re_category('re_commercial_sale_restaurant', 'مطعم', 're_commercial_sale', 'category', 5);
SELECT public._seed_re_category('re_commercial_sale_hotel', 'فندق', 're_commercial_sale', 'category', 6);
SELECT public._seed_re_category('re_commercial_sale_gym', 'صالة رياضية', 're_commercial_sale', 'category', 7);
SELECT public._seed_re_category('re_commercial_sale_gas', 'محطة وقود', 're_commercial_sale', 'category', 8);

SELECT public._seed_re_category('re_commercial_rent_office', 'مكتب', 're_commercial_rent', 'category', 1);
SELECT public._seed_re_category('re_commercial_rent_shop', 'محل', 're_commercial_rent', 'category', 2);
SELECT public._seed_re_category('re_commercial_rent_warehouse', 'مستودع', 're_commercial_rent', 'category', 3);
SELECT public._seed_re_category('re_commercial_rent_factory', 'مصنع', 're_commercial_rent', 'category', 4);
SELECT public._seed_re_category('re_commercial_rent_restaurant', 'مطعم', 're_commercial_rent', 'category', 5);
SELECT public._seed_re_category('re_commercial_rent_wedding', 'صالة أفراح', 're_commercial_rent', 'category', 6);
SELECT public._seed_re_category('re_commercial_rent_showroom', 'معرض', 're_commercial_rent', 'category', 7);

DROP FUNCTION public._seed_re_category(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
