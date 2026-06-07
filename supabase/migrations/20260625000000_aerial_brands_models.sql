-- مركبات جوية (veh_aircraft) — طائرات / مروحيات → brand → model
-- Safe to re-run: cleans veh_aircraft subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_aerial_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'veh_aircraft')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_aerial_node('veh_aircraft_planes', 'طائرات', 'veh_aircraft', 'category', 1, NULL, '#003478');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna', 'Cessna', 'veh_aircraft_planes', 'brand', 1, NULL, '#003478');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_172_skyhawk', 'Cessna 172 Skyhawk', 'veh_aircraft_planes_br_cessna', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_182_skylane', 'Cessna 182 Skylane', 'veh_aircraft_planes_br_cessna', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_206_stationair', 'Cessna 206 Stationair', 'veh_aircraft_planes_br_cessna', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_208_caravan', 'Cessna 208 Caravan', 'veh_aircraft_planes_br_cessna', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_210_centurion', 'Cessna 210 Centurion', 'veh_aircraft_planes_br_cessna', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_310', 'Cessna 310', 'veh_aircraft_planes_br_cessna', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_337_skymaster', 'Cessna 337 Skymaster', 'veh_aircraft_planes_br_cessna', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_citation_cj3', 'Cessna Citation CJ3', 'veh_aircraft_planes_br_cessna', 'model', 8, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_citation_xls', 'Cessna Citation XLS', 'veh_aircraft_planes_br_cessna', 'model', 9, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cessna_cessna_citation_latitude', 'Cessna Citation Latitude', 'veh_aircraft_planes_br_cessna', 'model', 10, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper', 'Piper', 'veh_aircraft_planes', 'brand', 2, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_28_cherokee', 'Piper PA-28 Cherokee', 'veh_aircraft_planes_br_piper', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_32_cherokee_six', 'Piper PA-32 Cherokee Six', 'veh_aircraft_planes_br_piper', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_34_seneca', 'Piper PA-34 Seneca', 'veh_aircraft_planes_br_piper', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_44_seminole', 'Piper PA-44 Seminole', 'veh_aircraft_planes_br_piper', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_46_malibu', 'Piper PA-46 Malibu', 'veh_aircraft_planes_br_piper', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_pa_46_meridian', 'Piper PA-46 Meridian', 'veh_aircraft_planes_br_piper', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_m600', 'Piper M600', 'veh_aircraft_planes_br_piper', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_piper_piper_archer_tx', 'Piper Archer TX', 'veh_aircraft_planes_br_piper', 'model', 8, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft', 'Beechcraft', 'veh_aircraft_planes', 'brand', 3, NULL, '#1A1A1A');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_bonanza_g36', 'Bonanza G36', 'veh_aircraft_planes_br_beechcraft', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_baron_g58', 'Baron G58', 'veh_aircraft_planes_br_beechcraft', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_king_air_c90', 'King Air C90', 'veh_aircraft_planes_br_beechcraft', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_king_air_200', 'King Air 200', 'veh_aircraft_planes_br_beechcraft', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_king_air_350', 'King Air 350', 'veh_aircraft_planes_br_beechcraft', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_beechjet_400a', 'Beechjet 400A', 'veh_aircraft_planes_br_beechcraft', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_beechcraft_premier_i', 'Premier I', 'veh_aircraft_planes_br_beechcraft', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cirrus', 'Cirrus', 'veh_aircraft_planes', 'brand', 4, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cirrus_sr20', 'SR20', 'veh_aircraft_planes_br_cirrus', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cirrus_sr22', 'SR22', 'veh_aircraft_planes_br_cirrus', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cirrus_sr22t', 'SR22T', 'veh_aircraft_planes_br_cirrus', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_cirrus_vision_jet_sf50', 'Vision Jet SF50', 'veh_aircraft_planes_br_cirrus', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_diamond', 'Diamond', 'veh_aircraft_planes', 'brand', 5, NULL, '#003087');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_diamond_da20', 'DA20', 'veh_aircraft_planes_br_diamond', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_diamond_da40', 'DA40', 'veh_aircraft_planes_br_diamond', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_diamond_da42_twin_star', 'DA42 Twin Star', 'veh_aircraft_planes_br_diamond', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_diamond_da62', 'DA62', 'veh_aircraft_planes_br_diamond', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream', 'Gulfstream', 'veh_aircraft_planes', 'brand', 6, NULL, '#1A1A1A');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g280', 'G280', 'veh_aircraft_planes_br_gulfstream', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g450', 'G450', 'veh_aircraft_planes_br_gulfstream', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g550', 'G550', 'veh_aircraft_planes_br_gulfstream', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g600', 'G600', 'veh_aircraft_planes_br_gulfstream', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g650', 'G650', 'veh_aircraft_planes_br_gulfstream', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g700', 'G700', 'veh_aircraft_planes_br_gulfstream', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_gulfstream_g800', 'G800', 'veh_aircraft_planes_br_gulfstream', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier', 'Bombardier', 'veh_aircraft_planes', 'brand', 7, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_learjet_75', 'Learjet 75', 'veh_aircraft_planes_br_bombardier', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_challenger_300', 'Challenger 300', 'veh_aircraft_planes_br_bombardier', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_challenger_350', 'Challenger 350', 'veh_aircraft_planes_br_bombardier', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_challenger_605', 'Challenger 605', 'veh_aircraft_planes_br_bombardier', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_challenger_650', 'Challenger 650', 'veh_aircraft_planes_br_bombardier', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_global_5500', 'Global 5500', 'veh_aircraft_planes_br_bombardier', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_global_6500', 'Global 6500', 'veh_aircraft_planes_br_bombardier', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_bombardier_global_7500', 'Global 7500', 'veh_aircraft_planes_br_bombardier', 'model', 8, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon', 'Dassault Falcon', 'veh_aircraft_planes', 'brand', 8, NULL, '#003087');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_2000', 'Falcon 2000', 'veh_aircraft_planes_br_dassault_falcon', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_2000lx', 'Falcon 2000LX', 'veh_aircraft_planes_br_dassault_falcon', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_6x', 'Falcon 6X', 'veh_aircraft_planes_br_dassault_falcon', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_7x', 'Falcon 7X', 'veh_aircraft_planes_br_dassault_falcon', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_8x', 'Falcon 8X', 'veh_aircraft_planes_br_dassault_falcon', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_dassault_falcon_falcon_10x', 'Falcon 10X', 'veh_aircraft_planes_br_dassault_falcon', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer', 'Embraer', 'veh_aircraft_planes', 'brand', 9, NULL, '#003478');
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_phenom_100', 'Phenom 100', 'veh_aircraft_planes_br_embraer', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_phenom_300', 'Phenom 300', 'veh_aircraft_planes_br_embraer', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_praetor_500', 'Praetor 500', 'veh_aircraft_planes_br_embraer', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_praetor_600', 'Praetor 600', 'veh_aircraft_planes_br_embraer', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_legacy_450', 'Legacy 450', 'veh_aircraft_planes_br_embraer', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_planes_br_embraer_legacy_500', 'Legacy 500', 'veh_aircraft_planes_br_embraer', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters', 'مروحيات', 'veh_aircraft', 'category', 2, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson', 'Robinson', 'veh_aircraft_helicopters', 'brand', 1, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson_r22_beta_ii', 'R22 Beta II', 'veh_aircraft_helicopters_br_robinson', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson_r44_raven_i', 'R44 Raven I', 'veh_aircraft_helicopters_br_robinson', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson_r44_raven_ii', 'R44 Raven II', 'veh_aircraft_helicopters_br_robinson', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson_r44_cadet', 'R44 Cadet', 'veh_aircraft_helicopters_br_robinson', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_robinson_r66_turbine', 'R66 Turbine', 'veh_aircraft_helicopters_br_robinson', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell', 'Bell', 'veh_aircraft_helicopters', 'brand', 2, NULL, '#003478');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_206_jetranger', 'Bell 206 JetRanger', 'veh_aircraft_helicopters_br_bell', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_206l_longranger', 'Bell 206L LongRanger', 'veh_aircraft_helicopters_br_bell', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_407', 'Bell 407', 'veh_aircraft_helicopters_br_bell', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_407gxi', 'Bell 407GXi', 'veh_aircraft_helicopters_br_bell', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_412', 'Bell 412', 'veh_aircraft_helicopters_br_bell', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_429', 'Bell 429', 'veh_aircraft_helicopters_br_bell', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_430', 'Bell 430', 'veh_aircraft_helicopters_br_bell', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_505_jet_ranger_x', 'Bell 505 Jet Ranger X', 'veh_aircraft_helicopters_br_bell', 'model', 8, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_525_relentless', 'Bell 525 Relentless', 'veh_aircraft_helicopters_br_bell', 'model', 9, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_bell_bell_47_classic', 'Bell 47 (Classic)', 'veh_aircraft_helicopters_br_bell', 'model', 10, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters', 'Airbus Helicopters', 'veh_aircraft_helicopters', 'brand', 3, NULL, '#00205B');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h125_as350', 'H125 (AS350 Écureuil)', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h130', 'H130', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h135', 'H135', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h145', 'H145', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h155', 'H155', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h160', 'H160', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h175', 'H175', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h215_super_puma', 'H215 Super Puma', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 8, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_h225_super_puma', 'H225 Super Puma', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 9, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_airbus_helicopters_ec120_colibri', 'EC120 Colibri', 'veh_aircraft_helicopters_br_airbus_helicopters', 'model', 10, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo', 'Leonardo', 'veh_aircraft_helicopters', 'brand', 4, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw109', 'AW109', 'veh_aircraft_helicopters_br_leonardo', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw119_koala', 'AW119 Koala', 'veh_aircraft_helicopters_br_leonardo', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw139', 'AW139', 'veh_aircraft_helicopters_br_leonardo', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw169', 'AW169', 'veh_aircraft_helicopters_br_leonardo', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw189', 'AW189', 'veh_aircraft_helicopters_br_leonardo', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw101_merlin', 'AW101 Merlin', 'veh_aircraft_helicopters_br_leonardo', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_leonardo_aw609_tiltrotor', 'AW609 (Tiltrotor)', 'veh_aircraft_helicopters_br_leonardo', 'model', 7, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky', 'Sikorsky', 'veh_aircraft_helicopters', 'brand', 5, NULL, '#003478');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_76_spirit', 'S-76 Spirit', 'veh_aircraft_helicopters_br_sikorsky', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_76d', 'S-76D', 'veh_aircraft_helicopters_br_sikorsky', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_92', 'S-92', 'veh_aircraft_helicopters_br_sikorsky', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_300c', 'S-300C', 'veh_aircraft_helicopters_br_sikorsky', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_333', 'S-333', 'veh_aircraft_helicopters_br_sikorsky', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_sikorsky_s_434', 'S-434', 'veh_aircraft_helicopters_br_sikorsky', 'model', 6, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters', 'MD Helicopters', 'veh_aircraft_helicopters', 'brand', 6, NULL, '#1A1A1A');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters_md_500e', 'MD 500E', 'veh_aircraft_helicopters_br_md_helicopters', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters_md_520n_notar', 'MD 520N NOTAR', 'veh_aircraft_helicopters_br_md_helicopters', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters_md_530f', 'MD 530F', 'veh_aircraft_helicopters_br_md_helicopters', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters_md_600n', 'MD 600N', 'veh_aircraft_helicopters_br_md_helicopters', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_md_helicopters_md_902_explorer', 'MD 902 Explorer', 'veh_aircraft_helicopters_br_md_helicopters', 'model', 5, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil', 'Mil', 'veh_aircraft_helicopters', 'brand', 7, NULL, '#CC0000');
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil_mi_8', 'Mi-8', 'veh_aircraft_helicopters_br_mil', 'model', 1, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil_mi_17', 'Mi-17', 'veh_aircraft_helicopters_br_mil', 'model', 2, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil_mi_171', 'Mi-171', 'veh_aircraft_helicopters_br_mil', 'model', 3, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil_mi_26', 'Mi-26', 'veh_aircraft_helicopters_br_mil', 'model', 4, NULL, NULL);
SELECT public._seed_aerial_node('veh_aircraft_helicopters_br_mil_mi_2', 'Mi-2', 'veh_aircraft_helicopters_br_mil', 'model', 5, NULL, NULL);

DROP FUNCTION public._seed_aerial_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);

