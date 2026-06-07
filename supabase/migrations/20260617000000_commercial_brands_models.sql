-- مركبات تجارية (veh_commercial) — brands + models (Iraq market)
-- Safe to re-run: cleans veh_commercial subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_comm_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_commercial')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_comm_node('veh_comm_br_toyota', 'Toyota', 'veh_commercial', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/toyota.svg', '#EB0A1E');
SELECT public._seed_comm_node('veh_comm_br_toyota_dyna', 'Dyna', 'veh_comm_br_toyota', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_dyna_200', 'Dyna 200', 'veh_comm_br_toyota', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_dyna_300', 'Dyna 300', 'veh_comm_br_toyota', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_coaster', 'Coaster', 'veh_comm_br_toyota', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_coaster_deluxe', 'Coaster Deluxe', 'veh_comm_br_toyota', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_land_cruiser_70', 'Land Cruiser 70', 'veh_comm_br_toyota', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_toyoace', 'Toyoace', 'veh_comm_br_toyota', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_hiace_van_cargo', 'HiAce Van (Cargo)', 'veh_comm_br_toyota', 'model', 8, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_toyota_hilux_cargo', 'Hilux (Cargo)', 'veh_comm_br_toyota', 'model', 9, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino', 'Hino', 'veh_commercial', 'brand', 2, 'https://upload.wikimedia.org/wikipedia/commons/1/16/Hino_Motors_logo.svg', '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_hino_hino_300', 'Hino 300', 'veh_comm_br_hino', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_500', 'Hino 500', 'veh_comm_br_hino', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_700', 'Hino 700', 'veh_comm_br_hino', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_300_dutro', 'Hino 300 Dutro', 'veh_comm_br_hino', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_500_ranger', 'Hino 500 Ranger', 'veh_comm_br_hino', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_700_profia', 'Hino 700 Profia', 'veh_comm_br_hino', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_bus', 'Hino Bus', 'veh_comm_br_hino', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_hino_hino_poncho', 'Hino Poncho', 'veh_comm_br_hino', 'model', 8, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu', 'Isuzu', 'veh_commercial', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/isuzu.svg', '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_isuzu_n_series_nlr_nmr', 'N-Series (NLR/NMR)', 'veh_comm_br_isuzu', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_f_series_frr_fvr', 'F-Series (FRR/FVR)', 'veh_comm_br_isuzu', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_cande_series_cxz', 'C&E-Series (CXZ)', 'veh_comm_br_isuzu', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_isuzu_elf', 'Isuzu Elf', 'veh_comm_br_isuzu', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_isuzu_forward', 'Isuzu Forward', 'veh_comm_br_isuzu', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_isuzu_giga', 'Isuzu Giga', 'veh_comm_br_isuzu', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_isuzu_d_max_cargo', 'Isuzu D-Max (Cargo)', 'veh_comm_br_isuzu', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_isuzu_isuzu_bus', 'Isuzu Bus', 'veh_comm_br_isuzu', 'model', 8, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso', 'Mitsubishi Fuso', 'veh_commercial', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/mitsubishi.svg', '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_canter', 'Canter', 'veh_comm_br_mitsubishi_fuso', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_canter_wide', 'Canter Wide', 'veh_comm_br_mitsubishi_fuso', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_fighter', 'Fighter', 'veh_comm_br_mitsubishi_fuso', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_super_great', 'Super Great', 'veh_comm_br_mitsubishi_fuso', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_rosa', 'Rosa', 'veh_comm_br_mitsubishi_fuso', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mitsubishi_fuso_aero_star_bus', 'Aero Star Bus', 'veh_comm_br_mitsubishi_fuso', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco', 'IVECO', 'veh_commercial', 'brand', 5, 'https://upload.wikimedia.org/wikipedia/commons/a/a2/IVECO_logo.svg', '#003087');
SELECT public._seed_comm_node('veh_comm_br_iveco_daily', 'Daily', 'veh_comm_br_iveco', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_daily_van', 'Daily Van', 'veh_comm_br_iveco', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_daily_chassis', 'Daily Chassis', 'veh_comm_br_iveco', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_eurocargo', 'Eurocargo', 'veh_comm_br_iveco', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_stralis', 'Stralis', 'veh_comm_br_iveco', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_trakker', 'Trakker', 'veh_comm_br_iveco', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_s_way', 'S-Way', 'veh_comm_br_iveco', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_iveco_bus_crossway', 'Bus Crossway', 'veh_comm_br_iveco', 'model', 8, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz', 'Mercedes-Benz', 'veh_commercial', 'brand', 6, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/mercedes-benz.svg', '#333333');
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_actros', 'Actros', 'veh_comm_br_mercedes_benz', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_axor', 'Axor', 'veh_comm_br_mercedes_benz', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_atego', 'Atego', 'veh_comm_br_mercedes_benz', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_arocs', 'Arocs', 'veh_comm_br_mercedes_benz', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_sprinter_cargo', 'Sprinter Cargo', 'veh_comm_br_mercedes_benz', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_tourismo_bus', 'Tourismo Bus', 'veh_comm_br_mercedes_benz', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_mercedes_benz_travego_bus', 'Travego Bus', 'veh_comm_br_mercedes_benz', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man', 'MAN', 'veh_commercial', 'brand', 7, 'https://upload.wikimedia.org/wikipedia/commons/f/f1/MAN_truck_and_bus_logo.svg', '#E2001A');
SELECT public._seed_comm_node('veh_comm_br_man_tgx', 'TGX', 'veh_comm_br_man', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man_tgs', 'TGS', 'veh_comm_br_man', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man_tgm', 'TGM', 'veh_comm_br_man', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man_tgl', 'TGL', 'veh_comm_br_man', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man_lion_s_coach_bus', 'Lion''s Coach Bus', 'veh_comm_br_man', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_man_lion_s_city_bus', 'Lion''s City Bus', 'veh_comm_br_man', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo', 'Volvo', 'veh_commercial', 'brand', 8, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/volvo.svg', '#003057');
SELECT public._seed_comm_node('veh_comm_br_volvo_fh', 'FH', 'veh_comm_br_volvo', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_fm', 'FM', 'veh_comm_br_volvo', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_fmx', 'FMX', 'veh_comm_br_volvo', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_fl', 'FL', 'veh_comm_br_volvo', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_fe', 'FE', 'veh_comm_br_volvo', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_b12_bus', 'B12 Bus', 'veh_comm_br_volvo', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_volvo_9700_bus', '9700 Bus', 'veh_comm_br_volvo', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania', 'Scania', 'veh_commercial', 'brand', 9, 'https://upload.wikimedia.org/wikipedia/commons/6/66/Scania_logo.svg', '#003087');
SELECT public._seed_comm_node('veh_comm_br_scania_r_series', 'R-Series', 'veh_comm_br_scania', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_s_series', 'S-Series', 'veh_comm_br_scania', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_g_series', 'G-Series', 'veh_comm_br_scania', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_p_series', 'P-Series', 'veh_comm_br_scania', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_l_series', 'L-Series', 'veh_comm_br_scania', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_touring_bus', 'Touring Bus', 'veh_comm_br_scania', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_scania_citywide_bus', 'Citywide Bus', 'veh_comm_br_scania', 'model', 7, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_daf', 'DAF', 'veh_commercial', 'brand', 10, NULL, '#003087');
SELECT public._seed_comm_node('veh_comm_br_daf_xf', 'XF', 'veh_comm_br_daf', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_daf_xg', 'XG', 'veh_comm_br_daf', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_daf_cf', 'CF', 'veh_comm_br_daf', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_daf_lf', 'LF', 'veh_comm_br_daf', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long', 'King Long', 'veh_commercial', 'brand', 11, NULL, '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_king_long_xmq6127', 'XMQ6127', 'veh_comm_br_king_long', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long_xmq6900', 'XMQ6900', 'veh_comm_br_king_long', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long_xmq6119', 'XMQ6119', 'veh_comm_br_king_long', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long_xmq6800', 'XMQ6800', 'veh_comm_br_king_long', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long_kingo_minibus', 'Kingo (minibus)', 'veh_comm_br_king_long', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_king_long_higer_bus', 'Higer Bus', 'veh_comm_br_king_long', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong', 'Yutong', 'veh_commercial', 'brand', 12, NULL, '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_yutong_zk6127h', 'ZK6127H', 'veh_comm_br_yutong', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong_zk6119h', 'ZK6119H', 'veh_comm_br_yutong', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong_zk6852h', 'ZK6852H', 'veh_comm_br_yutong', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong_zk6109h', 'ZK6109H', 'veh_comm_br_yutong', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong_zk6122h9', 'ZK6122H9', 'veh_comm_br_yutong', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_yutong_e12_electric', 'E12 Electric', 'veh_comm_br_yutong', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_jinbei', 'Jinbei', 'veh_commercial', 'brand', 13, NULL, '#1A1A1A');
SELECT public._seed_comm_node('veh_comm_br_jinbei_hiace_sy6548', 'Hiace (SY6548)', 'veh_comm_br_jinbei', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_jinbei_granse', 'Granse', 'veh_comm_br_jinbei', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_jinbei_f50', 'F50', 'veh_comm_br_jinbei', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_jinbei_sy1027', 'SY1027', 'veh_comm_br_jinbei', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_jinbei_big_sea', 'Big Sea', 'veh_comm_br_jinbei', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton', 'Foton', 'veh_commercial', 'brand', 14, NULL, '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_foton_aumark', 'Aumark', 'veh_comm_br_foton', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton_aumark_s', 'Aumark S', 'veh_comm_br_foton', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton_auman', 'Auman', 'veh_comm_br_foton', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton_auman_gtl', 'Auman GTL', 'veh_comm_br_foton', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton_view_minibus', 'View (Minibus)', 'veh_comm_br_foton', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_foton_tornado', 'Tornado', 'veh_comm_br_foton', 'model', 6, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_dongfeng', 'Dongfeng', 'veh_commercial', 'brand', 15, NULL, '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_dongfeng_captain_t', 'Captain T', 'veh_comm_br_dongfeng', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_dongfeng_kr', 'KR', 'veh_comm_br_dongfeng', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_dongfeng_kx', 'KX', 'veh_comm_br_dongfeng', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_dongfeng_dfm_van', 'DFM Van', 'veh_comm_br_dongfeng', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_dongfeng_dolika', 'Dolika', 'veh_comm_br_dongfeng', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_faw', 'FAW', 'veh_commercial', 'brand', 16, NULL, '#CC0000');
SELECT public._seed_comm_node('veh_comm_br_faw_j6p', 'J6P', 'veh_comm_br_faw', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_faw_j7', 'J7', 'veh_comm_br_faw', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_faw_tiger_v', 'Tiger V', 'veh_comm_br_faw', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_faw_ca1080', 'CA1080', 'veh_comm_br_faw', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_faw_ca1160', 'CA1160', 'veh_comm_br_faw', 'model', 5, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_nissan_ud', 'Nissan UD', 'veh_commercial', 'brand', 17, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/nissan.svg', '#C3002F');
SELECT public._seed_comm_node('veh_comm_br_nissan_ud_condor', 'Condor', 'veh_comm_br_nissan_ud', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_nissan_ud_quon', 'Quon', 'veh_comm_br_nissan_ud', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_nissan_ud_croner', 'Croner', 'veh_comm_br_nissan_ud', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_nissan_ud_kuzer', 'Kuzer', 'veh_comm_br_nissan_ud', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_ford', 'Ford', 'veh_commercial', 'brand', 18, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/ford.svg', '#003478');
SELECT public._seed_comm_node('veh_comm_br_ford_transit_cargo', 'Transit Cargo', 'veh_comm_br_ford', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_ford_transit_jumbo', 'Transit Jumbo', 'veh_comm_br_ford', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_ford_cargo_truck', 'Cargo Truck', 'veh_comm_br_ford', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_ford_f_series_truck', 'F-Series Truck', 'veh_comm_br_ford', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_renault_trucks', 'Renault Trucks', 'veh_commercial', 'brand', 19, 'https://upload.wikimedia.org/wikipedia/commons/b/b7/Renault_2021_Text.svg', '#FFCC00');
SELECT public._seed_comm_node('veh_comm_br_renault_trucks_t_series', 'T-Series', 'veh_comm_br_renault_trucks', 'model', 1, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_renault_trucks_c_series', 'C-Series', 'veh_comm_br_renault_trucks', 'model', 2, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_renault_trucks_k_series', 'K-Series', 'veh_comm_br_renault_trucks', 'model', 3, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_renault_trucks_d_series', 'D-Series', 'veh_comm_br_renault_trucks', 'model', 4, NULL, NULL);
SELECT public._seed_comm_node('veh_comm_br_renault_trucks_master_cargo', 'Master Cargo', 'veh_comm_br_renault_trucks', 'model', 5, NULL, NULL);

DROP FUNCTION public._seed_comm_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

