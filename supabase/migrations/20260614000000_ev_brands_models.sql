-- سيارات كهربائية (veh_electric) — EV brands + models with logos
-- Safe to re-run: cleans veh_electric subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_ev_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_electric')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_ev_node('veh_ev_br_tesla', 'Tesla', 'veh_electric', 'brand', 1, 'https://www.carlogos.org/car-logos/tesla-logo.png', '#CC0000');
SELECT public._seed_ev_node('veh_ev_br_tesla_model_s', 'Model S', 'veh_ev_br_tesla', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_model_3', 'Model 3', 'veh_ev_br_tesla', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_model_x', 'Model X', 'veh_ev_br_tesla', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_model_y', 'Model Y', 'veh_ev_br_tesla', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_cybertruck', 'Cybertruck', 'veh_ev_br_tesla', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_model_2', 'Model 2', 'veh_ev_br_tesla', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_tesla_roadster', 'Roadster', 'veh_ev_br_tesla', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw', 'BMW', 'veh_electric', 'brand', 2, 'https://www.carlogos.org/car-logos/bmw-logo.png', '#1C69D4');
SELECT public._seed_ev_node('veh_ev_br_bmw_i3', 'i3', 'veh_ev_br_bmw', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_i4', 'i4', 'veh_ev_br_bmw', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_i5', 'i5', 'veh_ev_br_bmw', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_i7', 'i7', 'veh_ev_br_bmw', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_ix', 'iX', 'veh_ev_br_bmw', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_ix1', 'iX1', 'veh_ev_br_bmw', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_ix2', 'iX2', 'veh_ev_br_bmw', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_ix3', 'iX3', 'veh_ev_br_bmw', 'model', 8, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_bmw_ix_m60', 'iX M60', 'veh_ev_br_bmw', 'model', 9, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz', 'Mercedes-Benz', 'veh_electric', 'brand', 3, 'https://www.carlogos.org/car-logos/mercedes-benz-logo.png', '#333333');
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqa', 'EQA', 'veh_ev_br_mercedes_benz', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqb', 'EQB', 'veh_ev_br_mercedes_benz', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqc', 'EQC', 'veh_ev_br_mercedes_benz', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqe', 'EQE', 'veh_ev_br_mercedes_benz', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqe_suv', 'EQE SUV', 'veh_ev_br_mercedes_benz', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqs', 'EQS', 'veh_ev_br_mercedes_benz', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqs_suv', 'EQS SUV', 'veh_ev_br_mercedes_benz', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_eqv', 'EQV', 'veh_ev_br_mercedes_benz', 'model', 8, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mercedes_benz_g_580_eq', 'G 580 EQ', 'veh_ev_br_mercedes_benz', 'model', 9, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi', 'Audi', 'veh_electric', 'brand', 4, 'https://www.carlogos.org/car-logos/audi-logo.png', '#BB0A30');
SELECT public._seed_ev_node('veh_ev_br_audi_e_tron', 'e-tron', 'veh_ev_br_audi', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_e_tron_gt', 'e-tron GT', 'veh_ev_br_audi', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_e_tron_s', 'e-tron S', 'veh_ev_br_audi', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_q4_e_tron', 'Q4 e-tron', 'veh_ev_br_audi', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_q6_e_tron', 'Q6 e-tron', 'veh_ev_br_audi', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_q8_e_tron', 'Q8 e-tron', 'veh_ev_br_audi', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_a6_e_tron', 'A6 e-tron', 'veh_ev_br_audi', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_audi_rs_e_tron_gt', 'RS e-tron GT', 'veh_ev_br_audi', 'model', 8, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche', 'Porsche', 'veh_electric', 'brand', 5, 'https://www.carlogos.org/car-logos/porsche-logo.png', '#000000');
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan', 'Taycan', 'veh_ev_br_porsche', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan_4s', 'Taycan 4S', 'veh_ev_br_porsche', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan_gts', 'Taycan GTS', 'veh_ev_br_porsche', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan_turbo', 'Taycan Turbo', 'veh_ev_br_porsche', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan_turbo_s', 'Taycan Turbo S', 'veh_ev_br_porsche', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_taycan_cross_turismo', 'Taycan Cross Turismo', 'veh_ev_br_porsche', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_porsche_macan_ev', 'Macan EV', 'veh_ev_br_porsche', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen', 'Volkswagen', 'veh_electric', 'brand', 6, 'https://www.carlogos.org/car-logos/volkswagen-logo.png', '#001E50');
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_3', 'ID.3', 'veh_ev_br_volkswagen', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_4', 'ID.4', 'veh_ev_br_volkswagen', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_5', 'ID.5', 'veh_ev_br_volkswagen', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_6', 'ID.6', 'veh_ev_br_volkswagen', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_7', 'ID.7', 'veh_ev_br_volkswagen', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volkswagen_id_buzz', 'ID. Buzz', 'veh_ev_br_volkswagen', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_hyundai', 'Hyundai', 'veh_electric', 'brand', 7, 'https://www.carlogos.org/car-logos/hyundai-logo.png', '#002C5F');
SELECT public._seed_ev_node('veh_ev_br_hyundai_ioniq_5', 'IONIQ 5', 'veh_ev_br_hyundai', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_hyundai_ioniq_6', 'IONIQ 6', 'veh_ev_br_hyundai', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_hyundai_ioniq_9', 'IONIQ 9', 'veh_ev_br_hyundai', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_hyundai_kona_electric', 'Kona Electric', 'veh_ev_br_hyundai', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_hyundai_nexo', 'Nexo', 'veh_ev_br_hyundai', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_kia', 'Kia', 'veh_electric', 'brand', 8, 'https://www.carlogos.org/car-logos/kia-logo.png', '#05141F');
SELECT public._seed_ev_node('veh_ev_br_kia_ev3', 'EV3', 'veh_ev_br_kia', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_kia_ev6', 'EV6', 'veh_ev_br_kia', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_kia_ev9', 'EV9', 'veh_ev_br_kia', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_kia_niro_ev', 'Niro EV', 'veh_ev_br_kia', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_kia_soul_ev', 'Soul EV', 'veh_ev_br_kia', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_rivian', 'Rivian', 'veh_electric', 'brand', 9, 'https://www.carlogos.org/car-logos/rivian-logo.png', '#00A651');
SELECT public._seed_ev_node('veh_ev_br_rivian_r1t', 'R1T', 'veh_ev_br_rivian', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_rivian_r1s', 'R1S', 'veh_ev_br_rivian', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_rivian_r2', 'R2', 'veh_ev_br_rivian', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_rivian_r3', 'R3', 'veh_ev_br_rivian', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lucid', 'Lucid', 'veh_electric', 'brand', 10, 'https://www.carlogos.org/car-logos/lucid-logo.png', '#C41230');
SELECT public._seed_ev_node('veh_ev_br_lucid_air_pure', 'Air Pure', 'veh_ev_br_lucid', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lucid_air_touring', 'Air Touring', 'veh_ev_br_lucid', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lucid_air_grand_touring', 'Air Grand Touring', 'veh_ev_br_lucid', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lucid_air_sapphire', 'Air Sapphire', 'veh_ev_br_lucid', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lucid_gravity', 'Gravity', 'veh_ev_br_lucid', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo', 'Volvo', 'veh_electric', 'brand', 11, 'https://www.carlogos.org/car-logos/volvo-logo.png', '#003057');
SELECT public._seed_ev_node('veh_ev_br_volvo_xc40_recharge', 'XC40 Recharge', 'veh_ev_br_volvo', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo_c40_recharge', 'C40 Recharge', 'veh_ev_br_volvo', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo_ex30', 'EX30', 'veh_ev_br_volvo', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo_ex40', 'EX40', 'veh_ev_br_volvo', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo_ex90', 'EX90', 'veh_ev_br_volvo', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_volvo_ec40', 'EC40', 'veh_ev_br_volvo', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_polestar', 'Polestar', 'veh_electric', 'brand', 12, 'https://www.carlogos.org/car-logos/polestar-logo.png', '#000000');
SELECT public._seed_ev_node('veh_ev_br_polestar_polestar_2', 'Polestar 2', 'veh_ev_br_polestar', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_polestar_polestar_3', 'Polestar 3', 'veh_ev_br_polestar', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_polestar_polestar_4', 'Polestar 4', 'veh_ev_br_polestar', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_polestar_polestar_6', 'Polestar 6', 'veh_ev_br_polestar', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio', 'NIO', 'veh_electric', 'brand', 13, 'https://www.carlogos.org/car-logos/nio-logo.png', '#00BEFF');
SELECT public._seed_ev_node('veh_ev_br_nio_et5', 'ET5', 'veh_ev_br_nio', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_et7', 'ET7', 'veh_ev_br_nio', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_el6', 'EL6', 'veh_ev_br_nio', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_el7', 'EL7', 'veh_ev_br_nio', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_el8', 'EL8', 'veh_ev_br_nio', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_es6', 'ES6', 'veh_ev_br_nio', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_es8', 'ES8', 'veh_ev_br_nio', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nio_ec6', 'EC6', 'veh_ev_br_nio', 'model', 8, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd', 'BYD', 'veh_electric', 'brand', 14, 'https://www.carlogos.org/car-logos/byd-logo.png', '#1DB954');
SELECT public._seed_ev_node('veh_ev_br_byd_atto_3', 'Atto 3', 'veh_ev_br_byd', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_seal', 'Seal', 'veh_ev_br_byd', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_dolphin', 'Dolphin', 'veh_ev_br_byd', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_han', 'Han', 'veh_ev_br_byd', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_tang', 'Tang', 'veh_ev_br_byd', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_song_plus_ev', 'Song Plus EV', 'veh_ev_br_byd', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_seagull', 'Seagull', 'veh_ev_br_byd', 'model', 7, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_byd_yangwang_u8', 'Yangwang U8', 'veh_ev_br_byd', 'model', 8, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng', 'Xpeng', 'veh_electric', 'brand', 15, NULL, '#FF6B35');
SELECT public._seed_ev_node('veh_ev_br_xpeng_p5', 'P5', 'veh_ev_br_xpeng', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng_p7', 'P7', 'veh_ev_br_xpeng', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng_g3', 'G3', 'veh_ev_br_xpeng', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng_g6', 'G6', 'veh_ev_br_xpeng', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng_g9', 'G9', 'veh_ev_br_xpeng', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_xpeng_x9', 'X9', 'veh_ev_br_xpeng', 'model', 6, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_li_auto', 'Li Auto', 'veh_electric', 'brand', 16, NULL, '#0066CC');
SELECT public._seed_ev_node('veh_ev_br_li_auto_li_l6', 'Li L6', 'veh_ev_br_li_auto', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_li_auto_li_l7', 'Li L7', 'veh_ev_br_li_auto', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_li_auto_li_l8', 'Li L8', 'veh_ev_br_li_auto', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_li_auto_li_l9', 'Li L9', 'veh_ev_br_li_auto', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_li_auto_li_mega', 'Li MEGA', 'veh_ev_br_li_auto', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_zeekr', 'Zeekr', 'veh_electric', 'brand', 17, NULL, '#000000');
SELECT public._seed_ev_node('veh_ev_br_zeekr_001', '001', 'veh_ev_br_zeekr', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_zeekr_007', '007', 'veh_ev_br_zeekr', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_zeekr_009', '009', 'veh_ev_br_zeekr', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_zeekr_x', 'X', 'veh_ev_br_zeekr', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jaguar', 'Jaguar', 'veh_electric', 'brand', 18, 'https://www.carlogos.org/car-logos/jaguar-logo.png', '#231F20');
SELECT public._seed_ev_node('veh_ev_br_jaguar_i_pace', 'I-PACE', 'veh_ev_br_jaguar', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jaguar_type_00', 'Type 00', 'veh_ev_br_jaguar', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lexus', 'Lexus', 'veh_electric', 'brand', 19, 'https://www.carlogos.org/car-logos/lexus-logo.png', '#1A1A1A');
SELECT public._seed_ev_node('veh_ev_br_lexus_rz_300e', 'RZ 300e', 'veh_ev_br_lexus', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lexus_rz_450e', 'RZ 450e', 'veh_ev_br_lexus', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lexus_ux_300e', 'UX 300e', 'veh_ev_br_lexus', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_lexus_lf_zc', 'LF-ZC', 'veh_ev_br_lexus', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_toyota', 'Toyota', 'veh_electric', 'brand', 20, 'https://www.carlogos.org/car-logos/toyota-logo.png', '#EB0A1E');
SELECT public._seed_ev_node('veh_ev_br_toyota_bz4x', 'bZ4X', 'veh_ev_br_toyota', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_toyota_bz3', 'bZ3', 'veh_ev_br_toyota', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_toyota_bz3x', 'bZ3X', 'veh_ev_br_toyota', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_toyota_mirai', 'Mirai', 'veh_ev_br_toyota', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nissan', 'Nissan', 'veh_electric', 'brand', 21, 'https://www.carlogos.org/car-logos/nissan-logo.png', '#C3002F');
SELECT public._seed_ev_node('veh_ev_br_nissan_leaf', 'Leaf', 'veh_ev_br_nissan', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nissan_ariya', 'Ariya', 'veh_ev_br_nissan', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_nissan_sakura', 'Sakura', 'veh_ev_br_nissan', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_chevrolet', 'Chevrolet', 'veh_electric', 'brand', 22, 'https://www.carlogos.org/car-logos/chevrolet-logo.png', '#D4AC0D');
SELECT public._seed_ev_node('veh_ev_br_chevrolet_bolt_ev', 'Bolt EV', 'veh_ev_br_chevrolet', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_chevrolet_bolt_euv', 'Bolt EUV', 'veh_ev_br_chevrolet', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_chevrolet_equinox_ev', 'Equinox EV', 'veh_ev_br_chevrolet', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_chevrolet_blazer_ev', 'Blazer EV', 'veh_ev_br_chevrolet', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_chevrolet_silverado_ev', 'Silverado EV', 'veh_ev_br_chevrolet', 'model', 5, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_ford', 'Ford', 'veh_electric', 'brand', 23, 'https://www.carlogos.org/car-logos/ford-logo.png', '#003478');
SELECT public._seed_ev_node('veh_ev_br_ford_mustang_mach_e', 'Mustang Mach-E', 'veh_ev_br_ford', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_ford_f_150_lightning', 'F-150 Lightning', 'veh_ev_br_ford', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_ford_explorer_ev', 'Explorer EV', 'veh_ev_br_ford', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_ford_capri_ev', 'Capri EV', 'veh_ev_br_ford', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jeep', 'Jeep', 'veh_electric', 'brand', 24, 'https://www.carlogos.org/car-logos/jeep-logo.png', '#1E3A5F');
SELECT public._seed_ev_node('veh_ev_br_jeep_avenger_ev', 'Avenger EV', 'veh_ev_br_jeep', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jeep_wrangler_4xe', 'Wrangler 4xe', 'veh_ev_br_jeep', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jeep_grand_cherokee_4xe', 'Grand Cherokee 4xe', 'veh_ev_br_jeep', 'model', 3, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_jeep_recon_ev', 'Recon EV', 'veh_ev_br_jeep', 'model', 4, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mini', 'MINI', 'veh_electric', 'brand', 25, 'https://www.carlogos.org/car-logos/mini-logo.png', '#000000');
SELECT public._seed_ev_node('veh_ev_br_mini_cooper_se', 'Cooper SE', 'veh_ev_br_mini', 'model', 1, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mini_countryman_se', 'Countryman SE', 'veh_ev_br_mini', 'model', 2, NULL, NULL);
SELECT public._seed_ev_node('veh_ev_br_mini_aceman_ev', 'Aceman EV', 'veh_ev_br_mini', 'model', 3, NULL, NULL);

DROP FUNCTION public._seed_ev_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

