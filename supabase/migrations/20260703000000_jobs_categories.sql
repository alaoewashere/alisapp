-- فرص العمل — 10 branches + 80 job-type leaves (2-level tree)
-- Safe to re-run: cleans jobs subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_jobs_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'jobs')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

-- Level 1 — branches
SELECT public._seed_jobs_node('jobs_it', 'تقنية المعلومات والبرمجة', 'jobs', 'category', 1, '#2196F3');
SELECT public._seed_jobs_node('jobs_engineering', 'الهندسة والبناء', 'jobs', 'category', 2, '#FF5722');
SELECT public._seed_jobs_node('jobs_medical', 'الطب والصحة', 'jobs', 'category', 3, '#4CAF50');
SELECT public._seed_jobs_node('jobs_business', 'الأعمال والإدارة والمال', 'jobs', 'category', 4, '#9C27B0');
SELECT public._seed_jobs_node('jobs_education', 'التعليم والتدريب', 'jobs', 'category', 5, '#FF9800');
SELECT public._seed_jobs_node('jobs_oil_energy', 'النفط والطاقة', 'jobs', 'category', 6, '#795548');
SELECT public._seed_jobs_node('jobs_media', 'الإعلام والتصميم والفنون', 'jobs', 'category', 7, '#E91E63');
SELECT public._seed_jobs_node('jobs_hospitality', 'الضيافة والسياحة والمطاعم', 'jobs', 'category', 8, '#00BCD4');
SELECT public._seed_jobs_node('jobs_trades', 'الحرف والمهن اليدوية', 'jobs', 'category', 9, '#607D8B');
SELECT public._seed_jobs_node('jobs_freelance', 'عمل حر وعن بُعد', 'jobs', 'category', 10, '#3F51B5');

-- Level 2 — تقنية المعلومات والبرمجة
SELECT public._seed_jobs_node('jobs_it_mobile_dev', 'مطور تطبيقات موبايل', 'jobs_it', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_it_web_dev', 'مطور ويب', 'jobs_it', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_it_backend', 'مهندس باك إند', 'jobs_it', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_it_frontend', 'مهندس فرونت إند', 'jobs_it', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_it_devops', 'مهندس DevOps وCloud', 'jobs_it', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_it_cybersecurity', 'مختص أمن سيبراني', 'jobs_it', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_it_networks', 'مهندس شبكات', 'jobs_it', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_it_data_ai', 'محلل بيانات وذكاء اصطناعي', 'jobs_it', 'model', 8, NULL);
SELECT public._seed_jobs_node('jobs_it_ui_ux', 'مصمم UI/UX', 'jobs_it', 'model', 9, NULL);
SELECT public._seed_jobs_node('jobs_it_tech_support', 'دعم تقني وصيانة حاسوب', 'jobs_it', 'model', 10, NULL);

-- Level 2 — الهندسة والبناء
SELECT public._seed_jobs_node('jobs_eng_civil', 'مهندس مدني', 'jobs_engineering', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_eng_architect', 'مهندس معماري', 'jobs_engineering', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_eng_electrical', 'مهندس كهربائي', 'jobs_engineering', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_eng_mechanical', 'مهندس ميكانيكي', 'jobs_engineering', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_eng_petroleum', 'مهندس نفط وغاز', 'jobs_engineering', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_eng_environment', 'مهندس بيئة ومياه', 'jobs_engineering', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_eng_site_supervisor', 'مشرف موقع', 'jobs_engineering', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_eng_surveyor', 'مساح ومخطط', 'jobs_engineering', 'model', 8, NULL);
SELECT public._seed_jobs_node('jobs_eng_electrician_plumber', 'فني كهرباء وسباكة', 'jobs_engineering', 'model', 9, NULL);
SELECT public._seed_jobs_node('jobs_eng_construction_worker', 'عامل بناء وتشطيب', 'jobs_engineering', 'model', 10, NULL);

-- Level 2 — الطب والصحة
SELECT public._seed_jobs_node('jobs_med_doctor', 'طبيب عام أو متخصص', 'jobs_medical', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_med_dentist', 'طبيب أسنان', 'jobs_medical', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_med_pharmacist', 'صيدلاني', 'jobs_medical', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_med_nurse', 'ممرض أو ممرضة', 'jobs_medical', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_med_physiotherapist', 'معالج فيزيائي', 'jobs_medical', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_med_lab_tech', 'مختبر طبي', 'jobs_medical', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_med_hospital_admin', 'إداري مستشفى وعيادة', 'jobs_medical', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_med_paramedic', 'مسعف وطوارئ', 'jobs_medical', 'model', 8, NULL);

-- Level 2 — الأعمال والإدارة والمال
SELECT public._seed_jobs_node('jobs_bus_accountant', 'محاسب ومراجع', 'jobs_business', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_bus_finance_manager', 'مدير مالي', 'jobs_business', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_bus_hr', 'موارد بشرية', 'jobs_business', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_bus_sales_marketing', 'مدير مبيعات وتسويق', 'jobs_business', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_bus_sales_rep', 'مندوب مبيعات', 'jobs_business', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_bus_secretary', 'سكرتير وإداري', 'jobs_business', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_bus_project_manager', 'مدير مشاريع', 'jobs_business', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_bus_lawyer', 'مستشار قانوني ومحامي', 'jobs_business', 'model', 8, NULL);
SELECT public._seed_jobs_node('jobs_bus_real_estate_agent', 'عقارات ووساطة', 'jobs_business', 'model', 9, NULL);
SELECT public._seed_jobs_node('jobs_bus_customer_service', 'خدمة عملاء', 'jobs_business', 'model', 10, NULL);

-- Level 2 — التعليم والتدريب
SELECT public._seed_jobs_node('jobs_edu_school_teacher', 'معلم مدرسة', 'jobs_education', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_edu_university_prof', 'أستاذ جامعي', 'jobs_education', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_edu_trainer', 'مدرب مهني', 'jobs_education', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_edu_english_teacher', 'مدرس لغة إنجليزية', 'jobs_education', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_edu_supervisor', 'مشرف تربوي', 'jobs_education', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_edu_nanny_teacher', 'مربية أطفال', 'jobs_education', 'model', 6, NULL);

-- Level 2 — النفط والطاقة
SELECT public._seed_jobs_node('jobs_oil_drilling_eng', 'مهندس حفر', 'jobs_oil_energy', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_oil_geologist', 'جيولوجي', 'jobs_oil_energy', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_oil_tech', 'فني منشآت نفطية', 'jobs_oil_energy', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_oil_power_plant', 'مشغل محطة طاقة', 'jobs_oil_energy', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_oil_solar_tech', 'فني طاقة شمسية', 'jobs_oil_energy', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_oil_hse', 'سلامة وبيئة HSE', 'jobs_oil_energy', 'model', 6, NULL);

-- Level 2 — الإعلام والتصميم والفنون
SELECT public._seed_jobs_node('jobs_media_graphic_designer', 'مصمم جرافيك', 'jobs_media', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_media_photographer', 'مصور فوتوغرافي وفيديو', 'jobs_media', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_media_video_editor', 'مونتير فيديو', 'jobs_media', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_media_journalist', 'صحفي ومذيع', 'jobs_media', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_media_social_media', 'مدير تواصل اجتماعي', 'jobs_media', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_media_content_writer', 'كاتب محتوى', 'jobs_media', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_media_translator', 'مترجم', 'jobs_media', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_media_producer', 'منتج إذاعي وتلفزيوني', 'jobs_media', 'model', 8, NULL);

-- Level 2 — الضيافة والسياحة والمطاعم
SELECT public._seed_jobs_node('jobs_hosp_chef', 'طاهي وشيف', 'jobs_hospitality', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_hosp_waiter', 'نادل وخدمة طاولات', 'jobs_hospitality', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_hosp_hotel_reception', 'موظف استقبال فندق', 'jobs_hospitality', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_hosp_tour_guide', 'مرشد سياحي', 'jobs_hospitality', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_hosp_manager', 'مدير مطعم أو فندق', 'jobs_hospitality', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_hosp_cleaning', 'عامل تنظيف وخدمات', 'jobs_hospitality', 'model', 6, NULL);

-- Level 2 — الحرف والمهن اليدوية
SELECT public._seed_jobs_node('jobs_trade_mechanic', 'ميكانيكي سيارات', 'jobs_trades', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_trade_welder', 'حداد ولحام', 'jobs_trades', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_trade_carpenter', 'نجار وأثاث', 'jobs_trades', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_trade_painter', 'دهان وديكور', 'jobs_trades', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_trade_plumber', 'سباك', 'jobs_trades', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_trade_ac_tech', 'تكييف وتبريد', 'jobs_trades', 'model', 6, NULL);
SELECT public._seed_jobs_node('jobs_trade_tailor', 'خياط وتفصيل', 'jobs_trades', 'model', 7, NULL);
SELECT public._seed_jobs_node('jobs_trade_barber', 'حلاق وصالون', 'jobs_trades', 'model', 8, NULL);
SELECT public._seed_jobs_node('jobs_trade_driver', 'سائق', 'jobs_trades', 'model', 9, NULL);
SELECT public._seed_jobs_node('jobs_trade_security', 'حارس أمن', 'jobs_trades', 'model', 10, NULL);

-- Level 2 — عمل حر وعن بُعد
SELECT public._seed_jobs_node('jobs_free_tech', 'فريلانسر برمجة وتقنية', 'jobs_freelance', 'model', 1, NULL);
SELECT public._seed_jobs_node('jobs_free_design', 'فريلانسر تصميم', 'jobs_freelance', 'model', 2, NULL);
SELECT public._seed_jobs_node('jobs_free_writing', 'فريلانسر كتابة وترجمة', 'jobs_freelance', 'model', 3, NULL);
SELECT public._seed_jobs_node('jobs_free_wfh', 'عمل من المنزل', 'jobs_freelance', 'model', 4, NULL);
SELECT public._seed_jobs_node('jobs_free_part_time', 'دوام جزئي', 'jobs_freelance', 'model', 5, NULL);
SELECT public._seed_jobs_node('jobs_free_internship', 'تدريب وتطوع', 'jobs_freelance', 'model', 6, NULL);

DROP FUNCTION IF EXISTS public._seed_jobs_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
