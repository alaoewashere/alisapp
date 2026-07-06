import '../../shared/models/category_model.dart';

/// Static card subtitles keyed by category slug (all locales).
const categoryFallbackSubtitlesByLocale = <String, Map<String, String>>{
  'veh_motorcycle': {
    'ar': 'دراجات نارية ، دراجات هوائية ، سكوتر',
    'en': 'Motorcycles, Bicycles, Scooters',
    'ku': 'مۆتۆرسikl، پاسکیل، سکوoter',
    'tr': 'Motosikletler, Bisikletler, Scooter',
  },
  'veh_rental': {
    'ar': 'Chevorlet , Audi , Tesla , BMW',
    'en': 'Chevrolet, Audi, Tesla, BMW',
    'ku': 'Chevrolet, Audi, Tesla, BMW',
    'tr': 'Chevrolet, Audi, Tesla, BMW',
  },
  'veh_damaged': {
    'ar': 'Toyota , Mercedes-Benz , BMW , Kia',
    'en': 'Toyota, Mercedes-Benz, BMW, Kia',
    'ku': 'Toyota, Mercedes-Benz, BMW, Kia',
    'tr': 'Toyota, Mercedes-Benz, BMW, Kia',
  },
  'veh_accessible': {
    'ar': 'Toyota , Mercedes-Benz , BMW , Kia',
    'en': 'Toyota, Mercedes-Benz, BMW, Kia',
    'ku': 'Toyota, Mercedes-Benz, BMW, Kia',
    'tr': 'Toyota, Mercedes-Benz, BMW, Kia',
  },
  'veh_electric': {
    'ar': 'Tesla , BMW , Mercedes-Benz , Audi',
    'en': 'Tesla, BMW, Mercedes-Benz, Audi',
    'ku': 'Tesla, BMW, Mercedes-Benz, Audi',
    'tr': 'Tesla, BMW, Mercedes-Benz, Audi',
  },
  'veh_minivan': {
    'ar': 'Toyota , Kia , Hyundai , Nissan',
    'en': 'Toyota, Kia, Hyundai, Nissan',
    'ku': 'Toyota, Kia, Hyundai, Nissan',
    'tr': 'Toyota, Kia, Hyundai, Nissan',
  },
  'veh_commercial': {
    'ar': 'Toyota , Hino , Isuzu , IVECO',
    'en': 'Toyota, Hino, Isuzu, IVECO',
    'ku': 'Toyota, Hino, Isuzu, IVECO',
    'tr': 'Toyota, Hino, Isuzu, IVECO',
  },
  'veh_suv_pickup': {
    'ar': 'Toyota , Land Rover , Jeep , Lexus',
    'en': 'Toyota, Land Rover, Jeep, Lexus',
    'ku': 'Toyota, Land Rover, Jeep, Lexus',
    'tr': 'Toyota, Land Rover, Jeep, Lexus',
  },
  'veh_marine': {
    'ar': 'Yamaha , Sea-Doo , Honda Marine , Mercury',
    'en': 'Yamaha, Sea-Doo, Honda Marine, Mercury',
    'ku': 'Yamaha, Sea-Doo, Honda Marine, Mercury',
    'tr': 'Yamaha, Sea-Doo, Honda Marine, Mercury',
  },
  'veh_caravan': {
    'ar': 'Coachmen , Airstream , Jayco , Winnebago',
    'en': 'Coachmen, Airstream, Jayco, Winnebago',
    'ku': 'Coachmen, Airstream, Jayco, Winnebago',
    'tr': 'Coachmen, Airstream, Jayco, Winnebago',
  },
  'veh_classic': {
    'ar': 'Mercedes-Benz , BMW , Toyota , Ford',
    'en': 'Mercedes-Benz, BMW, Toyota, Ford',
    'ku': 'Mercedes-Benz, BMW, Toyota, Ford',
    'tr': 'Mercedes-Benz, BMW, Toyota, Ford',
  },
  'veh_aircraft': {
    'ar': 'طائرات ، مروحيات',
    'en': 'Planes, Helicopters',
    'ku': 'فڕۆkە، هێلیکۆپتەر',
    'tr': 'Uçaklar, Helikopterler',
  },
  'veh_aircraft_planes': {
    'ar': 'Cessna , Piper , Gulfstream , Embraer',
    'en': 'Cessna, Piper, Gulfstream, Embraer',
    'ku': 'Cessna, Piper, Gulfstream, Embraer',
    'tr': 'Cessna, Piper, Gulfstream, Embraer',
  },
  'veh_aircraft_helicopters': {
    'ar': 'Robinson , Bell , Airbus Helicopters , Sikorsky',
    'en': 'Robinson, Bell, Airbus Helicopters, Sikorsky',
    'ku': 'Robinson, Bell, Airbus Helicopters, Sikorsky',
    'tr': 'Robinson, Bell, Airbus Helicopters, Sikorsky',
  },
  'electronics': {
    'ar': 'هواتف ذكية ، أجهزة لوحية ، لابتوب وكمبيوتر ، مكيفات',
    'en': 'Smartphones, Tablets, Laptops, AC',
    'ku': 'مۆبایلی زیرەک، تابلێت، laptop، کۆndیشن',
    'tr': 'Akıllı Telefonlar, Tabletler, Laptoplar, Klima',
  },
  'elec_smartphones': {
    'ar': 'Apple , Samsung , Huawei , Xiaomi',
    'en': 'Apple, Samsung, Huawei, Xiaomi',
    'ku': 'Apple, Samsung, Huawei, Xiaomi',
    'tr': 'Apple, Samsung, Huawei, Xiaomi',
  },
  'buy_sell': {
    'ar': 'موبايلات ، كمبيوتر ، ملابس ، أثاث',
    'en': 'Mobiles, Computers, Clothing, Furniture',
    'ku': 'مۆبایل، کۆمپیوتەر، جلوبەرگ، کەلوپەل',
    'tr': 'Telefonlar, Bilgisayarlar, Giyim, Mobilya',
  },
  'tutoring': {
    'ar': 'مدرسة ، جامعة ، لغات ، قرآن',
    'en': 'School, University, Languages, Quran',
    'ku': 'قوتابخانە، زانکۆ، زمان، قورئان',
    'tr': 'Okul, Üniversite, Diller, Kuran',
  },
  'tutor_school': {
    'ar': 'الرياضيات ، الفيزياء ، الكيمياء ، الأحياء',
    'en': 'Mathematics, Physics, Chemistry, Biology',
    'ku': 'بیرکاری، فیزیا، کیمیا، زیندەزانی',
    'tr': 'Matematik, Fizik, Kimya, Biyoloji',
  },
  'tutor_university': {
    'ar': 'هندسة البرمجيات ، علوم الحاسوب ، الذكاء الاصطناعي ، الخوارزميات',
    'en': 'Software Engineering, Computer Science, AI, Algorithms',
    'ku': 'ئەندازیاری نەرمامێر، زanستی کۆمپیوتەر، زیرەکی دەستکرد',
    'tr': 'Yazılım Mühendisliği, Bilgisayar, Yapay Zeka, Algoritmalar',
  },
  'tutor_languages': {
    'ar': 'الإنجليزية ، العربية للأجانب ، الكردية ، التركية',
    'en': 'English, Arabic for Foreigners, Kurdish, Turkish',
    'ku': 'ئینگلیزی، عەرەبی بۆ بیانی، کوردی، تورکی',
    'tr': 'İngilizce, Yabancılar İçin Arapça, Kürtçe, Türkçe',
  },
  'tutor_quran': {
    'ar': 'حفظ القرآن ، تجويد ، فقه ، عقيدة',
    'en': 'Quran Memorization, Tajweed, Fiqh, Aqeedah',
    'ku': 'لەبەرکردنی قورئان، تەجوید، فیقه، عەقیدە',
    'tr': 'Kuran Ezberleme, Tecvid, Fıkıh, Akide',
  },
  'tutor_professional': {
    'ar': 'برمجة ، تصميم ، مونتاج ، تسويق',
    'en': 'Programming, Design, Video Editing, Marketing',
    'ku': 'بەرنامەسازی، دیزایn، مۆنتاج، مارکێتینگ',
    'tr': 'Programlama, Tasarım, Video Kurgu, Pazarlama',
  },
  'jobs': {
    'ar': 'تقنية ، هندسة ، طب ، نفط',
    'en': 'IT, Engineering, Medicine, Oil & Energy',
    'ku': 'IT، ئەndازیari، پzیشki، neft',
    'tr': 'BT, Mühendislik, Tıp, Petrol',
  },
  'pets': {
    'ar': 'كلاب ، قطط ، طيور ، مزرعة',
    'en': 'Dogs, Cats, Birds, Farm Animals',
    'ku': 'سەگ، پشیلە، باڵندە، مەزرە',
    'tr': 'Köpekler, Kediler, Kuşlar, Çiftlik Hayvanları',
  },
  'home_help': {
    'ar': 'تنظيف ، طبخ ، مربيات ، سائق',
    'en': 'Cleaning, Cooking, Childcare, Driver',
    'ku': 'پاککردنەوە، چێشت، چاودێری منداڵ، شۆfêr',
    'tr': 'Temizlik, Yemek, Bakıcı, Şoför',
  },
  'home_cleaning': {
    'ar': 'تنظيف يومي ، تنظيف أسبوعي ، تنظيف عميق ، تنظيف بعد البناء',
    'en': 'Daily cleaning, Weekly cleaning, Deep cleaning, Post-construction',
    'ku': 'پاککردنەوەی ڕۆژانە، هەفتانە، قووڵ، دوای بیناسازی',
    'tr': 'Günlük temizlik, Haftalık temizlik, Derin temizlik, İnşaat sonrası',
  },
  'home_cooking': {
    'ar': 'طباخة منزلية ، طبخ مناسبات ، حلويات ، وجبات صحية',
    'en': 'Daily home cook, Event catering, Sweets, Healthy meals',
    'ku': 'چێشتلێنانی ماڵ، بۆنە، شیرینی، خواردنی تەندروست',
    'tr': 'Ev aşçısı, Etkinlik yemeği, Tatlılar, Sağlıklı yemekler',
  },
  'home_childcare': {
    'ar': 'مربية أطفال ، جليسة بالساعة ، رعاية الرضع ، مساعدة واجبات',
    'en': 'Nanny, Hourly babysitter, Infant care, Homework help',
    'ku': 'مامانی منداڵ، چاودێری کاتژمێر، نوێزاد، یارمەتی وانە',
    'tr': 'Dadı, Saatlik bakıcı, Bebek bakımı, Ödev yardımı',
  },
  'home_eldercare': {
    'ar': 'مرافق كبار السن ، ممرض منزلي ، مساعد شخصي ، فيزيوثيرابي',
    'en': 'Elder companion, Home nurse, Patient helper, Physiotherapy',
    'ku': 'هاوڕێی پیر، پەرستاری ماڵ، یارمەتیدەری نەخۆش، فیزیۆ',
    'tr': 'Yaşlı refakat, Ev hemşiresi, Hasta bakıcı, Fizyoterapi',
  },
  'home_driver': {
    'ar': 'سائق عائلي ، سائق بالساعة ، سائق مدرسي ، سائق لكبار السن',
    'en': 'Family driver, Hourly driver, School driver, Senior driver',
    'ku': 'شۆفێری خێزان، کاتژمێر، قوتابخانە، پیر',
    'tr': 'Aile şoförü, Saatlik şoför, Okul şoförü, Yaşlı şoför',
  },
  'home_gardening': {
    'ar': 'تنسيق حدائق ، قص العشب ، ري النباتات ، تنظيف المسابح',
    'en': 'Garden design, Lawn mowing, Plant care, Pool cleaning',
    'ku': 'دیزاینی باخ، چەندکردنی گیا، ئاودان، پاککردنەوەی حەوز',
    'tr': 'Bahçe düzenleme, Çim biçme, Bitki bakımı, Havuz temizliği',
  },
  'home_maintenance': {
    'ar': 'سباك ، كهربائي ، نجار ، دهان',
    'en': 'Plumber, Electrician, Carpenter, Painter',
    'ku': 'borîçî، کارەba، necar، boyax',
    'tr': 'Tesisatçı, Elektrikçi, Marangoz, Boyacı',
  },
  'home_moving': {
    'ar': 'نقل داخل المدينة ، نقل بين المحافظات ، تغليف وتخزين ، شركة نقل',
    'en': 'Local moving, Intercity moving, Packing & storage, Moving company',
    'ku': 'گواستنەوەی ناو شار، نێوان پارێزگا، پاکەت، کۆmpaniya',
    'tr': 'Şehir içi taşıma, Şehirler arası, Paketleme, Nakliye firması',
  },
  'home_security': {
    'ar': 'حارس منزل ، كاميرات ، أنظمة إنذار ، حراسة شخصية',
    'en': 'House guard, CCTV, Alarm systems, Personal security',
    'ku': 'پاسەوانی ماڵ، کامێra، ئاگادارکردنەوە، ئاسایشی کەسی',
    'tr': 'Ev bekçisi, Kamera, Alarm, Özel güvenlik',
  },
  'home_laundry': {
    'ar': 'غسيل منزلي ، كي الملابس ، مغسلة بالتوصيل ، تنظيف جاف',
    'en': 'Home laundry, Ironing, Pickup laundry, Dry cleaning',
    'ku': 'جلوبرگی ماڵ، ئistri، گوastنەوە، پاککردنەوەی وشک',
    'tr': 'Evde çamaşır, Ütü, Teslimatlı çamaşır, Kuru temizleme',
  },
  'elec_tablets': {
    'ar': 'Apple, Samsung, Huawei, Lenovo',
    'en': 'Apple, Samsung, Huawei, Lenovo',
    'ku': 'Apple, Samsung, Huawei, Lenovo',
    'tr': 'Apple, Samsung, Huawei, Lenovo',
  },
  'elec_laptops': {
    'ar': 'Apple, Dell, HP, Lenovo',
    'en': 'Apple, Dell, HP, Lenovo',
    'ku': 'Apple, Dell, HP, Lenovo',
    'tr': 'Apple, Dell, HP, Lenovo',
  },
  'elec_displays': {
    'ar': 'Samsung, LG, Sony, TCL',
    'en': 'Samsung, LG, Sony, TCL',
    'ku': 'Samsung, LG, Sony, TCL',
    'tr': 'Samsung, LG, Sony, TCL',
  },
  'elec_cameras': {
    'ar': 'Canon, Nikon, Sony, GoPro',
    'en': 'Canon, Nikon, Sony, GoPro',
    'ku': 'Canon, Nikon, Sony, GoPro',
    'tr': 'Canon, Nikon, Sony, GoPro',
  },
  'elec_audio': {
    'ar': 'JBL, Sony, Bose, Apple',
    'en': 'JBL, Sony, Bose, Apple',
    'ku': 'JBL, Sony, Bose, Apple',
    'tr': 'JBL, Sony, Bose, Apple',
  },
  'elec_gaming': {
    'ar': 'PlayStation, Xbox, Nintendo, PC Gaming',
    'en': 'PlayStation, Xbox, Nintendo, PC Gaming',
    'ku': 'PlayStation, Xbox, Nintendo, PC Gaming',
    'tr': 'PlayStation, Xbox, Nintendo, PC Gaming',
  },
  'elec_wearables': {
    'ar': 'Apple Watch, Samsung, Xiaomi, Fitbit',
    'en': 'Apple Watch, Samsung, Xiaomi, Fitbit',
    'ku': 'Apple Watch, Samsung, Xiaomi, Fitbit',
    'tr': 'Apple Watch, Samsung, Xiaomi, Fitbit',
  },
  'elec_printers': {
    'ar': 'HP, Canon, Epson, Brother',
    'en': 'HP, Canon, Epson, Brother',
    'ku': 'HP, Canon, Epson, Brother',
    'tr': 'HP, Canon, Epson, Brother',
  },
  'elec_networking': {
    'ar': 'TP-Link, Huawei, Netgear, Cisco',
    'en': 'TP-Link, Huawei, Netgear, Cisco',
    'ku': 'TP-Link, Huawei, Netgear, Cisco',
    'tr': 'TP-Link, Huawei, Netgear, Cisco',
  },
  'elec_smart_home': {
    'ar': 'Google, Amazon, Xiaomi, Philips Hue',
    'en': 'Google, Amazon, Xiaomi, Philips Hue',
    'ku': 'Google, Amazon, Xiaomi, Philips Hue',
    'tr': 'Google, Amazon, Xiaomi, Philips Hue',
  },
  'elec_parts': {
    'ar': 'Batteries, Chargers, Cables, Cases',
    'en': 'Batteries, Chargers, Cables, Cases',
    'ku': 'Batteries, Chargers, Cables, Cases',
    'tr': 'Piller, Şarj cihazları, Kablolar, Kılıflar',
  },
  'elec_appliances': {
    'ar': 'Samsung, LG, Bosch, Siemens',
    'en': 'Samsung, LG, Bosch, Siemens',
    'ku': 'Samsung, LG, Bosch, Siemens',
    'tr': 'Samsung, LG, Bosch, Siemens',
  },
  'elec_ac': {
    'ar': 'Gree, Carrier, LG, Samsung',
    'en': 'Gree, Carrier, LG, Samsung',
    'ku': 'Gree, Carrier, LG, Samsung',
    'tr': 'Gree, Carrier, LG, Samsung',
  },
  'pets_dogs': {
    'ar': 'German Shepherd, Husky, Labrador, Maltese',
    'en': 'German Shepherd, Husky, Labrador, Maltese',
    'ku': 'German Shepherd, Husky, Labrador, Maltese',
    'tr': 'Alman Kurdu, Husky, Labrador, Maltese',
  },
  'pets_cats': {
    'ar': 'Persian, Scottish Fold, British, Ragdoll',
    'en': 'Persian, Scottish Fold, British, Ragdoll',
    'ku': 'Persian, Scottish Fold, British, Ragdoll',
    'tr': 'Persian, Scottish Fold, British, Ragdoll',
  },
  'pets_birds': {
    'ar': 'Parrot, Canary, Budgie, Lovebird',
    'en': 'Parrot, Canary, Budgie, Lovebird',
    'ku': 'Parrot, Canary, Budgie, Lovebird',
    'tr': 'Papağan, Kanarya, Muhabbet, Lovebird',
  },
  'pets_fish': {
    'ar': 'Freshwater, Saltwater, Aquarium, Accessories',
    'en': 'Freshwater, Saltwater, Aquarium, Accessories',
    'ku': 'Freshwater, Saltwater, Aquarium, Accessories',
    'tr': 'Tatlı su, Tuzlu su, Akvaryum, Aksesuar',
  },
  'pets_farm': {
    'ar': 'Sheep, Goats, Cows, Chickens',
    'en': 'Sheep, Goats, Cows, Chickens',
    'ku': 'Sheep, Goats, Cows, Chickens',
    'tr': 'Koyun, Keçi, İnek, Tavuk',
  },
  'pets_reptiles': {
    'ar': 'Turtles, Snakes, Lizards, Frogs',
    'en': 'Turtles, Snakes, Lizards, Frogs',
    'ku': 'Turtles, Snakes, Lizards, Frogs',
    'tr': 'Kaplumbağa, Yılan, Kertenkele, Kurbağa',
  },
  'pets_rabbits': {
    'ar': 'Rabbits, Hamsters, Guinea pigs, Mice',
    'en': 'Rabbits, Hamsters, Guinea pigs, Mice',
    'ku': 'Rabbits, Hamsters, Guinea pigs, Mice',
    'tr': 'Tavşan, Hamster, Gine domuzu, Fare',
  },
  'pets_accessories': {
    'ar': 'Food, Toys, Cages, Grooming',
    'en': 'Food, Toys, Cages, Grooming',
    'ku': 'Food, Toys, Cages, Grooming',
    'tr': 'Mama, Oyuncak, Kafes, Bakım',
  },
  'pets_services': {
    'ar': 'Vet, Grooming, Training, Boarding',
    'en': 'Vet, Grooming, Training, Boarding',
    'ku': 'Vet, Grooming, Training, Boarding',
    'tr': 'Veteriner, Tımar, Eğitim, Pansiyon',
  },
  'pets_lost_found': {
    'ar': 'Lost pets, Found pets, Adoption',
    'en': 'Lost pets, Found pets, Adoption',
    'ku': 'Lost pets, Found pets, Adoption',
    'tr': 'Kayıp, Bulunan, Sahiplendirme',
  },
};

String categoryFallbackSubtitle(String slug, String localeCode) {
  final map = categoryFallbackSubtitlesByLocale[slug];
  if (map == null) return '';
  final code = CategoryModel.normalizeAppLocaleCode(localeCode);
  return map[code] ?? map['ar'] ?? '';
}

String categorySubtitleSeparator(String localeCode) {
  final code = CategoryModel.normalizeAppLocaleCode(localeCode);
  return (code == 'en' || code == 'tr') ? ', ' : ' ، ';
}
