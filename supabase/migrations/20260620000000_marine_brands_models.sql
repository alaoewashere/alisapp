-- مركبات بحرية (veh_marine) — brands + models (Iraq: Shatt al-Arab, rivers, Gulf)
-- Safe to re-run: cleans veh_marine subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_marine_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_marine')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_marine_node('veh_marine_br_yamaha', 'Yamaha', 'veh_marine', 'brand', 1, 'https://upload.wikimedia.org/wikipedia/commons/d/de/Yamaha_Motor_logo.svg', '#1A1A1A');
SELECT public._seed_marine_node('veh_marine_br_yamaha_fx_cruiser_ho', 'FX Cruiser HO', 'veh_marine_br_yamaha', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_fx_cruiser_svho', 'FX Cruiser SVHO', 'veh_marine_br_yamaha', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_vx_cruiser', 'VX Cruiser', 'veh_marine_br_yamaha', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_vx_deluxe', 'VX Deluxe', 'veh_marine_br_yamaha', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_ex_deluxe', 'EX Deluxe', 'veh_marine_br_yamaha', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_ex_sport', 'EX Sport', 'veh_marine_br_yamaha', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_superjet', 'SuperJet', 'veh_marine_br_yamaha', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_waverunner_vx', 'WaveRunner VX', 'veh_marine_br_yamaha', 'model', 8, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_f115_outboard', 'F115 Outboard', 'veh_marine_br_yamaha', 'model', 9, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_f200_outboard', 'F200 Outboard', 'veh_marine_br_yamaha', 'model', 10, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_f250_outboard', 'F250 Outboard', 'veh_marine_br_yamaha', 'model', 11, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_40hp_outboard', '40HP Outboard', 'veh_marine_br_yamaha', 'model', 12, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_yamaha_60hp_outboard', '60HP Outboard', 'veh_marine_br_yamaha', 'model', 13, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo', 'Sea-Doo', 'veh_marine', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/d/d9/BRP-Rotax_Logo.svg', '#FF6B00');
SELECT public._seed_marine_node('veh_marine_br_sea_doo_spark', 'Spark', 'veh_marine_br_sea_doo', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_spark_trixx', 'Spark Trixx', 'veh_marine_br_sea_doo', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_gti_130', 'GTI 130', 'veh_marine_br_sea_doo', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_gti_se_170', 'GTI SE 170', 'veh_marine_br_sea_doo', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_gtr_230', 'GTR 230', 'veh_marine_br_sea_doo', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_gtx_230', 'GTX 230', 'veh_marine_br_sea_doo', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_gtx_300', 'GTX 300', 'veh_marine_br_sea_doo', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_rxt_x_300', 'RXT-X 300', 'veh_marine_br_sea_doo', 'model', 8, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_rxp_x_300', 'RXP-X 300', 'veh_marine_br_sea_doo', 'model', 9, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_wake_pro_230', 'Wake Pro 230', 'veh_marine_br_sea_doo', 'model', 10, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sea_doo_fish_pro_scout', 'Fish Pro Scout', 'veh_marine_br_sea_doo', 'model', 11, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine', 'Honda Marine', 'veh_marine', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/honda.svg', '#CC0000');
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf2_3_outboard', 'BF2.3 Outboard', 'veh_marine_br_honda_marine', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf15_outboard', 'BF15 Outboard', 'veh_marine_br_honda_marine', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf40_outboard', 'BF40 Outboard', 'veh_marine_br_honda_marine', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf60_outboard', 'BF60 Outboard', 'veh_marine_br_honda_marine', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf100_outboard', 'BF100 Outboard', 'veh_marine_br_honda_marine', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf115_outboard', 'BF115 Outboard', 'veh_marine_br_honda_marine', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf150_outboard', 'BF150 Outboard', 'veh_marine_br_honda_marine', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf200_outboard', 'BF200 Outboard', 'veh_marine_br_honda_marine', 'model', 8, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_honda_marine_bf250_outboard', 'BF250 Outboard', 'veh_marine_br_honda_marine', 'model', 9, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury', 'Mercury', 'veh_marine', 'brand', 4, 'https://www.carlogos.org/car-logos/mercury-logo.png', '#CC0000');
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_40hp', 'Mercury 40HP', 'veh_marine_br_mercury', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_60hp', 'Mercury 60HP', 'veh_marine_br_mercury', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_75hp', 'Mercury 75HP', 'veh_marine_br_mercury', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_90hp', 'Mercury 90HP', 'veh_marine_br_mercury', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_115hp', 'Mercury 115HP', 'veh_marine_br_mercury', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_150hp', 'Mercury 150HP', 'veh_marine_br_mercury', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_200hp', 'Mercury 200HP', 'veh_marine_br_mercury', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_250hp', 'Mercury 250HP', 'veh_marine_br_mercury', 'model', 8, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_mercury_300hp', 'Mercury 300HP', 'veh_marine_br_mercury', 'model', 9, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_mercury_verado_350hp', 'Verado 350HP', 'veh_marine_br_mercury', 'model', 10, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine', 'Suzuki Marine', 'veh_marine', 'brand', 5, 'https://upload.wikimedia.org/wikipedia/commons/b/be/Suzuki_logo.svg', '#1A1A1A');
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df40a_outboard', 'DF40A Outboard', 'veh_marine_br_suzuki_marine', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df60a_outboard', 'DF60A Outboard', 'veh_marine_br_suzuki_marine', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df90a_outboard', 'DF90A Outboard', 'veh_marine_br_suzuki_marine', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df115a_outboard', 'DF115A Outboard', 'veh_marine_br_suzuki_marine', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df140a_outboard', 'DF140A Outboard', 'veh_marine_br_suzuki_marine', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df200a_outboard', 'DF200A Outboard', 'veh_marine_br_suzuki_marine', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df250ap_outboard', 'DF250AP Outboard', 'veh_marine_br_suzuki_marine', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_suzuki_marine_df300ap_outboard', 'DF300AP Outboard', 'veh_marine_br_suzuki_marine', 'model', 8, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki', 'Kawasaki', 'veh_marine', 'brand', 6, 'https://upload.wikimedia.org/wikipedia/commons/d/da/Kawasaki-logo.svg', '#009900');
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_stx_160', 'Jet Ski STX 160', 'veh_marine_br_kawasaki', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_stx_160lx', 'Jet Ski STX 160LX', 'veh_marine_br_kawasaki', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_ultra_160x', 'Jet Ski Ultra 160X', 'veh_marine_br_kawasaki', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_ultra_310x', 'Jet Ski Ultra 310X', 'veh_marine_br_kawasaki', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_ultra_310lx', 'Jet Ski Ultra 310LX', 'veh_marine_br_kawasaki', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_kawasaki_jet_ski_sx_r_160', 'Jet Ski SX-R 160', 'veh_marine_br_kawasaki', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu', 'Tohatsu', 'veh_marine', 'brand', 7, 'https://upload.wikimedia.org/wikipedia/commons/8/8c/Tohatsu_company_logo.svg', '#003087');
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs6_outboard', 'MFS6 Outboard', 'veh_marine_br_tohatsu', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs9_8_outboard', 'MFS9.8 Outboard', 'veh_marine_br_tohatsu', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs15_outboard', 'MFS15 Outboard', 'veh_marine_br_tohatsu', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs25_outboard', 'MFS25 Outboard', 'veh_marine_br_tohatsu', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs40_outboard', 'MFS40 Outboard', 'veh_marine_br_tohatsu', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs60_outboard', 'MFS60 Outboard', 'veh_marine_br_tohatsu', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_tohatsu_mfs90_outboard', 'MFS90 Outboard', 'veh_marine_br_tohatsu', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler', 'Boston Whaler', 'veh_marine', 'brand', 8, NULL, '#003478');
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_130_super_sport', '130 Super Sport', 'veh_marine_br_boston_whaler', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_170_montauk', '170 Montauk', 'veh_marine_br_boston_whaler', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_190_montauk', '190 Montauk', 'veh_marine_br_boston_whaler', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_210_montauk', '210 Montauk', 'veh_marine_br_boston_whaler', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_270_dauntless', '270 Dauntless', 'veh_marine_br_boston_whaler', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_320_outrage', '320 Outrage', 'veh_marine_br_boston_whaler', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_boston_whaler_420_outrage', '420 Outrage', 'veh_marine_br_boston_whaler', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner', 'Bayliner', 'veh_marine', 'brand', 9, NULL, '#003478');
SELECT public._seed_marine_node('veh_marine_br_bayliner_element_e16', 'Element E16', 'veh_marine_br_bayliner', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_element_e18', 'Element E18', 'veh_marine_br_bayliner', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_vr4', 'VR4', 'veh_marine_br_bayliner', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_vr5', 'VR5', 'veh_marine_br_bayliner', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_vr6', 'VR6', 'veh_marine_br_bayliner', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_dx2050', 'DX2050', 'veh_marine_br_bayliner', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_bayliner_trophy_2052', 'Trophy 2052', 'veh_marine_br_bayliner', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac', 'Zodiac', 'veh_marine', 'brand', 10, NULL, '#003087');
SELECT public._seed_marine_node('veh_marine_br_zodiac_cadet_aero_230', 'Cadet Aero 230', 'veh_marine_br_zodiac', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac_cadet_aero_310', 'Cadet Aero 310', 'veh_marine_br_zodiac', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac_medline_500', 'Medline 500', 'veh_marine_br_zodiac', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac_pro_420', 'Pro 420', 'veh_marine_br_zodiac', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac_pro_550', 'Pro 550', 'veh_marine_br_zodiac', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_zodiac_rescue_boat', 'Rescue Boat', 'veh_marine_br_zodiac', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_lund', 'Lund', 'veh_marine', 'brand', 11, NULL, '#003478');
SELECT public._seed_marine_node('veh_marine_br_lund_jon_1236', 'Jon 1236', 'veh_marine_br_lund', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_lund_jon_1448', 'Jon 1448', 'veh_marine_br_lund', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_lund_pro_v_1875', 'Pro-V 1875', 'veh_marine_br_lund', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_lund_fury_1600', 'Fury 1600', 'veh_marine_br_lund', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_lund_impact_1775', 'Impact 1775', 'veh_marine_br_lund', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional', 'قوارب تقليدية', 'veh_marine', 'brand', 12, NULL, '#8B4513');
SELECT public._seed_marine_node('veh_marine_br_traditional_mashhouf', 'مشحوف (Mashhouf)', 'veh_marine_br_traditional', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_tarada', 'تَرَادة (Tarada)', 'veh_marine_br_traditional', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_balam', 'بلم (Balam)', 'veh_marine_br_traditional', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_wooden_fishing_boat', 'قارب صيد خشبي', 'veh_marine_br_traditional', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_fiberglass_fishing_boat', 'قارب صيد فايبر', 'veh_marine_br_traditional', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_zlama', 'زلامة', 'veh_marine_br_traditional', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_traditional_river_ferry', 'عبّارة نهرية', 'veh_marine_br_traditional', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sunseeker', 'Sunseeker', 'veh_marine', 'brand', 13, NULL, '#1A1A1A');
SELECT public._seed_marine_node('veh_marine_br_sunseeker_portofino_40', 'Portofino 40', 'veh_marine_br_sunseeker', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sunseeker_manhattan_55', 'Manhattan 55', 'veh_marine_br_sunseeker', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sunseeker_predator_65', 'Predator 65', 'veh_marine_br_sunseeker', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sunseeker_ocean_75', 'Ocean 75', 'veh_marine_br_sunseeker', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_sunseeker_yacht_90', 'Yacht 90', 'veh_marine_br_sunseeker', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut', 'Azimut', 'veh_marine', 'brand', 14, NULL, '#003087');
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_40', 'Azimut 40', 'veh_marine_br_azimut', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_50', 'Azimut 50', 'veh_marine_br_azimut', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_60', 'Azimut 60', 'veh_marine_br_azimut', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_72', 'Azimut 72', 'veh_marine_br_azimut', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_s6', 'Azimut S6', 'veh_marine_br_azimut', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_azimut_azimut_grande_25', 'Azimut Grande 25', 'veh_marine_br_azimut', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats', 'قوارب سرعة', 'veh_marine', 'brand', 15, NULL, '#CC0000');
SELECT public._seed_marine_node('veh_marine_br_speed_boats_speed_17ft', 'قارب سرعة 17 قدم', 'veh_marine_br_speed_boats', 'model', 1, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_speed_20ft', 'قارب سرعة 20 قدم', 'veh_marine_br_speed_boats', 'model', 2, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_speed_24ft', 'قارب سرعة 24 قدم', 'veh_marine_br_speed_boats', 'model', 3, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_speed_28ft', 'قارب سرعة 28 قدم', 'veh_marine_br_speed_boats', 'model', 4, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_pleasure_launch', 'لنش سياحي', 'veh_marine_br_speed_boats', 'model', 5, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_fishing_launch', 'لنش صيد', 'veh_marine_br_speed_boats', 'model', 6, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_inflatable_boat', 'قارب مطاطي', 'veh_marine_br_speed_boats', 'model', 7, NULL, NULL);
SELECT public._seed_marine_node('veh_marine_br_speed_boats_aluminum_boat', 'قارب ألومنيوم', 'veh_marine_br_speed_boats', 'model', 8, NULL, NULL);

DROP FUNCTION public._seed_marine_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

