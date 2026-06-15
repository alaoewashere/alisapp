-- الحيوانات — 10 branches + 89 breed/type leaves (2-level tree)
-- Safe to re-run: cleans pets subtree then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION public._seed_pets_node(
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
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = 'pets')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

-- Level 1 — branches
SELECT public._seed_pets_node('pets_dogs', 'كلاب', 'pets', 'category', 1, '#795548');
SELECT public._seed_pets_node('pets_cats', 'قطط', 'pets', 'category', 2, '#FF9800');
SELECT public._seed_pets_node('pets_birds', 'طيور', 'pets', 'category', 3, '#4CAF50');
SELECT public._seed_pets_node('pets_fish', 'أسماك وأحواض', 'pets', 'category', 4, '#2196F3');
SELECT public._seed_pets_node('pets_farm', 'حيوانات المزرعة', 'pets', 'category', 5, '#8BC34A');
SELECT public._seed_pets_node('pets_reptiles', 'زواحف وبرمائيات', 'pets', 'category', 6, '#607D8B');
SELECT public._seed_pets_node('pets_rabbits', 'أرانب وقوارض', 'pets', 'category', 7, '#E91E63');
SELECT public._seed_pets_node('pets_accessories', 'مستلزمات الحيوانات', 'pets', 'category', 8, '#FF5722');
SELECT public._seed_pets_node('pets_services', 'خدمات الحيوانات', 'pets', 'category', 9, '#9C27B0');
SELECT public._seed_pets_node('pets_lost_found', 'مفقود وموجود', 'pets', 'category', 10, '#F44336');

-- Level 2 — كلاب
SELECT public._seed_pets_node('pets_dog_german_shepherd', 'جيرمن شيبرد', 'pets_dogs', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_dog_rottweiler', 'روت وايلر', 'pets_dogs', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_dog_husky', 'هاسكي', 'pets_dogs', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_dog_labrador', 'لابرادور ريتريفر', 'pets_dogs', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_dog_maltese', 'مالتيز', 'pets_dogs', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_dog_pitbull', 'بيتبول', 'pets_dogs', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_dog_pomeranian', 'بوميرانيان', 'pets_dogs', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_dog_chihuahua', 'شيواوا', 'pets_dogs', 'model', 8, NULL);
SELECT public._seed_pets_node('pets_dog_bulldog', 'بولدوج', 'pets_dogs', 'model', 9, NULL);
SELECT public._seed_pets_node('pets_dog_doberman', 'دوبرمان', 'pets_dogs', 'model', 10, NULL);
SELECT public._seed_pets_node('pets_dog_poodle', 'بودل', 'pets_dogs', 'model', 11, NULL);
SELECT public._seed_pets_node('pets_dog_golden_retriever', 'غولدن ريتريفر', 'pets_dogs', 'model', 12, NULL);
SELECT public._seed_pets_node('pets_dog_iraqi_saluki', 'سلوقي عراقي', 'pets_dogs', 'model', 13, NULL);
SELECT public._seed_pets_node('pets_dog_other', 'أصناف أخرى', 'pets_dogs', 'model', 14, NULL);

-- Level 2 — قطط
SELECT public._seed_pets_node('pets_cat_persian', 'شيرازي', 'pets_cats', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_cat_munchkin', 'مانشكين', 'pets_cats', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_cat_scottish_fold', 'سكوتيش فولد', 'pets_cats', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_cat_british_shorthair', 'بريتش شورت هير', 'pets_cats', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_cat_ragdoll', 'رغدول', 'pets_cats', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_cat_siamese', 'سيامي', 'pets_cats', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_cat_maine_coon', 'ماين كون', 'pets_cats', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_cat_bengal', 'بنغالي', 'pets_cats', 'model', 8, NULL);
SELECT public._seed_pets_node('pets_cat_abyssinian', 'أبيسيني', 'pets_cats', 'model', 9, NULL);
SELECT public._seed_pets_node('pets_cat_himalayan', 'هملايا', 'pets_cats', 'model', 10, NULL);
SELECT public._seed_pets_node('pets_cat_local', 'قط بلدي', 'pets_cats', 'model', 11, NULL);
SELECT public._seed_pets_node('pets_cat_other', 'أصناف أخرى', 'pets_cats', 'model', 12, NULL);

-- Level 2 — طيور
SELECT public._seed_pets_node('pets_bird_budgie', 'بادجي (حب لحب)', 'pets_birds', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_bird_cockatiel', 'كوكتيل', 'pets_birds', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_bird_african_grey', 'ببغاء أفريقي', 'pets_birds', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_bird_amazon', 'ببغاء أمازون', 'pets_birds', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_bird_macaw', 'كاسيكا', 'pets_birds', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_bird_canary', 'كناري', 'pets_birds', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_bird_racing_pigeon', 'حمام زاجل', 'pets_birds', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_bird_fancy_pigeon', 'حمام زينة', 'pets_birds', 'model', 8, NULL);
SELECT public._seed_pets_node('pets_bird_dove', 'يمام', 'pets_birds', 'model', 9, NULL);
SELECT public._seed_pets_node('pets_bird_peacock', 'بشنين (طاووس)', 'pets_birds', 'model', 10, NULL);
SELECT public._seed_pets_node('pets_bird_fancy_chicken', 'دجاج زينة', 'pets_birds', 'model', 11, NULL);
SELECT public._seed_pets_node('pets_bird_other', 'طيور أخرى', 'pets_birds', 'model', 12, NULL);

-- Level 2 — أسماك وأحواض
SELECT public._seed_pets_node('pets_fish_goldfish', 'سمك الذهب (غولدفيش)', 'pets_fish', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_fish_koi', 'سمك كوي', 'pets_fish', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_fish_arowana', 'سمك أروانا', 'pets_fish', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_fish_flowerhorn', 'سمك فلاور هورن', 'pets_fish', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_fish_oscar', 'سمك أسكار', 'pets_fish', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_fish_betta', 'سمك بيتا', 'pets_fish', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_fish_tropical', 'سمك نيون وزيبرا', 'pets_fish', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_fish_saltwater', 'أسماك بحرية', 'pets_fish', 'model', 8, NULL);
SELECT public._seed_pets_node('pets_fish_tanks', 'أحواض وإكسسوارات', 'pets_fish', 'model', 9, NULL);
SELECT public._seed_pets_node('pets_fish_other', 'أسماك أخرى', 'pets_fish', 'model', 10, NULL);

-- Level 2 — حيوانات المزرعة
SELECT public._seed_pets_node('pets_farm_cattle', 'أبقار وعجول', 'pets_farm', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_farm_sheep', 'أغنام', 'pets_farm', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_farm_goats', 'ماعز', 'pets_farm', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_farm_camels', 'جمال وناقات', 'pets_farm', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_farm_horses', 'خيول وأفراس', 'pets_farm', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_farm_donkeys', 'حمير وبغال', 'pets_farm', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_farm_poultry', 'دجاج وبط وأوز', 'pets_farm', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_farm_turkey', 'ديك رومي', 'pets_farm', 'model', 8, NULL);
SELECT public._seed_pets_node('pets_farm_rabbits', 'أرانب مزرعة', 'pets_farm', 'model', 9, NULL);
SELECT public._seed_pets_node('pets_farm_bees', 'نحل وعسل', 'pets_farm', 'model', 10, NULL);
SELECT public._seed_pets_node('pets_farm_other', 'حيوانات مزرعة أخرى', 'pets_farm', 'model', 11, NULL);

-- Level 2 — زواحف وبرمائيات
SELECT public._seed_pets_node('pets_reptile_leopard_gecko', 'سحلية ليوبارد غيكو', 'pets_reptiles', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_reptile_uromastyx', 'سحلية دابة', 'pets_reptiles', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_reptile_corn_snake', 'ثعبان كورن سنيك', 'pets_reptiles', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_reptile_ball_python', 'ثعبان بول بايثون', 'pets_reptiles', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_reptile_tortoise', 'سلحفاة برية', 'pets_reptiles', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_reptile_turtle', 'سلحفاة مائية', 'pets_reptiles', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_reptile_chameleon', 'حرباء', 'pets_reptiles', 'model', 7, NULL);
SELECT public._seed_pets_node('pets_reptile_other', 'زواحف أخرى', 'pets_reptiles', 'model', 8, NULL);

-- Level 2 — أرانب وقوارض
SELECT public._seed_pets_node('pets_rabbit_fancy', 'أرانب زينة', 'pets_rabbits', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_rabbit_hamster', 'هامستر', 'pets_rabbits', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_rabbit_guinea_pig', 'خنزير غيني', 'pets_rabbits', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_rabbit_squirrel', 'سنجاب', 'pets_rabbits', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_rabbit_hedgehog', 'قنفذ', 'pets_rabbits', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_rabbit_other', 'قوارض أخرى', 'pets_rabbits', 'model', 6, NULL);

-- Level 2 — مستلزمات الحيوانات
SELECT public._seed_pets_node('pets_acc_food', 'طعام وعلف', 'pets_accessories', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_acc_cages', 'أقفاص وبيوت', 'pets_accessories', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_acc_clothing', 'ملابس وإكسسوارات', 'pets_accessories', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_acc_toys', 'ألعاب حيوانات', 'pets_accessories', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_acc_medicine', 'أدوية وفيتامينات', 'pets_accessories', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_acc_collars', 'أحزمة وياقات', 'pets_accessories', 'model', 6, NULL);
SELECT public._seed_pets_node('pets_acc_grooming', 'شامبو وعناية', 'pets_accessories', 'model', 7, NULL);

-- Level 2 — خدمات الحيوانات
SELECT public._seed_pets_node('pets_svc_vet', 'طبيب بيطري', 'pets_services', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_svc_breeding', 'تزويج وتربية', 'pets_services', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_svc_dog_training', 'تدريب كلاب', 'pets_services', 'model', 3, NULL);
SELECT public._seed_pets_node('pets_svc_grooming', 'حلاقة وتجميل حيوانات', 'pets_services', 'model', 4, NULL);
SELECT public._seed_pets_node('pets_svc_pet_hotel', 'فندق حيوانات أليفة', 'pets_services', 'model', 5, NULL);
SELECT public._seed_pets_node('pets_svc_delivery', 'توصيل حيوانات', 'pets_services', 'model', 6, NULL);

-- Level 2 — مفقود وموجود
SELECT public._seed_pets_node('pets_lost_pet', 'حيوان مفقود', 'pets_lost_found', 'model', 1, NULL);
SELECT public._seed_pets_node('pets_found_pet', 'حيوان تم إيجاده', 'pets_lost_found', 'model', 2, NULL);
SELECT public._seed_pets_node('pets_adoption', 'تبني حيوانات', 'pets_lost_found', 'model', 3, NULL);

DROP FUNCTION IF EXISTS public._seed_pets_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);
