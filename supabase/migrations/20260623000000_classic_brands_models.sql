-- سيارات كلاسيكية (veh_classic) — classic car brands + models (Iraq market)
-- Safe to re-run: cleans veh_classic subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_classic_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_classic')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_classic_node('veh_classic_br_mercedes_benz', 'Mercedes-Benz', 'veh_classic', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/mercedes-benz.svg', '#333333');
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w123_1976_1985', 'W123 (1976–1985)', 'veh_classic_br_mercedes_benz', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w124_1984_1997', 'W124 (1984–1997)', 'veh_classic_br_mercedes_benz', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w126_1979_1991', 'W126 (1979–1991)', 'veh_classic_br_mercedes_benz', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w114_w115_1968_1976', 'W114/W115 (1968–1976)', 'veh_classic_br_mercedes_benz', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w108_w109_1965_1972', 'W108/W109 (1965–1972)', 'veh_classic_br_mercedes_benz', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_w111_fintail_1959_1968', 'W111 Fintail (1959–1968)', 'veh_classic_br_mercedes_benz', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_190e_2_3_16_1984', '190E 2.3-16 (1984)', 'veh_classic_br_mercedes_benz', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_300sl_gullwing_1954_1957', '300SL Gullwing (1954–1957)', 'veh_classic_br_mercedes_benz', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_pagoda_230sl_1963_1971', 'Pagoda 230SL (1963–1971)', 'veh_classic_br_mercedes_benz', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_600_grosser_1963_1981', '600 Grosser (1963–1981)', 'veh_classic_br_mercedes_benz', 'model', 10, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_r107_sl_1971_1989', 'R107 SL (1971–1989)', 'veh_classic_br_mercedes_benz', 'model', 11, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_mercedes_benz_g_class_w460_1979_1991', 'G-Class W460 (1979–1991)', 'veh_classic_br_mercedes_benz', 'model', 12, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw', 'BMW', 'veh_classic', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/bmw.svg', '#1C69D4');
SELECT public._seed_classic_node('veh_classic_br_bmw_e10_2002_1968_1976', 'E10 2002 (1968–1976)', 'veh_classic_br_bmw', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e21_3_series_1975_1983', 'E21 3-Series (1975–1983)', 'veh_classic_br_bmw', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e30_3_series_1982_1994', 'E30 3-Series (1982–1994)', 'veh_classic_br_bmw', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e28_5_series_1981_1988', 'E28 5-Series (1981–1988)', 'veh_classic_br_bmw', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e34_5_series_1988_1996', 'E34 5-Series (1988–1996)', 'veh_classic_br_bmw', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e24_6_series_1976_1989', 'E24 6-Series (1976–1989)', 'veh_classic_br_bmw', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e32_7_series_1986_1994', 'E32 7-Series (1986–1994)', 'veh_classic_br_bmw', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_e38_7_series_1994_2001', 'E38 7-Series (1994–2001)', 'veh_classic_br_bmw', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_m1_1978_1981', 'M1 (1978–1981)', 'veh_classic_br_bmw', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_bmw_507_roadster_1956_1959', '507 Roadster (1956–1959)', 'veh_classic_br_bmw', 'model', 10, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota', 'Toyota', 'veh_classic', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/toyota.svg', '#EB0A1E');
SELECT public._seed_classic_node('veh_classic_br_toyota_land_cruiser_fj40_1960_1984', 'Land Cruiser FJ40 (1960–1984)', 'veh_classic_br_toyota', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_land_cruiser_fj55_1967_1980', 'Land Cruiser FJ55 (1967–1980)', 'veh_classic_br_toyota', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_land_cruiser_bj60_1980_1987', 'Land Cruiser BJ60 (1980–1987)', 'veh_classic_br_toyota', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_land_cruiser_hj61_1987_1990', 'Land Cruiser HJ61 (1987–1990)', 'veh_classic_br_toyota', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_celica_1970_1977', 'Celica (1970–1977)', 'veh_classic_br_toyota', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_corolla_e20_1970_1979', 'Corolla E20 (1970–1979)', 'veh_classic_br_toyota', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_corolla_e30_1979_1983', 'Corolla E30 (1979–1983)', 'veh_classic_br_toyota', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_corona_1957_1982', 'Corona (1957–1982)', 'veh_classic_br_toyota', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_crown_1955_1979', 'Crown (1955–1979)', 'veh_classic_br_toyota', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_cressida_1976_1992', 'Cressida (1976–1992)', 'veh_classic_br_toyota', 'model', 10, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_hilux_1st_3rd_gen_1968_1983', 'Hilux 1st–3rd Gen (1968–1983)', 'veh_classic_br_toyota', 'model', 11, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_toyota_supra_a60_1981_1986', 'Supra A60 (1981–1986)', 'veh_classic_br_toyota', 'model', 12, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford', 'Ford', 'veh_classic', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/ford.svg', '#003478');
SELECT public._seed_classic_node('veh_classic_br_ford_mustang_1st_gen_1964_1973', 'Mustang 1st Gen (1964–1973)', 'veh_classic_br_ford', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_mustang_mach_1_1969_1973', 'Mustang Mach 1 (1969–1973)', 'veh_classic_br_ford', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_mustang_boss_302_1969_1970', 'Mustang Boss 302 (1969–1970)', 'veh_classic_br_ford', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_thunderbird_1955_1976', 'Thunderbird (1955–1976)', 'veh_classic_br_ford', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_falcon_1960_1970', 'Falcon (1960–1970)', 'veh_classic_br_ford', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_galaxy_1959_1974', 'Galaxy (1959–1974)', 'veh_classic_br_ford', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_f_100_pickup_1953_1979', 'F-100 Pickup (1953–1979)', 'veh_classic_br_ford', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_bronco_1st_gen_1966_1977', 'Bronco 1st Gen (1966–1977)', 'veh_classic_br_ford', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_capri_1968_1986', 'Capri (1968–1986)', 'veh_classic_br_ford', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ford_cortina_1962_1982', 'Cortina (1962–1982)', 'veh_classic_br_ford', 'model', 10, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet', 'Chevrolet', 'veh_classic', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/chevrolet.svg', '#D4AC0D');
SELECT public._seed_classic_node('veh_classic_br_chevrolet_corvette_c1_1953_1962', 'Corvette C1 (1953–1962)', 'veh_classic_br_chevrolet', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_corvette_c2_1963_1967', 'Corvette C2 (1963–1967)', 'veh_classic_br_chevrolet', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_corvette_c3_1968_1982', 'Corvette C3 (1968–1982)', 'veh_classic_br_chevrolet', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_camaro_1st_gen_1966_1969', 'Camaro 1st Gen (1966–1969)', 'veh_classic_br_chevrolet', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_camaro_2nd_gen_1970_1981', 'Camaro 2nd Gen (1970–1981)', 'veh_classic_br_chevrolet', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_impala_1958_1976', 'Impala (1958–1976)', 'veh_classic_br_chevrolet', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_bel_air_1950_1975', 'Bel Air (1950–1975)', 'veh_classic_br_chevrolet', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_nova_1962_1979', 'Nova (1962–1979)', 'veh_classic_br_chevrolet', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_el_camino_1959_1987', 'El Camino (1959–1987)', 'veh_classic_br_chevrolet', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_chevrolet_blazer_k5_1969_1994', 'Blazer K5 (1969–1994)', 'veh_classic_br_chevrolet', 'model', 10, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge', 'Dodge', 'veh_classic', 'brand', 6, 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Dodge_logo.svg', '#CC0000');
SELECT public._seed_classic_node('veh_classic_br_dodge_charger_1966_1978', 'Charger (1966–1978)', 'veh_classic_br_dodge', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_challenger_1970_1974', 'Challenger (1970–1974)', 'veh_classic_br_dodge', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_dart_1960_1976', 'Dart (1960–1976)', 'veh_classic_br_dodge', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_coronet_1949_1976', 'Coronet (1949–1976)', 'veh_classic_br_dodge', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_super_bee_1968_1971', 'Super Bee (1968–1971)', 'veh_classic_br_dodge', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_plymouth_barracuda_1964_1974', 'Plymouth Barracuda (1964–1974)', 'veh_classic_br_dodge', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_plymouth_road_runner_1968_1980', 'Plymouth Road Runner (1968–1980)', 'veh_classic_br_dodge', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_dodge_chrysler_300_letter_1955_1965', 'Chrysler 300 Letter (1955–1965)', 'veh_classic_br_dodge', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen', 'Volkswagen', 'veh_classic', 'brand', 7, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/volkswagen.svg', '#001E50');
SELECT public._seed_classic_node('veh_classic_br_volkswagen_beetle_1938_2003', 'Beetle (1938–2003)', 'veh_classic_br_volkswagen', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_golf_gti_mk1_1974_1984', 'Golf GTI Mk1 (1974–1984)', 'veh_classic_br_volkswagen', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_golf_gti_mk2_1984_1992', 'Golf GTI Mk2 (1984–1992)', 'veh_classic_br_volkswagen', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_karmann_ghia_1955_1974', 'Karmann Ghia (1955–1974)', 'veh_classic_br_volkswagen', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_type_2_bus_1950_1979', 'Type 2 Bus (1950–1979)', 'veh_classic_br_volkswagen', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_scirocco_mk1_1974_1981', 'Scirocco Mk1 (1974–1981)', 'veh_classic_br_volkswagen', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_volkswagen_polo_mk1_1975_1981', 'Polo Mk1 (1975–1981)', 'veh_classic_br_volkswagen', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche', 'Porsche', 'veh_classic', 'brand', 8, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/porsche.svg', '#000000');
SELECT public._seed_classic_node('veh_classic_br_porsche_356_1948_1965', '356 (1948–1965)', 'veh_classic_br_porsche', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_911_2_0_1963_1969', '911 2.0 (1963–1969)', 'veh_classic_br_porsche', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_911_carrera_rs_1972_1973', '911 Carrera RS (1972–1973)', 'veh_classic_br_porsche', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_911_sc_1978_1983', '911 SC (1978–1983)', 'veh_classic_br_porsche', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_911_carrera_3_2_1984_1989', '911 Carrera 3.2 (1984–1989)', 'veh_classic_br_porsche', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_914_1969_1976', '914 (1969–1976)', 'veh_classic_br_porsche', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_924_1976_1988', '924 (1976–1988)', 'veh_classic_br_porsche', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_944_1982_1991', '944 (1982–1991)', 'veh_classic_br_porsche', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_porsche_928_1977_1995', '928 (1977–1995)', 'veh_classic_br_porsche', 'model', 9, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar', 'Jaguar', 'veh_classic', 'brand', 9, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/jaguar.svg', '#231F20');
SELECT public._seed_classic_node('veh_classic_br_jaguar_e_type_1961_1975', 'E-Type (1961–1975)', 'veh_classic_br_jaguar', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xk120_1948_1954', 'XK120 (1948–1954)', 'veh_classic_br_jaguar', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xk140_1954_1957', 'XK140 (1954–1957)', 'veh_classic_br_jaguar', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xk150_1957_1961', 'XK150 (1957–1961)', 'veh_classic_br_jaguar', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_mark_2_1959_1967', 'Mark 2 (1959–1967)', 'veh_classic_br_jaguar', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xj6_series_1_1968_1973', 'XJ6 Series 1 (1968–1973)', 'veh_classic_br_jaguar', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xj6_series_2_1973_1979', 'XJ6 Series 2 (1973–1979)', 'veh_classic_br_jaguar', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_jaguar_xjs_1975_1996', 'XJS (1975–1996)', 'veh_classic_br_jaguar', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun', 'Nissan / Datsun', 'veh_classic', 'brand', 10, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/nissan.svg', '#C3002F');
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_datsun_240z_1969_1973', 'Datsun 240Z (1969–1973)', 'veh_classic_br_nissan_datsun', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_datsun_260z_1973_1978', 'Datsun 260Z (1973–1978)', 'veh_classic_br_nissan_datsun', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_datsun_280z_1975_1978', 'Datsun 280Z (1975–1978)', 'veh_classic_br_nissan_datsun', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_nissan_300zx_z31_1983_1989', 'Nissan 300ZX Z31 (1983–1989)', 'veh_classic_br_nissan_datsun', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_datsun_510_1967_1973', 'Datsun 510 (1967–1973)', 'veh_classic_br_nissan_datsun', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_datsun_1200_1970_1973', 'Datsun 1200 (1970–1973)', 'veh_classic_br_nissan_datsun', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_nissan_skyline_gt_r_c10', 'Nissan Skyline GT-R C10', 'veh_classic_br_nissan_datsun', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_nissan_datsun_nissan_patrol_60_series', 'Nissan Patrol 60 Series', 'veh_classic_br_nissan_datsun', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_pontiac', 'Pontiac', 'veh_classic', 'brand', 11, 'https://www.carlogos.org/car-logos/pontiac-logo.png', '#CC0000');
SELECT public._seed_classic_node('veh_classic_br_pontiac_gto_1964_1974', 'GTO (1964–1974)', 'veh_classic_br_pontiac', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_pontiac_firebird_1967_1981', 'Firebird (1967–1981)', 'veh_classic_br_pontiac', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_pontiac_trans_am_1969_1981', 'Trans Am (1969–1981)', 'veh_classic_br_pontiac', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_pontiac_bonneville_1957_1970', 'Bonneville (1957–1970)', 'veh_classic_br_pontiac', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_pontiac_catalina_1950_1981', 'Catalina (1950–1981)', 'veh_classic_br_pontiac', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce', 'Rolls-Royce', 'veh_classic', 'brand', 12, 'https://upload.wikimedia.org/wikipedia/commons/5/5b/Rolls-Royce_Motor_Cars_logo.svg', '#2C2C2C');
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_silver_shadow_1965_1980', 'Silver Shadow (1965–1980)', 'veh_classic_br_rolls_royce', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_silver_ghost_1906_1926', 'Silver Ghost (1906–1926)', 'veh_classic_br_rolls_royce', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_silver_cloud_1955_1966', 'Silver Cloud (1955–1966)', 'veh_classic_br_rolls_royce', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_corniche_1971_1996', 'Corniche (1971–1996)', 'veh_classic_br_rolls_royce', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_camargue_1975_1986', 'Camargue (1975–1986)', 'veh_classic_br_rolls_royce', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_rolls_royce_silver_spirit_1980_1998', 'Silver Spirit (1980–1998)', 'veh_classic_br_rolls_royce', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover', 'Land Rover', 'veh_classic', 'brand', 13, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/land-rover.svg', '#005A2B');
SELECT public._seed_classic_node('veh_classic_br_land_rover_series_i_1948_1958', 'Series I (1948–1958)', 'veh_classic_br_land_rover', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover_series_ii_1958_1971', 'Series II (1958–1971)', 'veh_classic_br_land_rover', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover_series_iii_1971_1985', 'Series III (1971–1985)', 'veh_classic_br_land_rover', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover_range_rover_classic_1970_1996', 'Range Rover Classic (1970–1996)', 'veh_classic_br_land_rover', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover_defender_90_1983_2016', 'Defender 90 (1983–2016)', 'veh_classic_br_land_rover', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_land_rover_defender_110_1983_2016', 'Defender 110 (1983–2016)', 'veh_classic_br_land_rover', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_cadillac', 'Cadillac', 'veh_classic', 'brand', 14, 'https://upload.wikimedia.org/wikipedia/commons/2/22/Cadillac_logo.svg', '#2C2C2C');
SELECT public._seed_classic_node('veh_classic_br_cadillac_eldorado_1953_1978', 'Eldorado (1953–1978)', 'veh_classic_br_cadillac', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_cadillac_deville_1959_1977', 'DeVille (1959–1977)', 'veh_classic_br_cadillac', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_cadillac_fleetwood_1955_1996', 'Fleetwood (1955–1996)', 'veh_classic_br_cadillac', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_cadillac_seville_1975_1985', 'Seville (1975–1985)', 'veh_classic_br_cadillac', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_cadillac_series_62_1940_1964', 'Series 62 (1940–1964)', 'veh_classic_br_cadillac', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo', 'Alfa Romeo', 'veh_classic', 'brand', 15, 'https://upload.wikimedia.org/wikipedia/commons/b/b8/Alfa_Romeo_Logo.svg', '#CC0000');
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_spider_duetto_1966_1993', 'Spider Duetto (1966–1993)', 'veh_classic_br_alfa_romeo', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_gtv_1963_1977', 'GTV (1963–1977)', 'veh_classic_br_alfa_romeo', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_montreal_1970_1977', 'Montreal (1970–1977)', 'veh_classic_br_alfa_romeo', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_giulia_sprint_1963_1978', 'Giulia Sprint (1963–1978)', 'veh_classic_br_alfa_romeo', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_alfetta_1972_1987', 'Alfetta (1972–1987)', 'veh_classic_br_alfa_romeo', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_33_1983_1995', '33 (1983–1995)', 'veh_classic_br_alfa_romeo', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_alfa_romeo_75_milano_1985_1992', '75 / Milano (1985–1992)', 'veh_classic_br_alfa_romeo', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari', 'Ferrari', 'veh_classic', 'brand', 16, 'https://upload.wikimedia.org/wikipedia/commons/d/d1/Ferrari-Logo.svg', '#CC0000');
SELECT public._seed_classic_node('veh_classic_br_ferrari_250_gto_1962_1964', '250 GTO (1962–1964)', 'veh_classic_br_ferrari', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_275_gtb_1964_1968', '275 GTB (1964–1968)', 'veh_classic_br_ferrari', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_308_gtb_gts_1975_1985', '308 GTB/GTS (1975–1985)', 'veh_classic_br_ferrari', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_328_gtb_gts_1985_1989', '328 GTB/GTS (1985–1989)', 'veh_classic_br_ferrari', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_348_1989_1995', '348 (1989–1995)', 'veh_classic_br_ferrari', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_testarossa_1984_1991', 'Testarossa (1984–1991)', 'veh_classic_br_ferrari', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_dino_246_1969_1974', 'Dino 246 (1969–1974)', 'veh_classic_br_ferrari', 'model', 7, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_ferrari_365_gtb_4_daytona_1968_1973', '365 GTB/4 Daytona (1968–1973)', 'veh_classic_br_ferrari', 'model', 8, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi', 'Audi', 'veh_classic', 'brand', 17, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/audi.svg', '#BB0A30');
SELECT public._seed_classic_node('veh_classic_br_audi_audi_quattro_1980_1991', 'Audi Quattro (1980–1991)', 'veh_classic_br_audi', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi_audi_80_b1_1972_1978', 'Audi 80 B1 (1972–1978)', 'veh_classic_br_audi', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi_audi_100_c1_1968_1976', 'Audi 100 C1 (1968–1976)', 'veh_classic_br_audi', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi_audi_100_c2_1976_1982', 'Audi 100 C2 (1976–1982)', 'veh_classic_br_audi', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi_audi_coupe_gt_1980_1988', 'Audi Coupe GT (1980–1988)', 'veh_classic_br_audi', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_audi_nsu_ro_80_1967_1977', 'NSU Ro 80 (1967–1977)', 'veh_classic_br_audi', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_oldsmobile', 'Oldsmobile', 'veh_classic', 'brand', 18, 'https://www.carlogos.org/car-logos/oldsmobile-logo.png', '#CC0000');
SELECT public._seed_classic_node('veh_classic_br_oldsmobile_442_1964_1980', '442 (1964–1980)', 'veh_classic_br_oldsmobile', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_oldsmobile_toronado_1966_1992', 'Toronado (1966–1992)', 'veh_classic_br_oldsmobile', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_oldsmobile_cutlass_supreme_1966_1988', 'Cutlass Supreme (1966–1988)', 'veh_classic_br_oldsmobile', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_oldsmobile_delta_88_1965_1985', 'Delta 88 (1965–1985)', 'veh_classic_br_oldsmobile', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_oldsmobile_ninety_eight_1941_1996', 'Ninety-Eight (1941–1996)', 'veh_classic_br_oldsmobile', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel', 'Opel', 'veh_classic', 'brand', 19, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/opel.svg', '#FFD700');
SELECT public._seed_classic_node('veh_classic_br_opel_rekord_1953_1986', 'Rekord (1953–1986)', 'veh_classic_br_opel', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel_kadett_b_1965_1973', 'Kadett B (1965–1973)', 'veh_classic_br_opel', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel_manta_a_1970_1975', 'Manta A (1970–1975)', 'veh_classic_br_opel', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel_gt_1968_1973', 'GT (1968–1973)', 'veh_classic_br_opel', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel_commodore_1967_1982', 'Commodore (1967–1982)', 'veh_classic_br_opel', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_opel_senator_a_1978_1987', 'Senator A (1978–1987)', 'veh_classic_br_opel', 'model', 6, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln', 'Lincoln', 'veh_classic', 'brand', 20, 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Lincoln_Motor_Company_logo.svg', '#2C2C2C');
SELECT public._seed_classic_node('veh_classic_br_lincoln_continental_1961_1969', 'Continental (1961–1969)', 'veh_classic_br_lincoln', 'model', 1, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln_mark_iii_1969_1971', 'Mark III (1969–1971)', 'veh_classic_br_lincoln', 'model', 2, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln_mark_iv_1972_1976', 'Mark IV (1972–1976)', 'veh_classic_br_lincoln', 'model', 3, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln_mark_v_1977_1979', 'Mark V (1977–1979)', 'veh_classic_br_lincoln', 'model', 4, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln_capri_1952_1959', 'Capri (1952–1959)', 'veh_classic_br_lincoln', 'model', 5, NULL, NULL);
SELECT public._seed_classic_node('veh_classic_br_lincoln_town_car_1981_1997', 'Town Car (1981–1997)', 'veh_classic_br_lincoln', 'model', 6, NULL, NULL);

DROP FUNCTION public._seed_classic_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

