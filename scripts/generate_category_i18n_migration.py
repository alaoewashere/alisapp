#!/usr/bin/env python3
"""Generate SQL migration for category descriptions and model-row name translations."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = ROOT / "supabase" / "migrations"
OUT = MIGRATIONS / "20260727000000_category_descriptions_and_models.sql"

SEED_RE = re.compile(
    r"_seed_(?:tutor|jobs|souq)_node\('([^']+)',\s*'([^']*)'",
)

# slug -> (en, ku, tr)
TUTOR: dict[str, tuple[str, str, str]] = {
    "tutor_school_math": ("Mathematics", "بیرکاری", "Matematik"),
    "tutor_school_physics": ("Physics", "فیزیا", "Fizik"),
    "tutor_school_chemistry": ("Chemistry", "کیمیا", "Kimya"),
    "tutor_school_biology": ("Biology", "زیندەزانی", "Biyoloji"),
    "tutor_school_arabic": ("Arabic Language", "زمانی عەرەبی", "Arapça"),
    "tutor_school_english": ("English Language", "زمانی ئینگلیزی", "İngilizce"),
    "tutor_school_history_geo": ("History & Geography", "مێژوو و جوgrafiya", "Tarih ve Coğrafya"),
    "tutor_school_islamic": ("Islamic Education", "پەروەردەی ئیسلامی", "İslam Eğitimi"),
    "tutor_school_science": ("General Science", "زانستی گشتی", "Genel Fen"),
    "tutor_school_computer": ("Computer & Technology", "کۆمپیوتەر و تەکنەلۆژیا", "Bilgisayar ve Teknoloji"),
    "tutor_school_civic": ("Civics", "پەروەردەی نیشتمانی", "Vatandaşlık"),
    "tutor_school_grade6": ("Grade 6 Primary", "پۆلی شەشەمی سەرەتایی", "6. Sınıf İlkokul"),
    "tutor_school_grade9": ("Grade 9 Intermediate", "پۆلی سێیەمی ناوەند", "9. Sınıf Ortaokul"),
    "tutor_school_grade12_sci": ("Grade 12 Scientific", "پۆلی شەشەمی ئامادەیی (زانستی)", "12. Sınıf Fen"),
    "tutor_school_grade12_art": ("Grade 12 Literary", "پۆلی شەشەمی ئامادەیی (وێژەیی)", "12. Sınıf Sözel"),
    "tutor_uni_software_eng": ("Software Engineering", "ئەندازیاری نەرمامێر", "Yazılım Mühendisliği"),
    "tutor_uni_cs": ("Computer Science", "زانستی کۆمپیوتەر", "Bilgisayar Bilimleri"),
    "tutor_uni_ai": ("Artificial Intelligence", "زیرەکی دەستکرد", "Yapay Zeka"),
    "tutor_uni_algorithms": ("Algorithms & Data Structures", "ئەلگۆریتم و پێکهاتەی داتا", "Algoritmalar ve Veri Yapıları"),
    "tutor_uni_databases": ("Databases", "بنکەی زانیاری", "Veritabanları"),
    "tutor_uni_networks": ("Computer Networks", "تۆڕەکانی کۆمپیوتەر", "Bilgisayar Ağları"),
    "tutor_uni_electrical_eng": ("Electrical Engineering", "ئەندازیاری کارەبا", "Elektrik Mühendisliği"),
    "tutor_uni_civil_eng": ("Civil Engineering", "ئەندازیاری شارستانی", "İnşaat Mühendisliği"),
    "tutor_uni_mechanical_eng": ("Mechanical Engineering", "ئەندازیاری میکانیک", "Makine Mühendisliği"),
    "tutor_uni_architecture": ("Architecture", "ئەندازیاری تەلارسازی", "Mimarlık"),
    "tutor_uni_medicine": ("Medicine & Pharmacy", "پزیشکی و دەرمانسازی", "Tıp ve Eczacılık"),
    "tutor_uni_nursing": ("Nursing & Health Sciences", "پەرستاری و زانستی تەندروستی", "Hemşirelik ve Sağlık Bilimleri"),
    "tutor_uni_accounting": ("Accounting & Management", "ژمێریاری و بەڕێوەبردن", "Muhasebe ve Yönetim"),
    "tutor_uni_economics": ("Economics & Banking", "ئابووری و بانک", "Ekonomi ve Bankacılık"),
    "tutor_uni_law": ("Law", "یاسا", "Hukuk"),
    "tutor_uni_math": ("Applied Mathematics", "بیرکاری کاربردی", "Uygulamalı Matematik"),
    "tutor_uni_physics": ("University Physics", "فیزیاکانی زانکۆ", "Üniversite Fiziği"),
    "tutor_uni_chemistry": ("University Chemistry", "کیمیای زانکۆ", "Üniversite Kimyası"),
    "tutor_uni_arabic_lit": ("Arabic Language & Literature", "زمانی عەرەبی و ئەدەبیات", "Arap Dili ve Edebiyatı"),
    "tutor_uni_english_lit": ("English Language & Literature", "زمانی ئینگلیزی و ئەدەبیات", "İngiliz Dili ve Edebiyatı"),
    "tutor_uni_media": ("Media & Journalism", "میدیا و ڕۆژنامەگەری", "Medya ve Gazetecilik"),
    "tutor_uni_education": ("Education & Psychology", "پەروەردە و دەروونناسی", "Eğitim ve Psikoloji"),
    "tutor_uni_agriculture": ("Agriculture & Environment", "کشتوکاڵ و ژینگە", "Tarım ve Çevre"),
    "tutor_lang_english": ("English Language", "زمانی ئینگلیزی", "İngilizce"),
    "tutor_lang_arabic_foreign": ("Arabic for Foreigners", "عەرەبی بۆ بیانییەکان", "Yabancılar İçin Arapça"),
    "tutor_lang_kurdish": ("Kurdish Language", "زمانی کوردی", "Kürtçe"),
    "tutor_lang_turkish": ("Turkish Language", "زمانی تورکی", "Türkçe"),
    "tutor_lang_persian": ("Persian Language", "زمانی فارسی", "Farsça"),
    "tutor_lang_french": ("French Language", "زمانی فەڕەنسی", "Fransızca"),
    "tutor_lang_german": ("German Language", "زمانی ئەڵمانی", "Almanca"),
    "tutor_lang_russian": ("Russian Language", "زمانی ڕووسی", "Rusça"),
    "tutor_lang_chinese": ("Chinese Language", "زمانی چینی", "Çince"),
    "tutor_lang_korean": ("Korean Language", "زمانی کۆری", "Korece"),
    "tutor_lang_ielts": ("IELTS / TOEFL Prep", "ئامادەکاری IELTS / TOEFL", "IELTS / TOEFL Hazırlık"),
    "tutor_quran_memorization": ("Quran Memorization", "لەبەرکردنی قورئان", "Kuran Ezberleme"),
    "tutor_quran_tajweed": ("Quran Tajweed", "تەجویدی قورئان", "Kuran Tecvid"),
    "tutor_islamic_fiqh": ("Islamic Jurisprudence", "فیقهی ئیسلامی", "İslam Hukuku"),
    "tutor_islamic_aqeedah": ("Aqeedah & Tafsir", "عەقیدە و تفسیر", "Akide ve Tefsir"),
    "tutor_islamic_arabic": ("Islamic Arabic", "عەرەبی شەرعی", "İslami Arapça"),
    "tutor_prof_programming": ("Programming & App Development", "بەرنامەسازی و گەشەپێدانی ئەپ", "Programlama ve Uygulama Geliştirme"),
    "tutor_prof_graphic_design": ("Graphic Design", "دیزاینی گرافیک", "Grafik Tasarım"),
    "tutor_prof_video": ("Video Editing & Production", "مۆنتاج و بەرهەمهێنانی ڤیدیۆ", "Video Kurgu ve Prodüksiyon"),
    "tutor_prof_marketing": ("Digital Marketing", "مارکێتینگی دیجیتاڵ", "Dijital Pazarlama"),
    "tutor_prof_accounting_sw": ("Accounting & Finance Software", "ژمێریاری و نەرمامێری دارایی", "Muhasebe ve Finans Yazılımı"),
    "tutor_prof_office": ("Office Skills (Word/Excel)", "لێهاتوویی ئۆفیس (Word/Excel)", "Ofis Becerileri (Word/Excel)"),
    "tutor_prof_cybersecurity": ("Cybersecurity", "ئاسایشی سایبری", "Siber Güvenlik"),
    "tutor_prof_ai_ml": ("AI & Machine Learning", "زیرەکی دەستکرد و فێربوونی ئامێر", "Yapay Zeka ve Makine Öğrenimi"),
    "tutor_prof_project_mgmt": ("Project Management", "بەڕێوەبردنی پڕۆژە", "Proje Yönetimi"),
    "tutor_prof_entrepreneurship": ("Entrepreneurship", "کارگێڕی", "Girişimcilik"),
}

JOBS: dict[str, tuple[str, str, str]] = {
    "jobs_it_mobile_dev": ("Mobile App Developer", "گەشەپێدەری ئەپی مۆبایل", "Mobil Uygulama Geliştirici"),
    "jobs_it_web_dev": ("Web Developer", "گەشەپێدەری وێب", "Web Geliştirici"),
    "jobs_it_backend": ("Backend Engineer", "ئەندازیاری باك ئێند", "Backend Mühendisi"),
    "jobs_it_frontend": ("Frontend Engineer", "ئەندازیاری فرۆنت ئێند", "Frontend Mühendisi"),
    "jobs_it_devops": ("DevOps & Cloud Engineer", "ئەندازیاری DevOps و Cloud", "DevOps ve Bulut Mühendisi"),
    "jobs_it_cybersecurity": ("Cybersecurity Specialist", "پسپۆڕی ئاسایشی سایبری", "Siber Güvenlik Uzmanı"),
    "jobs_it_networks": ("Network Engineer", "ئەندازیاری تۆڕ", "Ağ Mühendisi"),
    "jobs_it_data_ai": ("Data Analyst & AI", "شیکردنەوەی داتا و زیرەکی دەستکرد", "Veri Analisti ve Yapay Zeka"),
    "jobs_it_ui_ux": ("UI/UX Designer", "دیزاینەری UI/UX", "UI/UX Tasarımcı"),
    "jobs_it_tech_support": ("Technical Support", "پشتگیری تەکنیکی", "Teknik Destek"),
    "jobs_eng_civil": ("Civil Engineer", "ئەندازیاری شارستانی", "İnşaat Mühendisi"),
    "jobs_eng_architect": ("Architect", "ئەندازیاری تەلارسازی", "Mimar"),
    "jobs_eng_electrical": ("Electrical Engineer", "ئەندازیاری کارەبا", "Elektrik Mühendisi"),
    "jobs_eng_mechanical": ("Mechanical Engineer", "ئەندازیاری میکانیک", "Makine Mühendisi"),
    "jobs_eng_petroleum": ("Petroleum Engineer", "ئەندازیاری نەوت", "Petrol Mühendisi"),
    "jobs_eng_environment": ("Environmental Engineer", "ئەندازیاری ژینگە", "Çevre Mühendisi"),
    "jobs_eng_site_supervisor": ("Site Supervisor", "سەرپەرشتیاری شوێن", "Saha Sorumlusu"),
    "jobs_eng_surveyor": ("Surveyor & Planner", "پێوان و پلاندانەر", "Harita Mühendisi"),
    "jobs_eng_electrician_plumber": ("Electrician & Plumber", "کارەباچی و بۆریچی", "Elektrikçi ve Tesisatçı"),
    "jobs_eng_construction_worker": ("Construction Worker", "کرێکاری بیناسازی", "İnşaat İşçisi"),
    "jobs_med_doctor": ("Doctor", "پزیشک", "Doktor"),
    "jobs_med_dentist": ("Dentist", "ددانساز", "Diş Hekimi"),
    "jobs_med_pharmacist": ("Pharmacist", "دەرمانساز", "Eczacı"),
    "jobs_med_nurse": ("Nurse", "پەرستار", "Hemşire"),
    "jobs_med_physiotherapist": ("Physiotherapist", "چارەسەری فیزیایی", "Fizyoterapist"),
    "jobs_med_lab_tech": ("Medical Lab Technician", "تەکنیکی تاقیگەی پزیشکی", "Tıbbi Laborant"),
    "jobs_med_hospital_admin": ("Hospital Administrator", "بەڕێوەبەری نەخۆشخانە", "Hastane Yöneticisi"),
    "jobs_med_paramedic": ("Paramedic", "پزیشکی فریاکەوتن", "Paramedik"),
    "jobs_bus_accountant": ("Accountant & Auditor", "ژمێریار و پشکن", "Muhasebeci ve Denetçi"),
    "jobs_bus_finance_manager": ("Finance Manager", "بەڕێوەبەری دارایی", "Finans Müdürü"),
    "jobs_bus_hr": ("Human Resources", "سەرچاوەی مرۆیی", "İnsan Kaynakları"),
    "jobs_bus_sales_marketing": ("Sales & Marketing Manager", "بەڕێوەبەری فرۆشتن و مارکێتینگ", "Satış ve Pazarlama Müdürü"),
    "jobs_bus_sales_rep": ("Sales Representative", "نوێنەری فرۆشتن", "Satış Temsilcisi"),
    "jobs_bus_secretary": ("Secretary & Administrator", "سekreter و بەڕێوەبەر", "Sekreter ve Yönetici"),
    "jobs_bus_project_manager": ("Project Manager", "بەڕێوەبەری پڕۆژە", "Proje Müdürü"),
    "jobs_bus_lawyer": ("Legal Consultant & Lawyer", "ڕاوێژکاری یاسایی", "Avukat ve Hukuk Danışmanı"),
    "jobs_bus_real_estate_agent": ("Real Estate Agent", "بریکاری خانوبەرە", "Emlak Danışmanı"),
    "jobs_bus_customer_service": ("Customer Service", "خزمەتگوزاری کڕیار", "Müşteri Hizmetleri"),
    "jobs_edu_school_teacher": ("School Teacher", "مامۆستای قوتابخانە", "Okul Öğretmeni"),
    "jobs_edu_university_prof": ("University Professor", "پrofessorی زانکۆ", "Üniversite Profesörü"),
    "jobs_edu_trainer": ("Professional Trainer", "ڕاهێنەری پیشەیی", "Mesleki Eğitmen"),
    "jobs_edu_english_teacher": ("English Teacher", "مامۆستای ئینگلیزی", "İngilizce Öğretmeni"),
    "jobs_edu_supervisor": ("Education Supervisor", "سەرپەرشتیاری پەروەردەیی", "Eğitim Denetmeni"),
    "jobs_edu_nanny_teacher": ("Nanny & Childcare", "مامانی منداڵ", "Çocuk Bakıcısı"),
    "jobs_oil_drilling_eng": ("Drilling Engineer", "ئەندازیاری کۆنکردن", "Sondaj Mühendisi"),
    "jobs_oil_geologist": ("Geologist", "جیۆلۆژ", "Jeolog"),
    "jobs_oil_tech": ("Oil Facilities Technician", "تەکنیکی دامەزراوەی نەوت", "Petrol Tesis Teknisyeni"),
    "jobs_oil_power_plant": ("Power Plant Operator", "کارگێڕی وێستگەی وزە", "Enerji Santrali Operatörü"),
    "jobs_oil_solar_tech": ("Solar Energy Technician", "تەکنیکی وزەی خۆر", "Güneş Enerjisi Teknisyeni"),
    "jobs_oil_hse": ("HSE Safety & Environment", "سلامەت و HSE", "İSG ve Çevre"),
    "jobs_media_graphic_designer": ("Graphic Designer", "دیزاینەری گرافیک", "Grafik Tasarımcı"),
    "jobs_media_photographer": ("Photographer & Videographer", "وێنەگر و ڤیدیۆگر", "Fotoğrafçı ve Videograf"),
    "jobs_media_video_editor": ("Video Editor", "مۆنتێر", "Video Editörü"),
    "jobs_media_journalist": ("Journalist & Presenter", "ڕۆژنامەvan و پێشکەشکار", "Gazeteci ve Sunucu"),
    "jobs_media_social_media": ("Social Media Manager", "بەڕێوەبەری تۆڕە کۆمەڵایەتییەکان", "Sosyal Medya Yöneticisi"),
    "jobs_media_content_writer": ("Content Writer", "نووسەری ناوەڕۆk", "İçerik Yazarı"),
    "jobs_media_translator": ("Translator", "وەرگێڕ", "Tercüman"),
    "jobs_media_producer": ("Broadcast Producer", "بەرهەمهێنەری ڕادیۆ و تەلەفزیۆn", "Yapımcı"),
    "jobs_hosp_chef": ("Chef", "چێشتلێن", "Aşçı"),
    "jobs_hosp_waiter": ("Waiter", "گارسۆn", "Garson"),
    "jobs_hosp_hotel_reception": ("Hotel Receptionist", "کارمەندی پێشوازی هۆtel", "Otel Resepsiyonisti"),
    "jobs_hosp_tour_guide": ("Tour Guide", "ڕێبەری گەشتیاری", "Tur Rehberi"),
    "jobs_hosp_manager": ("Restaurant or Hotel Manager", "بەڕێوەبەری چێشتخانە یان هۆtel", "Restoran veya Otel Müdürü"),
    "jobs_hosp_cleaning": ("Cleaning & Hospitality Staff", "کارمەندی پاککردنەوە", "Temizlik Personeli"),
    "jobs_trade_mechanic": ("Auto Mechanic", "میکانیکی ئۆتۆمبێل", "Oto Tamircisi"),
    "jobs_trade_welder": ("Welder & Blacksmith", "ئاسنگەر و جوڵکەر", "Kaynakçı"),
    "jobs_trade_carpenter": ("Carpenter & Furniture", "نجار و کەلوپەل", "Marangoz"),
    "jobs_trade_painter": ("Painter & Decorator", "ڕەنگکەر و دیکۆr", "Boyacı"),
    "jobs_trade_plumber": ("Plumber", "بۆریچی", "Tesisatçı"),
    "jobs_trade_ac_tech": ("AC & Refrigeration Technician", "تەکنیکی کۆndیشن", "Klima Teknisyeni"),
    "jobs_trade_tailor": ("Tailor", "خیاط", "Terzi"),
    "jobs_trade_barber": ("Barber & Salon", "سەرتاش و سالۆn", "Berber"),
    "jobs_trade_driver": ("Driver", "شۆfêr", "Şoför"),
    "jobs_trade_security": ("Security Guard", "پاسewan", "Güvenlik Görevlisi"),
    "jobs_free_tech": ("Freelance Tech", "فریلانسەری تەکنەلۆژیا", "Serbest Teknoloji"),
    "jobs_free_design": ("Freelance Design", "فریلانسەری دیزاین", "Serbest Tasarım"),
    "jobs_free_writing": ("Freelance Writing & Translation", "فریلانسەری نووسین و وەرگێڕan", "Serbest Yazarlık ve Çeviri"),
    "jobs_free_wfh": ("Work from Home", "کارکردن لە ماڵەوە", "Evden Çalışma"),
    "jobs_free_part_time": ("Part-time Work", "کارکردنی بەشەکی", "Yarı Zamanlı"),
    "jobs_free_internship": ("Internship & Volunteering", "ڕاهێnan و خۆبەخشی", "Staj ve Gönüllülük"),
}

# slug -> (ar, en, ku, tr) category card subtitles / descriptions
DESCRIPTIONS: dict[str, tuple[str, str, str, str]] = {
    "real_estate": ("سكني ، سياحي ، مشاريع ، أراضي", "Residential, Tourism, Projects, Land", "نیشتەجێبوون، گەشتیاری، پڕۆژە، زەوی", "Konut, Turizm, Projeler, Arsa"),
    "cars": ("سيارات ، SUV ، دراجات ، تجارية", "Cars, SUV, Motorcycles, Commercial", "ئۆتۆمبێل، SUV، مۆتۆرسikl، بازرگانی", "Arabalar, SUV, Motosikletler, Ticari"),
    "veh_motorcycle": ("دراجات نارية ، دراجات هوائية ، سكوتر", "Motorcycles, Bicycles, Scooters", "مۆتۆرسikl، پاسکیل، سکوoter", "Motosikletler, Bisikletler, Scooter"),
    "veh_rental": ("Chevrolet, Audi, Tesla, BMW", "Chevrolet, Audi, Tesla, BMW", "Chevrolet, Audi, Tesla, BMW", "Chevrolet, Audi, Tesla, BMW"),
    "veh_damaged": ("Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia"),
    "veh_accessible": ("Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia", "Toyota, Mercedes-Benz, BMW, Kia"),
    "veh_electric": ("Tesla, BMW, Mercedes-Benz, Audi", "Tesla, BMW, Mercedes-Benz, Audi", "Tesla, BMW, Mercedes-Benz, Audi", "Tesla, BMW, Mercedes-Benz, Audi"),
    "veh_minivan": ("Toyota, Kia, Hyundai, Nissan", "Toyota, Kia, Hyundai, Nissan", "Toyota, Kia, Hyundai, Nissan", "Toyota, Kia, Hyundai, Nissan"),
    "veh_commercial": ("Toyota, Hino, Isuzu, IVECO", "Toyota, Hino, Isuzu, IVECO", "Toyota, Hino, Isuzu, IVECO", "Toyota, Hino, Isuzu, IVECO"),
    "veh_suv_pickup": ("Toyota, Land Rover, Jeep, Lexus", "Toyota, Land Rover, Jeep, Lexus", "Toyota, Land Rover, Jeep, Lexus", "Toyota, Land Rover, Jeep, Lexus"),
    "veh_marine": ("Yamaha, Sea-Doo, Honda Marine, Mercury", "Yamaha, Sea-Doo, Honda Marine, Mercury", "Yamaha, Sea-Doo, Honda Marine, Mercury", "Yamaha, Sea-Doo, Honda Marine, Mercury"),
    "veh_caravan": ("Coachmen, Airstream, Jayco, Winnebago", "Coachmen, Airstream, Jayco, Winnebago", "Coachmen, Airstream, Jayco, Winnebago", "Coachmen, Airstream, Jayco, Winnebago"),
    "veh_classic": ("Mercedes-Benz, BMW, Toyota, Ford", "Mercedes-Benz, BMW, Toyota, Ford", "Mercedes-Benz, BMW, Toyota, Ford", "Mercedes-Benz, BMW, Toyota, Ford"),
    "veh_aircraft": ("طائرات ، مروحيات", "Planes, Helicopters", "فڕۆkە، هێلیکۆپتەر", "Uçaklar, Helikopterler"),
    "veh_aircraft_planes": ("Cessna, Piper, Gulfstream, Embraer", "Cessna, Piper, Gulfstream, Embraer", "Cessna, Piper, Gulfstream, Embraer", "Cessna, Piper, Gulfstream, Embraer"),
    "veh_aircraft_helicopters": ("Robinson, Bell, Airbus Helicopters, Sikorsky", "Robinson, Bell, Airbus Helicopters, Sikorsky", "Robinson, Bell, Airbus Helicopters, Sikorsky", "Robinson, Bell, Airbus Helicopters, Sikorsky"),
    "electronics": ("هواتف ذكية ، أجهزة لوحية ، لابتوب وكمبيوتر ، مكيفات", "Smartphones, Tablets, Laptops, AC", "مۆبایل، تابلێت، laptop، کۆndیشن", "Akıllı Telefonlar, Tabletler, Laptoplar, Klima"),
    "elec_smartphones": ("Apple, Samsung, Huawei, Xiaomi", "Apple, Samsung, Huawei, Xiaomi", "Apple, Samsung, Huawei, Xiaomi", "Apple, Samsung, Huawei, Xiaomi"),
    "buy_sell": ("موبايلات ، كمبيوتر ، ملابس ، أثاث", "Mobiles, Computers, Clothing, Furniture", "مۆبایل، کۆمپیوتەر، جلوبەرگ، کەلوپەل", "Telefonlar, Bilgisayarlar, Giyim, Mobilya"),
    "tutoring": ("مدرسة ، جامعة ، لغات ، قرآن", "School, University, Languages, Quran", "قوتابخانە، زانکۆ، زمان، قورئان", "Okul, Üniversite, Diller, Kuran"),
    "tutor_school": ("الرياضيات ، الفيزياء ، الكيمياء ، الأحياء", "Mathematics, Physics, Chemistry, Biology", "بیرکاری، فیزیا، کیمیا، زیندەزانی", "Matematik, Fizik, Kimya, Biyoloji"),
    "tutor_university": ("هندسة البرمجيات ، علوم الحاسوب ، الذكاء الاصطناعي ، الخوارزميات", "Software Engineering, Computer Science, AI, Algorithms", "ئەندازیاری نەرمامێر، زanستی کۆمپیوتەر، زیرەکی دەستکرد، ئەلگۆریtm", "Yazılım Mühendisliği, Bilgisayar Bilimleri, Yapay Zeka, Algoritmalar"),
    "tutor_languages": ("الإنجليزية ، العربية للأجانب ، الكردية ، التركية", "English, Arabic for Foreigners, Kurdish, Turkish", "ئینگلیزی، عەرەبی بۆ بیانی، کوردی، تورکی", "İngilizce, Yabancılar İçin Arapça, Kürtçe, Türkçe"),
    "tutor_quran": ("حفظ القرآن ، تجويد ، فقه ، عقيدة", "Quran Memorization, Tajweed, Fiqh, Aqeedah", "لەبەرکردنی قورئان، تەجوید، فیقه، عەقیدە", "Kuran Ezberleme, Tecvid, Fıkıh, Akide"),
    "tutor_professional": ("برمجة ، تصميم ، مونتاج ، تسويق", "Programming, Design, Video Editing, Marketing", "بەرنامەسازی، دیزایn، مۆنتاج، مارکێتینگ", "Programlama, Tasarım, Video Kurgu, Pazarlama"),
    "jobs": ("تقنية ، هندسة ، طب ، نفط", "IT, Engineering, Medicine, Oil & Energy", "IT، ئەndازیari، پzیشki، neft", "BT, Mühendislik, Tıp, Petrol"),
    "jobs_it": ("مطور موبايل ، مطور ويب ، باك إند ، فرونت إند", "Mobile Dev, Web Dev, Backend, Frontend", "گەشەپێدەری مۆبایل، وێب، باك ئێند، فرۆنت ئێند", "Mobil, Web, Backend, Frontend"),
    "jobs_engineering": ("مدني ، معماري ، كهربائي ، ميكانيكي", "Civil, Architect, Electrical, Mechanical", "شارستانی، تەلarsazi، کارەba، mekanik", "İnşaat, Mimar, Elektrik, Makine"),
    "jobs_medical": ("طبيب ، صيدلاني ، ممرض ، معالج فيزيائي", "Doctor, Pharmacist, Nurse, Physiotherapist", "pزیشk، dەرmanسaz، pەرstار", "Doktor, Eczacı, Hemşire, Fizyoterapist"),
    "jobs_business": ("محاسب ، مدير مالي ، موارد بشرية ، مبيعات", "Accountant, Finance Manager, HR, Sales", "ژmێriar، بەڕێwەbەri darayi", "Muhasebeci, Finans Müdürü, İK, Satış"),
    "jobs_education": ("معلم ، أستاذ جامعي ، مدرب ، مدرس إنجليزي", "Teacher, Professor, Trainer, English Teacher", "mamoستa، professor، rahêner", "Öğretmen, Profesör, Eğitmen, İngilizce Öğretmeni"),
    "jobs_oil_energy": ("حفر ، جيولوجي ، فني نفط ، طاقة شمسية", "Drilling, Geologist, Oil Tech, Solar", "kon، jeoloj، tekniker neft", "Sondaj, Jeolog, Petrol Teknisyeni, Güneş"),
    "jobs_media": ("جرافيك ، تصوير ، مونتاج ، صحافة", "Graphic Design, Photography, Editing, Journalism", "grafik، wêne، montaj", "Grafik, Fotoğraf, Kurgu, Gazetecilik"),
    "jobs_hospitality": ("طاهي ، نادل ، استقبال ، مرشد سياحي", "Chef, Waiter, Reception, Tour Guide", "aşpز، garson، pêşwazî", "Aşçı, Garson, Resepsiyon, Rehber"),
    "jobs_trades": ("ميكانيكي ، نجار ، سباك ، كهربائي", "Mechanic, Carpenter, Plumber, Electrician", "mekanik، necar، borîçî", "Tamirci, Marangoz, Tesisatçı, Elektrikçi"),
    "jobs_freelance": ("فريلانسر ، عمل من المنزل ، دوام جزئي", "Freelance, Work from Home, Part-time", "freelance، kar li mal", "Serbest, Evden Çalışma, Yarı Zamanlı"),
    "pets": ("كلاب ، قطط ، طيور ، مزرعة", "Dogs, Cats, Birds, Farm Animals", "sag، pisîl، balinde", "Köpekler, Kediler, Kuşlar, Çiftlik"),
    "home_help": ("تنظيف ، طبخ ، مربيات ، سائق", "Cleaning, Cooking, Childcare, Driver", "pak، xwarin، mamani", "Temizlik, Yemek, Bakıcı, Şoför"),
    "souq_mobile": ("هواتف ذكية ، آيفون ، سامسونج ، هواوي", "Smartphones, iPhone, Samsung, Huawei", "smartphone، iphone، samsung", "Akıllı Telefonlar, iPhone, Samsung, Huawei"),
    "souq_computer": ("لابتوب ، ماك ، كمبيوتر مكتبي ، شاشات", "Laptops, Mac, Desktop, Monitors", "laptop، mac، desktop", "Laptop, Mac, Masaüstü, Monitörler"),
    "souq_fashion": ("رجالي ، نسائي ، أطفال ، أحذية", "Men, Women, Kids, Shoes", "pîyan، jinan، zarok", "Erkek, Kadın, Çocuk, Ayakkabı"),
    "souq_furniture": ("غرف نوم ، صالون ، مطبخ ، مكتب", "Bedroom, Living Room, Kitchen, Office", "jûr، salon، metbex", "Yatak Odası, Salon, Mutfak, Ofis"),
    "souq_sports": ("كرة قدم ، لياقة ، دراجات ، صيد", "Football, Fitness, Bikes, Hunting", "topy، fitness، bisiklet", "Futbol, Fitness, Bisiklet, Av"),
    "souq_misc": ("متنوع ، أدوات ، هدايا ، أخرى", "Miscellaneous, Tools, Gifts, Other", "cihêj، amûr، diyari", "Çeşitli, Araçlar, Hediyeler, Diğer"),
}


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def parse_souq() -> dict[str, tuple[str, str, str]]:
    """Build souq model translations from category_translations.json names where possible."""
    path = ROOT / "scripts" / "category_translations.json"
    if not path.exists():
        return {}
    import json

    data = json.loads(path.read_text(encoding="utf-8"))
    result: dict[str, tuple[str, str, str]] = {}
    for slug, langs in data.items():
        if not slug.startswith("souq_") or slug.endswith("_item_01"):
            continue
        if "en" in langs and "ku" in langs and "tr" in langs:
            result[slug] = (langs["en"], langs["ku"], langs["tr"])
    return result


def parse_migration_models(path: Path) -> list[tuple[str, str]]:
    text = path.read_text(encoding="utf-8")
    return [(m.group(1), m.group(2)) for m in SEED_RE.finditer(text)]


def update_name_sql(slug: str, en: str, ku: str, tr: str) -> str:
    e, k, t = map(sql_escape, (en, ku, tr))
    return (
        f"UPDATE public.categories SET "
        f"name_en = '{e}', name_ku = '{k}', name_tr = '{t}' "
        f"WHERE slug = '{slug}';"
    )


def update_desc_sql(slug: str, ar: str, en: str, ku: str, tr: str) -> str:
    a, e, k, t = map(sql_escape, (ar, en, ku, tr))
    return (
        f"UPDATE public.categories SET "
        f"description_ar = '{a}', description_en = '{e}', "
        f"description_ku = '{k}', description_tr = '{t}' "
        f"WHERE slug = '{slug}';"
    )


def main() -> None:
    lines: list[str] = [
        "-- Category descriptions + tutor/jobs/souq model name translations.",
        "",
        "ALTER TABLE public.categories",
        "  ADD COLUMN IF NOT EXISTS description_ar TEXT,",
        "  ADD COLUMN IF NOT EXISTS description_en TEXT,",
        "  ADD COLUMN IF NOT EXISTS description_ku TEXT,",
        "  ADD COLUMN IF NOT EXISTS description_tr TEXT;",
        "",
    ]

    lines.extend(
        [
            "",
            "-- Clear Arabic wrongly copied into name_en for tutor/jobs models",
            "UPDATE public.categories SET name_en = NULL, name_ku = NULL, name_tr = NULL",
            "WHERE icon = 'model' AND slug ~ '^(tutor_|jobs_)'",
            "  AND name_en ~ '[\\u0600-\\u06FF]';",
        ]
    )

    for slug, (ar, en, ku, tr) in sorted(DESCRIPTIONS.items()):
        lines.append(update_desc_sql(slug, ar, en, ku, tr))

    lines.append("")
    lines.append("-- Tutor subject names")
    for slug, (en, ku, tr) in sorted(TUTOR.items()):
        lines.append(update_name_sql(slug, en, ku, tr))

    lines.append("")
    lines.append("-- Jobs role names")
    for slug, (en, ku, tr) in sorted(JOBS.items()):
        lines.append(update_name_sql(slug, en, ku, tr))

    souq_json_path = ROOT / "scripts" / "souq_model_i18n.json"
    souq_from_file: dict[str, tuple[str, str, str]] = {}
    if souq_json_path.exists():
        import json

        raw = json.loads(souq_json_path.read_text(encoding="utf-8"))
        for slug, langs in raw.items():
            souq_from_file[slug] = (langs[0], langs[1], langs[2])

    buy_sell_path = MIGRATIONS / "20260630000000_buy_sell_marketplace_categories.sql"
    souq_branches = {
        "souq_mobile",
        "souq_computer",
        "souq_tv_audio",
        "souq_appliances",
        "souq_kitchen",
        "souq_gaming",
        "souq_fashion",
        "souq_beauty",
        "souq_furniture",
        "souq_sports",
        "souq_baby",
        "souq_books",
        "souq_music",
        "souq_hobbies",
        "souq_jewelry",
        "souq_building",
        "souq_garden",
        "souq_food",
        "souq_misc",
    }
    souq_models = [
        (slug, name_ar)
        for slug, name_ar in parse_migration_models(buy_sell_path)
        if slug.startswith("souq_") and slug not in souq_branches
    ]

    lines.append("")
    lines.append("-- Clear Arabic wrongly copied into name_en for souq models")
    lines.append(
        "UPDATE public.categories SET name_en = NULL, name_ku = NULL, name_tr = NULL"
    )
    lines.append(
        "WHERE icon = 'model' AND slug LIKE 'souq_%'"
    )
    lines.append("  AND name_en ~ '[\\u0600-\\u06FF]';")
    lines.append("")
    lines.append("-- Souq marketplace item names")
    for slug, _name_ar in souq_models:
        if slug not in souq_from_file:
            continue
        en, ku, tr = souq_from_file[slug]
        lines.append(update_name_sql(slug, en, ku, tr))

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(lines)} lines)")


if __name__ == "__main__":
    main()
