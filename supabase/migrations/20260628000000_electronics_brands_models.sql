-- الإلكترونيات (electronics) — subcategories → brand → model
-- Safe to re-run: cleans electronics subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

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

DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'electronics')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_elec_node('elec_smartphones', 'هواتف ذكية', 'electronics', 'category', 1, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_smartphones_br_apple', 'Apple', 'elec_smartphones', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_16_pro_max', 'iPhone 16 Pro Max', 'elec_smartphones_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_16_pro', 'iPhone 16 Pro', 'elec_smartphones_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_16_plus', 'iPhone 16 Plus', 'elec_smartphones_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_16', 'iPhone 16', 'elec_smartphones_br_apple', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_15_pro_max', 'iPhone 15 Pro Max', 'elec_smartphones_br_apple', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_15_pro', 'iPhone 15 Pro', 'elec_smartphones_br_apple', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_15_plus', 'iPhone 15 Plus', 'elec_smartphones_br_apple', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_15', 'iPhone 15', 'elec_smartphones_br_apple', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_14_pro_max', 'iPhone 14 Pro Max', 'elec_smartphones_br_apple', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_14_pro', 'iPhone 14 Pro', 'elec_smartphones_br_apple', 'model', 10, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_14_plus', 'iPhone 14 Plus', 'elec_smartphones_br_apple', 'model', 11, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_14', 'iPhone 14', 'elec_smartphones_br_apple', 'model', 12, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_13_pro_max', 'iPhone 13 Pro Max', 'elec_smartphones_br_apple', 'model', 13, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_13', 'iPhone 13', 'elec_smartphones_br_apple', 'model', 14, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_12', 'iPhone 12', 'elec_smartphones_br_apple', 'model', 15, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_11', 'iPhone 11', 'elec_smartphones_br_apple', 'model', 16, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_xs_max', 'iPhone XS Max', 'elec_smartphones_br_apple', 'model', 17, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_apple_iphone_xr', 'iPhone XR', 'elec_smartphones_br_apple', 'model', 18, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung', 'Samsung', 'elec_smartphones', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', '#1428A0');
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s25_ultra', 'Galaxy S25 Ultra', 'elec_smartphones_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s25_plus', 'Galaxy S25+', 'elec_smartphones_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s25', 'Galaxy S25', 'elec_smartphones_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s24_ultra', 'Galaxy S24 Ultra', 'elec_smartphones_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s24_plus', 'Galaxy S24+', 'elec_smartphones_br_samsung', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_s24', 'Galaxy S24', 'elec_smartphones_br_samsung', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_z_fold_6', 'Galaxy Z Fold 6', 'elec_smartphones_br_samsung', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_z_flip_6', 'Galaxy Z Flip 6', 'elec_smartphones_br_samsung', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_a55', 'Galaxy A55', 'elec_smartphones_br_samsung', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_a35', 'Galaxy A35', 'elec_smartphones_br_samsung', 'model', 10, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_a15', 'Galaxy A15', 'elec_smartphones_br_samsung', 'model', 11, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_a05', 'Galaxy A05', 'elec_smartphones_br_samsung', 'model', 12, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_m55', 'Galaxy M55', 'elec_smartphones_br_samsung', 'model', 13, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_samsung_galaxy_f55', 'Galaxy F55', 'elec_smartphones_br_samsung', 'model', 14, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei', 'Huawei', 'elec_smartphones', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Huawei_logo.svg', '#CF0A2C');
SELECT public._seed_elec_node('elec_smartphones_br_huawei_pura_70_ultra', 'Pura 70 Ultra', 'elec_smartphones_br_huawei', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_pura_70_pro', 'Pura 70 Pro', 'elec_smartphones_br_huawei', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_mate_60_pro', 'Mate 60 Pro', 'elec_smartphones_br_huawei', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_mate_60', 'Mate 60', 'elec_smartphones_br_huawei', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_nova_12_pro', 'Nova 12 Pro', 'elec_smartphones_br_huawei', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_nova_12', 'Nova 12', 'elec_smartphones_br_huawei', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_y9s', 'Y9s', 'elec_smartphones_br_huawei', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_huawei_y7a', 'Y7a', 'elec_smartphones_br_huawei', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi', 'Xiaomi', 'elec_smartphones', 'brand', 4, 'https://upload.wikimedia.org/wikipedia/commons/2/29/Xiaomi_logo.svg', '#FF6900');
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_xiaomi_14_ultra', 'Xiaomi 14 Ultra', 'elec_smartphones_br_xiaomi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_xiaomi_14_pro', 'Xiaomi 14 Pro', 'elec_smartphones_br_xiaomi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_xiaomi_14', 'Xiaomi 14', 'elec_smartphones_br_xiaomi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_redmi_note_13_pro_plus', 'Redmi Note 13 Pro+', 'elec_smartphones_br_xiaomi', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_redmi_note_13_pro', 'Redmi Note 13 Pro', 'elec_smartphones_br_xiaomi', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_redmi_note_13', 'Redmi Note 13', 'elec_smartphones_br_xiaomi', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_redmi_13c', 'Redmi 13C', 'elec_smartphones_br_xiaomi', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_poco_x6_pro', 'POCO X6 Pro', 'elec_smartphones_br_xiaomi', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_poco_m6_pro', 'POCO M6 Pro', 'elec_smartphones_br_xiaomi', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_xiaomi_mi_11', 'Mi 11', 'elec_smartphones_br_xiaomi', 'model', 10, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo', 'Oppo', 'elec_smartphones', 'brand', 5, NULL, '#1D8348');
SELECT public._seed_elec_node('elec_smartphones_br_oppo_find_x7_ultra', 'Find X7 Ultra', 'elec_smartphones_br_oppo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo_reno_12_pro', 'Reno 12 Pro', 'elec_smartphones_br_oppo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo_reno_12', 'Reno 12', 'elec_smartphones_br_oppo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo_a3_pro', 'A3 Pro', 'elec_smartphones_br_oppo', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo_a78', 'A78', 'elec_smartphones_br_oppo', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oppo_a58', 'A58', 'elec_smartphones_br_oppo', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo', 'Vivo', 'elec_smartphones', 'brand', 6, NULL, '#415FFF');
SELECT public._seed_elec_node('elec_smartphones_br_vivo_x100_ultra', 'X100 Ultra', 'elec_smartphones_br_vivo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo_x100_pro', 'X100 Pro', 'elec_smartphones_br_vivo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo_v30_pro', 'V30 Pro', 'elec_smartphones_br_vivo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo_v30', 'V30', 'elec_smartphones_br_vivo', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo_y200', 'Y200', 'elec_smartphones_br_vivo', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_vivo_y100', 'Y100', 'elec_smartphones_br_vivo', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oneplus', 'OnePlus', 'elec_smartphones', 'brand', 7, NULL, '#F5010C');
SELECT public._seed_elec_node('elec_smartphones_br_oneplus_oneplus_12', 'OnePlus 12', 'elec_smartphones_br_oneplus', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oneplus_oneplus_12r', 'OnePlus 12R', 'elec_smartphones_br_oneplus', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oneplus_oneplus_nord_4', 'OnePlus Nord 4', 'elec_smartphones_br_oneplus', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_oneplus_oneplus_nord_ce4', 'OnePlus Nord CE4', 'elec_smartphones_br_oneplus', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_tecno', 'Tecno', 'elec_smartphones', 'brand', 8, NULL, '#0095DA');
SELECT public._seed_elec_node('elec_smartphones_br_tecno_camon_30_pro', 'Camon 30 Pro', 'elec_smartphones_br_tecno', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_tecno_spark_20_pro', 'Spark 20 Pro', 'elec_smartphones_br_tecno', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_tecno_phantom_v_fold', 'Phantom V Fold', 'elec_smartphones_br_tecno', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_tecno_pop_8', 'Pop 8', 'elec_smartphones_br_tecno', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_infinix', 'Infinix', 'elec_smartphones', 'brand', 9, NULL, '#FF0000');
SELECT public._seed_elec_node('elec_smartphones_br_infinix_note_40_pro', 'Note 40 Pro', 'elec_smartphones_br_infinix', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_infinix_hot_40_pro', 'Hot 40 Pro', 'elec_smartphones_br_infinix', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_infinix_smart_8_plus', 'Smart 8 Plus', 'elec_smartphones_br_infinix', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smartphones_br_infinix_zero_30', 'Zero 30', 'elec_smartphones_br_infinix', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets', 'أجهزة لوحية', 'electronics', 'category', 2, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_tablets_br_apple', 'Apple', 'elec_tablets', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_pro_13in_m4', 'iPad Pro 13" M4', 'elec_tablets_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_pro_11in_m4', 'iPad Pro 11" M4', 'elec_tablets_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_air_13in_m2', 'iPad Air 13" M2', 'elec_tablets_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_air_11in_m2', 'iPad Air 11" M2', 'elec_tablets_br_apple', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_10th_gen', 'iPad 10th Gen', 'elec_tablets_br_apple', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_apple_ipad_mini_7', 'iPad mini 7', 'elec_tablets_br_apple', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_samsung', 'Samsung', 'elec_tablets', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', '#1428A0');
SELECT public._seed_elec_node('elec_tablets_br_samsung_galaxy_tab_s9_ultra', 'Galaxy Tab S9 Ultra', 'elec_tablets_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_samsung_galaxy_tab_s9_plus', 'Galaxy Tab S9+', 'elec_tablets_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_samsung_galaxy_tab_s9', 'Galaxy Tab S9', 'elec_tablets_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_samsung_galaxy_tab_a9_plus', 'Galaxy Tab A9+', 'elec_tablets_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_samsung_galaxy_tab_a9', 'Galaxy Tab A9', 'elec_tablets_br_samsung', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_huawei', 'Huawei', 'elec_tablets', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Huawei_logo.svg', '#CF0A2C');
SELECT public._seed_elec_node('elec_tablets_br_huawei_matepad_pro_13_2in', 'MatePad Pro 13.2"', 'elec_tablets_br_huawei', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_huawei_matepad_11_5in', 'MatePad 11.5"', 'elec_tablets_br_huawei', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_huawei_matepad_se', 'MatePad SE', 'elec_tablets_br_huawei', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_xiaomi', 'Xiaomi', 'elec_tablets', 'brand', 4, 'https://upload.wikimedia.org/wikipedia/commons/2/29/Xiaomi_logo.svg', '#FF6900');
SELECT public._seed_elec_node('elec_tablets_br_xiaomi_pad_6_pro', 'Pad 6 Pro', 'elec_tablets_br_xiaomi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_xiaomi_pad_6', 'Pad 6', 'elec_tablets_br_xiaomi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_xiaomi_redmi_pad_pro', 'Redmi Pad Pro', 'elec_tablets_br_xiaomi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_tablets_br_xiaomi_redmi_pad_se', 'Redmi Pad SE', 'elec_tablets_br_xiaomi', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops', 'لابتوب وكمبيوتر', 'electronics', 'category', 3, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_laptops_br_apple', 'Apple', 'elec_laptops', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_laptops_br_apple_macbook_pro_16in_m4', 'MacBook Pro 16" M4', 'elec_laptops_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_macbook_pro_14in_m4', 'MacBook Pro 14" M4', 'elec_laptops_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_macbook_air_15in_m3', 'MacBook Air 15" M3', 'elec_laptops_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_macbook_air_13in_m3', 'MacBook Air 13" M3', 'elec_laptops_br_apple', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_imac_24in_m3', 'iMac 24" M3', 'elec_laptops_br_apple', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_mac_mini_m4', 'Mac mini M4', 'elec_laptops_br_apple', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_mac_studio_m3_ultra', 'Mac Studio M3 Ultra', 'elec_laptops_br_apple', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_apple_mac_pro_m2_ultra', 'Mac Pro M2 Ultra', 'elec_laptops_br_apple', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell', 'Dell', 'elec_laptops', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/4/48/Dell_Logo.svg', '#007DB8');
SELECT public._seed_elec_node('elec_laptops_br_dell_xps_15', 'XPS 15', 'elec_laptops_br_dell', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_xps_13', 'XPS 13', 'elec_laptops_br_dell', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_inspiron_15', 'Inspiron 15', 'elec_laptops_br_dell', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_inspiron_14', 'Inspiron 14', 'elec_laptops_br_dell', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_g15_gaming', 'G15 Gaming', 'elec_laptops_br_dell', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_g16_gaming', 'G16 Gaming', 'elec_laptops_br_dell', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_alienware_m16', 'Alienware m16', 'elec_laptops_br_dell', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_vostro_15', 'Vostro 15', 'elec_laptops_br_dell', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_dell_latitude_5540', 'Latitude 5540', 'elec_laptops_br_dell', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp', 'HP', 'elec_laptops', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/a/ad/HP_logo_2012.svg', '#0096D6');
SELECT public._seed_elec_node('elec_laptops_br_hp_spectre_x360_14', 'Spectre x360 14', 'elec_laptops_br_hp', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_envy_x360_15', 'Envy x360 15', 'elec_laptops_br_hp', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_pavilion_15', 'Pavilion 15', 'elec_laptops_br_hp', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_victus_16_gaming', 'Victus 16 Gaming', 'elec_laptops_br_hp', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_omen_16_gaming', 'Omen 16 Gaming', 'elec_laptops_br_hp', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_elitebook_840', 'EliteBook 840', 'elec_laptops_br_hp', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_hp_probook_450', 'ProBook 450', 'elec_laptops_br_hp', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo', 'Lenovo', 'elec_laptops', 'brand', 4, 'https://upload.wikimedia.org/wikipedia/commons/b/b8/Lenovo_logo_2015.svg', '#E2231A');
SELECT public._seed_elec_node('elec_laptops_br_lenovo_thinkpad_x1_carbon', 'ThinkPad X1 Carbon', 'elec_laptops_br_lenovo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_ideapad_5_pro', 'IdeaPad 5 Pro', 'elec_laptops_br_lenovo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_ideapad_gaming_3', 'IdeaPad Gaming 3', 'elec_laptops_br_lenovo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_legion_5_pro', 'Legion 5 Pro', 'elec_laptops_br_lenovo', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_legion_7i', 'Legion 7i', 'elec_laptops_br_lenovo', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_yoga_9i', 'Yoga 9i', 'elec_laptops_br_lenovo', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_lenovo_loq_15', 'LOQ 15', 'elec_laptops_br_lenovo', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus', 'Asus', 'elec_laptops', 'brand', 5, 'https://upload.wikimedia.org/wikipedia/commons/2/2e/ASUS_Logo.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_laptops_br_asus_zenbook_14', 'ZenBook 14', 'elec_laptops_br_asus', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus_vivobook_15', 'VivoBook 15', 'elec_laptops_br_asus', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus_rog_strix_g16', 'ROG Strix G16', 'elec_laptops_br_asus', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus_rog_zephyrus_g14', 'ROG Zephyrus G14', 'elec_laptops_br_asus', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus_tuf_gaming_a15', 'TUF Gaming A15', 'elec_laptops_br_asus', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_asus_proart_studiobook', 'ProArt Studiobook', 'elec_laptops_br_asus', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_msi', 'MSI', 'elec_laptops', 'brand', 6, NULL, '#CC0000');
SELECT public._seed_elec_node('elec_laptops_br_msi_titan_gt77', 'Titan GT77', 'elec_laptops_br_msi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_msi_raider_ge78', 'Raider GE78', 'elec_laptops_br_msi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_msi_stealth_16_studio', 'Stealth 16 Studio', 'elec_laptops_br_msi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_msi_creator_z17', 'Creator Z17', 'elec_laptops_br_msi', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_laptops_br_msi_katana_15', 'Katana 15', 'elec_laptops_br_msi', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_displays', 'شاشات وتلفزيونات', 'electronics', 'category', 4, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_displays_br_samsung', 'Samsung', 'elec_displays', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', '#1428A0');
SELECT public._seed_elec_node('elec_displays_br_samsung_qled_4k_55in', 'QLED 4K 55"', 'elec_displays_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_samsung_qled_4k_65in', 'QLED 4K 65"', 'elec_displays_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_samsung_qled_4k_75in', 'QLED 4K 75"', 'elec_displays_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_samsung_neo_qled_8k', 'Neo QLED 8K', 'elec_displays_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_samsung_the_frame_55in', 'The Frame 55"', 'elec_displays_br_samsung', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_samsung_odyssey_gaming_monitor', 'Odyssey Gaming Monitor', 'elec_displays_br_samsung', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg', 'LG', 'elec_displays', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/b/bf/LG_logo_%282015%29.svg', '#A50034');
SELECT public._seed_elec_node('elec_displays_br_lg_oled_c4_55in', 'OLED C4 55"', 'elec_displays_br_lg', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg_oled_c4_65in', 'OLED C4 65"', 'elec_displays_br_lg', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg_oled_c4_77in', 'OLED C4 77"', 'elec_displays_br_lg', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg_qned_4k_55in', 'QNED 4K 55"', 'elec_displays_br_lg', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg_ultragear_gaming_27in', 'UltraGear Gaming 27"', 'elec_displays_br_lg', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_lg_ultrawide_34in', 'UltraWide 34"', 'elec_displays_br_lg', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_sony', 'Sony', 'elec_displays', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_displays_br_sony_bravia_xr_a95l_oled', 'Bravia XR A95L OLED', 'elec_displays_br_sony', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_sony_bravia_9_mini_led', 'Bravia 9 Mini LED', 'elec_displays_br_sony', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_sony_bravia_7_4k', 'Bravia 7 4K', 'elec_displays_br_sony', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_sony_inzone_m9_gaming', 'Inzone M9 Gaming', 'elec_displays_br_sony', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_tcl', 'TCL', 'elec_displays', 'brand', 4, NULL, '#CC0000');
SELECT public._seed_elec_node('elec_displays_br_tcl_qled_4k_55in', 'QLED 4K 55"', 'elec_displays_br_tcl', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_tcl_qled_4k_65in', 'QLED 4K 65"', 'elec_displays_br_tcl', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_tcl_mini_led_75in', 'Mini LED 75"', 'elec_displays_br_tcl', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_displays_br_tcl_android_tv_43in', 'Android TV 43"', 'elec_displays_br_tcl', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras', 'كاميرات', 'electronics', 'category', 5, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_cameras_br_canon', 'Canon', 'elec_cameras', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/0/04/Canon_wordmark.svg', '#CC0000');
SELECT public._seed_elec_node('elec_cameras_br_canon_eos_r5_mark_ii', 'EOS R5 Mark II', 'elec_cameras_br_canon', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_canon_eos_r6_mark_ii', 'EOS R6 Mark II', 'elec_cameras_br_canon', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_canon_eos_r50', 'EOS R50', 'elec_cameras_br_canon', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_canon_eos_90d_dslr', 'EOS 90D DSLR', 'elec_cameras_br_canon', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_canon_powershot_v10', 'PowerShot V10', 'elec_cameras_br_canon', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_sony', 'Sony', 'elec_cameras', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_cameras_br_sony_alpha_7_iv', 'Alpha 7 IV', 'elec_cameras_br_sony', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_sony_alpha_7c_ii', 'Alpha 7C II', 'elec_cameras_br_sony', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_sony_alpha_7r_v', 'Alpha 7R V', 'elec_cameras_br_sony', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_sony_zv_e10_ii', 'ZV-E10 II', 'elec_cameras_br_sony', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_sony_rx100_vii', 'RX100 VII', 'elec_cameras_br_sony', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_nikon', 'Nikon', 'elec_cameras', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/e/e9/Nikon_logo.svg', '#FFD700');
SELECT public._seed_elec_node('elec_cameras_br_nikon_z8', 'Z8', 'elec_cameras_br_nikon', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_nikon_z6_iii', 'Z6 III', 'elec_cameras_br_nikon', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_nikon_z50_ii', 'Z50 II', 'elec_cameras_br_nikon', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_nikon_d7500_dslr', 'D7500 DSLR', 'elec_cameras_br_nikon', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_gopro', 'GoPro', 'elec_cameras', 'brand', 4, NULL, '#00ADEF');
SELECT public._seed_elec_node('elec_cameras_br_gopro_hero_13_black', 'Hero 13 Black', 'elec_cameras_br_gopro', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_gopro_hero_12_black', 'Hero 12 Black', 'elec_cameras_br_gopro', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_gopro_hero_11_mini', 'Hero 11 Mini', 'elec_cameras_br_gopro', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_cameras_br_gopro_max_360', 'Max 360', 'elec_cameras_br_gopro', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_audio', 'سماعات وصوتيات', 'electronics', 'category', 6, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_audio_br_apple', 'Apple', 'elec_audio', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_audio_br_apple_airpods_pro_2', 'AirPods Pro 2', 'elec_audio_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_apple_airpods_4', 'AirPods 4', 'elec_audio_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_apple_airpods_max', 'AirPods Max', 'elec_audio_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_sony', 'Sony', 'elec_audio', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_audio_br_sony_wh_1000xm5', 'WH-1000XM5', 'elec_audio_br_sony', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_sony_wf_1000xm5', 'WF-1000XM5', 'elec_audio_br_sony', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_sony_wh_ch720n', 'WH-CH720N', 'elec_audio_br_sony', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_sony_srs_xb100', 'SRS-XB100', 'elec_audio_br_sony', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_samsung', 'Samsung', 'elec_audio', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', '#1428A0');
SELECT public._seed_elec_node('elec_audio_br_samsung_galaxy_buds3_pro', 'Galaxy Buds3 Pro', 'elec_audio_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_samsung_galaxy_buds3', 'Galaxy Buds3', 'elec_audio_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_samsung_galaxy_buds_fe', 'Galaxy Buds FE', 'elec_audio_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_samsung_soundbar_q990d', 'Soundbar Q990D', 'elec_audio_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl', 'JBL', 'elec_audio', 'brand', 4, NULL, '#FF6900');
SELECT public._seed_elec_node('elec_audio_br_jbl_tune_770nc', 'Tune 770NC', 'elec_audio_br_jbl', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl_live_pro_2', 'Live Pro 2', 'elec_audio_br_jbl', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl_charge_5', 'Charge 5', 'elec_audio_br_jbl', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl_xtreme_3', 'Xtreme 3', 'elec_audio_br_jbl', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl_partybox_310', 'PartyBox 310', 'elec_audio_br_jbl', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_jbl_bar_1000_soundbar', 'Bar 1000 Soundbar', 'elec_audio_br_jbl', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_bose', 'Bose', 'elec_audio', 'brand', 5, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_audio_br_bose_quietcomfort_45', 'QuietComfort 45', 'elec_audio_br_bose', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_bose_quietcomfort_ultra', 'QuietComfort Ultra', 'elec_audio_br_bose', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_bose_sport_earbuds', 'Sport Earbuds', 'elec_audio_br_bose', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_audio_br_bose_soundlink_max', 'SoundLink Max', 'elec_audio_br_bose', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming', 'ألعاب فيديو', 'electronics', 'category', 7, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation', 'Sony PlayStation', 'elec_gaming', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Playstation_logo_colour.svg', '#003087');
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_playstation_5', 'PlayStation 5', 'elec_gaming_br_sony_playstation', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_ps5_slim', 'PS5 Slim', 'elec_gaming_br_sony_playstation', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_ps5_pro', 'PS5 Pro', 'elec_gaming_br_sony_playstation', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_playstation_4_pro', 'PlayStation 4 Pro', 'elec_gaming_br_sony_playstation', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_playstation_4', 'PlayStation 4', 'elec_gaming_br_sony_playstation', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_sony_playstation_ps_vr2', 'PS VR2', 'elec_gaming_br_sony_playstation', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_microsoft_xbox', 'Microsoft Xbox', 'elec_gaming', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/8/8c/XBOX_logo_2012.svg', '#107C10');
SELECT public._seed_elec_node('elec_gaming_br_microsoft_xbox_xbox_series_x', 'Xbox Series X', 'elec_gaming_br_microsoft_xbox', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_microsoft_xbox_xbox_series_s', 'Xbox Series S', 'elec_gaming_br_microsoft_xbox', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_microsoft_xbox_xbox_one_x', 'Xbox One X', 'elec_gaming_br_microsoft_xbox', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_microsoft_xbox_xbox_one_s', 'Xbox One S', 'elec_gaming_br_microsoft_xbox', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_nintendo', 'Nintendo', 'elec_gaming', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/0/0d/Nintendo.svg', '#E4000F');
SELECT public._seed_elec_node('elec_gaming_br_nintendo_switch_oled', 'Switch OLED', 'elec_gaming_br_nintendo', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_nintendo_switch_lite', 'Switch Lite', 'elec_gaming_br_nintendo', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_gaming_br_nintendo_switch_2', 'Switch 2', 'elec_gaming_br_nintendo', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables', 'ساعات ذكية وإكسسوار', 'electronics', 'category', 8, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_wearables_br_apple', 'Apple', 'elec_wearables', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg', '#1A1A1A');
SELECT public._seed_elec_node('elec_wearables_br_apple_apple_watch_ultra_2', 'Apple Watch Ultra 2', 'elec_wearables_br_apple', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_apple_apple_watch_series_10', 'Apple Watch Series 10', 'elec_wearables_br_apple', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_apple_apple_watch_se', 'Apple Watch SE', 'elec_wearables_br_apple', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_samsung', 'Samsung', 'elec_wearables', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg', '#1428A0');
SELECT public._seed_elec_node('elec_wearables_br_samsung_galaxy_watch_7', 'Galaxy Watch 7', 'elec_wearables_br_samsung', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_samsung_galaxy_watch_ultra', 'Galaxy Watch Ultra', 'elec_wearables_br_samsung', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_samsung_galaxy_watch_fe', 'Galaxy Watch FE', 'elec_wearables_br_samsung', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_samsung_galaxy_ring', 'Galaxy Ring', 'elec_wearables_br_samsung', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_huawei', 'Huawei', 'elec_wearables', 'brand', 3, 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Huawei_logo.svg', '#CF0A2C');
SELECT public._seed_elec_node('elec_wearables_br_huawei_watch_gt_4', 'Watch GT 4', 'elec_wearables_br_huawei', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_huawei_watch_4_pro', 'Watch 4 Pro', 'elec_wearables_br_huawei', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_huawei_band_8', 'Band 8', 'elec_wearables_br_huawei', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_xiaomi', 'Xiaomi', 'elec_wearables', 'brand', 4, 'https://upload.wikimedia.org/wikipedia/commons/2/29/Xiaomi_logo.svg', '#FF6900');
SELECT public._seed_elec_node('elec_wearables_br_xiaomi_watch_s3', 'Watch S3', 'elec_wearables_br_xiaomi', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_xiaomi_band_8_pro', 'Band 8 Pro', 'elec_wearables_br_xiaomi', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_wearables_br_xiaomi_redmi_watch_4', 'Redmi Watch 4', 'elec_wearables_br_xiaomi', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_printers', 'طابعات وملحقات', 'electronics', 'category', 9, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_printers_br_hp', 'HP', 'elec_printers', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/a/ad/HP_logo_2012.svg', '#0096D6');
SELECT public._seed_elec_node('elec_printers_br_hp_deskjet_4220e', 'DeskJet 4220e', 'elec_printers_br_hp', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_hp_officejet_pro_9015e', 'OfficeJet Pro 9015e', 'elec_printers_br_hp', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_hp_laserjet_pro_m404n', 'LaserJet Pro M404n', 'elec_printers_br_hp', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_hp_color_laserjet_mfp', 'Color LaserJet MFP', 'elec_printers_br_hp', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_canon', 'Canon', 'elec_printers', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/0/04/Canon_wordmark.svg', '#CC0000');
SELECT public._seed_elec_node('elec_printers_br_canon_pixma_g3470', 'PIXMA G3470', 'elec_printers_br_canon', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_canon_pixma_tr8620', 'PIXMA TR8620', 'elec_printers_br_canon', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_canon_imageclass_mf3010', 'imageCLASS MF3010', 'elec_printers_br_canon', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_epson', 'Epson', 'elec_printers', 'brand', 3, NULL, '#003087');
SELECT public._seed_elec_node('elec_printers_br_epson_ecotank_l3250', 'EcoTank L3250', 'elec_printers_br_epson', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_epson_ecotank_l6490', 'EcoTank L6490', 'elec_printers_br_epson', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_printers_br_epson_workforce_pro_wf_7840', 'WorkForce Pro WF-7840', 'elec_printers_br_epson', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_networking', 'شبكات وراوتر', 'electronics', 'category', 10, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_networking_br_tp_link', 'TP-Link', 'elec_networking', 'brand', 1, NULL, '#55ACEE');
SELECT public._seed_elec_node('elec_networking_br_tp_link_archer_ax73_wifi_6', 'Archer AX73 WiFi 6', 'elec_networking_br_tp_link', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_tp_link_deco_xe75_mesh', 'Deco XE75 Mesh', 'elec_networking_br_tp_link', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_tp_link_tl_wr940n', 'TL-WR940N', 'elec_networking_br_tp_link', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_tp_link_archer_c6', 'Archer C6', 'elec_networking_br_tp_link', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_tp_link_4g_lte_router_mr600', '4G LTE Router MR600', 'elec_networking_br_tp_link', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_huawei', 'Huawei', 'elec_networking', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Huawei_logo.svg', '#CF0A2C');
SELECT public._seed_elec_node('elec_networking_br_huawei_ax3_pro_wifi_6', 'AX3 Pro WiFi 6', 'elec_networking_br_huawei', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_huawei_b535_4g_router', 'B535 4G Router', 'elec_networking_br_huawei', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_huawei_b818_4g_router', 'B818 4G Router', 'elec_networking_br_huawei', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_huawei_cpe_pro_5g', 'CPE Pro 5G', 'elec_networking_br_huawei', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_cisco', 'Cisco', 'elec_networking', 'brand', 3, NULL, '#049FD9');
SELECT public._seed_elec_node('elec_networking_br_cisco_rv340_router', 'RV340 Router', 'elec_networking_br_cisco', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_cisco_cbs220_switch', 'CBS220 Switch', 'elec_networking_br_cisco', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_networking_br_cisco_wap571_access_point', 'WAP571 Access Point', 'elec_networking_br_cisco', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home', 'أجهزة منزلية ذكية', 'electronics', 'category', 11, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_smart_home_amazon_echo', 'Amazon Echo', 'elec_smart_home', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_google_nest_hub', 'Google Nest Hub', 'elec_smart_home', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_xiaomi_smart_hub', 'Xiaomi Smart Hub', 'elec_smart_home', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_indoor_camera', 'كاميرا مراقبة داخلية', 'elec_smart_home', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_outdoor_camera', 'كاميرا مراقبة خارجية', 'elec_smart_home', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_smart_doorbell', 'جرس ذكي', 'elec_smart_home', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_smart_curtain', 'ستارة ذكية', 'elec_smart_home', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_smart_led', 'إضاءة ذكية LED', 'elec_smart_home', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_smart_ac', 'مكيف ذكي', 'elec_smart_home', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_smart_home_smart_lock', 'قفل ذكي', 'elec_smart_home', 'model', 10, NULL, NULL);
SELECT public._seed_elec_node('elec_parts', 'قطع غيار وإكسسوارات', 'electronics', 'category', 12, NULL, '#1A1A1A');
SELECT public._seed_elec_node('elec_parts_phone_screen', 'شاشة هاتف (سبير)', 'elec_parts', 'model', 1, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_phone_battery', 'بطارية هاتف', 'elec_parts', 'model', 2, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_case_protection', 'كفر وحماية', 'elec_parts', 'model', 3, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_charger_cable', 'شاحن وكابل', 'elec_parts', 'model', 4, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_power_bank', 'باور بانك', 'elec_parts', 'model', 5, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_keyboard_mouse', 'كيبورد وماوس', 'elec_parts', 'model', 6, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_external_hdd', 'هارد ديسك خارجي', 'elec_parts', 'model', 7, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_usb_flash', 'فلاشة USB', 'elec_parts', 'model', 8, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_memory_card', 'كارت ذاكرة', 'elec_parts', 'model', 9, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_laptop_ram', 'رام لابتوب', 'elec_parts', 'model', 10, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_gpu', 'GPU كرت شاشة', 'elec_parts', 'model', 11, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_cpu', 'معالج CPU', 'elec_parts', 'model', 12, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_motherboard', 'لوحة أم Motherboard', 'elec_parts', 'model', 13, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_cooling_fan', 'مروحة تبريد', 'elec_parts', 'model', 14, NULL, NULL);
SELECT public._seed_elec_node('elec_parts_pc_case', 'كيس كمبيوتر', 'elec_parts', 'model', 15, NULL, NULL);

DROP FUNCTION public._seed_elec_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

