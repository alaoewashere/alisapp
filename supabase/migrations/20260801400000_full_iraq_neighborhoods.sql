-- Mirrors lib/core/constants/iraq_neighborhoods.dart — fills in the 12
-- governorates that previously had zero areas, and rounds out Basra/Erbil/
-- Nineveh/Najaf/Karbala to a fuller list, so every governorate has real
-- selectable المنطقة/الحي options, not just Baghdad.
INSERT INTO public.listing_area_centers (slug, name_ar, governorate_slug, latitude, longitude, display_order) VALUES
  ('basra_maqal', 'المعقل', 'basra', 30.5450, 47.7900, 34),
  ('basra_abu_al_khaseeb', 'أبو الخصيب', 'basra', 30.4200, 47.9200, 35),
  ('basra_hartha', 'الهارثة', 'basra', 30.6300, 47.6900, 36),
  ('basra_qurna', 'القرنة', 'basra', 31.0100, 47.4300, 37),
  ('basra_fao', 'الفاو', 'basra', 29.9700, 48.4700, 38),
  ('basra_hayyaniyah', 'الحيانية', 'basra', 30.5300, 47.7500, 39),
  ('basra_andalus', 'الأندلس', 'basra', 30.4900, 47.7700, 40),

  ('erbil_dream_city', 'دريم سيتي', 'erbil', 36.1500, 43.9700, 44),
  ('erbil_empire', 'إمباير وورلد', 'erbil', 36.1650, 44.0550, 45),
  ('erbil_zanko', 'زانكو (١٠٠ متري)', 'erbil', 36.1850, 44.0200, 46),
  ('erbil_shorsh', 'شورش', 'erbil', 36.1950, 43.9950, 47),
  ('erbil_iskan', 'اسكان', 'erbil', 36.1700, 43.9850, 48),
  ('erbil_bakhtiari', 'بختياري', 'erbil', 36.2000, 44.0300, 49),

  ('nineveh_left_coast', 'الساحل الأيسر', 'nineveh', 36.3600, 43.1600, 52),
  ('nineveh_maidan', 'الميدان', 'nineveh', 36.3350, 43.1300, 53),
  ('nineveh_hamdaniya', 'الحمدانية', 'nineveh', 36.2500, 43.4700, 54),
  ('nineveh_bashiqa', 'بعشيقة', 'nineveh', 36.4200, 43.4900, 55),
  ('nineveh_sinjar', 'سنجار', 'nineveh', 36.3200, 41.8700, 56),
  ('nineveh_qayyarah', 'القيارة', 'nineveh', 35.8200, 43.3100, 57),

  ('najaf_kufa', 'الكوفة', 'najaf', 32.0300, 44.4030, 61),
  ('najaf_meshkhab', 'المشخاب', 'najaf', 31.7900, 44.4700, 62),
  ('najaf_hurriya', 'الحرية', 'najaf', 32.0100, 44.3400, 63),
  ('najaf_old_city', 'المدينة القديمة', 'najaf', 31.9950, 44.3200, 64),

  ('karbala_hindiya', 'الهندية', 'karbala', 32.7400, 44.2600, 71),
  ('karbala_ain_tamur', 'عين التمر', 'karbala', 32.5700, 43.6800, 72),
  ('karbala_husseiniya', 'الحسينية', 'karbala', 32.6300, 44.0500, 73),
  ('karbala_bab_salalem', 'باب السلالم', 'karbala', 32.6100, 44.0350, 74),

  ('sulaymaniyah_center', 'مركز السليمانية', 'sulaymaniyah', 35.5650, 45.4347, 90),
  ('sulaymaniyah_bakrajo', 'بكرجو', 'sulaymaniyah', 35.5900, 45.3800, 91),
  ('sulaymaniyah_sarchinar', 'سه‌رچنار', 'sulaymaniyah', 35.5450, 45.4550, 92),
  ('sulaymaniyah_rania', 'رانية', 'sulaymaniyah', 36.2500, 44.8900, 93),
  ('sulaymaniyah_chwarchra', 'چوارچرا', 'sulaymaniyah', 35.5550, 45.4200, 94),
  ('sulaymaniyah_malik_mahmud', 'ملك محمود', 'sulaymaniyah', 35.5750, 45.4400, 95),

  ('duhok_center', 'مركز دهوك', 'duhok', 36.8617, 42.9885, 110),
  ('duhok_zakho', 'زاخو', 'duhok', 37.1440, 42.6820, 111),
  ('duhok_simele', 'سميل', 'duhok', 36.9000, 42.8300, 112),
  ('duhok_amedi', 'العمادية', 'duhok', 37.0930, 43.4890, 113),
  ('duhok_akre', 'عقرة', 'duhok', 36.7440, 43.8900, 114),

  ('kirkuk_center', 'مركز كركوك', 'kirkuk', 35.4681, 44.3922, 130),
  ('kirkuk_rahimawa', 'رحيماوة', 'kirkuk', 35.4750, 44.4000, 131),
  ('kirkuk_iskan', 'اسكان', 'kirkuk', 35.4600, 44.3700, 132),
  ('kirkuk_shorja', 'الشورجة', 'kirkuk', 35.4550, 44.4100, 133),
  ('kirkuk_dibs', 'الدبس', 'kirkuk', 35.5850, 44.0450, 134),

  ('anbar_ramadi', 'الرمادي', 'anbar', 33.4200, 43.3000, 150),
  ('anbar_fallujah', 'الفلوجة', 'anbar', 33.3489, 43.7840, 151),
  ('anbar_qaim', 'القائم', 'anbar', 34.3700, 41.1500, 152),
  ('anbar_haditha', 'حديثة', 'anbar', 34.1300, 42.3700, 153),
  ('anbar_rutba', 'الرطبة', 'anbar', 33.0350, 40.2850, 154),
  ('anbar_habbaniyah', 'الحبانية', 'anbar', 33.3700, 43.5600, 155),

  ('babil_hillah', 'الحلة', 'babil', 32.4830, 44.4200, 170),
  ('babil_musayyib', 'المسيب', 'babil', 32.7800, 44.2900, 171),
  ('babil_hashimiyah', 'الهاشمية', 'babil', 32.4000, 44.6300, 172),
  ('babil_mahawil', 'المحاويل', 'babil', 32.6100, 44.3300, 173),
  ('babil_iskandariya', 'الإسكندرية', 'babil', 33.0000, 44.2900, 174),

  ('diyala_baqubah', 'بعقوبة', 'diyala', 33.7460, 44.6420, 190),
  ('diyala_khalis', 'الخالص', 'diyala', 33.8130, 44.5330, 191),
  ('diyala_muqdadiyah', 'المقدادية', 'diyala', 33.9860, 44.9520, 192),
  ('diyala_khanaqin', 'خانقين', 'diyala', 34.3450, 45.3850, 193),
  ('diyala_balad_ruz', 'بلدروز', 'diyala', 33.7180, 44.9270, 194),

  ('wasit_kut', 'الكوت', 'wasit', 32.5120, 45.8180, 210),
  ('wasit_hai', 'الحي', 'wasit', 32.1660, 46.0280, 211),
  ('wasit_suwaira', 'الصويرة', 'wasit', 32.9330, 44.9530, 212),
  ('wasit_numaniyah', 'النعمانية', 'wasit', 32.6870, 45.2790, 213),
  ('wasit_badra', 'بدرة', 'wasit', 33.1120, 45.9760, 214),

  ('maysan_amarah', 'العمارة', 'maysan', 31.8350, 47.1450, 230),
  ('maysan_majar_kabir', 'المجر الكبير', 'maysan', 31.6600, 47.1400, 231),
  ('maysan_ali_gharbi', 'علي الغربي', 'maysan', 32.4570, 46.7040, 232),
  ('maysan_qalat_salih', 'قلعة صالح', 'maysan', 31.8500, 47.0000, 233),
  ('maysan_kahla', 'الكحلاء', 'maysan', 31.6120, 47.0400, 234),

  ('dhi_qar_nasiriyah', 'الناصرية', 'dhi_qar', 31.0430, 46.2570, 250),
  ('dhi_qar_shatra', 'الشطرة', 'dhi_qar', 31.4200, 46.1900, 251),
  ('dhi_qar_rifai', 'الرفاعي', 'dhi_qar', 31.8090, 46.1150, 252),
  ('dhi_qar_suq_shuyukh', 'سوق الشيوخ', 'dhi_qar', 30.8280, 46.4550, 253),
  ('dhi_qar_chibayish', 'الجبايش', 'dhi_qar', 30.9070, 46.9020, 254),

  ('muthanna_samawah', 'السماوة', 'muthanna', 31.3160, 45.2870, 270),
  ('muthanna_rumaitha', 'الرميثة', 'muthanna', 31.5290, 45.1900, 271),
  ('muthanna_khidr', 'الخضر', 'muthanna', 31.8020, 45.5710, 272),
  ('muthanna_salman', 'السلمان', 'muthanna', 30.4880, 44.5310, 273),

  ('qadisiyyah_diwaniyah', 'الديوانية', 'qadisiyyah', 31.9930, 44.9260, 290),
  ('qadisiyyah_shamiya', 'الشامية', 'qadisiyyah', 31.8560, 44.6220, 291),
  ('qadisiyyah_afaq', 'عفك', 'qadisiyyah', 32.0740, 45.2510, 292),
  ('qadisiyyah_hamza', 'الحمزة', 'qadisiyyah', 31.6510, 44.9770, 293),

  ('saladin_tikrit', 'تكريت', 'saladin', 34.6000, 43.6790, 310),
  ('saladin_samarra', 'سامراء', 'saladin', 34.1970, 43.8890, 311),
  ('saladin_baiji', 'بيجي', 'saladin', 34.9350, 43.4930, 312),
  ('saladin_balad', 'بلد', 'saladin', 34.0170, 44.1450, 313),
  ('saladin_dour', 'الدور', 'saladin', 34.4700, 43.7500, 314)
ON CONFLICT (slug) DO NOTHING;
