-- كرفان (veh_caravan) — RV & caravan brands + models (Iraq market)
-- Safe to re-run: cleans veh_caravan subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_caravan_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_caravan')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_caravan_node('veh_caravan_br_coachmen', 'Coachmen', 'veh_caravan', 'brand', 1, NULL, '#CC0000');
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_freelander_27qb', 'Freelander 27QB', 'veh_caravan_br_coachmen', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_freelander_32bh', 'Freelander 32BH', 'veh_caravan_br_coachmen', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_apex_ultra_lite', 'Apex Ultra-Lite', 'veh_caravan_br_coachmen', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_apex_213rds', 'Apex 213RDS', 'veh_caravan_br_coachmen', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_catalina_184bhs', 'Catalina 184BHS', 'veh_caravan_br_coachmen', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_catalina_243rbs', 'Catalina 243RBS', 'veh_caravan_br_coachmen', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_mirada_35es', 'Mirada 35ES', 'veh_caravan_br_coachmen', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_coachmen_pursuit_31bh', 'Pursuit 31BH', 'veh_caravan_br_coachmen', 'model', 8, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream', 'Airstream', 'veh_caravan', 'brand', 2, NULL, '#C0C0C0');
SELECT public._seed_caravan_node('veh_caravan_br_airstream_bambi_16rb', 'Bambi 16RB', 'veh_caravan_br_airstream', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_sport_22fb', 'Sport 22FB', 'veh_caravan_br_airstream', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_flying_cloud_25fb', 'Flying Cloud 25FB', 'veh_caravan_br_airstream', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_flying_cloud_30rb', 'Flying Cloud 30RB', 'veh_caravan_br_airstream', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_classic_33fb', 'Classic 33FB', 'veh_caravan_br_airstream', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_interstate_24gt', 'Interstate 24GT', 'veh_caravan_br_airstream', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_atlas', 'Atlas', 'veh_caravan_br_airstream', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_airstream_basecamp_20', 'Basecamp 20', 'veh_caravan_br_airstream', 'model', 8, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco', 'Jayco', 'veh_caravan', 'brand', 3, NULL, '#003478');
SELECT public._seed_caravan_node('veh_caravan_br_jayco_jay_feather_22rb', 'Jay Feather 22RB', 'veh_caravan_br_jayco', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_jay_flight_28bhs', 'Jay Flight 28BHS', 'veh_caravan_br_jayco', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_eagle_330rsts', 'Eagle 330RSTS', 'veh_caravan_br_jayco', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_north_point_382flrb', 'North Point 382FLRB', 'veh_caravan_br_jayco', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_redhawk_31f', 'Redhawk 31F', 'veh_caravan_br_jayco', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_greyhawk_31f', 'Greyhawk 31F', 'veh_caravan_br_jayco', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_jayco_pinnacle_36fbts', 'Pinnacle 36FBTS', 'veh_caravan_br_jayco', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor', 'Thor', 'veh_caravan', 'brand', 4, NULL, '#1A1A1A');
SELECT public._seed_caravan_node('veh_caravan_br_thor_ace_27_2', 'Ace 27.2', 'veh_caravan_br_thor', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_chateau_28a', 'Chateau 28A', 'veh_caravan_br_thor', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_magnitude_sv34', 'Magnitude SV34', 'veh_caravan_br_thor', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_windsport_34j', 'Windsport 34J', 'veh_caravan_br_thor', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_venetian_j40', 'Venetian J40', 'veh_caravan_br_thor', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_axis_24_1', 'Axis 24.1', 'veh_caravan_br_thor', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_thor_four_winds_28z', 'Four Winds 28Z', 'veh_caravan_br_thor', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago', 'Winnebago', 'veh_caravan', 'brand', 5, NULL, '#CC0000');
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_micro_minnie_2108ds', 'Micro Minnie 2108DS', 'veh_caravan_br_winnebago', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_minnie_plus_27bhss', 'Minnie Plus 27BHSS', 'veh_caravan_br_winnebago', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_voyage_2831rl', 'Voyage 2831RL', 'veh_caravan_br_winnebago', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_vista_29ve', 'Vista 29VE', 'veh_caravan_br_winnebago', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_intent_29l', 'Intent 29L', 'veh_caravan_br_winnebago', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_travato_59gl', 'Travato 59GL', 'veh_caravan_br_winnebago', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_ekko_22a', 'Ekko 22A', 'veh_caravan_br_winnebago', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_winnebago_revel_44e', 'Revel 44E', 'veh_caravan_br_winnebago', 'model', 8, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river', 'Forest River', 'veh_caravan', 'brand', 6, NULL, '#006400');
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_rockwood_mini_lite', 'Rockwood Mini Lite', 'veh_caravan_br_forest_river', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_rockwood_signature', 'Rockwood Signature', 'veh_caravan_br_forest_river', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_salem_27rei', 'Salem 27REI', 'veh_caravan_br_forest_river', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_georgetown_5_series', 'Georgetown 5 Series', 'veh_caravan_br_forest_river', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_cherokee_wolf_pup', 'Cherokee Wolf Pup', 'veh_caravan_br_forest_river', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_sunseeker_2860ds', 'Sunseeker 2860DS', 'veh_caravan_br_forest_river', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_forest_river_forester_3011ds', 'Forester 3011DS', 'veh_caravan_br_forest_river', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer', 'Hymer', 'veh_caravan', 'brand', 7, NULL, '#003087');
SELECT public._seed_caravan_node('veh_caravan_br_hymer_b_class_580', 'B-Class 580', 'veh_caravan_br_hymer', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_b_class_680', 'B-Class 680', 'veh_caravan_br_hymer', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_t_class_674', 'T-Class 674', 'veh_caravan_br_hymer', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_s_class_650', 'S-Class 650', 'veh_caravan_br_hymer', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_exsis_t_588', 'Exsis-T 588', 'veh_caravan_br_hymer', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_tramp_650', 'Tramp 650', 'veh_caravan_br_hymer', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hymer_free_600_campus', 'Free 600 Campus', 'veh_caravan_br_hymer', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby', 'Hobby', 'veh_caravan', 'brand', 8, NULL, '#CC0000');
SELECT public._seed_caravan_node('veh_caravan_br_hobby_de_luxe_460ufe', 'De Luxe 460UFe', 'veh_caravan_br_hobby', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby_de_luxe_540ul', 'De Luxe 540UL', 'veh_caravan_br_hobby', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby_excellent_560wfu', 'Excellent 560WFU', 'veh_caravan_br_hobby', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby_prestige_720_wfkt', 'Prestige 720 WFKT', 'veh_caravan_br_hobby', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby_optima_540_ofc', 'Optima 540 OFc', 'veh_caravan_br_hobby', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_hobby_landhaus_770_kmfe', 'Landhaus 770 KMFe', 'veh_caravan_br_hobby', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs', 'Dethleffs', 'veh_caravan', 'brand', 9, NULL, '#003087');
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs_camper_500_qmk', 'Camper 500 QMK', 'veh_caravan_br_dethleffs', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs_camper_650_vfk', 'Camper 650 VFK', 'veh_caravan_br_dethleffs', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs_trend_t_6857_eb', 'Trend T 6857 EB', 'veh_caravan_br_dethleffs', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs_globebus_t1', 'Globebus T1', 'veh_caravan_br_dethleffs', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_dethleffs_pulse_i7', 'Pulse i7', 'veh_caravan_br_dethleffs', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria', 'Adria', 'veh_caravan', 'brand', 10, NULL, '#CC0000');
SELECT public._seed_caravan_node('veh_caravan_br_adria_altea_432_px', 'Altea 432 PX', 'veh_caravan_br_adria', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria_adora_613_ht', 'Adora 613 HT', 'veh_caravan_br_adria', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria_astella_804_hp', 'Astella 804 HP', 'veh_caravan_br_adria', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria_sonic_axess_600_sl', 'Sonic Axess 600 SL', 'veh_caravan_br_adria', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria_matrix_plus_670_sl', 'Matrix Plus 670 SL', 'veh_caravan_br_adria', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_adria_twin_axess_640_slb', 'Twin Axess 640 SLB', 'veh_caravan_br_adria', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_knaus', 'Knaus', 'veh_caravan', 'brand', 11, NULL, '#003087');
SELECT public._seed_caravan_node('veh_caravan_br_knaus_sport_420_qd', 'Sport 420 QD', 'veh_caravan_br_knaus', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_knaus_sun_ti_650_meg', 'Sun TI 650 MEG', 'veh_caravan_br_knaus', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_knaus_s_dwind_590_qf', 'Südwind 590 QF', 'veh_caravan_br_knaus', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_knaus_boxstar_600_mq', 'BoxStar 600 MQ', 'veh_caravan_br_knaus', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_knaus_van_ti_plus_650_meg', 'Van TI Plus 650 MEG', 'veh_caravan_br_knaus', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local', 'كرفان محلي', 'veh_caravan', 'brand', 12, NULL, '#8B4513');
SELECT public._seed_caravan_node('veh_caravan_br_local_toyota_chassis', 'كرفان على شاسيه تويوتا', 'veh_caravan_br_local', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_mitsubishi_chassis', 'كرفان على شاسيه ميتسوبيشي', 'veh_caravan_br_local', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_ford_chassis', 'كرفان على شاسيه فورد', 'veh_caravan_br_local', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_static_camp', 'كرفان ثابت (للمخيمات)', 'veh_caravan_br_local', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_mobile_office', 'كرفان مكتب متنقل', 'veh_caravan_br_local', 'model', 5, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_mobile_clinic', 'كرفان عيادة متنقلة', 'veh_caravan_br_local', 'model', 6, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_local_installment_sale', 'كرفان للبيع بالتقسيط', 'veh_caravan_br_local', 'model', 7, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream', 'Gulf Stream', 'veh_caravan', 'brand', 13, NULL, '#006699');
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream_conquest_6237', 'Conquest 6237', 'veh_caravan_br_gulf_stream', 'model', 1, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream_envision_225rb', 'Envision 225RB', 'veh_caravan_br_gulf_stream', 'model', 2, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream_kingsport_299qb', 'Kingsport 299QB', 'veh_caravan_br_gulf_stream', 'model', 3, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream_innsbruck_295qb', 'Innsbruck 295QB', 'veh_caravan_br_gulf_stream', 'model', 4, NULL, NULL);
SELECT public._seed_caravan_node('veh_caravan_br_gulf_stream_bt_cruiser_5270', 'BT Cruiser 5270', 'veh_caravan_br_gulf_stream', 'model', 5, NULL, NULL);

DROP FUNCTION public._seed_caravan_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

