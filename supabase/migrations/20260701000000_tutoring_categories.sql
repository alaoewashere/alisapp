-- دروس خصوصية — 5 branches + 64 subject leaves (2-level tree)
-- Safe to re-run: cleans tutoring subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

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

DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'tutoring')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

-- Level 1 — main branches
SELECT public._seed_tutor_node('tutor_school', 'دروس المدرسة', 'tutoring', 'category', 1, '#4CAF50');
SELECT public._seed_tutor_node('tutor_university', 'دروس جامعية', 'tutoring', 'category', 2, '#2196F3');
SELECT public._seed_tutor_node('tutor_languages', 'تعليم اللغات', 'tutoring', 'category', 3, '#FF9800');
SELECT public._seed_tutor_node('tutor_quran', 'القرآن والعلوم الدينية', 'tutoring', 'category', 4, '#009688');
SELECT public._seed_tutor_node('tutor_professional', 'مهارات مهنية وتقنية', 'tutoring', 'category', 5, '#9C27B0');

-- Level 2 — دروس المدرسة
SELECT public._seed_tutor_node('tutor_school_math', 'الرياضيات', 'tutor_school', 'model', 1, NULL);
SELECT public._seed_tutor_node('tutor_school_physics', 'الفيزياء', 'tutor_school', 'model', 2, NULL);
SELECT public._seed_tutor_node('tutor_school_chemistry', 'الكيمياء', 'tutor_school', 'model', 3, NULL);
SELECT public._seed_tutor_node('tutor_school_biology', 'الأحياء', 'tutor_school', 'model', 4, NULL);
SELECT public._seed_tutor_node('tutor_school_arabic', 'اللغة العربية', 'tutor_school', 'model', 5, NULL);
SELECT public._seed_tutor_node('tutor_school_english', 'اللغة الإنجليزية', 'tutor_school', 'model', 6, NULL);
SELECT public._seed_tutor_node('tutor_school_history_geo', 'التاريخ والجغرافية', 'tutor_school', 'model', 7, NULL);
SELECT public._seed_tutor_node('tutor_school_islamic', 'التربية الإسلامية', 'tutor_school', 'model', 8, NULL);
SELECT public._seed_tutor_node('tutor_school_science', 'العلوم العامة', 'tutor_school', 'model', 9, NULL);
SELECT public._seed_tutor_node('tutor_school_computer', 'الحاسوب والتقنية', 'tutor_school', 'model', 10, NULL);
SELECT public._seed_tutor_node('tutor_school_civic', 'التربية الوطنية', 'tutor_school', 'model', 11, NULL);
SELECT public._seed_tutor_node('tutor_school_grade6', 'مواد الصف السادس الابتدائي', 'tutor_school', 'model', 12, NULL);
SELECT public._seed_tutor_node('tutor_school_grade9', 'مواد الثالث المتوسط', 'tutor_school', 'model', 13, NULL);
SELECT public._seed_tutor_node('tutor_school_grade12_sci', 'مواد السادس الإعدادي (علمي)', 'tutor_school', 'model', 14, NULL);
SELECT public._seed_tutor_node('tutor_school_grade12_art', 'مواد السادس الإعدادي (أدبي)', 'tutor_school', 'model', 15, NULL);

-- Level 2 — دروس جامعية
SELECT public._seed_tutor_node('tutor_uni_software_eng', 'هندسة البرمجيات', 'tutor_university', 'model', 1, NULL);
SELECT public._seed_tutor_node('tutor_uni_cs', 'علوم الحاسوب', 'tutor_university', 'model', 2, NULL);
SELECT public._seed_tutor_node('tutor_uni_ai', 'الذكاء الاصطناعي', 'tutor_university', 'model', 3, NULL);
SELECT public._seed_tutor_node('tutor_uni_algorithms', 'الخوارزميات وهياكل البيانات', 'tutor_university', 'model', 4, NULL);
SELECT public._seed_tutor_node('tutor_uni_databases', 'قواعد البيانات', 'tutor_university', 'model', 5, NULL);
SELECT public._seed_tutor_node('tutor_uni_networks', 'شبكات الحاسوب', 'tutor_university', 'model', 6, NULL);
SELECT public._seed_tutor_node('tutor_uni_electrical_eng', 'الهندسة الكهربائية', 'tutor_university', 'model', 7, NULL);
SELECT public._seed_tutor_node('tutor_uni_civil_eng', 'الهندسة المدنية', 'tutor_university', 'model', 8, NULL);
SELECT public._seed_tutor_node('tutor_uni_mechanical_eng', 'الهندسة الميكانيكية', 'tutor_university', 'model', 9, NULL);
SELECT public._seed_tutor_node('tutor_uni_architecture', 'الهندسة المعمارية', 'tutor_university', 'model', 10, NULL);
SELECT public._seed_tutor_node('tutor_uni_medicine', 'الطب والصيدلة', 'tutor_university', 'model', 11, NULL);
SELECT public._seed_tutor_node('tutor_uni_nursing', 'تمريض وعلوم صحية', 'tutor_university', 'model', 12, NULL);
SELECT public._seed_tutor_node('tutor_uni_accounting', 'المحاسبة والإدارة', 'tutor_university', 'model', 13, NULL);
SELECT public._seed_tutor_node('tutor_uni_economics', 'الاقتصاد والمصارف', 'tutor_university', 'model', 14, NULL);
SELECT public._seed_tutor_node('tutor_uni_law', 'القانون', 'tutor_university', 'model', 15, NULL);
SELECT public._seed_tutor_node('tutor_uni_math', 'الرياضيات التطبيقية', 'tutor_university', 'model', 16, NULL);
SELECT public._seed_tutor_node('tutor_uni_physics', 'الفيزياء الجامعية', 'tutor_university', 'model', 17, NULL);
SELECT public._seed_tutor_node('tutor_uni_chemistry', 'الكيمياء الجامعية', 'tutor_university', 'model', 18, NULL);
SELECT public._seed_tutor_node('tutor_uni_arabic_lit', 'اللغة العربية وآدابها', 'tutor_university', 'model', 19, NULL);
SELECT public._seed_tutor_node('tutor_uni_english_lit', 'اللغة الإنجليزية وآدابها', 'tutor_university', 'model', 20, NULL);
SELECT public._seed_tutor_node('tutor_uni_media', 'الإعلام والصحافة', 'tutor_university', 'model', 21, NULL);
SELECT public._seed_tutor_node('tutor_uni_education', 'التربية وعلم النفس', 'tutor_university', 'model', 22, NULL);
SELECT public._seed_tutor_node('tutor_uni_agriculture', 'الزراعة والبيئة', 'tutor_university', 'model', 23, NULL);

-- Level 2 — تعليم اللغات
SELECT public._seed_tutor_node('tutor_lang_english', 'اللغة الإنجليزية', 'tutor_languages', 'model', 1, NULL);
SELECT public._seed_tutor_node('tutor_lang_arabic_foreign', 'اللغة العربية للأجانب', 'tutor_languages', 'model', 2, NULL);
SELECT public._seed_tutor_node('tutor_lang_kurdish', 'اللغة الكردية', 'tutor_languages', 'model', 3, NULL);
SELECT public._seed_tutor_node('tutor_lang_turkish', 'اللغة التركية', 'tutor_languages', 'model', 4, NULL);
SELECT public._seed_tutor_node('tutor_lang_persian', 'اللغة الفارسية', 'tutor_languages', 'model', 5, NULL);
SELECT public._seed_tutor_node('tutor_lang_french', 'اللغة الفرنسية', 'tutor_languages', 'model', 6, NULL);
SELECT public._seed_tutor_node('tutor_lang_german', 'اللغة الألمانية', 'tutor_languages', 'model', 7, NULL);
SELECT public._seed_tutor_node('tutor_lang_russian', 'اللغة الروسية', 'tutor_languages', 'model', 8, NULL);
SELECT public._seed_tutor_node('tutor_lang_chinese', 'اللغة الصينية', 'tutor_languages', 'model', 9, NULL);
SELECT public._seed_tutor_node('tutor_lang_korean', 'اللغة الكورية', 'tutor_languages', 'model', 10, NULL);
SELECT public._seed_tutor_node('tutor_lang_ielts', 'تحضير IELTS / TOEFL', 'tutor_languages', 'model', 11, NULL);

-- Level 2 — القرآن والعلوم الدينية
SELECT public._seed_tutor_node('tutor_quran_memorization', 'حفظ القرآن الكريم', 'tutor_quran', 'model', 1, NULL);
SELECT public._seed_tutor_node('tutor_quran_tajweed', 'تجويد القرآن', 'tutor_quran', 'model', 2, NULL);
SELECT public._seed_tutor_node('tutor_islamic_fiqh', 'الفقه الإسلامي', 'tutor_quran', 'model', 3, NULL);
SELECT public._seed_tutor_node('tutor_islamic_aqeedah', 'العقيدة والتفسير', 'tutor_quran', 'model', 4, NULL);
SELECT public._seed_tutor_node('tutor_islamic_arabic', 'اللغة العربية الشرعية', 'tutor_quran', 'model', 5, NULL);

-- Level 2 — مهارات مهنية وتقنية
SELECT public._seed_tutor_node('tutor_prof_programming', 'البرمجة وتطوير التطبيقات', 'tutor_professional', 'model', 1, NULL);
SELECT public._seed_tutor_node('tutor_prof_graphic_design', 'تصميم الجرافيك', 'tutor_professional', 'model', 2, NULL);
SELECT public._seed_tutor_node('tutor_prof_video', 'المونتاج وإنتاج الفيديو', 'tutor_professional', 'model', 3, NULL);
SELECT public._seed_tutor_node('tutor_prof_marketing', 'التسويق الإلكتروني', 'tutor_professional', 'model', 4, NULL);
SELECT public._seed_tutor_node('tutor_prof_accounting_sw', 'المحاسبة وبرامج المالية', 'tutor_professional', 'model', 5, NULL);
SELECT public._seed_tutor_node('tutor_prof_office', 'مهارات الأوفيس (Word/Excel)', 'tutor_professional', 'model', 6, NULL);
SELECT public._seed_tutor_node('tutor_prof_cybersecurity', 'الأمن السيبراني', 'tutor_professional', 'model', 7, NULL);
SELECT public._seed_tutor_node('tutor_prof_ai_ml', 'الذكاء الاصطناعي والتعلم الآلي', 'tutor_professional', 'model', 8, NULL);
SELECT public._seed_tutor_node('tutor_prof_project_mgmt', 'إدارة المشاريع', 'tutor_professional', 'model', 9, NULL);
SELECT public._seed_tutor_node('tutor_prof_entrepreneurship', 'ريادة الأعمال', 'tutor_professional', 'model', 10, NULL);

DROP FUNCTION IF EXISTS public._seed_tutor_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
