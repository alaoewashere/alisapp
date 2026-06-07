-- دراجات lives under السيارات (veh_motorcycle) — remove standalone root + دراجات نارية label.
-- Safe to re-run.

DELETE FROM public.categories
WHERE slug = 'motorcycles' AND parent_id IS NULL;

DO $$
DECLARE
  v_cars_id INT;
BEGIN
  SELECT id INTO v_cars_id FROM public.categories WHERE slug = 'cars';
  IF v_cars_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE public.categories
  SET name_ar = 'دراجات', display_order = 4
  WHERE slug = 'veh_motorcycle' AND parent_id = v_cars_id;
END $$;

UPDATE public.categories SET display_order = 3 WHERE slug = 'electronics' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 4 WHERE slug = 'buy_sell' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 5 WHERE slug = 'industry' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 6 WHERE slug = 'services' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 7 WHERE slug = 'tutoring' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 8 WHERE slug = 'jobs' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 9 WHERE slug = 'pets' AND parent_id IS NULL;
UPDATE public.categories SET display_order = 10 WHERE slug = 'home_help' AND parent_id IS NULL;
