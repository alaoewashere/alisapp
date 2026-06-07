-- الإلكترونيات — additional subcategories (append-only, no delete).

CREATE OR REPLACE FUNCTION public._seed_elec_node(
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

SELECT public._seed_elec_node('elec_appliances', 'أجهزة المنزل الكهربائية', 'electronics', 'category', 13, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_appliances_br_samsung', 'Samsung', 'elec_appliances', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-samsung.svg', '#1428A0');
SELECT public._seed_elec_node('elec_appliances_br_samsung_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_samsung_fridge', 'ثلاجة', 'elec_appliances_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_samsung_dishwasher', 'غسالة صحون', 'elec_appliances_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_samsung_microwave', 'ميكروويف', 'elec_appliances_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_samsung_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_samsung', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_samsung_air_fryer', 'Air Fryer', 'elec_appliances_br_samsung', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg', 'LG', 'elec_appliances', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-lg.svg', '#A50034');
SELECT public._seed_elec_node('elec_appliances_br_lg_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_lg', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg_fridge', 'ثلاجة', 'elec_appliances_br_lg', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg_dishwasher', 'غسالة صحون', 'elec_appliances_br_lg', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg_microwave', 'ميكروويف', 'elec_appliances_br_lg', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_lg', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_lg_air_fryer', 'Air Fryer', 'elec_appliances_br_lg', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch', 'Bosch', 'elec_appliances', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-bosch.svg', '#EA0016');
SELECT public._seed_elec_node('elec_appliances_br_bosch_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_bosch', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch_fridge', 'ثلاجة', 'elec_appliances_br_bosch', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch_dishwasher', 'غسالة صحون', 'elec_appliances_br_bosch', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch_microwave', 'ميكروويف', 'elec_appliances_br_bosch', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_bosch', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_bosch_air_fryer', 'Air Fryer', 'elec_appliances_br_bosch', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens', 'Siemens', 'elec_appliances', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-siemens.svg', '#009999');
SELECT public._seed_elec_node('elec_appliances_br_siemens_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_siemens', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens_fridge', 'ثلاجة', 'elec_appliances_br_siemens', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens_dishwasher', 'غسالة صحون', 'elec_appliances_br_siemens', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens_microwave', 'ميكروويف', 'elec_appliances_br_siemens', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_siemens', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_siemens_air_fryer', 'Air Fryer', 'elec_appliances_br_siemens', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux', 'Electrolux', 'elec_appliances', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-electrolux.svg', '#041E42');
SELECT public._seed_elec_node('elec_appliances_br_electrolux_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_electrolux', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux_fridge', 'ثلاجة', 'elec_appliances_br_electrolux', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux_dishwasher', 'غسالة صحون', 'elec_appliances_br_electrolux', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux_microwave', 'ميكروويف', 'elec_appliances_br_electrolux', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_electrolux', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_electrolux_air_fryer', 'Air Fryer', 'elec_appliances_br_electrolux', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool', 'Whirlpool', 'elec_appliances', 'brand', 6, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-whirlpool.svg', '#FFB600');
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_whirlpool', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_fridge', 'ثلاجة', 'elec_appliances_br_whirlpool', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_dishwasher', 'غسالة صحون', 'elec_appliances_br_whirlpool', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_microwave', 'ميكروويف', 'elec_appliances_br_whirlpool', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_whirlpool', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_whirlpool_air_fryer', 'Air Fryer', 'elec_appliances_br_whirlpool', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier', 'Haier', 'elec_appliances', 'brand', 7, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-haier.svg', '#005AAA');
SELECT public._seed_elec_node('elec_appliances_br_haier_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_haier', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier_fridge', 'ثلاجة', 'elec_appliances_br_haier', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier_dishwasher', 'غسالة صحون', 'elec_appliances_br_haier', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier_microwave', 'ميكروويف', 'elec_appliances_br_haier', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_haier', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_haier_air_fryer', 'Air Fryer', 'elec_appliances_br_haier', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea', 'Midea', 'elec_appliances', 'brand', 8, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-midea.svg', '#0092DF');
SELECT public._seed_elec_node('elec_appliances_br_midea_washing_machine', 'غسالة أوتوماتيك', 'elec_appliances_br_midea', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea_fridge', 'ثلاجة', 'elec_appliances_br_midea', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea_dishwasher', 'غسالة صحون', 'elec_appliances_br_midea', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea_microwave', 'ميكروويف', 'elec_appliances_br_midea', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea_vacuum', 'مكنسة كهربائية', 'elec_appliances_br_midea', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_appliances_br_midea_air_fryer', 'Air Fryer', 'elec_appliances_br_midea', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac', 'مكيفات', 'electronics', 'category', 14, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_ac_br_gree', 'Gree', 'elec_ac', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-gree.svg', '#009944');
SELECT public._seed_elec_node('elec_ac_br_gree_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_gree', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_gree', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_gree', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_gree', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_cassette', 'كاسيت', 'elec_ac_br_gree', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_ceiling', 'سقفي', 'elec_ac_br_gree', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_portable', 'Portable', 'elec_ac_br_gree', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_gree_window', 'Window', 'elec_ac_br_gree', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier', 'Carrier', 'elec_ac', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-carrier.svg', '#0066B3');
SELECT public._seed_elec_node('elec_ac_br_carrier_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_carrier', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_carrier', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_carrier', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_carrier', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_cassette', 'كاسيت', 'elec_ac_br_carrier', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_ceiling', 'سقفي', 'elec_ac_br_carrier', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_portable', 'Portable', 'elec_ac_br_carrier', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_carrier_window', 'Window', 'elec_ac_br_carrier', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg', 'LG', 'elec_ac', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-lg.svg', '#A50034');
SELECT public._seed_elec_node('elec_ac_br_lg_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_lg', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_lg', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_lg', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_lg', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_cassette', 'كاسيت', 'elec_ac_br_lg', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_ceiling', 'سقفي', 'elec_ac_br_lg', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_portable', 'Portable', 'elec_ac_br_lg', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_lg_window', 'Window', 'elec_ac_br_lg', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung', 'Samsung', 'elec_ac', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-samsung.svg', '#1428A0');
SELECT public._seed_elec_node('elec_ac_br_samsung_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_cassette', 'كاسيت', 'elec_ac_br_samsung', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_ceiling', 'سقفي', 'elec_ac_br_samsung', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_portable', 'Portable', 'elec_ac_br_samsung', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_samsung_window', 'Window', 'elec_ac_br_samsung', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea', 'Midea', 'elec_ac', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-midea.svg', '#0092DF');
SELECT public._seed_elec_node('elec_ac_br_midea_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_midea', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_midea', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_midea', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_midea', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_cassette', 'كاسيت', 'elec_ac_br_midea', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_ceiling', 'سقفي', 'elec_ac_br_midea', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_portable', 'Portable', 'elec_ac_br_midea', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_midea_window', 'Window', 'elec_ac_br_midea', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier', 'Haier', 'elec_ac', 'brand', 6, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-haier.svg', '#005AAA');
SELECT public._seed_elec_node('elec_ac_br_haier_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_haier', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_haier', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_haier', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_haier', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_cassette', 'كاسيت', 'elec_ac_br_haier', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_ceiling', 'سقفي', 'elec_ac_br_haier', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_portable', 'Portable', 'elec_ac_br_haier', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_haier_window', 'Window', 'elec_ac_br_haier', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin', 'Daikin', 'elec_ac', 'brand', 7, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-daikin.svg', '#0097DB');
SELECT public._seed_elec_node('elec_ac_br_daikin_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_daikin', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_daikin', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_daikin', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_daikin', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_cassette', 'كاسيت', 'elec_ac_br_daikin', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_ceiling', 'سقفي', 'elec_ac_br_daikin', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_portable', 'Portable', 'elec_ac_br_daikin', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_daikin_window', 'Window', 'elec_ac_br_daikin', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba', 'Toshiba', 'elec_ac', 'brand', 8, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-toshiba.svg', '#FF0000');
SELECT public._seed_elec_node('elec_ac_br_toshiba_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_toshiba', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_toshiba', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_toshiba', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_toshiba', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_cassette', 'كاسيت', 'elec_ac_br_toshiba', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_ceiling', 'سقفي', 'elec_ac_br_toshiba', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_portable', 'Portable', 'elec_ac_br_toshiba', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_toshiba_window', 'Window', 'elec_ac_br_toshiba', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi', 'Hitachi', 'elec_ac', 'brand', 9, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-hitachi.svg', '#E60027');
SELECT public._seed_elec_node('elec_ac_br_hitachi_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_hitachi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_hitachi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_hitachi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_hitachi', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_cassette', 'كاسيت', 'elec_ac_br_hitachi', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_ceiling', 'سقفي', 'elec_ac_br_hitachi', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_portable', 'Portable', 'elec_ac_br_hitachi', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_hitachi_window', 'Window', 'elec_ac_br_hitachi', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic', 'Panasonic', 'elec_ac', 'brand', 10, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-panasonic.svg', '#004098');
SELECT public._seed_elec_node('elec_ac_br_panasonic_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_panasonic', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_panasonic', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_panasonic', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_panasonic', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_cassette', 'كاسيت', 'elec_ac_br_panasonic', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_ceiling', 'سقفي', 'elec_ac_br_panasonic', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_portable', 'Portable', 'elec_ac_br_panasonic', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_panasonic_window', 'Window', 'elec_ac_br_panasonic', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york', 'York', 'elec_ac', 'brand', 11, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-york.svg', '#0033A0');
SELECT public._seed_elec_node('elec_ac_br_york_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_york', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_york', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_york', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_york', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_cassette', 'كاسيت', 'elec_ac_br_york', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_ceiling', 'سقفي', 'elec_ac_br_york', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_portable', 'Portable', 'elec_ac_br_york', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_york_window', 'Window', 'elec_ac_br_york', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo', 'Chigo', 'elec_ac', 'brand', 12, NULL, '#E31937');
SELECT public._seed_elec_node('elec_ac_br_chigo_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_chigo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_chigo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_chigo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_chigo', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_cassette', 'كاسيت', 'elec_ac_br_chigo', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_ceiling', 'سقفي', 'elec_ac_br_chigo', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_portable', 'Portable', 'elec_ac_br_chigo', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_chigo_window', 'Window', 'elec_ac_br_chigo', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool', 'KOOL', 'elec_ac', 'brand', 13, NULL, '#009FE3');
SELECT public._seed_elec_node('elec_ac_br_kool_split_1_5hp', 'سبليت 1.5 حصان', 'elec_ac_br_kool', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_split_2hp', 'سبليت 2 حصان', 'elec_ac_br_kool', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_split_2_5hp', 'سبليت 2.5 حصان', 'elec_ac_br_kool', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_split_3hp', 'سبليت 3 حصان', 'elec_ac_br_kool', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_cassette', 'كاسيت', 'elec_ac_br_kool', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_ceiling', 'سقفي', 'elec_ac_br_kool', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_portable', 'Portable', 'elec_ac_br_kool', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_ac_br_kool_window', 'Window', 'elec_ac_br_kool', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops', 'كمبيوتر مكتبي', 'electronics', 'category', 15, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_desktops_br_apple', 'Apple', 'elec_desktops', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-apple.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_desktops_br_apple_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_apple_workstation', 'Workstation', 'elec_desktops_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_apple_all_in_one', 'All-in-One', 'elec_desktops_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_apple_mini_pc', 'Mini PC', 'elec_desktops_br_apple', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_dell', 'Dell', 'elec_desktops', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-dell.svg', '#007DB8');
SELECT public._seed_elec_node('elec_desktops_br_dell_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_dell', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_dell_workstation', 'Workstation', 'elec_desktops_br_dell', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_dell_all_in_one', 'All-in-One', 'elec_desktops_br_dell', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_dell_mini_pc', 'Mini PC', 'elec_desktops_br_dell', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_hp', 'HP', 'elec_desktops', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-hp.svg', '#0096D6');
SELECT public._seed_elec_node('elec_desktops_br_hp_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_hp', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_hp_workstation', 'Workstation', 'elec_desktops_br_hp', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_hp_all_in_one', 'All-in-One', 'elec_desktops_br_hp', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_hp_mini_pc', 'Mini PC', 'elec_desktops_br_hp', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_lenovo', 'Lenovo', 'elec_desktops', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-lenovo.svg', '#E2231A');
SELECT public._seed_elec_node('elec_desktops_br_lenovo_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_lenovo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_lenovo_workstation', 'Workstation', 'elec_desktops_br_lenovo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_lenovo_all_in_one', 'All-in-One', 'elec_desktops_br_lenovo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_lenovo_mini_pc', 'Mini PC', 'elec_desktops_br_lenovo', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_asus', 'Asus', 'elec_desktops', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-asus.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_desktops_br_asus_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_asus', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_asus_workstation', 'Workstation', 'elec_desktops_br_asus', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_asus_all_in_one', 'All-in-One', 'elec_desktops_br_asus', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_asus_mini_pc', 'Mini PC', 'elec_desktops_br_asus', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_custom_build', 'تجميع', 'elec_desktops', 'brand', 6, NULL, '#757575');
SELECT public._seed_elec_node('elec_desktops_br_custom_build_gaming_desktop', 'Gaming Desktop', 'elec_desktops_br_custom_build', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_custom_build_workstation', 'Workstation', 'elec_desktops_br_custom_build', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_custom_build_all_in_one', 'All-in-One', 'elec_desktops_br_custom_build', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_desktops_br_custom_build_mini_pc', 'Mini PC', 'elec_desktops_br_custom_build', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_drones', 'درون وطائرات مسيّرة', 'electronics', 'category', 16, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_drones_br_dji', 'DJI', 'elec_drones', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-dji.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_drones_br_dji_dji_mini_4_pro', 'DJI Mini 4 Pro', 'elec_drones_br_dji', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_dji_dji_air_3', 'DJI Air 3', 'elec_drones_br_dji', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_dji_dji_mavic_3_pro', 'DJI Mavic 3 Pro', 'elec_drones_br_dji', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_dji_dji_agras', 'DJI Agras', 'elec_drones_br_dji', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_dji_fpv_drone', 'FPV Drone', 'elec_drones_br_dji', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_autel', 'Autel', 'elec_drones', 'brand', 2, NULL, '#E31937');
SELECT public._seed_elec_node('elec_drones_br_autel_evo_lite_plus', 'EVO Lite+', 'elec_drones_br_autel', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_autel_evo_max_4t', 'EVO Max 4T', 'elec_drones_br_autel', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_autel_dragonfish', 'Dragonfish', 'elec_drones_br_autel', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_autel_fpv_drone', 'FPV Drone', 'elec_drones_br_autel', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_holy_stone', 'Holy Stone', 'elec_drones', 'brand', 3, NULL, '#FF6900');
SELECT public._seed_elec_node('elec_drones_br_holy_stone_hs720e', 'HS720E', 'elec_drones_br_holy_stone', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_holy_stone_hs600', 'HS600', 'elec_drones_br_holy_stone', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_holy_stone_hs175d', 'HS175D', 'elec_drones_br_holy_stone', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_holy_stone_fpv_drone', 'FPV Drone', 'elec_drones_br_holy_stone', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_parrot', 'Parrot', 'elec_drones', 'brand', 4, NULL, '#0082C3');
SELECT public._seed_elec_node('elec_drones_br_parrot_anafi', 'Anafi', 'elec_drones_br_parrot', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_parrot_anafi_ai', 'ANAFI AI', 'elec_drones_br_parrot', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_parrot_anafi_usa', 'Anafi USA', 'elec_drones_br_parrot', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_drones_br_parrot_fpv_drone', 'FPV Drone', 'elec_drones_br_parrot', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors', 'بروجيكتور وشاشة عرض', 'electronics', 'category', 17, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_projectors_br_epson', 'Epson', 'elec_projectors', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-epson.svg', '#003087');
SELECT public._seed_elec_node('elec_projectors_br_epson_home_theater', 'Home Theater', 'elec_projectors_br_epson', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_epson_portable', 'Portable', 'elec_projectors_br_epson', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_epson_business_projector', 'Business Projector', 'elec_projectors_br_epson', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_benq', 'BenQ', 'elec_projectors', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-benq.svg', '#6B2C91');
SELECT public._seed_elec_node('elec_projectors_br_benq_home_theater', 'Home Theater', 'elec_projectors_br_benq', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_benq_portable', 'Portable', 'elec_projectors_br_benq', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_benq_business_projector', 'Business Projector', 'elec_projectors_br_benq', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_optoma', 'Optoma', 'elec_projectors', 'brand', 3, NULL, '#E31937');
SELECT public._seed_elec_node('elec_projectors_br_optoma_home_theater', 'Home Theater', 'elec_projectors_br_optoma', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_optoma_portable', 'Portable', 'elec_projectors_br_optoma', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_optoma_business_projector', 'Business Projector', 'elec_projectors_br_optoma', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_lg', 'LG', 'elec_projectors', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-lg.svg', '#A50034');
SELECT public._seed_elec_node('elec_projectors_br_lg_home_theater', 'Home Theater', 'elec_projectors_br_lg', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_lg_portable', 'Portable', 'elec_projectors_br_lg', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_lg_business_projector', 'Business Projector', 'elec_projectors_br_lg', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_samsung', 'Samsung', 'elec_projectors', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-samsung.svg', '#1428A0');
SELECT public._seed_elec_node('elec_projectors_br_samsung_home_theater', 'Home Theater', 'elec_projectors_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_samsung_portable', 'Portable', 'elec_projectors_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_samsung_business_projector', 'Business Projector', 'elec_projectors_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_xiaomi', 'Xiaomi', 'elec_projectors', 'brand', 6, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-xiaomi.svg', '#FF6900');
SELECT public._seed_elec_node('elec_projectors_br_xiaomi_home_theater', 'Home Theater', 'elec_projectors_br_xiaomi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_xiaomi_portable', 'Portable', 'elec_projectors_br_xiaomi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_xiaomi_business_projector', 'Business Projector', 'elec_projectors_br_xiaomi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_viewsonic', 'ViewSonic', 'elec_projectors', 'brand', 7, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/elec-viewsonic.svg', '#0082C3');
SELECT public._seed_elec_node('elec_projectors_br_viewsonic_home_theater', 'Home Theater', 'elec_projectors_br_viewsonic', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_viewsonic_portable', 'Portable', 'elec_projectors_br_viewsonic', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_projectors_br_viewsonic_business_projector', 'Business Projector', 'elec_projectors_br_viewsonic', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_medical', 'أجهزة طبية منزلية', 'electronics', 'category', 18, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_medical_bp_monitor', 'جهاز ضغط الدم', 'elec_medical', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_medical_glucose_meter', 'جهاز قياس السكر', 'elec_medical', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_medical_nebulizer', 'جهاز تنفس', 'elec_medical', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_medical_massager', 'جهاز تدليك', 'elec_medical', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_medical_baby_nebulizer', 'جهاز بخار للأطفال', 'elec_medical', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_medical_digital_thermometer', 'جهاز قياس الحرارة الرقمي', 'elec_medical', 'model', 6, NULL, NULL);

DROP FUNCTION public._seed_elec_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

