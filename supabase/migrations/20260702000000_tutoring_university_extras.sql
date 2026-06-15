-- Extra university tutoring subjects under tutor_university (53 leaves)
-- Safe to re-run: upserts by slug.

CREATE OR REPLACE FUNCTION public._seed_tutor_node(
  p_slug TEXT,
  p_name_ar TEXT,
  p_parent_slug TEXT,
  p_icon TEXT DEFAULT 'category',
  p_display_order INT DEFAULT 0,
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
    slug, name_ar, name_ku, name_en, icon, parent_id, display_order, sort_order, color_hex
  )
  VALUES (
    p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id,
    p_display_order, p_display_order, p_color_hex
  )
  ON CONFLICT (slug) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_ku = NULL,
    name_en = NULL,
    icon = EXCLUDED.icon,
    parent_id = EXCLUDED.parent_id,
    display_order = EXCLUDED.display_order,
    sort_order = EXCLUDED.sort_order,
    color_hex = EXCLUDED.color_hex;
END;
$$ LANGUAGE plpgsql;

-- Engineering & Technology
SELECT public._seed_tutor_node('tutor_uni_petroleum_eng', 'هندسة النفط والغاز', 'tutor_university', 'model', 24, NULL);
SELECT public._seed_tutor_node('tutor_uni_chemical_eng', 'هندسة الكيمياء', 'tutor_university', 'model', 25, NULL);
SELECT public._seed_tutor_node('tutor_uni_environmental_eng', 'هندسة البيئة', 'tutor_university', 'model', 26, NULL);
SELECT public._seed_tutor_node('tutor_uni_laser_optics', 'هندسة الليزر والبصريات', 'tutor_university', 'model', 27, NULL);
SELECT public._seed_tutor_node('tutor_uni_materials_eng', 'هندسة المواد', 'tutor_university', 'model', 28, NULL);
SELECT public._seed_tutor_node('tutor_uni_mechatronics', 'هندسة الميكاترونيكس', 'tutor_university', 'model', 29, NULL);
SELECT public._seed_tutor_node('tutor_uni_telecom_eng', 'هندسة الاتصالات', 'tutor_university', 'model', 30, NULL);
SELECT public._seed_tutor_node('tutor_uni_electronics_eng', 'هندسة الإلكترونيات', 'tutor_university', 'model', 31, NULL);
SELECT public._seed_tutor_node('tutor_uni_hvac_eng', 'هندسة التبريد والتكييف', 'tutor_university', 'model', 32, NULL);
SELECT public._seed_tutor_node('tutor_uni_geomatics', 'هندسة الجيوماتكس والمساحة', 'tutor_university', 'model', 33, NULL);
SELECT public._seed_tutor_node('tutor_uni_production_eng', 'هندسة الإنتاج والمعادن', 'tutor_university', 'model', 34, NULL);
SELECT public._seed_tutor_node('tutor_uni_aerospace_eng', 'هندسة الطيران', 'tutor_university', 'model', 35, NULL);

-- Medical & Health
SELECT public._seed_tutor_node('tutor_uni_dentistry', 'طب الأسنان', 'tutor_university', 'model', 36, NULL);
SELECT public._seed_tutor_node('tutor_uni_microbiology', 'علم الأحياء المجهرية', 'tutor_university', 'model', 37, NULL);
SELECT public._seed_tutor_node('tutor_uni_pathology', 'التحليلات المرضية', 'tutor_university', 'model', 38, NULL);
SELECT public._seed_tutor_node('tutor_uni_physiotherapy', 'العلاج الطبيعي وإعادة التأهيل', 'tutor_university', 'model', 39, NULL);
SELECT public._seed_tutor_node('tutor_uni_radiology', 'علم الأشعة والتصوير الطبي', 'tutor_university', 'model', 40, NULL);
SELECT public._seed_tutor_node('tutor_uni_physiology', 'علم وظائف الأعضاء', 'tutor_university', 'model', 41, NULL);
SELECT public._seed_tutor_node('tutor_uni_pharmacology', 'علم الأدوية والسموم', 'tutor_university', 'model', 42, NULL);
SELECT public._seed_tutor_node('tutor_uni_veterinary', 'الطب البيطري', 'tutor_university', 'model', 43, NULL);
SELECT public._seed_tutor_node('tutor_uni_environmental_health', 'صحة البيئة', 'tutor_university', 'model', 44, NULL);

-- Science
SELECT public._seed_tutor_node('tutor_uni_astronomy', 'علم الفلك والفضاء', 'tutor_university', 'model', 45, NULL);
SELECT public._seed_tutor_node('tutor_uni_geology', 'الجيولوجيا والمعادن', 'tutor_university', 'model', 46, NULL);
SELECT public._seed_tutor_node('tutor_uni_biology', 'علم الأحياء', 'tutor_university', 'model', 47, NULL);
SELECT public._seed_tutor_node('tutor_uni_statistics', 'الإحصاء والبيانات', 'tutor_university', 'model', 48, NULL);
SELECT public._seed_tutor_node('tutor_uni_ecology', 'علم البيئة', 'tutor_university', 'model', 49, NULL);

-- Business & Social
SELECT public._seed_tutor_node('tutor_uni_mba', 'إدارة الأعمال MBA', 'tutor_university', 'model', 50, NULL);
SELECT public._seed_tutor_node('tutor_uni_marketing', 'التسويق والمبيعات', 'tutor_university', 'model', 51, NULL);
SELECT public._seed_tutor_node('tutor_uni_hr', 'إدارة الموارد البشرية', 'tutor_university', 'model', 52, NULL);
SELECT public._seed_tutor_node('tutor_uni_islamic_finance', 'المالية والمصارف الإسلامية', 'tutor_university', 'model', 53, NULL);
SELECT public._seed_tutor_node('tutor_uni_political_sci', 'العلوم السياسية والعلاقات الدولية', 'tutor_university', 'model', 54, NULL);
SELECT public._seed_tutor_node('tutor_uni_sociology', 'علم الاجتماع والأنثروبولوجيا', 'tutor_university', 'model', 55, NULL);
SELECT public._seed_tutor_node('tutor_uni_psychology', 'علم النفس', 'tutor_university', 'model', 56, NULL);
SELECT public._seed_tutor_node('tutor_uni_geography', 'الجغرافية والتخطيط العمراني', 'tutor_university', 'model', 57, NULL);
SELECT public._seed_tutor_node('tutor_uni_public_admin', 'الإدارة العامة والحكومية', 'tutor_university', 'model', 58, NULL);
SELECT public._seed_tutor_node('tutor_uni_tourism', 'السياحة والفنادق', 'tutor_university', 'model', 59, NULL);

-- Arts & Humanities
SELECT public._seed_tutor_node('tutor_uni_philosophy', 'الفلسفة', 'tutor_university', 'model', 60, NULL);
SELECT public._seed_tutor_node('tutor_uni_history', 'التاريخ والحضارات', 'tutor_university', 'model', 61, NULL);
SELECT public._seed_tutor_node('tutor_uni_archaeology', 'الآثار والتراث', 'tutor_university', 'model', 62, NULL);
SELECT public._seed_tutor_node('tutor_uni_fine_arts', 'الفنون الجميلة والتشكيلية', 'tutor_university', 'model', 63, NULL);
SELECT public._seed_tutor_node('tutor_uni_music_arts', 'الموسيقى والفنون الأدائية', 'tutor_university', 'model', 64, NULL);
SELECT public._seed_tutor_node('tutor_uni_french_lit', 'اللغة الفرنسية وآدابها', 'tutor_university', 'model', 65, NULL);
SELECT public._seed_tutor_node('tutor_uni_persian_lit', 'اللغة الفارسية وآدابها', 'tutor_university', 'model', 66, NULL);
SELECT public._seed_tutor_node('tutor_uni_turkish_lit', 'اللغة التركية وآدابها', 'tutor_university', 'model', 67, NULL);
SELECT public._seed_tutor_node('tutor_uni_translation', 'الترجمة والتعريب', 'tutor_university', 'model', 68, NULL);

-- Education
SELECT public._seed_tutor_node('tutor_uni_sports_edu', 'التربية الرياضية', 'tutor_university', 'model', 69, NULL);
SELECT public._seed_tutor_node('tutor_uni_special_edu', 'تربية خاصة واحتياجات خاصة', 'tutor_university', 'model', 70, NULL);
SELECT public._seed_tutor_node('tutor_uni_early_edu', 'رياض الأطفال والتربية المبكرة', 'tutor_university', 'model', 71, NULL);
SELECT public._seed_tutor_node('tutor_uni_edu_tech', 'تكنولوجيا التعليم', 'tutor_university', 'model', 72, NULL);

-- Agriculture & Environment
SELECT public._seed_tutor_node('tutor_uni_agri_eng', 'الهندسة الزراعية', 'tutor_university', 'model', 73, NULL);
SELECT public._seed_tutor_node('tutor_uni_food_science', 'علوم الغذاء والتغذية', 'tutor_university', 'model', 74, NULL);
SELECT public._seed_tutor_node('tutor_uni_animal_sci', 'الثروة الحيوانية والدواجن', 'tutor_university', 'model', 75, NULL);
SELECT public._seed_tutor_node('tutor_uni_water_resources', 'الموارد المائية والري', 'tutor_university', 'model', 76, NULL);

DROP FUNCTION IF EXISTS public._seed_tutor_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
