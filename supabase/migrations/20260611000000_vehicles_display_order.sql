-- Reorder السيارات level-1 branches (display_order = sort_order in app spec).
-- Safe to re-run.

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
