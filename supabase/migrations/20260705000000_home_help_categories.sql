-- مساعدة منزلية — 10 branches + 60 service leaves (2-level tree)
-- Safe to re-run: cleans home_help subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_home_help_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'home_help')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

-- Level 1 — branches
SELECT public._seed_home_help_node('home_cleaning', 'تنظيف المنازل', 'home_help', 'category', 1, '#2196F3');
SELECT public._seed_home_help_node('home_cooking', 'طبخ وإعداد الطعام', 'home_help', 'category', 2, '#FF9800');
SELECT public._seed_home_help_node('home_childcare', 'رعاية الأطفال', 'home_help', 'category', 3, '#4CAF50');
SELECT public._seed_home_help_node('home_eldercare', 'رعاية كبار السن والمرضى', 'home_help', 'category', 4, '#9C27B0');
SELECT public._seed_home_help_node('home_driver', 'سائق خاص', 'home_help', 'category', 5, '#607D8B');
SELECT public._seed_home_help_node('home_gardening', 'حدائق ومسابح', 'home_help', 'category', 6, '#8BC34A');
SELECT public._seed_home_help_node('home_maintenance', 'صيانة وإصلاح منزلي', 'home_help', 'category', 7, '#FF5722');
SELECT public._seed_home_help_node('home_moving', 'نقل الأثاث والعفش', 'home_help', 'category', 8, '#795548');
SELECT public._seed_home_help_node('home_security', 'حراسة وأمن', 'home_help', 'category', 9, '#F44336');
SELECT public._seed_home_help_node('home_laundry', 'غسيل وكي الملابس', 'home_help', 'category', 10, '#00BCD4');

-- Level 2 — تنظيف المنازل
SELECT public._seed_home_help_node('home_cleaning_daily', 'تنظيف يومي', 'home_cleaning', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_cleaning_weekly', 'تنظيف أسبوعي أو شهري', 'home_cleaning', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_cleaning_deep', 'تنظيف عميق وشامل', 'home_cleaning', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_cleaning_post_construction', 'تنظيف بعد البناء والتشطيب', 'home_cleaning', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_cleaning_carpet', 'تنظيف السجاد والموكيت', 'home_cleaning', 'model', 5, NULL);
SELECT public._seed_home_help_node('home_cleaning_curtains', 'تنظيف الستائر والمفروشات', 'home_cleaning', 'model', 6, NULL);
SELECT public._seed_home_help_node('home_cleaning_glass', 'تنظيف الزجاج والواجهات', 'home_cleaning', 'model', 7, NULL);
SELECT public._seed_home_help_node('home_cleaning_sterilization', 'تعقيم وتطهير', 'home_cleaning', 'model', 8, NULL);
SELECT public._seed_home_help_node('home_cleaning_kitchen_bath', 'تنظيف المطابخ والحمامات', 'home_cleaning', 'model', 9, NULL);
SELECT public._seed_home_help_node('home_cleaning_company', 'شركة تنظيف', 'home_cleaning', 'model', 10, NULL);

-- Level 2 — طبخ وإعداد الطعام
SELECT public._seed_home_help_node('home_cooking_daily', 'طباخة منزلية يومية', 'home_cooking', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_cooking_events', 'طبخ مناسبات وولائم', 'home_cooking', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_cooking_sweets', 'طبخ حلويات وكيك', 'home_cooking', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_cooking_diet', 'وجبات دايت وصحية', 'home_cooking', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_cooking_iraqi', 'طبخ عراقي تقليدي', 'home_cooking', 'model', 5, NULL);
SELECT public._seed_home_help_node('home_cooking_catering', 'مطبخ مركزي وتوصيل', 'home_cooking', 'model', 6, NULL);

-- Level 2 — رعاية الأطفال
SELECT public._seed_home_help_node('home_childcare_nanny', 'مربية أطفال (نانية)', 'home_childcare', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_childcare_babysitter', 'جليسة أطفال بالساعة', 'home_childcare', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_childcare_infant', 'رعاية الرضع والمواليد', 'home_childcare', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_childcare_homework', 'مساعدة في الواجبات المدرسية', 'home_childcare', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_childcare_school_escort', 'مرافقة الأطفال للمدرسة', 'home_childcare', 'model', 5, NULL);
SELECT public._seed_home_help_node('home_childcare_special_needs', 'رعاية أطفال ذوي احتياجات خاصة', 'home_childcare', 'model', 6, NULL);

-- Level 2 — رعاية كبار السن والمرضى
SELECT public._seed_home_help_node('home_elder_companion', 'مرافق كبار السن', 'home_eldercare', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_elder_nurse', 'ممرض منزلي', 'home_eldercare', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_elder_patient_helper', 'مساعد شخصي للمرضى', 'home_eldercare', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_elder_physiotherapy', 'فيزيوثيرابي منزلي', 'home_eldercare', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_elder_special_needs', 'رعاية ذوي الاحتياجات الخاصة', 'home_eldercare', 'model', 5, NULL);

-- Level 2 — سائق خاص
SELECT public._seed_home_help_node('home_driver_fulltime', 'سائق عائلي دوام كامل', 'home_driver', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_driver_hourly', 'سائق بالساعة أو اليوم', 'home_driver', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_driver_school', 'سائق مدرسي', 'home_driver', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_driver_elderly', 'سائق لكبار السن', 'home_driver', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_driver_delivery', 'سائق توصيل وتسوق', 'home_driver', 'model', 5, NULL);

-- Level 2 — حدائق ومسابح
SELECT public._seed_home_help_node('home_garden_design', 'تنسيق وتصميم الحدائق', 'home_gardening', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_garden_mowing', 'قص العشب والأشجار', 'home_gardening', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_garden_watering', 'ري وعناية بالنباتات', 'home_gardening', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_garden_pool', 'تنظيف وصيانة المسابح', 'home_gardening', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_garden_pest', 'مكافحة الحشرات والآفات', 'home_gardening', 'model', 5, NULL);

-- Level 2 — صيانة وإصلاح منزلي
SELECT public._seed_home_help_node('home_maint_plumber', 'سباك', 'home_maintenance', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_maint_electrician', 'كهربائي', 'home_maintenance', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_maint_carpenter', 'نجار وأبواب', 'home_maintenance', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_maint_painter', 'دهان وديكور', 'home_maintenance', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_maint_ac', 'تكييف وتبريد', 'home_maintenance', 'model', 5, NULL);
SELECT public._seed_home_help_node('home_maint_tiling', 'تبليط وسيراميك', 'home_maintenance', 'model', 6, NULL);
SELECT public._seed_home_help_node('home_maint_furniture', 'تركيب أثاث وإيكيا', 'home_maintenance', 'model', 7, NULL);
SELECT public._seed_home_help_node('home_maint_appliances', 'إصلاح أجهزة منزلية', 'home_maintenance', 'model', 8, NULL);
SELECT public._seed_home_help_node('home_maint_general', 'صيانة عامة', 'home_maintenance', 'model', 9, NULL);

-- Level 2 — نقل الأثاث والعفش
SELECT public._seed_home_help_node('home_moving_local', 'نقل عفش داخل المدينة', 'home_moving', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_moving_intercity', 'نقل عفش بين المحافظات', 'home_moving', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_moving_packing', 'تغليف وتخزين', 'home_moving', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_moving_crane', 'رافعة هيدروليك', 'home_moving', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_moving_company', 'شركة نقل عفش', 'home_moving', 'model', 5, NULL);

-- Level 2 — حراسة وأمن
SELECT public._seed_home_help_node('home_security_house_guard', 'حارس منزل أو فيلا', 'home_security', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_security_cameras', 'تركيب كاميرات مراقبة', 'home_security', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_security_alarm', 'أنظمة إنذار وحماية', 'home_security', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_security_personal', 'حراسة شخصية', 'home_security', 'model', 4, NULL);

-- Level 2 — غسيل وكي الملابس
SELECT public._seed_home_help_node('home_laundry_home', 'غسيل منزلي', 'home_laundry', 'model', 1, NULL);
SELECT public._seed_home_help_node('home_laundry_ironing', 'كي الملابس', 'home_laundry', 'model', 2, NULL);
SELECT public._seed_home_help_node('home_laundry_delivery', 'مغسلة بالتوصيل', 'home_laundry', 'model', 3, NULL);
SELECT public._seed_home_help_node('home_laundry_formal', 'غسيل ملابس رسمية وبدل', 'home_laundry', 'model', 4, NULL);
SELECT public._seed_home_help_node('home_laundry_dry_clean', 'تنظيف جاف', 'home_laundry', 'model', 5, NULL);

DROP FUNCTION IF EXISTS public._seed_home_help_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
