-- السيارات — full Arabic category tree (Sahibinden-style)
-- Safe to re-run: ON CONFLICT (slug) upserts; descendants refreshed via slug.

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS color_hex TEXT;

UPDATE public.categories
SET name_ar = 'المركبات', display_order = COALESCE(display_order, 0)
WHERE slug = 'cars';

DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id
    FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'cars')
    UNION ALL
    SELECT c.id
    FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

CREATE OR REPLACE FUNCTION public._seed_veh_category(
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
-- Level 1 — main branches under السيارات
-- ---------------------------------------------------------------------------
SELECT public._seed_veh_category('veh_automobile', 'سيارات', 'cars', '🚗', 1, '#E53935');
SELECT public._seed_veh_category('veh_suv_pickup', 'دفع رباعي وبيك أب', 'cars', '🛻', 2, '#FF7043');
SELECT public._seed_veh_category('veh_electric', 'سيارات كهربائية', 'cars', '⚡', 3, '#66BB6A');
SELECT public._seed_veh_category('veh_motorcycle', 'دراجات', 'cars', '🏍️', 4, '#AB47BC');
SELECT public._seed_veh_category('veh_minivan', 'ميني فان وفان', 'cars', '🚐', 5, '#5C6BC0');
SELECT public._seed_veh_category('veh_commercial', 'مركبات تجارية', 'cars', '🚛', 6, '#78909C');
SELECT public._seed_veh_category('veh_rental', 'سيارات للإيجار', 'cars', '🔑', 7, '#29B6F6');
SELECT public._seed_veh_category('veh_marine', 'مركبات بحرية', 'cars', '⛵', 8, '#26C6DA');
SELECT public._seed_veh_category('veh_damaged', 'سيارات تالفة', 'cars', '🔧', 9, '#8D6E63');
SELECT public._seed_veh_category('veh_caravan', 'كرفان', 'cars', '🏕️', 10, '#FFA726');
SELECT public._seed_veh_category('veh_classic', 'سيارات كلاسيكية', 'cars', '🏆', 11, '#D4AF37');
SELECT public._seed_veh_category('veh_aircraft', 'مركبات جوية', 'cars', '✈️', 12, '#42A5F5');
SELECT public._seed_veh_category('veh_atv', 'ATV', 'cars', '🏁', 13, '#7CB342');
SELECT public._seed_veh_category('veh_utv', 'UTV', 'cars', '🏁', 14, '#558B2F');
SELECT public._seed_veh_category('veh_accessible', 'سيارات ذوي الاحتياجات الخاصة', 'cars', '♿', 15, '#7E57C2');

DROP FUNCTION public._seed_veh_category(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
