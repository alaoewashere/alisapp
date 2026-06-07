-- سيارات تالفة (veh_damaged) — copy brand/model tree from سيارات (veh_automobile)
-- Safe to re-run: replaces veh_damaged subtree; slugs veh_auto_br_* → veh_damaged_br_*

CREATE OR REPLACE FUNCTION public._copy_auto_tree_to_damaged() RETURNS VOID AS $$
DECLARE
  v_source_id INT;
  v_target_id INT;
  brand_rec RECORD;
  model_rec RECORD;
  v_new_brand_id INT;
  v_new_slug TEXT;
BEGIN
  SELECT id INTO v_source_id FROM public.categories WHERE slug = 'veh_automobile';
  SELECT id INTO v_target_id FROM public.categories WHERE slug = 'veh_damaged';

  IF v_source_id IS NULL THEN
    RAISE EXCEPTION 'Source category not found: veh_automobile';
  END IF;
  IF v_target_id IS NULL THEN
    RAISE EXCEPTION 'Target category not found: veh_damaged';
  END IF;

  DELETE FROM public.categories
  WHERE id IN (
    WITH RECURSIVE subtree AS (
      SELECT c.id FROM public.categories c WHERE c.parent_id = v_target_id
      UNION ALL
      SELECT c.id FROM public.categories c
      INNER JOIN subtree s ON c.parent_id = s.id
    )
    SELECT id FROM subtree
  );

  FOR brand_rec IN
    SELECT id, slug, name_ar, name_ku, name_en, icon, logo_url, color_hex, display_order, sort_order
    FROM public.categories
    WHERE parent_id = v_source_id AND icon = 'brand'
    ORDER BY display_order, id
  LOOP
    v_new_slug := replace(brand_rec.slug, 'veh_auto_br_', 'veh_damaged_br_');

    INSERT INTO public.categories (
      slug, name_ar, name_ku, name_en, icon, parent_id,
      display_order, sort_order, logo_url, color_hex
    )
    VALUES (
      v_new_slug, brand_rec.name_ar, brand_rec.name_ku, brand_rec.name_en, brand_rec.icon,
      v_target_id, brand_rec.display_order, brand_rec.sort_order,
      brand_rec.logo_url, brand_rec.color_hex
    )
    ON CONFLICT (slug) DO UPDATE SET
      name_ar = EXCLUDED.name_ar,
      name_ku = EXCLUDED.name_ku,
      name_en = EXCLUDED.name_en,
      icon = EXCLUDED.icon,
      parent_id = EXCLUDED.parent_id,
      display_order = EXCLUDED.display_order,
      sort_order = EXCLUDED.sort_order,
      logo_url = EXCLUDED.logo_url,
      color_hex = EXCLUDED.color_hex
    RETURNING id INTO v_new_brand_id;

    FOR model_rec IN
      SELECT slug, name_ar, name_ku, name_en, icon, display_order, sort_order
      FROM public.categories
      WHERE parent_id = brand_rec.id
      ORDER BY display_order, id
    LOOP
      v_new_slug := replace(model_rec.slug, 'veh_auto_br_', 'veh_damaged_br_');

      INSERT INTO public.categories (
        slug, name_ar, name_ku, name_en, icon, parent_id,
        display_order, sort_order
      )
      VALUES (
        v_new_slug, model_rec.name_ar, model_rec.name_ku, model_rec.name_en, model_rec.icon,
        v_new_brand_id, model_rec.display_order, model_rec.sort_order
      )
      ON CONFLICT (slug) DO UPDATE SET
        name_ar = EXCLUDED.name_ar,
        name_ku = EXCLUDED.name_ku,
        name_en = EXCLUDED.name_en,
        icon = EXCLUDED.icon,
        parent_id = EXCLUDED.parent_id,
        display_order = EXCLUDED.display_order,
        sort_order = EXCLUDED.sort_order;
    END LOOP;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT public._copy_auto_tree_to_damaged();

DROP FUNCTION public._copy_auto_tree_to_damaged();
