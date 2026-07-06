-- Multilingual category names: Turkish column + seed top-level browse categories.
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS name_tr TEXT;

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Real Estate'),
  name_ku = COALESCE(name_ku, 'خانوووبەرە'),
  name_tr = COALESCE(name_tr, 'Emlak')
WHERE slug = 'real_estate';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Vehicles'),
  name_ku = COALESCE(name_ku, 'ئۆتۆمبێل'),
  name_tr = COALESCE(name_tr, 'Araçlar')
WHERE slug = 'cars';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Electronics'),
  name_ku = COALESCE(name_ku, 'ئەلیکترۆنی'),
  name_tr = COALESCE(name_tr, 'Elektronik')
WHERE slug = 'electronics';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Marketplace'),
  name_ku = COALESCE(name_ku, 'بازاڕ'),
  name_tr = COALESCE(name_tr, 'Pazar')
WHERE slug = 'buy_sell';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Tutoring'),
  name_ku = COALESCE(name_ku, 'وانە تایبەت'),
  name_tr = COALESCE(name_tr, 'Özel Ders')
WHERE slug = 'tutoring';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Jobs'),
  name_ku = COALESCE(name_ku, 'کار'),
  name_tr = COALESCE(name_tr, 'İş İlanları')
WHERE slug = 'jobs';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Pets'),
  name_ku = COALESCE(name_ku, 'ئاژەڵ'),
  name_tr = COALESCE(name_tr, 'Evcil Hayvan')
WHERE slug = 'pets';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Home Help'),
  name_ku = COALESCE(name_ku, 'یارمەتی ماڵ'),
  name_tr = COALESCE(name_tr, 'Ev Yardımı')
WHERE slug = 'home_help';

UPDATE public.categories SET
  name_en = COALESCE(name_en, 'Services'),
  name_ku = COALESCE(name_ku, 'خزمەتگوزاری'),
  name_tr = COALESCE(name_tr, 'Hizmetler')
WHERE slug = 'services';
