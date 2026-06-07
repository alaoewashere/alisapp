-- ميني فان وفان (veh_minivan) — brands + models (Iraq market)
-- Safe to re-run: cleans veh_minivan subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_van_node(
  p_slug TEXT,
  p_name_ar TEXT,
  p_parent_slug TEXT,
  p_icon TEXT DEFAULT 'category',
  p_display_order INT DEFAULT 0,
  p_logo_url TEXT DEFAULT NULL,
  p_color_hex TEXT DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
  v_parent_id INT;
BEGIN
  SELECT id INTO v_parent_id FROM public.categories WHERE slug = p_parent_slug;
  IF v_parent_id IS NULL THEN
    RAISE EXCEPTION 'Parent category not found: %', p_parent_slug;
  END IF;

  INSERT INTO public.categories (
    slug, name_ar, name_ku, name_en, icon, parent_id, display_order, sort_order, logo_url, color_hex
  )
  VALUES (
    p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id,
    p_display_order, p_display_order, p_logo_url, p_color_hex
  )
  ON CONFLICT (slug) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_ku = NULL,
    name_en = NULL,
    icon = EXCLUDED.icon,
    parent_id = EXCLUDED.parent_id,
    display_order = EXCLUDED.display_order,
    sort_order = EXCLUDED.sort_order,
    logo_url = EXCLUDED.logo_url,
    color_hex = EXCLUDED.color_hex;
END;
$$ LANGUAGE plpgsql;

DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_minivan')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_van_node('veh_van_br_toyota', 'Toyota', 'veh_minivan', 'brand', 1, 'https://www.carlogos.org/car-logos/toyota-logo.png', '#EB0A1E');
SELECT public._seed_van_node('veh_van_br_toyota_hiace', 'HiAce', 'veh_van_br_toyota', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_hiace_gl', 'Hiace GL', 'veh_van_br_toyota', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_hiace_high_roof', 'Hiace High Roof', 'veh_van_br_toyota', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_hiace_commuter', 'Hiace Commuter', 'veh_van_br_toyota', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_noah', 'Noah', 'veh_van_br_toyota', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_voxy', 'Voxy', 'veh_van_br_toyota', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_alphard', 'Alphard', 'veh_van_br_toyota', 'model', 7, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_vellfire', 'Vellfire', 'veh_van_br_toyota', 'model', 8, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_sienna', 'Sienna', 'veh_van_br_toyota', 'model', 9, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_innova', 'Innova', 'veh_van_br_toyota', 'model', 10, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_toyota_granvia', 'Granvia', 'veh_van_br_toyota', 'model', 11, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_kia', 'Kia', 'veh_minivan', 'brand', 2, 'https://www.carlogos.org/car-logos/kia-logo.png', '#05141F');
SELECT public._seed_van_node('veh_van_br_kia_carnival', 'Carnival', 'veh_van_br_kia', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_kia_carnival_limousine', 'Carnival Limousine', 'veh_van_br_kia', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_kia_bongo', 'Bongo', 'veh_van_br_kia', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_kia_grand_carnival', 'Grand Carnival', 'veh_van_br_kia', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_kia_pregio', 'Pregio', 'veh_van_br_kia', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai', 'Hyundai', 'veh_minivan', 'brand', 3, 'https://www.carlogos.org/car-logos/hyundai-logo.png', '#002C5F');
SELECT public._seed_van_node('veh_van_br_hyundai_staria', 'Staria', 'veh_van_br_hyundai', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_staria_limousine', 'Staria Limousine', 'veh_van_br_hyundai', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_h_1', 'H-1', 'veh_van_br_hyundai', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_h_1_van', 'H-1 Van', 'veh_van_br_hyundai', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_starex', 'Starex', 'veh_van_br_hyundai', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_grand_starex', 'Grand Starex', 'veh_van_br_hyundai', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_hyundai_county', 'County', 'veh_van_br_hyundai', 'model', 7, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan', 'Nissan', 'veh_minivan', 'brand', 4, 'https://www.carlogos.org/car-logos/nissan-logo.png', '#C3002F');
SELECT public._seed_van_node('veh_van_br_nissan_urvan', 'Urvan', 'veh_van_br_nissan', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan_urvan_high_roof', 'Urvan High Roof', 'veh_van_br_nissan', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan_serena', 'Serena', 'veh_van_br_nissan', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan_quest', 'Quest', 'veh_van_br_nissan', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan_elgrand', 'Elgrand', 'veh_van_br_nissan', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_nissan_cabstar', 'Cabstar', 'veh_van_br_nissan', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz', 'Mercedes-Benz', 'veh_minivan', 'brand', 5, 'https://www.carlogos.org/car-logos/mercedes-benz-logo.png', '#333333');
SELECT public._seed_van_node('veh_van_br_mercedes_benz_sprinter', 'Sprinter', 'veh_van_br_mercedes_benz', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_sprinter_313', 'Sprinter 313', 'veh_van_br_mercedes_benz', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_sprinter_315', 'Sprinter 315', 'veh_van_br_mercedes_benz', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_sprinter_316', 'Sprinter 316', 'veh_van_br_mercedes_benz', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_vito', 'Vito', 'veh_van_br_mercedes_benz', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_vito_tourer', 'Vito Tourer', 'veh_van_br_mercedes_benz', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_v_class', 'V-Class', 'veh_van_br_mercedes_benz', 'model', 7, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_v_class_marco_polo', 'V-Class Marco Polo', 'veh_van_br_mercedes_benz', 'model', 8, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mercedes_benz_metris', 'Metris', 'veh_van_br_mercedes_benz', 'model', 9, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen', 'Volkswagen', 'veh_minivan', 'brand', 6, 'https://www.carlogos.org/car-logos/volkswagen-logo.png', '#001E50');
SELECT public._seed_van_node('veh_van_br_volkswagen_transporter_t6', 'Transporter T6', 'veh_van_br_volkswagen', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen_transporter_t7', 'Transporter T7', 'veh_van_br_volkswagen', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen_caravelle', 'Caravelle', 'veh_van_br_volkswagen', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen_multivan', 'Multivan', 'veh_van_br_volkswagen', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen_crafter', 'Crafter', 'veh_van_br_volkswagen', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_volkswagen_touran', 'Touran', 'veh_van_br_volkswagen', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford', 'Ford', 'veh_minivan', 'brand', 7, 'https://www.carlogos.org/car-logos/ford-logo.png', '#003478');
SELECT public._seed_van_node('veh_van_br_ford_transit', 'Transit', 'veh_van_br_ford', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford_transit_custom', 'Transit Custom', 'veh_van_br_ford', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford_transit_connect', 'Transit Connect', 'veh_van_br_ford', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford_tourneo', 'Tourneo', 'veh_van_br_ford', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford_tourneo_custom', 'Tourneo Custom', 'veh_van_br_ford', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_ford_econoline', 'Econoline', 'veh_van_br_ford', 'model', 6, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_gmc', 'GMC', 'veh_minivan', 'brand', 8, 'https://www.carlogos.org/car-logos/gmc-logo.png', '#CC0000');
SELECT public._seed_van_node('veh_van_br_gmc_safari', 'Safari', 'veh_van_br_gmc', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_gmc_savana', 'Savana', 'veh_van_br_gmc', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_gmc_express', 'Express', 'veh_van_br_gmc', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_gmc_vandura', 'Vandura', 'veh_van_br_gmc', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mitsubishi', 'Mitsubishi', 'veh_minivan', 'brand', 9, 'https://www.carlogos.org/car-logos/mitsubishi-logo.png', '#CC0000');
SELECT public._seed_van_node('veh_van_br_mitsubishi_delica', 'Delica', 'veh_van_br_mitsubishi', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mitsubishi_delica_d_5', 'Delica D:5', 'veh_van_br_mitsubishi', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mitsubishi_l300', 'L300', 'veh_van_br_mitsubishi', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mitsubishi_express', 'Express', 'veh_van_br_mitsubishi', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mitsubishi_rosa', 'Rosa', 'veh_van_br_mitsubishi', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_honda', 'Honda', 'veh_minivan', 'brand', 10, 'https://www.carlogos.org/car-logos/honda-logo.png', '#CC0000');
SELECT public._seed_van_node('veh_van_br_honda_odyssey', 'Odyssey', 'veh_van_br_honda', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_honda_elysion', 'Elysion', 'veh_van_br_honda', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_honda_stepwgn', 'Stepwgn', 'veh_van_br_honda', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_honda_freed', 'Freed', 'veh_van_br_honda', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_honda_br_v', 'BR-V', 'veh_van_br_honda', 'model', 5, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_chrysler', 'Chrysler', 'veh_minivan', 'brand', 11, 'https://www.carlogos.org/car-logos/chrysler-logo.png', '#1A1A1A');
SELECT public._seed_van_node('veh_van_br_chrysler_pacifica', 'Pacifica', 'veh_van_br_chrysler', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_chrysler_grand_caravan', 'Grand Caravan', 'veh_van_br_chrysler', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_chrysler_voyager', 'Voyager', 'veh_van_br_chrysler', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_chrysler_town_and_country', 'Town & Country', 'veh_van_br_chrysler', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_renault', 'Renault', 'veh_minivan', 'brand', 12, 'https://www.carlogos.org/car-logos/renault-logo.png', '#FFCC00');
SELECT public._seed_van_node('veh_van_br_renault_trafic', 'Trafic', 'veh_van_br_renault', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_renault_master', 'Master', 'veh_van_br_renault', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_renault_kangoo', 'Kangoo', 'veh_van_br_renault', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_renault_espace', 'Espace', 'veh_van_br_renault', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mazda', 'Mazda', 'veh_minivan', 'brand', 13, 'https://www.carlogos.org/car-logos/mazda-logo.png', '#1E1E1E');
SELECT public._seed_van_node('veh_van_br_mazda_bongo', 'Bongo', 'veh_van_br_mazda', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mazda_bongo_friendee', 'Bongo Friendee', 'veh_van_br_mazda', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mazda_mpv', 'MPV', 'veh_van_br_mazda', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_mazda_biante', 'Biante', 'veh_van_br_mazda', 'model', 4, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_isuzu', 'Isuzu', 'veh_minivan', 'brand', 14, 'https://www.carlogos.org/car-logos/isuzu-logo.png', '#CC0000');
SELECT public._seed_van_node('veh_van_br_isuzu_traviz', 'Traviz', 'veh_van_br_isuzu', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_isuzu_nlr', 'NLR', 'veh_van_br_isuzu', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_isuzu_journey', 'Journey', 'veh_van_br_isuzu', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_opel', 'Opel', 'veh_minivan', 'brand', 15, 'https://www.carlogos.org/car-logos/opel-logo.png', '#FFD700');
SELECT public._seed_van_node('veh_van_br_opel_vivaro', 'Vivaro', 'veh_van_br_opel', 'model', 1, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_opel_movano', 'Movano', 'veh_van_br_opel', 'model', 2, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_opel_zafira', 'Zafira', 'veh_van_br_opel', 'model', 3, NULL, NULL);
SELECT public._seed_van_node('veh_van_br_opel_combo', 'Combo', 'veh_van_br_opel', 'model', 4, NULL, NULL);

DROP FUNCTION public._seed_van_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

