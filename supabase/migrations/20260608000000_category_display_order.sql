-- Reorder categories by importance (display_order = sort_order in app spec).
-- Safe to re-run.

-- ---------------------------------------------------------------------------
-- Step 1 — top-level roots (parent_id IS NULL)
-- ---------------------------------------------------------------------------
UPDATE public.categories SET display_order = 1, name_ar = 'العقارات'
WHERE slug = 'real_estate' AND parent_id IS NULL;

UPDATE public.categories SET display_order = 2, name_ar = 'المركبات'
WHERE slug = 'cars' AND parent_id IS NULL;

UPDATE public.categories SET display_order = 3, name_ar = 'الإلكترونيات'
WHERE slug = 'electronics' AND parent_id IS NULL;

INSERT INTO public.categories (slug, name_ar, icon, display_order)
VALUES
  ('buy_sell', 'البيع والشراء', 'shopping_bag', 4),
  ('industry', 'الآلات والصناعة', 'precision_manufacturing', 5),
  ('tutoring', 'دروس خصوصية', 'menu_book', 7),
  ('pets', 'الحيوانات', 'pets', 9),
  ('home_help', 'مساعدة منزلية', 'child_care', 10)
ON CONFLICT (slug) DO UPDATE SET
  name_ar = EXCLUDED.name_ar,
  display_order = EXCLUDED.display_order;

UPDATE public.categories SET display_order = 4 WHERE slug = 'buy_sell' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 5 WHERE slug = 'industry' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 6, name_ar = 'الخدمات والحرف'
WHERE slug = 'services' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 7 WHERE slug = 'tutoring' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 8, name_ar = 'فرص العمل'
WHERE slug = 'jobs' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 9 WHERE slug = 'pets' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 10 WHERE slug = 'home_help' AND parent_id IS NULL;

-- ---------------------------------------------------------------------------
-- Step 2 — السيارات branches (by slug under cars root)
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  v_cars_id INT;
BEGIN
  SELECT id INTO v_cars_id FROM public.categories WHERE slug = 'cars';
  IF v_cars_id IS NULL THEN
    RAISE NOTICE 'cars root not found — skipping vehicle branch order';
    RETURN;
  END IF;

  UPDATE public.categories SET display_order = 1
  WHERE slug = 'veh_automobile' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 2
  WHERE slug = 'veh_rental' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 3
  WHERE slug = 'veh_electric' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 4, name_ar = 'دراجات'
  WHERE slug = 'veh_motorcycle' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 5
  WHERE slug = 'veh_minivan' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 6
  WHERE slug = 'veh_commercial' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 7
  WHERE slug = 'veh_suv_pickup' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 8
  WHERE slug = 'veh_marine' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 9
  WHERE slug = 'veh_damaged' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 10
  WHERE slug = 'veh_caravan' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 11
  WHERE slug = 'veh_classic' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 12
  WHERE slug = 'veh_aircraft' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 13, name_ar = 'رباعي العجلات الصغير'
  WHERE slug = 'veh_atv' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 14, name_ar = 'رباعي العجلات الكبير'
  WHERE slug = 'veh_utv' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 15
  WHERE slug = 'veh_accessible' AND parent_id = v_cars_id;
END $$;
