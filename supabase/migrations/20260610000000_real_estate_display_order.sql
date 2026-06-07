-- Reorder العقارات level-1 branches (display_order = sort_order in app spec).
-- Safe to re-run.

DO $$
DECLARE
  v_re_id INT;
BEGIN
  SELECT id INTO v_re_id FROM public.categories WHERE slug = 'real_estate';
  IF v_re_id IS NULL THEN
    RAISE NOTICE 'real_estate root not found — skipping';
    RETURN;
  END IF;

  UPDATE public.categories SET display_order = 1
  WHERE slug = 're_residential' AND parent_id = v_re_id;

  UPDATE public.categories SET display_order = 2
  WHERE slug = 're_tourism' AND parent_id = v_re_id;

  UPDATE public.categories SET display_order = 3
  WHERE slug = 're_shared' AND parent_id = v_re_id;

  UPDATE public.categories SET display_order = 4
  WHERE slug = 're_land' AND parent_id = v_re_id;

  UPDATE public.categories SET display_order = 5
  WHERE slug = 're_projects' AND parent_id = v_re_id;

  UPDATE public.categories SET display_order = 6, name_ar = 'محلات تجارية'
  WHERE slug = 're_commercial' AND parent_id = v_re_id;
END $$;
