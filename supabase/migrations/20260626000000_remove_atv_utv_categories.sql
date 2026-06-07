-- Remove ATV / UTV vehicle branches (رباعي العجلات الصغير / الكبير).
-- Safe to re-run: DELETE is idempotent; display_order bump is guarded by slug.

DELETE FROM public.categories
WHERE slug IN ('veh_atv', 'veh_utv');

DO $$
DECLARE
  v_cars_id INT;
BEGIN
  SELECT id INTO v_cars_id FROM public.categories WHERE slug = 'cars';
  IF v_cars_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE public.categories SET display_order = 13, sort_order = 13
  WHERE slug = 'veh_accessible' AND parent_id = v_cars_id;
END $$;
