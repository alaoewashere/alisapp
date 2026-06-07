-- دفع رباعي وبيك أب (veh_suv_pickup) — brands + models (Iraq market)
-- Safe to re-run: cleans veh_suv_pickup subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_suv_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_suv_pickup')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_suv_node('veh_suv_br_toyota', 'Toyota', 'veh_suv_pickup', 'brand', 1, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/toyota.svg', '#EB0A1E');
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_70', 'Land Cruiser 70', 'veh_suv_br_toyota', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_76', 'Land Cruiser 76', 'veh_suv_br_toyota', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_78', 'Land Cruiser 78', 'veh_suv_br_toyota', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_79_pick_up', 'Land Cruiser 79 (Pick Up)', 'veh_suv_br_toyota', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_200', 'Land Cruiser 200', 'veh_suv_br_toyota', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_300', 'Land Cruiser 300', 'veh_suv_br_toyota', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_prado_150', 'Land Cruiser Prado 150', 'veh_suv_br_toyota', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_land_cruiser_prado_120', 'Land Cruiser Prado 120', 'veh_suv_br_toyota', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_fj_cruiser', 'FJ Cruiser', 'veh_suv_br_toyota', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_4runner', '4Runner', 'veh_suv_br_toyota', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_rav4', 'RAV4', 'veh_suv_br_toyota', 'model', 11, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_fortuner', 'Fortuner', 'veh_suv_br_toyota', 'model', 12, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_hilux_pick_up', 'Hilux (Pick Up)', 'veh_suv_br_toyota', 'model', 13, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_hilux_revo', 'Hilux Revo', 'veh_suv_br_toyota', 'model', 14, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_hilux_champ', 'Hilux Champ', 'veh_suv_br_toyota', 'model', 15, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_rush', 'Rush', 'veh_suv_br_toyota', 'model', 16, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_toyota_sequoia', 'Sequoia', 'veh_suv_br_toyota', 'model', 17, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan', 'Nissan', 'veh_suv_pickup', 'brand', 2, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/nissan.svg', '#C3002F');
SELECT public._seed_suv_node('veh_suv_br_nissan_patrol_y61', 'Patrol Y61', 'veh_suv_br_nissan', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_patrol_y62', 'Patrol Y62', 'veh_suv_br_nissan', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_patrol_safari', 'Patrol Safari', 'veh_suv_br_nissan', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_xterra', 'Xterra', 'veh_suv_br_nissan', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_pathfinder', 'Pathfinder', 'veh_suv_br_nissan', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_navara_pick_up', 'Navara (Pick Up)', 'veh_suv_br_nissan', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_frontier_pick_up', 'Frontier (Pick Up)', 'veh_suv_br_nissan', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_murano', 'Murano', 'veh_suv_br_nissan', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_terra', 'Terra', 'veh_suv_br_nissan', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_nissan_x_terra', 'X-Terra', 'veh_suv_br_nissan', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover', 'Land Rover', 'veh_suv_pickup', 'brand', 3, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/land-rover.svg', '#005A2B');
SELECT public._seed_suv_node('veh_suv_br_land_rover_defender_90', 'Defender 90', 'veh_suv_br_land_rover', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_defender_110', 'Defender 110', 'veh_suv_br_land_rover', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_defender_130', 'Defender 130', 'veh_suv_br_land_rover', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_discovery_3', 'Discovery 3', 'veh_suv_br_land_rover', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_discovery_4', 'Discovery 4', 'veh_suv_br_land_rover', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_discovery_5', 'Discovery 5', 'veh_suv_br_land_rover', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_discovery_sport', 'Discovery Sport', 'veh_suv_br_land_rover', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_range_rover', 'Range Rover', 'veh_suv_br_land_rover', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_range_rover_sport', 'Range Rover Sport', 'veh_suv_br_land_rover', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_range_rover_vogue', 'Range Rover Vogue', 'veh_suv_br_land_rover', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_range_rover_evoque', 'Range Rover Evoque', 'veh_suv_br_land_rover', 'model', 11, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_range_rover_velar', 'Range Rover Velar', 'veh_suv_br_land_rover', 'model', 12, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_land_rover_freelander', 'Freelander', 'veh_suv_br_land_rover', 'model', 13, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep', 'Jeep', 'veh_suv_pickup', 'brand', 4, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/jeep.svg', '#1E3A5F');
SELECT public._seed_suv_node('veh_suv_br_jeep_wrangler', 'Wrangler', 'veh_suv_br_jeep', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_wrangler_unlimited', 'Wrangler Unlimited', 'veh_suv_br_jeep', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_grand_cherokee', 'Grand Cherokee', 'veh_suv_br_jeep', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_grand_cherokee_l', 'Grand Cherokee L', 'veh_suv_br_jeep', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_cherokee', 'Cherokee', 'veh_suv_br_jeep', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_compass', 'Compass', 'veh_suv_br_jeep', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_renegade', 'Renegade', 'veh_suv_br_jeep', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_gladiator_pick_up', 'Gladiator (Pick Up)', 'veh_suv_br_jeep', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_jeep_commander', 'Commander', 'veh_suv_br_jeep', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus', 'Lexus', 'veh_suv_pickup', 'brand', 5, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/lexus.svg', '#1A1A1A');
SELECT public._seed_suv_node('veh_suv_br_lexus_lx_570', 'LX 570', 'veh_suv_br_lexus', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_lx_600', 'LX 600', 'veh_suv_br_lexus', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_gx_460', 'GX 460', 'veh_suv_br_lexus', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_gx_550', 'GX 550', 'veh_suv_br_lexus', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_rx_350', 'RX 350', 'veh_suv_br_lexus', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_rx_500h', 'RX 500h', 'veh_suv_br_lexus', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_nx_250', 'NX 250', 'veh_suv_br_lexus', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_nx_350h', 'NX 350h', 'veh_suv_br_lexus', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_ux_200', 'UX 200', 'veh_suv_br_lexus', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lexus_tx_550h', 'TX 550h', 'veh_suv_br_lexus', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc', 'GMC', 'veh_suv_pickup', 'brand', 6, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/gmc.svg', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_gmc_yukon', 'Yukon', 'veh_suv_br_gmc', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_yukon_xl', 'Yukon XL', 'veh_suv_br_gmc', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_tahoe', 'Tahoe', 'veh_suv_br_gmc', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_suburban', 'Suburban', 'veh_suv_br_gmc', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_envoy', 'Envoy', 'veh_suv_br_gmc', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_terrain', 'Terrain', 'veh_suv_br_gmc', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_sierra_pick_up', 'Sierra (Pick Up)', 'veh_suv_br_gmc', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_canyon_pick_up', 'Canyon (Pick Up)', 'veh_suv_br_gmc', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_gmc_jimmy', 'Jimmy', 'veh_suv_br_gmc', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford', 'Ford', 'veh_suv_pickup', 'brand', 7, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/ford.svg', '#003478');
SELECT public._seed_suv_node('veh_suv_br_ford_f_150_pick_up', 'F-150 (Pick Up)', 'veh_suv_br_ford', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_f_250', 'F-250', 'veh_suv_br_ford', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_f_350', 'F-350', 'veh_suv_br_ford', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_raptor', 'Raptor', 'veh_suv_br_ford', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_explorer', 'Explorer', 'veh_suv_br_ford', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_expedition', 'Expedition', 'veh_suv_br_ford', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_bronco', 'Bronco', 'veh_suv_br_ford', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_bronco_sport', 'Bronco Sport', 'veh_suv_br_ford', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_edge', 'Edge', 'veh_suv_br_ford', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_escape', 'Escape', 'veh_suv_br_ford', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_ecosport', 'EcoSport', 'veh_suv_br_ford', 'model', 11, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_ranger_pick_up', 'Ranger (Pick Up)', 'veh_suv_br_ford', 'model', 12, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_ford_everest', 'Everest', 'veh_suv_br_ford', 'model', 13, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet', 'Chevrolet', 'veh_suv_pickup', 'brand', 8, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/chevrolet.svg', '#D4AC0D');
SELECT public._seed_suv_node('veh_suv_br_chevrolet_tahoe', 'Tahoe', 'veh_suv_br_chevrolet', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_suburban', 'Suburban', 'veh_suv_br_chevrolet', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_silverado_pick_up', 'Silverado (Pick Up)', 'veh_suv_br_chevrolet', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_colorado_pick_up', 'Colorado (Pick Up)', 'veh_suv_br_chevrolet', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_blazer', 'Blazer', 'veh_suv_br_chevrolet', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_trailblazer', 'TrailBlazer', 'veh_suv_br_chevrolet', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_captiva', 'Captiva', 'veh_suv_br_chevrolet', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_equinox', 'Equinox', 'veh_suv_br_chevrolet', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_chevrolet_traverse', 'Traverse', 'veh_suv_br_chevrolet', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi', 'Mitsubishi', 'veh_suv_pickup', 'brand', 9, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/mitsubishi.svg', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_pajero', 'Pajero', 'veh_suv_br_mitsubishi', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_pajero_sport', 'Pajero Sport', 'veh_suv_br_mitsubishi', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_pajero_full', 'Pajero Full', 'veh_suv_br_mitsubishi', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_l200_pick_up', 'L200 (Pick Up)', 'veh_suv_br_mitsubishi', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_triton_pick_up', 'Triton (Pick Up)', 'veh_suv_br_mitsubishi', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_outlander', 'Outlander', 'veh_suv_br_mitsubishi', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_eclipse_cross', 'Eclipse Cross', 'veh_suv_br_mitsubishi', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_asx', 'ASX', 'veh_suv_br_mitsubishi', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mitsubishi_montero', 'Montero', 'veh_suv_br_mitsubishi', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia', 'Kia', 'veh_suv_pickup', 'brand', 10, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/kia.svg', '#05141F');
SELECT public._seed_suv_node('veh_suv_br_kia_telluride', 'Telluride', 'veh_suv_br_kia', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia_sorento', 'Sorento', 'veh_suv_br_kia', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia_sportage', 'Sportage', 'veh_suv_br_kia', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia_mohave', 'Mohave', 'veh_suv_br_kia', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia_stonic', 'Stonic', 'veh_suv_br_kia', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_kia_seltos', 'Seltos', 'veh_suv_br_kia', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai', 'Hyundai', 'veh_suv_pickup', 'brand', 11, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/hyundai.svg', '#002C5F');
SELECT public._seed_suv_node('veh_suv_br_hyundai_santa_fe', 'Santa Fe', 'veh_suv_br_hyundai', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_tucson', 'Tucson', 'veh_suv_br_hyundai', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_palisade', 'Palisade', 'veh_suv_br_hyundai', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_creta', 'Creta', 'veh_suv_br_hyundai', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_venue', 'Venue', 'veh_suv_br_hyundai', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_kona', 'Kona', 'veh_suv_br_hyundai', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hyundai_terracan', 'Terracan', 'veh_suv_br_hyundai', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz', 'Mercedes-Benz', 'veh_suv_pickup', 'brand', 12, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/mercedes-benz.svg', '#333333');
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_g_class_g63', 'G-Class G63', 'veh_suv_br_mercedes_benz', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_g_class_g500', 'G-Class G500', 'veh_suv_br_mercedes_benz', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_g_class_g350d', 'G-Class G350d', 'veh_suv_br_mercedes_benz', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_gls_450', 'GLS 450', 'veh_suv_br_mercedes_benz', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_gls_600_maybach', 'GLS 600 Maybach', 'veh_suv_br_mercedes_benz', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_gle_450', 'GLE 450', 'veh_suv_br_mercedes_benz', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_gle_63_amg', 'GLE 63 AMG', 'veh_suv_br_mercedes_benz', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_glc_300', 'GLC 300', 'veh_suv_br_mercedes_benz', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_gla_200', 'GLA 200', 'veh_suv_br_mercedes_benz', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_glb_200', 'GLB 200', 'veh_suv_br_mercedes_benz', 'model', 10, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mercedes_benz_x_class_pick_up', 'X-Class (Pick Up)', 'veh_suv_br_mercedes_benz', 'model', 11, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw', 'BMW', 'veh_suv_pickup', 'brand', 13, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/bmw.svg', '#1C69D4');
SELECT public._seed_suv_node('veh_suv_br_bmw_x1', 'X1', 'veh_suv_br_bmw', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x2', 'X2', 'veh_suv_br_bmw', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x3', 'X3', 'veh_suv_br_bmw', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x4', 'X4', 'veh_suv_br_bmw', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x5', 'X5', 'veh_suv_br_bmw', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x6', 'X6', 'veh_suv_br_bmw', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_x7', 'X7', 'veh_suv_br_bmw', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_bmw_xm', 'XM', 'veh_suv_br_bmw', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi', 'Audi', 'veh_suv_pickup', 'brand', 14, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/audi.svg', '#BB0A30');
SELECT public._seed_suv_node('veh_suv_br_audi_q2', 'Q2', 'veh_suv_br_audi', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q3', 'Q3', 'veh_suv_br_audi', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q4', 'Q4', 'veh_suv_br_audi', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q5', 'Q5', 'veh_suv_br_audi', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q6', 'Q6', 'veh_suv_br_audi', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q7', 'Q7', 'veh_suv_br_audi', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_q8', 'Q8', 'veh_suv_br_audi', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_sq7', 'SQ7', 'veh_suv_br_audi', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_audi_rsq8', 'RSQ8', 'veh_suv_br_audi', 'model', 9, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche', 'Porsche', 'veh_suv_pickup', 'brand', 15, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/porsche.svg', '#000000');
SELECT public._seed_suv_node('veh_suv_br_porsche_cayenne', 'Cayenne', 'veh_suv_br_porsche', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche_cayenne_gts', 'Cayenne GTS', 'veh_suv_br_porsche', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche_cayenne_turbo', 'Cayenne Turbo', 'veh_suv_br_porsche', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche_macan', 'Macan', 'veh_suv_br_porsche', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche_macan_s', 'Macan S', 'veh_suv_br_porsche', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_porsche_macan_gts', 'Macan GTS', 'veh_suv_br_porsche', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_dodge', 'Dodge', 'veh_suv_pickup', 'brand', 16, 'https://www.carlogos.org/car-logos/dodge-logo.png', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_dodge_durango', 'Durango', 'veh_suv_br_dodge', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_dodge_journey', 'Journey', 'veh_suv_br_dodge', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_dodge_ram_1500_pick_up', 'Ram 1500 (Pick Up)', 'veh_suv_br_dodge', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_dodge_ram_2500', 'Ram 2500', 'veh_suv_br_dodge', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_dodge_ram_3500', 'Ram 3500', 'veh_suv_br_dodge', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti', 'Infiniti', 'veh_suv_pickup', 'brand', 17, 'https://www.carlogos.org/car-logos/infiniti-logo.png', '#1A1A1A');
SELECT public._seed_suv_node('veh_suv_br_infiniti_qx80', 'QX80', 'veh_suv_br_infiniti', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_qx60', 'QX60', 'veh_suv_br_infiniti', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_qx55', 'QX55', 'veh_suv_br_infiniti', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_qx50', 'QX50', 'veh_suv_br_infiniti', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_fx35', 'FX35', 'veh_suv_br_infiniti', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_fx37', 'FX37', 'veh_suv_br_infiniti', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_fx50', 'FX50', 'veh_suv_br_infiniti', 'model', 7, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_infiniti_ex35', 'EX35', 'veh_suv_br_infiniti', 'model', 8, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac', 'Cadillac', 'veh_suv_pickup', 'brand', 18, 'https://www.carlogos.org/car-logos/cadillac-logo.png', '#2C2C2C');
SELECT public._seed_suv_node('veh_suv_br_cadillac_escalade', 'Escalade', 'veh_suv_br_cadillac', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac_escalade_esv', 'Escalade ESV', 'veh_suv_br_cadillac', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac_xt4', 'XT4', 'veh_suv_br_cadillac', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac_xt5', 'XT5', 'veh_suv_br_cadillac', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac_xt6', 'XT6', 'veh_suv_br_cadillac', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_cadillac_srx', 'SRX', 'veh_suv_br_cadillac', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln', 'Lincoln', 'veh_suv_pickup', 'brand', 19, 'https://www.carlogos.org/car-logos/lincoln-logo.png', '#2C2C2C');
SELECT public._seed_suv_node('veh_suv_br_lincoln_navigator', 'Navigator', 'veh_suv_br_lincoln', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln_navigator_l', 'Navigator L', 'veh_suv_br_lincoln', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln_aviator', 'Aviator', 'veh_suv_br_lincoln', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln_nautilus', 'Nautilus', 'veh_suv_br_lincoln', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln_mkx', 'MKX', 'veh_suv_br_lincoln', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_lincoln_mkt', 'MKT', 'veh_suv_br_lincoln', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volkswagen', 'Volkswagen', 'veh_suv_pickup', 'brand', 20, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/volkswagen.svg', '#001E50');
SELECT public._seed_suv_node('veh_suv_br_volkswagen_touareg', 'Touareg', 'veh_suv_br_volkswagen', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volkswagen_tiguan', 'Tiguan', 'veh_suv_br_volkswagen', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volkswagen_t_roc', 'T-Roc', 'veh_suv_br_volkswagen', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volkswagen_amarok_pick_up', 'Amarok (Pick Up)', 'veh_suv_br_volkswagen', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volkswagen_teramont', 'Teramont', 'veh_suv_br_volkswagen', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval', 'Haval', 'veh_suv_pickup', 'brand', 21, 'https://www.carlogos.org/car-logos/haval-logo.png', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_haval_h6', 'H6', 'veh_suv_br_haval', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval_h9', 'H9', 'veh_suv_br_haval', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval_jolion', 'Jolion', 'veh_suv_br_haval', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval_dargo', 'Dargo', 'veh_suv_br_haval', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval_big_dog', 'Big Dog', 'veh_suv_br_haval', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_haval_shenshou', 'Shenshou', 'veh_suv_br_haval', 'model', 6, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mg', 'MG', 'veh_suv_pickup', 'brand', 22, 'https://www.carlogos.org/car-logos/mg-logo.png', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_mg_mg_hs', 'MG HS', 'veh_suv_br_mg', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mg_mg_zs', 'MG ZS', 'veh_suv_br_mg', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mg_mg_rx8', 'MG RX8', 'veh_suv_br_mg', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mg_mg_vs_hev', 'MG VS HEV', 'veh_suv_br_mg', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_mg_extender_pick_up', 'Extender (Pick Up)', 'veh_suv_br_mg', 'model', 5, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_isuzu', 'Isuzu', 'veh_suv_pickup', 'brand', 23, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/isuzu.svg', '#CC0000');
SELECT public._seed_suv_node('veh_suv_br_isuzu_d_max_pick_up', 'D-Max (Pick Up)', 'veh_suv_br_isuzu', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_isuzu_d_max_v_cross', 'D-Max V-Cross', 'veh_suv_br_isuzu', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_isuzu_mu_x', 'MU-X', 'veh_suv_br_isuzu', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hummer', 'Hummer', 'veh_suv_pickup', 'brand', 24, 'https://www.carlogos.org/car-logos/hummer-logo.png', '#2C2C2C');
SELECT public._seed_suv_node('veh_suv_br_hummer_h1', 'H1', 'veh_suv_br_hummer', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hummer_h2', 'H2', 'veh_suv_br_hummer', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hummer_h3', 'H3', 'veh_suv_br_hummer', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_hummer_ev_pick_up', 'EV (Pick Up)', 'veh_suv_br_hummer', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_subaru', 'Subaru', 'veh_suv_pickup', 'brand', 25, 'https://www.carlogos.org/car-logos/subaru-logo.png', '#003399');
SELECT public._seed_suv_node('veh_suv_br_subaru_forester', 'Forester', 'veh_suv_br_subaru', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_subaru_outback', 'Outback', 'veh_suv_br_subaru', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_subaru_xv', 'XV', 'veh_suv_br_subaru', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_subaru_ascent', 'Ascent', 'veh_suv_br_subaru', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volvo', 'Volvo', 'veh_suv_pickup', 'brand', 26, 'https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos/volvo.svg', '#003057');
SELECT public._seed_suv_node('veh_suv_br_volvo_xc40', 'XC40', 'veh_suv_br_volvo', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volvo_xc60', 'XC60', 'veh_suv_br_volvo', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volvo_xc90', 'XC90', 'veh_suv_br_volvo', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_volvo_v90_cross_country', 'V90 Cross Country', 'veh_suv_br_volvo', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_suzuki', 'Suzuki', 'veh_suv_pickup', 'brand', 27, 'https://www.carlogos.org/car-logos/suzuki-logo.png', '#1A1A1A');
SELECT public._seed_suv_node('veh_suv_br_suzuki_vitara', 'Vitara', 'veh_suv_br_suzuki', 'model', 1, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_suzuki_grand_vitara', 'Grand Vitara', 'veh_suv_br_suzuki', 'model', 2, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_suzuki_jimny', 'Jimny', 'veh_suv_br_suzuki', 'model', 3, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_suzuki_s_cross', 'S-Cross', 'veh_suv_br_suzuki', 'model', 4, NULL, NULL);
SELECT public._seed_suv_node('veh_suv_br_suzuki_equator_pick_up', 'Equator (Pick Up)', 'veh_suv_br_suzuki', 'model', 5, NULL, NULL);

DROP FUNCTION public._seed_suv_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

