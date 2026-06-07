#!/usr/bin/env python3
"""Generate electronics category tree: subcategory → brand → model (Iraq market)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260628000000_electronics_brands_models.sql"

ROOT_SLUG = "electronics"
PREFIX = "elec"
STORAGE_BASE = "https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos"
EXTRAS_KEYS = ("appliances", "ac", "desktops", "drones", "projectors", "medical")
EXTRAS_START_ORDER = 13

BRAND_LOGOS: dict[str, str] = {
    "Apple": "https://upload.wikimedia.org/wikipedia/commons/f/fa/Apple_logo_black.svg",
    "Samsung": "https://upload.wikimedia.org/wikipedia/commons/2/24/Samsung_Logo.svg",
    "Huawei": "https://upload.wikimedia.org/wikipedia/commons/e/e8/Huawei_logo.svg",
    "Xiaomi": "https://upload.wikimedia.org/wikipedia/commons/2/29/Xiaomi_logo.svg",
    "Dell": "https://upload.wikimedia.org/wikipedia/commons/4/48/Dell_Logo.svg",
    "HP": "https://upload.wikimedia.org/wikipedia/commons/a/ad/HP_logo_2012.svg",
    "Lenovo": "https://upload.wikimedia.org/wikipedia/commons/b/b8/Lenovo_logo_2015.svg",
    "Asus": "https://upload.wikimedia.org/wikipedia/commons/2/2e/ASUS_Logo.svg",
    "LG": "https://upload.wikimedia.org/wikipedia/commons/b/bf/LG_logo_%282015%29.svg",
    "Sony": "https://upload.wikimedia.org/wikipedia/commons/c/ca/Sony_logo.svg",
    "Canon": "https://upload.wikimedia.org/wikipedia/commons/0/04/Canon_wordmark.svg",
    "Nikon": "https://upload.wikimedia.org/wikipedia/commons/e/e9/Nikon_logo.svg",
    "Sony PlayStation": "https://upload.wikimedia.org/wikipedia/commons/4/4e/Playstation_logo_colour.svg",
    "Microsoft Xbox": "https://upload.wikimedia.org/wikipedia/commons/8/8c/XBOX_logo_2012.svg",
    "Nintendo": "https://upload.wikimedia.org/wikipedia/commons/0/0d/Nintendo.svg",
}

BRAND_SLUG_OVERRIDES: dict[str, str] = {
    "Sony PlayStation": "sony_playstation",
    "Microsoft Xbox": "microsoft_xbox",
    "Holy Stone": "holy_stone",
    "تجميع": "custom_build",
}

MODEL_SLUG_OVERRIDES: dict[str, str] = {
    "غسالة أوتوماتيك": "washing_machine",
    "ثلاجة": "fridge",
    "غسالة صحون": "dishwasher",
    "ميكروويف": "microwave",
    "مكنسة كهربائية": "vacuum",
    "Air Fryer": "air_fryer",
    "سبليت 1.5 حصان": "split_1_5hp",
    "سبليت 2 حصان": "split_2hp",
    "سبليت 2.5 حصان": "split_2_5hp",
    "سبليت 3 حصان": "split_3hp",
    "كاسيت": "cassette",
    "سقفي": "ceiling",
    "Portable": "portable",
    "Window": "window",
    "Gaming Desktop": "gaming_desktop",
    "Workstation": "workstation",
    "All-in-One": "all_in_one",
    "Mini PC": "mini_pc",
    "Home Theater": "home_theater",
    "Business Projector": "business_projector",
}

FLAT_SLUG_OVERRIDES: dict[str, str] = {
    "Amazon Echo": "amazon_echo",
    "Google Nest Hub": "google_nest_hub",
    "Xiaomi Smart Hub": "xiaomi_smart_hub",
    "كاميرا مراقبة داخلية": "indoor_camera",
    "كاميرا مراقبة خارجية": "outdoor_camera",
    "جرس ذكي": "smart_doorbell",
    "ستارة ذكية": "smart_curtain",
    "إضاءة ذكية LED": "smart_led",
    "مكيف ذكي": "smart_ac",
    "قفل ذكي": "smart_lock",
    "شاشة هاتف (سبير)": "phone_screen",
    "بطارية هاتف": "phone_battery",
    "كفر وحماية": "case_protection",
    "شاحن وكابل": "charger_cable",
    "باور بانك": "power_bank",
    "كيبورد وماوس": "keyboard_mouse",
    "هارد ديسك خارجي": "external_hdd",
    "فلاشة USB": "usb_flash",
    "كارت ذاكرة": "memory_card",
    "رام لابتوب": "laptop_ram",
    "GPU كرت شاشة": "gpu",
    "معالج CPU": "cpu",
    "لوحة أم Motherboard": "motherboard",
    "مروحة تبريد": "cooling_fan",
    "كيس كمبيوتر": "pc_case",
    "جهاز ضغط الدم": "bp_monitor",
    "جهاز قياس السكر": "glucose_meter",
    "جهاز تنفس": "nebulizer",
    "جهاز تدليك": "massager",
    "جهاز بخار للأطفال": "baby_nebulizer",
    "جهاز قياس الحرارة الرقمي": "digital_thermometer",
}

# type_key → (name_ar, color, brands dict | None, flat items | None)
# brands: name → (color, [models])
ELECTRONICS_TREE: dict[str, tuple[str, str, dict[str, tuple[str, list[str]]] | None, list[str] | None]] = {
    "smartphones": ("هواتف ذكية", "#1A1A1A", {
        "Apple": ("#1A1A1A", [
            "iPhone 16 Pro Max", "iPhone 16 Pro", "iPhone 16 Plus", "iPhone 16",
            "iPhone 15 Pro Max", "iPhone 15 Pro", "iPhone 15 Plus", "iPhone 15",
            "iPhone 14 Pro Max", "iPhone 14 Pro", "iPhone 14 Plus", "iPhone 14",
            "iPhone 13 Pro Max", "iPhone 13", "iPhone 12", "iPhone 11",
            "iPhone XS Max", "iPhone XR",
        ]),
        "Samsung": ("#1428A0", [
            "Galaxy S25 Ultra", "Galaxy S25+", "Galaxy S25", "Galaxy S24 Ultra",
            "Galaxy S24+", "Galaxy S24", "Galaxy Z Fold 6", "Galaxy Z Flip 6",
            "Galaxy A55", "Galaxy A35", "Galaxy A15", "Galaxy A05",
            "Galaxy M55", "Galaxy F55",
        ]),
        "Huawei": ("#CF0A2C", [
            "Pura 70 Ultra", "Pura 70 Pro", "Mate 60 Pro", "Mate 60",
            "Nova 12 Pro", "Nova 12", "Y9s", "Y7a",
        ]),
        "Xiaomi": ("#FF6900", [
            "Xiaomi 14 Ultra", "Xiaomi 14 Pro", "Xiaomi 14", "Redmi Note 13 Pro+",
            "Redmi Note 13 Pro", "Redmi Note 13", "Redmi 13C", "POCO X6 Pro",
            "POCO M6 Pro", "Mi 11",
        ]),
        "Oppo": ("#1D8348", ["Find X7 Ultra", "Reno 12 Pro", "Reno 12", "A3 Pro", "A78", "A58"]),
        "Vivo": ("#415FFF", ["X100 Ultra", "X100 Pro", "V30 Pro", "V30", "Y200", "Y100"]),
        "OnePlus": ("#F5010C", ["OnePlus 12", "OnePlus 12R", "OnePlus Nord 4", "OnePlus Nord CE4"]),
        "Tecno": ("#0095DA", ["Camon 30 Pro", "Spark 20 Pro", "Phantom V Fold", "Pop 8"]),
        "Infinix": ("#FF0000", ["Note 40 Pro", "Hot 40 Pro", "Smart 8 Plus", "Zero 30"]),
    }, None),
    "tablets": ("أجهزة لوحية", "#1A1A1A", {
        "Apple": ("#1A1A1A", [
            'iPad Pro 13" M4', 'iPad Pro 11" M4', 'iPad Air 13" M2', 'iPad Air 11" M2',
            "iPad 10th Gen", "iPad mini 7",
        ]),
        "Samsung": ("#1428A0", [
            "Galaxy Tab S9 Ultra", "Galaxy Tab S9+", "Galaxy Tab S9",
            "Galaxy Tab A9+", "Galaxy Tab A9",
        ]),
        "Huawei": ("#CF0A2C", ['MatePad Pro 13.2"', 'MatePad 11.5"', "MatePad SE"]),
        "Xiaomi": ("#FF6900", ["Pad 6 Pro", "Pad 6", "Redmi Pad Pro", "Redmi Pad SE"]),
    }, None),
    "laptops": ("لابتوب وكمبيوتر", "#1A1A1A", {
        "Apple": ("#1A1A1A", [
            'MacBook Pro 16" M4', 'MacBook Pro 14" M4', 'MacBook Air 15" M3',
            'MacBook Air 13" M3', 'iMac 24" M3', "Mac mini M4",
            "Mac Studio M3 Ultra", "Mac Pro M2 Ultra",
        ]),
        "Dell": ("#007DB8", [
            "XPS 15", "XPS 13", "Inspiron 15", "Inspiron 14", "G15 Gaming", "G16 Gaming",
            "Alienware m16", "Vostro 15", "Latitude 5540",
        ]),
        "HP": ("#0096D6", [
            "Spectre x360 14", "Envy x360 15", "Pavilion 15", "Victus 16 Gaming",
            "Omen 16 Gaming", "EliteBook 840", "ProBook 450",
        ]),
        "Lenovo": ("#E2231A", [
            "ThinkPad X1 Carbon", "IdeaPad 5 Pro", "IdeaPad Gaming 3", "Legion 5 Pro",
            "Legion 7i", "Yoga 9i", "LOQ 15",
        ]),
        "Asus": ("#1A1A1A", [
            "ZenBook 14", "VivoBook 15", "ROG Strix G16", "ROG Zephyrus G14",
            "TUF Gaming A15", "ProArt Studiobook",
        ]),
        "MSI": ("#CC0000", [
            "Titan GT77", "Raider GE78", "Stealth 16 Studio", "Creator Z17", "Katana 15",
        ]),
    }, None),
    "displays": ("شاشات وتلفزيونات", "#1A1A1A", {
        "Samsung": ("#1428A0", [
            'QLED 4K 55"', 'QLED 4K 65"', 'QLED 4K 75"', "Neo QLED 8K",
            'The Frame 55"', "Odyssey Gaming Monitor",
        ]),
        "LG": ("#A50034", [
            'OLED C4 55"', 'OLED C4 65"', 'OLED C4 77"', 'QNED 4K 55"',
            'UltraGear Gaming 27"', 'UltraWide 34"',
        ]),
        "Sony": ("#1A1A1A", [
            "Bravia XR A95L OLED", "Bravia 9 Mini LED", "Bravia 7 4K", "Inzone M9 Gaming",
        ]),
        "TCL": ("#CC0000", [
            'QLED 4K 55"', 'QLED 4K 65"', 'Mini LED 75"', 'Android TV 43"',
        ]),
    }, None),
    "cameras": ("كاميرات", "#1A1A1A", {
        "Canon": ("#CC0000", [
            "EOS R5 Mark II", "EOS R6 Mark II", "EOS R50", "EOS 90D DSLR", "PowerShot V10",
        ]),
        "Sony": ("#1A1A1A", [
            "Alpha 7 IV", "Alpha 7C II", "Alpha 7R V", "ZV-E10 II", "RX100 VII",
        ]),
        "Nikon": ("#FFD700", ["Z8", "Z6 III", "Z50 II", "D7500 DSLR"]),
        "GoPro": ("#00ADEF", ["Hero 13 Black", "Hero 12 Black", "Hero 11 Mini", "Max 360"]),
    }, None),
    "audio": ("سماعات وصوتيات", "#1A1A1A", {
        "Apple": ("#1A1A1A", ["AirPods Pro 2", "AirPods 4", "AirPods Max"]),
        "Sony": ("#1A1A1A", ["WH-1000XM5", "WF-1000XM5", "WH-CH720N", "SRS-XB100"]),
        "Samsung": ("#1428A0", ["Galaxy Buds3 Pro", "Galaxy Buds3", "Galaxy Buds FE", "Soundbar Q990D"]),
        "JBL": ("#FF6900", [
            "Tune 770NC", "Live Pro 2", "Charge 5", "Xtreme 3", "PartyBox 310", "Bar 1000 Soundbar",
        ]),
        "Bose": ("#1A1A1A", ["QuietComfort 45", "QuietComfort Ultra", "Sport Earbuds", "SoundLink Max"]),
    }, None),
    "gaming": ("ألعاب فيديو", "#1A1A1A", {
        "Sony PlayStation": ("#003087", [
            "PlayStation 5", "PS5 Slim", "PS5 Pro", "PlayStation 4 Pro", "PlayStation 4", "PS VR2",
        ]),
        "Microsoft Xbox": ("#107C10", ["Xbox Series X", "Xbox Series S", "Xbox One X", "Xbox One S"]),
        "Nintendo": ("#E4000F", ["Switch OLED", "Switch Lite", "Switch 2"]),
    }, None),
    "wearables": ("ساعات ذكية وإكسسوار", "#1A1A1A", {
        "Apple": ("#1A1A1A", ["Apple Watch Ultra 2", "Apple Watch Series 10", "Apple Watch SE"]),
        "Samsung": ("#1428A0", ["Galaxy Watch 7", "Galaxy Watch Ultra", "Galaxy Watch FE", "Galaxy Ring"]),
        "Huawei": ("#CF0A2C", ["Watch GT 4", "Watch 4 Pro", "Band 8"]),
        "Xiaomi": ("#FF6900", ["Watch S3", "Band 8 Pro", "Redmi Watch 4"]),
    }, None),
    "printers": ("طابعات وملحقات", "#1A1A1A", {
        "HP": ("#0096D6", ["DeskJet 4220e", "OfficeJet Pro 9015e", "LaserJet Pro M404n", "Color LaserJet MFP"]),
        "Canon": ("#CC0000", ["PIXMA G3470", "PIXMA TR8620", "imageCLASS MF3010"]),
        "Epson": ("#003087", ["EcoTank L3250", "EcoTank L6490", "WorkForce Pro WF-7840"]),
    }, None),
    "networking": ("شبكات وراوتر", "#1A1A1A", {
        "TP-Link": ("#55ACEE", [
            "Archer AX73 WiFi 6", "Deco XE75 Mesh", "TL-WR940N", "Archer C6", "4G LTE Router MR600",
        ]),
        "Huawei": ("#CF0A2C", ["AX3 Pro WiFi 6", "B535 4G Router", "B818 4G Router", "CPE Pro 5G"]),
        "Cisco": ("#049FD9", ["RV340 Router", "CBS220 Switch", "WAP571 Access Point"]),
    }, None),
    "smart_home": ("أجهزة منزلية ذكية", "#1A1A1A", None, [
        "Amazon Echo", "Google Nest Hub", "Xiaomi Smart Hub", "كاميرا مراقبة داخلية",
        "كاميرا مراقبة خارجية", "جرس ذكي", "ستارة ذكية", "إضاءة ذكية LED",
        "مكيف ذكي", "قفل ذكي",
    ]),
    "parts": ("قطع غيار وإكسسوارات", "#1A1A1A", None, [
        "شاشة هاتف (سبير)", "بطارية هاتف", "كفر وحماية", "شاحن وكابل", "باور بانك",
        "كيبورد وماوس", "هارد ديسك خارجي", "فلاشة USB", "كارت ذاكرة", "رام لابتوب",
        "GPU كرت شاشة", "معالج CPU", "لوحة أم Motherboard", "مروحة تبريد", "كيس كمبيوتر",
    ]),
    "appliances": ("أجهزة المنزل الكهربائية", "#1A1A1A", {
        "Samsung": ("#1428A0", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "LG": ("#A50034", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Bosch": ("#EA0016", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Siemens": ("#009999", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Electrolux": ("#041E42", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Whirlpool": ("#FFB600", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Haier": ("#005AAA", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
        "Midea": ("#0092DF", [
            "غسالة أوتوماتيك", "ثلاجة", "غسالة صحون", "ميكروويف", "مكنسة كهربائية", "Air Fryer",
        ]),
    }, None),
    "ac": ("مكيفات", "#1A1A1A", {
        "Gree": ("#009944", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Carrier": ("#0066B3", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "LG": ("#A50034", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Samsung": ("#1428A0", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Midea": ("#0092DF", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Haier": ("#005AAA", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Daikin": ("#0097DB", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Toshiba": ("#FF0000", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Hitachi": ("#E60027", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Panasonic": ("#004098", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "York": ("#0033A0", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "Chigo": ("#E31937", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
        "KOOL": ("#009FE3", [
            "سبليت 1.5 حصان", "سبليت 2 حصان", "سبليت 2.5 حصان", "سبليت 3 حصان",
            "كاسيت", "سقفي", "Portable", "Window",
        ]),
    }, None),
    "desktops": ("كمبيوتر مكتبي", "#1A1A1A", {
        "Apple": ("#1A1A1A", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
        "Dell": ("#007DB8", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
        "HP": ("#0096D6", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
        "Lenovo": ("#E2231A", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
        "Asus": ("#1A1A1A", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
        "تجميع": ("#757575", ["Gaming Desktop", "Workstation", "All-in-One", "Mini PC"]),
    }, None),
    "drones": ("درون وطائرات مسيّرة", "#1A1A1A", {
        "DJI": ("#1A1A1A", [
            "DJI Mini 4 Pro", "DJI Air 3", "DJI Mavic 3 Pro", "DJI Agras", "FPV Drone",
        ]),
        "Autel": ("#E31937", ["EVO Lite+", "EVO Max 4T", "Dragonfish", "FPV Drone"]),
        "Holy Stone": ("#FF6900", ["HS720E", "HS600", "HS175D", "FPV Drone"]),
        "Parrot": ("#0082C3", ["Anafi", "ANAFI AI", "Anafi USA", "FPV Drone"]),
    }, None),
    "projectors": ("بروجيكتور وشاشة عرض", "#1A1A1A", {
        "Epson": ("#003087", ["Home Theater", "Portable", "Business Projector"]),
        "BenQ": ("#6B2C91", ["Home Theater", "Portable", "Business Projector"]),
        "Optoma": ("#E31937", ["Home Theater", "Portable", "Business Projector"]),
        "LG": ("#A50034", ["Home Theater", "Portable", "Business Projector"]),
        "Samsung": ("#1428A0", ["Home Theater", "Portable", "Business Projector"]),
        "Xiaomi": ("#FF6900", ["Home Theater", "Portable", "Business Projector"]),
        "ViewSonic": ("#0082C3", ["Home Theater", "Portable", "Business Projector"]),
    }, None),
    "medical": ("أجهزة طبية منزلية", "#1A1A1A", None, [
        "جهاز ضغط الدم", "جهاز قياس السكر", "جهاز تنفس", "جهاز تدليك",
        "جهاز بخار للأطفال", "جهاز قياس الحرارة الرقمي",
    ]),
}


def slugify_ascii(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("+", "_plus")
    text = text.replace('"', "in")
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def node_slug(name: str) -> str:
    if name in BRAND_SLUG_OVERRIDES:
        return BRAND_SLUG_OVERRIDES[name]
    if name in MODEL_SLUG_OVERRIDES:
        return MODEL_SLUG_OVERRIDES[name]
    if name in FLAT_SLUG_OVERRIDES:
        return FLAT_SLUG_OVERRIDES[name]
    paren = re.search(r"\(([^)]+)\)", name)
    if paren:
        inner = slugify_ascii(paren.group(1))
        prefix = slugify_ascii(re.sub(r"\([^)]*\)", "", name))
        if prefix and inner:
            return f"{prefix}_{inner}"
        if inner:
            return inner
    slug = slugify_ascii(name)
    if slug:
        return slug
    raise ValueError(f"cannot slugify: {name!r}")


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def sql_nullable(value: str | None) -> str:
    if value is None:
        return "NULL"
    return f"'{sql_escape(value)}'"


def logo_for(brand: str) -> str | None:
    slug = (
        brand.lower()
        .replace("&", "and")
        .replace(" ", "-")
    )
    slug = re.sub(r"[^a-z0-9-]+", "-", slug)
    slug = re.sub(r"-+", "-", slug).strip("-")
    if brand in BRAND_LOGOS or brand in {
        "Samsung", "Huawei", "Xiaomi", "Oppo", "Vivo", "OnePlus", "Tecno", "Infinix",
        "Dell", "HP", "Lenovo", "Asus", "MSI", "LG", "Sony", "TCL", "Canon", "Nikon",
        "GoPro", "JBL", "Bose", "Sony PlayStation", "Microsoft Xbox", "Nintendo",
        "TP-Link", "Cisco", "Epson", "Bosch", "Siemens", "Electrolux", "Whirlpool",
        "Haier", "Midea", "Gree", "Carrier", "Daikin", "Toshiba", "Hitachi",
        "Panasonic", "York", "DJI", "BenQ", "ViewSonic",
    }:
        return f"{STORAGE_BASE}/elec-{slug}.svg"
    return BRAND_LOGOS.get(brand)


def main() -> None:
    import sys

    extras_only = "--extras-only" in sys.argv
    out_path = (
        ROOT / "supabase/migrations/20260629000001_electronics_extra_subcategories.sql"
        if extras_only
        else OUT
    )

    header = (
        "-- الإلكترونيات — additional subcategories (append-only, no delete)."
        if extras_only
        else "-- الإلكترونيات (electronics) — subcategories → brand → model\n"
        "-- Safe to re-run: cleans electronics subtree then upserts by slug."
    )

    lines: list[str] = [
        header,
        "",
        "CREATE OR REPLACE FUNCTION public._seed_elec_node(",
        "  p_slug TEXT,",
        "  p_name_ar TEXT,",
        "  p_parent_slug TEXT,",
        "  p_icon TEXT DEFAULT 'category',",
        "  p_display_order INT DEFAULT 0,",
        "  p_logo_url TEXT DEFAULT NULL,",
        "  p_color_hex TEXT DEFAULT NULL",
        ") RETURNS VOID AS $$",
        "DECLARE",
        "  v_parent_id INT;",
        "BEGIN",
        "  SELECT id INTO v_parent_id FROM public.categories WHERE slug = p_parent_slug;",
        "  IF v_parent_id IS NULL THEN",
        "    RAISE EXCEPTION 'Parent category not found: %', p_parent_slug;",
        "  END IF;",
        "",
        "  INSERT INTO public.categories (",
        "    slug, name_ar, name_ku, name_en, icon, parent_id, display_order, sort_order, logo_url, color_hex",
        "  )",
        "  VALUES (",
        "    p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id,",
        "    p_display_order, p_display_order, p_logo_url, p_color_hex",
        "  )",
        "  ON CONFLICT (slug) DO UPDATE SET",
        "    name_ar = EXCLUDED.name_ar,",
        "    name_ku = NULL,",
        "    name_en = NULL,",
        "    icon = EXCLUDED.icon,",
        "    parent_id = EXCLUDED.parent_id,",
        "    display_order = EXCLUDED.display_order,",
        "    sort_order = EXCLUDED.sort_order,",
        "    logo_url = EXCLUDED.logo_url,",
        "    color_hex = EXCLUDED.color_hex;",
        "END;",
        "$$ LANGUAGE plpgsql;",
        "",
    ]

    if not extras_only:
        lines[2:2] = [
            "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
            "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
            "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
            "",
        ]
        lines.extend([
            "DELETE FROM public.categories",
            "WHERE id IN (",
            "  WITH RECURSIVE subtree AS (",
            "    SELECT c.id FROM public.categories c",
            f"    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = '{ROOT_SLUG}')",
            "    UNION ALL",
            "    SELECT c.id FROM public.categories c",
            "    INNER JOIN subtree s ON c.parent_id = s.id",
            "  )",
            "  SELECT id FROM subtree",
            ");",
            "",
        ])

    seen: set[str] = set()
    type_order = EXTRAS_START_ORDER - 1 if extras_only else 0
    brand_count = 0
    model_count = 0

    tree_items = (
        ((k, ELECTRONICS_TREE[k]) for k in EXTRAS_KEYS)
        if extras_only
        else ELECTRONICS_TREE.items()
    )

    for type_key, (type_name, type_color, brands, flat_items) in tree_items:
        type_order += 1
        type_slug = f"{PREFIX}_{type_key}"
        if type_slug in seen:
            raise ValueError(f"duplicate slug: {type_slug}")
        seen.add(type_slug)
        lines.append(
            f"SELECT public._seed_elec_node('{type_slug}', '{sql_escape(type_name)}', "
            f"'{ROOT_SLUG}', 'category', {type_order}, NULL, '{type_color}');"
        )

        if brands:
            brand_order = 0
            for brand, (color, models) in brands.items():
                brand_order += 1
                brand_count += 1
                brand_slug = f"{type_slug}_br_{node_slug(brand)}"
                if brand_slug in seen:
                    raise ValueError(f"duplicate slug: {brand_slug}")
                seen.add(brand_slug)
                lines.append(
                    f"SELECT public._seed_elec_node('{brand_slug}', '{sql_escape(brand)}', "
                    f"'{type_slug}', 'brand', {brand_order}, {sql_nullable(logo_for(brand))}, '{color}');"
                )
                model_order = 0
                for model in models:
                    model_order += 1
                    model_count += 1
                    model_slug = f"{brand_slug}_{node_slug(model)}"
                    if model_slug in seen:
                        raise ValueError(f"duplicate slug: {model_slug} from {model!r}")
                    seen.add(model_slug)
                    lines.append(
                        f"SELECT public._seed_elec_node('{model_slug}', '{sql_escape(model)}', "
                        f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
                    )

        if flat_items:
            item_order = 0
            for item in flat_items:
                item_order += 1
                model_count += 1
                item_slug = f"{type_slug}_{node_slug(item)}"
                if item_slug in seen:
                    raise ValueError(f"duplicate slug: {item_slug}")
                seen.add(item_slug)
                lines.append(
                    f"SELECT public._seed_elec_node('{item_slug}', '{sql_escape(item)}', "
                    f"'{type_slug}', 'model', {item_order}, NULL, NULL);"
                )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_elec_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    sub_count = type_order - (EXTRAS_START_ORDER - 1 if extras_only else 0)
    print(
        f"Wrote {out_path.name}: {sub_count} subcategories, {brand_count} brands, "
        f"{model_count} models/items, {len(lines)} lines"
    )


if __name__ == "__main__":
    main()
