-- سوق المستعمل والجديد (buy_sell) — rename + 19 subcategories → items
-- Safe to re-run: cleans buy_sell subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

UPDATE public.categories
SET name_ar = 'سوق المستعمل والجديد'
WHERE slug = 'buy_sell';

CREATE OR REPLACE FUNCTION public._seed_souq_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'buy_sell')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

SELECT public._seed_souq_node('souq_mobile', 'موبايلات وإكسسوارات', 'buy_sell', 'category', 1, '#1A1A1A');
SELECT public._seed_souq_node('souq_mobile_item_01', 'هواتف ذكية', 'souq_mobile', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_mobile_item_02', 'آيفون', 'souq_mobile', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_mobile_item_03', 'سامسونج', 'souq_mobile', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_mobile_item_04', 'هواوي', 'souq_mobile', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_mobile_item_05', 'شاومي وريدمي', 'souq_mobile', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_mobile_item_06', 'أوبو وفيفو', 'souq_mobile', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_mobile_item_07', 'هواتف عادية', 'souq_mobile', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_mobile_item_08', 'شواحن وكيبلات', 'souq_mobile', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_mobile_item_09', 'باور بانك', 'souq_mobile', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_mobile_item_10', 'كفرات وحماية', 'souq_mobile', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_mobile_item_11', 'سماعات بلوتوث', 'souq_mobile', 'model', 11, NULL);
SELECT public._seed_souq_node('souq_mobile_item_12', 'ساعات ذكية', 'souq_mobile', 'model', 12, NULL);
SELECT public._seed_souq_node('souq_mobile_item_13', 'قطع غيار هواتف', 'souq_mobile', 'model', 13, NULL);
SELECT public._seed_souq_node('souq_mobile_item_14', 'بطاريات هواتف', 'souq_mobile', 'model', 14, NULL);
SELECT public._seed_souq_node('souq_computer', 'كمبيوتر ولابتوب', 'buy_sell', 'category', 2, '#003478');
SELECT public._seed_souq_node('souq_computer_item_01', 'لابتوب', 'souq_computer', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_computer_item_02', 'لابتوب ماك', 'souq_computer', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_computer_item_03', 'كمبيوتر مكتبي', 'souq_computer', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_computer_item_04', 'شاشات كمبيوتر', 'souq_computer', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_computer_item_05', 'كيبورد وماوس', 'souq_computer', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_computer_item_06', 'طابعات وسكانر', 'souq_computer', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_computer_item_07', 'هارد ديسك', 'souq_computer', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_computer_item_08', 'رام وقطع داخلية', 'souq_computer', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_computer_gpu', 'كرت شاشة GPU', 'souq_computer', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_computer_item_10', 'راوتر وشبكات', 'souq_computer', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_computer_ups', 'UPS وبطاريات', 'souq_computer', 'model', 11, NULL);
SELECT public._seed_souq_node('souq_computer_item_12', 'فلاشات وميموري', 'souq_computer', 'model', 12, NULL);
SELECT public._seed_souq_node('souq_tv_audio', 'تلفزيونات وصوتيات', 'buy_sell', 'category', 3, '#1A1A1A');
SELECT public._seed_souq_node('souq_tv_audio_item_01', 'تلفزيون سمارت', 'souq_tv_audio', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_tv_audio_oled', 'تلفزيون OLED', 'souq_tv_audio', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_tv_audio_qled', 'تلفزيون QLED', 'souq_tv_audio', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_04', 'تلفزيون عادي', 'souq_tv_audio', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_05', 'ريسيفر وستلايت', 'souq_tv_audio', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_06', 'مسرح منزلي', 'souq_tv_audio', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_07', 'مكبر صوت', 'souq_tv_audio', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_08', 'سماعات منزلية', 'souq_tv_audio', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_09', 'بروجيكتور', 'souq_tv_audio', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_tv_audio_item_10', 'ريموت وإكسسوار', 'souq_tv_audio', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_appliances', 'أجهزة منزلية كهربائية', 'buy_sell', 'category', 4, '#CC0000');
SELECT public._seed_souq_node('souq_appliances_item_01', 'غسالة ملابس', 'souq_appliances', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_appliances_item_02', 'غسالة صحون', 'souq_appliances', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_appliances_item_03', 'ثلاجة', 'souq_appliances', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_appliances_item_04', 'فريزر', 'souq_appliances', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_appliances_item_05', 'مكيف سبليت', 'souq_appliances', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_appliances_item_06', 'مكيف شباك', 'souq_appliances', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_appliances_item_07', 'مكيف محمول', 'souq_appliances', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_appliances_item_08', 'مروحة', 'souq_appliances', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_appliances_item_09', 'مدفأة كهربائية', 'souq_appliances', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_appliances_item_10', 'مكنسة كهربائية', 'souq_appliances', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_appliances_item_11', 'كوي ملابس', 'souq_appliances', 'model', 11, NULL);
SELECT public._seed_souq_node('souq_appliances_item_12', 'ستيريلايزر', 'souq_appliances', 'model', 12, NULL);
SELECT public._seed_souq_node('souq_kitchen', 'أجهزة مطبخ', 'buy_sell', 'category', 5, '#CC0000');
SELECT public._seed_souq_node('souq_kitchen_item_01', 'غاز طبخ', 'souq_kitchen', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_02', 'فرن كهربائي', 'souq_kitchen', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_03', 'ميكروويف', 'souq_kitchen', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_04', 'قلاية هوائية', 'souq_kitchen', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_05', 'خلاط وعصارة', 'souq_kitchen', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_06', 'شاور قهوة وشاي', 'souq_kitchen', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_07', 'ساندويتش وتوستر', 'souq_kitchen', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_08', 'طنجرة ضغط كهربائية', 'souq_kitchen', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_09', 'خبازة', 'souq_kitchen', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_kitchen_item_10', 'أواني وإكسسوار مطبخ', 'souq_kitchen', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_gaming', 'ألعاب فيديو وترفيه', 'buy_sell', 'category', 6, '#107C10');
SELECT public._seed_souq_node('souq_gaming_5', 'بلايستيشن 5', 'souq_gaming', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_gaming_4', 'بلايستيشن 4', 'souq_gaming', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_gaming_xbox_series_x_s', 'Xbox Series X/S', 'souq_gaming', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_gaming_nintendo_switch', 'Nintendo Switch', 'souq_gaming', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_gaming_cd', 'ألعاب CD وكروت', 'souq_gaming', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_gaming_item_06', 'جوي ستيك وإكسسوار', 'souq_gaming', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_gaming_vr_headset', 'VR هيدسيت', 'souq_gaming', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_gaming_item_08', 'ألعاب أطفال إلكترونية', 'souq_gaming', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_fashion', 'ملابس وأزياء', 'buy_sell', 'category', 7, '#8B4513');
SELECT public._seed_souq_node('souq_fashion_item_01', 'ملابس رجالية', 'souq_fashion', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_fashion_item_02', 'ملابس نسائية', 'souq_fashion', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_fashion_item_03', 'ملابس أطفال', 'souq_fashion', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_fashion_item_04', 'عباءات ودشاديش', 'souq_fashion', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_fashion_item_05', 'أحذية رجالية', 'souq_fashion', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_fashion_item_06', 'أحذية نسائية', 'souq_fashion', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_fashion_item_07', 'أحذية أطفال', 'souq_fashion', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_fashion_item_08', 'حقائب يد', 'souq_fashion', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_fashion_item_09', 'حقائب سفر وشنط', 'souq_fashion', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_fashion_item_10', 'ساعات يد', 'souq_fashion', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_fashion_item_11', 'نظارات', 'souq_fashion', 'model', 11, NULL);
SELECT public._seed_souq_node('souq_fashion_item_12', 'إكسسوارات أزياء', 'souq_fashion', 'model', 12, NULL);
SELECT public._seed_souq_node('souq_beauty', 'صحة وجمال', 'buy_sell', 'category', 8, '#FF69B4');
SELECT public._seed_souq_node('souq_beauty_item_01', 'عطور رجالية', 'souq_beauty', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_beauty_item_02', 'عطور نسائية', 'souq_beauty', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_beauty_item_03', 'مستحضرات عناية بالبشرة', 'souq_beauty', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_beauty_item_04', 'مكياج وتجميل', 'souq_beauty', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_beauty_item_05', 'أجهزة تجميل', 'souq_beauty', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_beauty_item_06', 'أجهزة قياس صحية', 'souq_beauty', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_beauty_item_07', 'فيتامينات ومكملات', 'souq_beauty', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_beauty_item_08', 'كراسي تدليك', 'souq_beauty', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_beauty_item_09', 'نظارات طبية', 'souq_beauty', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_beauty_item_10', 'أدوات حلاقة', 'souq_beauty', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_furniture', 'أثاث ومفروشات', 'buy_sell', 'category', 9, '#8B4513');
SELECT public._seed_souq_node('souq_furniture_item_01', 'غرفة نوم', 'souq_furniture', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_furniture_item_02', 'صالة وجلوسية', 'souq_furniture', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_furniture_item_03', 'سفرة وطاولات أكل', 'souq_furniture', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_furniture_item_04', 'مكتب ودراسة', 'souq_furniture', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_furniture_item_05', 'ستائر وسجاد', 'souq_furniture', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_furniture_item_06', 'مطبخ وخزائن', 'souq_furniture', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_furniture_item_07', 'إضاءة وثريات', 'souq_furniture', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_furniture_item_08', 'ديكور ولوحات', 'souq_furniture', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_furniture_item_09', 'بياضات وفرش', 'souq_furniture', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_furniture_item_10', 'أدوات منزلية متنوعة', 'souq_furniture', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_sports', 'رياضة ولياقة', 'buy_sell', 'category', 10, '#006400');
SELECT public._seed_souq_node('souq_sports_item_01', 'أجهزة رياضية منزلية', 'souq_sports', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_sports_item_02', 'مشاية ودراجة ثابتة', 'souq_sports', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_sports_item_03', 'أوزان ودمبل', 'souq_sports', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_sports_item_04', 'ملابس رياضية', 'souq_sports', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_sports_item_05', 'أحذية رياضية', 'souq_sports', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_sports_item_06', 'كرة قدم ومستلزماتها', 'souq_sports', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_sports_item_07', 'كرة سلة وطائرة', 'souq_sports', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_sports_item_08', 'سباحة وغوص', 'souq_sports', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_sports_item_09', 'دراجات هوائية', 'souq_sports', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_sports_item_10', 'ملاكمة وفنون قتالية', 'souq_sports', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_sports_item_11', 'تخييم وأنشطة خارجية', 'souq_sports', 'model', 11, NULL);
SELECT public._seed_souq_node('souq_sports_item_12', 'صيد سمك', 'souq_sports', 'model', 12, NULL);
SELECT public._seed_souq_node('souq_baby', 'أطفال وأمومة', 'buy_sell', 'category', 11, '#FF69B4');
SELECT public._seed_souq_node('souq_baby_item_01', 'عربات أطفال', 'souq_baby', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_baby_item_02', 'كراسي سيارة للأطفال', 'souq_baby', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_baby_item_03', 'سرير أطفال', 'souq_baby', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_baby_item_04', 'ملابس أطفال ورضّع', 'souq_baby', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_baby_item_05', 'ألعاب أطفال', 'souq_baby', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_baby_item_06', 'أدوات تغذية', 'souq_baby', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_baby_item_07', 'أجهزة مراقبة الطفل', 'souq_baby', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_baby_item_08', 'حليب وأغذية رضع', 'souq_baby', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_baby_item_09', 'حقائب ومستلزمات مدرسية', 'souq_baby', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_baby_item_10', 'دراجات ومركبات أطفال', 'souq_baby', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_books', 'كتب ومجلات وتعليم', 'buy_sell', 'category', 12, '#003478');
SELECT public._seed_souq_node('souq_books_item_01', 'كتب عربية', 'souq_books', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_books_item_02', 'كتب إنجليزية', 'souq_books', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_books_item_03', 'كتب دراسية ومناهج', 'souq_books', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_books_item_04', 'كتب دينية', 'souq_books', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_books_item_05', 'روايات وقصص', 'souq_books', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_books_item_06', 'مجلات وجرائد', 'souq_books', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_books_item_07', 'قرطاسية ومستلزمات مكتبية', 'souq_books', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_books_item_08', 'أدوات رسم وفنون', 'souq_books', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_music', 'موسيقى وآلات موسيقية', 'buy_sell', 'category', 13, '#8B0000');
SELECT public._seed_souq_node('souq_music_item_01', 'غيتار', 'souq_music', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_music_item_02', 'عود وقانون', 'souq_music', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_music_item_03', 'بيانو وأورغ', 'souq_music', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_music_item_04', 'طبلة وإيقاع', 'souq_music', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_music_dj', 'مكسر صوت DJ', 'souq_music', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_music_item_06', 'ميكروفون وتسجيل', 'souq_music', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_music_item_07', 'نايات وآلات نفخ', 'souq_music', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_music_item_08', 'جهاز كاريوكي', 'souq_music', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_hobbies', 'هوايات وتحف ومقتنيات', 'buy_sell', 'category', 14, '#8B4513');
SELECT public._seed_souq_node('souq_hobbies_item_01', 'تحف وأنتيكات', 'souq_hobbies', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_02', 'طوابع وعملات قديمة', 'souq_hobbies', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_03', 'لوحات فنية', 'souq_hobbies', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_04', 'ألعاب لوحية وورق', 'souq_hobbies', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_05', 'نماذج وموديلات', 'souq_hobbies', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_06', 'دورن ومسيّرات', 'souq_hobbies', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_07', 'مجسمات وتماثيل', 'souq_hobbies', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_hobbies_item_08', 'مقتنيات رياضية', 'souq_hobbies', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_jewelry', 'مجوهرات وذهب وفضة', 'buy_sell', 'category', 15, '#FFD700');
SELECT public._seed_souq_node('souq_jewelry_21', 'ذهب عيار 21', 'souq_jewelry', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_jewelry_18', 'ذهب عيار 18', 'souq_jewelry', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_03', 'فضة', 'souq_jewelry', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_04', 'ألماس وأحجار كريمة', 'souq_jewelry', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_05', 'خواتم وأساور', 'souq_jewelry', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_06', 'قلائد وأطواق', 'souq_jewelry', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_07', 'ساعات فاخرة', 'souq_jewelry', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_jewelry_item_08', 'مسابح', 'souq_jewelry', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_building', 'بناء ومواد إنشائية', 'buy_sell', 'category', 16, '#808080');
SELECT public._seed_souq_node('souq_building_item_01', 'حديد وصلب', 'souq_building', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_building_item_02', 'أسمنت وبلوك', 'souq_building', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_building_item_03', 'طابوق وحجر', 'souq_building', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_building_item_04', 'بلاط وسيراميك', 'souq_building', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_building_item_05', 'دهانات وورق جدران', 'souq_building', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_building_item_06', 'أبواب ونوافذ', 'souq_building', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_building_item_07', 'سباكة وصحية', 'souq_building', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_building_item_08', 'كهرباء وإنارة', 'souq_building', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_building_item_09', 'أدوات يدوية وكهربائية', 'souq_building', 'model', 9, NULL);
SELECT public._seed_souq_node('souq_building_item_10', 'مولدات وطاقة شمسية', 'souq_building', 'model', 10, NULL);
SELECT public._seed_souq_node('souq_garden', 'حدائق وزراعة', 'buy_sell', 'category', 17, '#006400');
SELECT public._seed_souq_node('souq_garden_item_01', 'نباتات وأشجار', 'souq_garden', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_garden_item_02', 'بذور وأسمدة', 'souq_garden', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_garden_item_03', 'أدوات حدائق', 'souq_garden', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_garden_item_04', 'مضخات مياه', 'souq_garden', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_garden_item_05', 'نباتات صناعية وديكور', 'souq_garden', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_garden_item_06', 'أصص وتربة', 'souq_garden', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_garden_item_07', 'نوافير حدائق', 'souq_garden', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_food', 'طعام ومشروبات', 'buy_sell', 'category', 18, '#CC0000');
SELECT public._seed_souq_node('souq_food_item_01', 'تمور وحلويات عراقية', 'souq_food', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_food_item_02', 'عسل طبيعي', 'souq_food', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_food_item_03', 'زيت زيتون وزيوت', 'souq_food', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_food_item_04', 'منتجات ألبان', 'souq_food', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_food_item_05', 'مربى ومعلبات', 'souq_food', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_food_item_06', 'مشروبات طاقة ومياه', 'souq_food', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_food_item_07', 'بهارات وأعشاب', 'souq_food', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_food_item_08', 'أطعمة عضوية', 'souq_food', 'model', 8, NULL);
SELECT public._seed_souq_node('souq_misc', 'متفرقات وأخرى', 'buy_sell', 'category', 19, '#808080');
SELECT public._seed_souq_node('souq_misc_item_01', 'هدايا ومناسبات', 'souq_misc', 'model', 1, NULL);
SELECT public._seed_souq_node('souq_misc_item_02', 'مستلزمات دينية', 'souq_misc', 'model', 2, NULL);
SELECT public._seed_souq_node('souq_misc_item_03', 'أدوات مكتبية', 'souq_misc', 'model', 3, NULL);
SELECT public._seed_souq_node('souq_misc_item_04', 'حقائب سفر', 'souq_misc', 'model', 4, NULL);
SELECT public._seed_souq_node('souq_misc_item_05', 'مستلزمات تصوير', 'souq_misc', 'model', 5, NULL);
SELECT public._seed_souq_node('souq_misc_item_06', 'معدات تصوير احترافي', 'souq_misc', 'model', 6, NULL);
SELECT public._seed_souq_node('souq_misc_item_07', 'بضاعة جملة', 'souq_misc', 'model', 7, NULL);
SELECT public._seed_souq_node('souq_misc_other', 'أخرى', 'souq_misc', 'model', 8, NULL);

DROP FUNCTION public._seed_souq_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);

