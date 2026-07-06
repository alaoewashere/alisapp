#!/usr/bin/env python3
"""Generate SQL to seed name_en, name_ku, name_tr for navigational categories."""

from __future__ import annotations

import json
from pathlib import Path

# slug -> (en, ku, tr)
TRANSLATIONS: dict[str, tuple[str, str, str]] = {
    # Top-level
    "real_estate": ("Real Estate", "خانوووبەرە", "Emlak"),
    "cars": ("Vehicles", "ئۆتۆمبێل", "Araçlar"),
    "electronics": ("Electronics", "ئەلیکترۆنی", "Elektronik"),
    "buy_sell": ("Marketplace", "بازاڕ", "Pazar"),
    "tutoring": ("Tutoring", "وانە تایبەت", "Özel Ders"),
    "jobs": ("Jobs", "کار", "İş İlanları"),
    "pets": ("Pets", "ئاژەڵ", "Evcil Hayvan"),
    "home_help": ("Home Help", "یارمەتی ماڵ", "Ev Yardımı"),
    # Real estate
    "re_residential": ("Residential", "نیشتەجێبوون", "Konut"),
    "re_tourism": ("Tourism Properties", "خاوەنداڕی گەشتیاری", "Turizm Tesisleri"),
    "re_shared": ("Shared Ownership", "خاوەنداڕی هاوبەش", "Ortak Mülkiyet"),
    "re_land": ("Land", "زەوی", "Arsa"),
    "re_projects": ("Housing Projects", "پڕۆژەی نیشتەجێبوون", "Konut Projeleri"),
    "re_commercial": ("Commercial Shops", "دوکانە بازرگانییەکان", "Ticari Dükkanlar"),
    "re_residential_sale": ("For Sale", "بۆ فرۆشتن", "Satılık"),
    "re_residential_rent": ("For Rent", "بۆ کرێ", "Kiralık"),
    "re_tourism_sale": ("For Sale", "بۆ فرۆشتن", "Satılık"),
    "re_tourism_rent": ("For Rent", "بۆ کرێ", "Kiralık"),
    "re_shared_sale": ("For Sale", "بۆ فرۆشتن", "Satılık"),
    "re_shared_rent": ("For Rent", "بۆ کرێ", "Kiralık"),
    "re_land_residential": ("Residential", "نیشتەجێبوون", "Konut"),
    "re_land_commercial": ("Commercial", "بازرگانی", "Ticari"),
    "re_land_agricultural": ("Agricultural", "کشتوکاڵ", "Tarım"),
    "re_land_industrial": ("Industrial", "پیشەسازی", "Sanayi"),
    "re_land_tourism": ("Tourism", "گەشتیاری", "Turizm"),
    "re_projects_new": ("New Housing Project", "پڕۆژەی نیشتەجێبوونی نوێ", "Yeni Konut Projesi"),
    "re_projects_complex": ("Residential Complex", "کۆمپلێکسی نیشتەجێبوون", "Konut Kompleksi"),
    "re_projects_compound": ("Compound", "کۆمپاوند", "Site"),
    "re_commercial_sale": ("For Sale", "بۆ فرۆشتن", "Satılık"),
    "re_commercial_rent": ("For Rent", "بۆ کرێ", "Kiralık"),
    "re_residential_sale_apartment": ("Apartment", "شوقە", "Daire"),
    "re_residential_sale_villa": ("Villa", "ڤیلا", "Villa"),
    "re_residential_sale_house": ("House", "خانوو", "Ev"),
    "re_residential_sale_duplex": ("Duplex", "دوبلێکس", "Dubleks"),
    "re_residential_sale_palace": ("Palace", "قەسر", "Saray"),
    "re_residential_sale_studio": ("Studio", "ستودیۆ", "Stüdyo"),
    "re_residential_rent_apartment": ("Apartment", "شوقە", "Daire"),
    "re_residential_rent_villa": ("Villa", "ڤیلا", "Villa"),
    "re_residential_rent_house": ("House", "خانوو", "Ev"),
    "re_residential_rent_duplex": ("Duplex", "دوبلێکس", "Dubleks"),
    "re_residential_rent_room": ("Room", "ژوور", "Oda"),
    "re_residential_rent_studio": ("Studio", "ستودیۆ", "Stüdyo"),
    "re_tourism_sale_hotel": ("Hotel", "هۆتێل", "Otel"),
    "re_tourism_sale_resort": ("Resort", "ڕیزۆرت", "Tatil Köyü"),
    "re_tourism_sale_chalet": ("Chalet", "شالێ", "Şale"),
    "re_tourism_sale_resthouse": ("Rest House", "استراحة", "Dinlenme Evi"),
    "re_tourism_sale_motel": ("Motel", "موتێل", "Motel"),
    "re_tourism_rent_hotel": ("Hotel", "هۆتێل", "Otel"),
    "re_tourism_rent_resort": ("Resort", "ڕیزۆرت", "Tatil Köyü"),
    "re_tourism_rent_chalet": ("Chalet", "شالێ", "Şale"),
    "re_tourism_rent_resthouse": ("Rest House", "استراحة", "Dinlenme Evi"),
    "re_tourism_rent_motel": ("Motel", "موتێل", "Motel"),
    "re_commercial_sale_office": ("Office", "نووسینگە", "Ofis"),
    "re_commercial_sale_shop": ("Shop", "دوکان", "Dükkan"),
    "re_commercial_sale_warehouse": ("Warehouse", "کۆگا", "Depo"),
    "re_commercial_sale_factory": ("Factory", "کارگە", "Fabrika"),
    "re_commercial_sale_restaurant": ("Restaurant", "چێشتخانە", "Restoran"),
    "re_commercial_sale_hotel": ("Hotel", "هۆتێل", "Otel"),
    "re_commercial_sale_gym": ("Gym", "هۆڵی وەرزش", "Spor Salonu"),
    "re_commercial_sale_gas": ("Gas Station", "وێستگەی سووتەمەنی", "Benzin İstasyonu"),
    "re_commercial_rent_office": ("Office", "نووسینگە", "Ofis"),
    "re_commercial_rent_shop": ("Shop", "دوکان", "Dükkan"),
    "re_commercial_rent_warehouse": ("Warehouse", "کۆگا", "Depo"),
    "re_commercial_rent_factory": ("Factory", "کارگە", "Fabrika"),
    "re_commercial_rent_restaurant": ("Restaurant", "چێشتخانە", "Restoran"),
    "re_commercial_rent_wedding": ("Wedding Hall", "هۆڵی ئاهەنگ", "Düğün Salonu"),
    "re_commercial_rent_showroom": ("Showroom", "پێشانگا", "Showroom"),
    # Vehicles
    "veh_automobile": ("Cars", "ئەتومبێل", "Arabalar"),
    "veh_rental": ("Car Rentals", "ئەتومبێلی کرێ", "Kiralık Arabalar"),
    "veh_electric": ("Electric Cars", "ئەتومبێلی کارەبایی", "Elektrikli Arabalar"),
    "veh_motorcycle": ("Motorcycles", "موتەر", "Motosikletler"),
    "veh_minivan": ("Vans & Minivans", "ڤان و مینی ڤان", "Van ve Minivan"),
    "veh_commercial": ("Commercial Vehicles", "ئامێری بازرگانی", "Ticari Araçlar"),
    "veh_suv_pickup": ("SUV & Pickup", "SUV و پیکاپ", "SUV ve Pickup"),
    "veh_marine": ("Marine Vehicles", "ئامێری دeryایی", "Deniz Araçları"),
    "veh_damaged": ("Damaged Cars", "ئەتومبێلی تێکچوو", "Hasarlı Arabalar"),
    "veh_caravan": ("Caravan", "کارavan", "Karavan"),
    "veh_classic": ("Classic Cars", "ئەتومبێلی کلاسیک", "Klasik Arabalar"),
    "veh_aircraft": ("Aircraft", "فڕۆکە", "Hava Araçları"),
    "veh_accessible": ("Accessible Vehicles", "ئەتومبێلی کەمئەندام", "Engelli Araçları"),
    "veh_aircraft_planes": ("Planes", "فڕۆکە", "Uçaklar"),
    "veh_aircraft_helicopters": ("Helicopters", "هێلیکۆپتەر", "Helikopterler"),
    # Electronics
    "elec_smartphones": ("Smartphones", "مۆبایلی زیرەک", "Akıllı Telefonlar"),
    "elec_tablets": ("Tablets", "تابلێت", "Tabletler"),
    "elec_laptops": ("Laptops & Computers", "لaptop و کۆمپیوتەر", "Laptop ve Bilgisayar"),
    "elec_displays": ("TVs & Displays", "تەلەفزیۆن و شاشە", "TV ve Ekranlar"),
    "elec_cameras": ("Cameras", "کامێرا", "Kameralar"),
    "elec_audio": ("Audio & Speakers", "دەنگ و بڵندگۆ", "Ses ve Hoparlörler"),
    "elec_gaming": ("Video Games", "یاری ڤیدیۆیی", "Video Oyunları"),
    "elec_wearables": ("Smartwatches & Wearables", "کاتژمێری زیرەک", "Akıllı Saatler"),
    "elec_printers": ("Printers & Accessories", "چاپکەر و پێکهاتەکان", "Yazıcılar"),
    "elec_networking": ("Networking & Routers", "تۆڕ و ڕاوتەر", "Ağ ve Yönlendiriciler"),
    "elec_smart_home": ("Smart Home Devices", "ئامێری ماڵی زیرەک", "Akıllı Ev Cihazları"),
    "elec_parts": ("Parts & Accessories", "پارچە و ئیکسسۆوار", "Parça ve Aksesuar"),
    "elec_appliances": ("Home Appliances", "ئامێری کارەبایی ماڵ", "Ev Aletleri"),
    "elec_ac": ("Air Conditioners", "کۆندیشن", "Klima"),
    "elec_desktops": ("Desktop Computers", "کۆمپیوتەری مێز", "Masaüstü Bilgisayar"),
    "elec_drones": ("Drones", "درۆن", "Drone"),
    "elec_projectors": ("Projectors", "پڕۆجێکتۆر", "Projektör"),
    "elec_medical": ("Home Medical Devices", "ئامێری پزیشکی ماڵ", "Ev Tipi Tıbbi Cihazlar"),
    # Jobs
    "jobs_it": ("IT & Programming", "IT و بەرنامەسازی", "BT ve Programlama"),
    "jobs_engineering": ("Engineering & Construction", "ئەندازیاری و بیناسازی", "Mühendislik ve İnşaat"),
    "jobs_medical": ("Medicine & Health", "پزیشکی و تەندروستی", "Tıp ve Sağlık"),
    "jobs_business": ("Business & Finance", "بازرگانی و دارایی", "İş ve Finans"),
    "jobs_education": ("Education & Training", "پەروەردە و ڕاهێنان", "Eğitim ve Öğretim"),
    "jobs_oil_energy": ("Oil & Energy", "نەوت و وزە", "Petrol ve Enerji"),
    "jobs_media": ("Media & Design", "میدیا و دیزاین", "Medya ve Tasarım"),
    "jobs_hospitality": ("Hospitality & Tourism", "میوانداری و گەشتیاری", "Otelcilik ve Turizm"),
    "jobs_trades": ("Trades & Crafts", "پیشە و دەستکاری", "Zanaat ve El Sanatları"),
    "jobs_freelance": ("Freelance & Remote", "کارکردنی ئازاد", "Serbest ve Uzaktan"),
    # Marketplace (buy_sell)
    "souq_mobile": ("Mobiles & Accessories", "مۆبایل و ئیکسسۆوار", "Telefon ve Aksesuar"),
    "souq_computer": ("Computers & Laptops", "کۆمپیوتەر و laptop", "Bilgisayar ve Laptop"),
    "souq_tv_audio": ("TV & Audio", "تەلەفزیۆن و دەنگ", "TV ve Ses"),
    "souq_appliances": ("Home Appliances", "ئامێری ماڵ", "Ev Aletleri"),
    "souq_kitchen": ("Kitchen Appliances", "ئامێری چێشتخانە", "Mutfak Aletleri"),
    "souq_gaming": ("Gaming & Entertainment", "یاری و کات بەسەربردن", "Oyun ve Eğlence"),
    "souq_fashion": ("Fashion & Clothing", "جلوبەرگ و مۆدە", "Moda ve Giyim"),
    "souq_beauty": ("Health & Beauty", "تەندروستی و جوانکاری", "Sağlık ve Güzellik"),
    "souq_furniture": ("Furniture", "کەلوپەل و مۆبیلیات", "Mobilya"),
    "souq_sports": ("Sports & Fitness", "وەرزش و تەندروستی", "Spor ve Fitness"),
    "souq_baby": ("Baby & Maternity", "منداڵ و دایکایەتی", "Bebek ve Anne"),
    "souq_books": ("Books & Education", "کتێب و پەروەردە", "Kitap ve Eğitim"),
    "souq_music": ("Music & Instruments", "مۆسیقا و ئامێر", "Müzik ve Enstrüman"),
    "souq_hobbies": ("Hobbies & Collectibles", "هەوای و کۆکردنەوە", "Hobi ve Koleksiyon"),
    "souq_jewelry": ("Jewelry & Gold", "زێڕ و زیو", "Mücevher ve Altın"),
    "souq_building": ("Building Materials", "بناء و ماددە", "Yapı Malzemeleri"),
    "souq_garden": ("Garden & Agriculture", "باخچە و کشتوکاڵ", "Bahçe ve Tarım"),
    "souq_food": ("Food & Beverages", "خواردن و خواردنەوە", "Yiyecek ve İçecek"),
    "souq_misc": ("Miscellaneous", "هەمەجۆر", "Diğer"),
    # Tutoring
    "tutor_school": ("School Tutoring", "وانەی قوتابخانە", "Okul Dersleri"),
    "tutor_university": ("University Tutoring", "وانەی زانکۆ", "Üniversite Dersleri"),
    "tutor_languages": ("Language Learning", "فێrbوونی زمان", "Dil Eğitimi"),
    "tutor_quran": ("Quran & Religious Studies", "قورئان و زانستی ئایینی", "Kuran ve Din"),
    "tutor_professional": ("Professional Skills", "لێهاتوویی پیشەیی", "Mesleki Beceriler"),
    # Pets
    "pets_dogs": ("Dogs", "سەگ", "Köpekler"),
    "pets_cats": ("Cats", "پشیلە", "Kediler"),
    "pets_birds": ("Birds", "باڵندە", "Kuşlar"),
    "pets_fish": ("Fish & Aquariums", "ماسی و ئاکوارێوم", "Balık ve Akvaryum"),
    "pets_farm": ("Farm Animals", "ئاژەڵی مەزرە", "Çiftlik Hayvanları"),
    "pets_reptiles": ("Reptiles & Amphibians", "خشók و دووجگە", "Sürüngenler"),
    "pets_rabbits": ("Rabbits & Rodents", "کەروێشک", "Tavşan ve Kemirgenler"),
    "pets_accessories": ("Pet Supplies", "پێداویستی ئاژەڵ", "Pet Malzemeleri"),
    "pets_services": ("Pet Services", "خزمەتگوزاری ئاژەڵ", "Pet Hizmetleri"),
    "pets_lost_found": ("Lost & Found", "ونبوو و دۆزراوە", "Kayıp ve Bulunan"),
    # Home help
    "home_cleaning": ("House Cleaning", "پاککردنەوەی ماڵ", "Ev Temizliği"),
    "home_cooking": ("Cooking & Catering", "چێشتلێنان", "Yemek Hazırlama"),
    "home_childcare": ("Childcare", "چاودێری منداڵ", "Çocuk Bakımı"),
    "home_eldercare": ("Elderly & Patient Care", "چاودێری پیر و نەخۆش", "Yaşlı ve Hasta Bakımı"),
    "home_driver": ("Private Driver", "شۆفێری تایبەت", "Özel Şoför"),
    "home_gardening": ("Garden & Pool", "باخچە و مەلەوانگە", "Bahçe ve Havuz"),
    "home_maintenance": ("Home Maintenance", "چاککردنەوەی ماڵ", "Ev Bakımı"),
    "home_moving": ("Moving & Furniture", "گواستنەوەی کەلوپەل", "Taşıma"),
    "home_security": ("Security & Guarding", "ئاسایش و پاسەوانی", "Güvenlik"),
    "home_laundry": ("Laundry & Ironing", "جلوشۆردن و ئistri", "Çamaşır ve Ütü"),
}


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def build_sql() -> str:
    lines = [
        "-- Seed navigational category translations (en, ku, tr).",
        "-- Brand/model rows copy Latin names where applicable.",
        "",
    ]
    for slug, (en, ku, tr) in sorted(TRANSLATIONS.items()):
        lines.append(
            "UPDATE public.categories SET "
            f"name_en = COALESCE(name_en, '{sql_escape(en)}'), "
            f"name_ku = COALESCE(name_ku, '{sql_escape(ku)}'), "
            f"name_tr = COALESCE(name_tr, '{sql_escape(tr)}') "
            f"WHERE slug = '{sql_escape(slug)}';"
        )

    lines.extend(
        [
            "",
            "-- Brand/model nodes: use Arabic name as fallback for Latin script names.",
            "UPDATE public.categories SET "
            "name_en = COALESCE(name_en, name_ar), "
            "name_ku = COALESCE(name_ku, name_ar), "
            "name_tr = COALESCE(name_tr, name_ar) "
            "WHERE icon IN ('brand', 'model') AND name_en IS NULL;",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    sql = build_sql()
    migration = root / "supabase/migrations/20260726000000_seed_category_translations.sql"
    migration.write_text(sql, encoding="utf-8")
    json_path = root / "scripts/category_translations.json"
    json_path.write_text(
        json.dumps({k: {"en": v[0], "ku": v[1], "tr": v[2]} for k, v in TRANSLATIONS.items()}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Wrote {migration} ({len(TRANSLATIONS)} slugs)")
    print(f"Wrote {json_path}")


if __name__ == "__main__":
    main()
