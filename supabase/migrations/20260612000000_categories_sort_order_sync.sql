-- categories.sort_order mirrors display_order (some SQL scripts use either name).
-- Safe to re-run.

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

UPDATE public.categories
SET sort_order = display_order
WHERE sort_order IS DISTINCT FROM display_order;

-- Re-apply السيارات branch order on BOTH columns.
DO $$
DECLARE
  v_cars_id INT;
BEGIN
  SELECT id INTO v_cars_id FROM public.categories WHERE slug = 'cars';
  IF v_cars_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE public.categories SET display_order = 1, sort_order = 1
  WHERE slug = 'veh_automobile' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 2, sort_order = 2
  WHERE slug = 'veh_rental' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 3, sort_order = 3
  WHERE slug = 'veh_electric' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 4, sort_order = 4, name_ar = 'دراجات'
  WHERE slug = 'veh_motorcycle' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 5, sort_order = 5
  WHERE slug = 'veh_minivan' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 6, sort_order = 6
  WHERE slug = 'veh_commercial' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 7, sort_order = 7
  WHERE slug = 'veh_suv_pickup' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 8, sort_order = 8
  WHERE slug = 'veh_marine' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 9, sort_order = 9
  WHERE slug = 'veh_damaged' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 10, sort_order = 10
  WHERE slug = 'veh_caravan' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 11, sort_order = 11
  WHERE slug = 'veh_classic' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 12, sort_order = 12
  WHERE slug = 'veh_aircraft' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 13, sort_order = 13
  WHERE slug = 'veh_atv' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 14, sort_order = 14
  WHERE slug = 'veh_utv' AND parent_id = v_cars_id;

  UPDATE public.categories SET display_order = 15, sort_order = 15
  WHERE slug = 'veh_accessible' AND parent_id = v_cars_id;
END $$;

CREATE INDEX IF NOT EXISTS categories_sort_order_idx
  ON public.categories (parent_id, sort_order);
