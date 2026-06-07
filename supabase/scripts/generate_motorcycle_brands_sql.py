#!/usr/bin/env python3
"""Generate motorcycle brands/models seed migration SQL."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260607000000_motorcycle_darajat_brands.sql"

PARENT_SLUG = "veh_motorcycle"
PREFIX = "veh_moto"

LOGO_SLUG_OVERRIDES: dict[str, str] = {
    "Harley-Davidson": "harley-davidson",
    "Royal Enfield": "royal-enfield",
    "MV Agusta": "mv-agusta",
    "BMW": "bmw-motorrad",
    "CFMoto": "cf-moto",
    "Moto Guzzi": "moto-guzzi",
    "Royal Alloy": "royal-alloy",
    "Regal Raptor": "regal-raptor",
}


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def logo_slug(brand: str) -> str:
    if brand in LOGO_SLUG_OVERRIDES:
        return LOGO_SLUG_OVERRIDES[brand]
    return slugify(brand).replace("_", "-")


def logo_url(brand: str) -> str:
    return f"https://www.carlogos.org/motorcycle-logos/{logo_slug(brand)}-logo.png"


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


MOTORCYCLE_TREE: dict[str, list[str]] = {
    "Yamaha": [
        "YZF-R125", "YZF-R3", "YZF-R6", "YZF-R7", "YZF-R1",
        "MT-125", "MT-03", "MT-07", "MT-09", "MT-10",
        "Ténéré 700", "Tracer 7", "Tracer 9",
        "NMAX 125", "NMAX 155", "NMAX 160",
        "XMAX 250", "XMAX 300", "XMAX 400", "TMAX 560", "Aerox 155",
        "YBR 125", "YZ125", "YZ250", "YZ450F", "WR250F", "WR450F",
    ],
    "Honda": [
        "CB125F", "CB150F", "CB500F", "CB650R",
        "CBR125R", "CBR500R", "CBR650R", "CBR1000RR",
        "CRF250L", "CRF300L", "CRF450R", "Africa Twin 1100", "Gold Wing",
        "Rebel 300", "Rebel 500",
        "PCX 125", "PCX 160", "Forza 125", "Forza 350", "Forza 750", "ADV 350",
    ],
    "Kawasaki": [
        "Ninja 125", "Ninja 250", "Ninja 400", "Ninja 650", "Ninja 1000",
        "Ninja ZX-6R", "Ninja ZX-10R", "Ninja ZX-4R",
        "Z125", "Z400", "Z650", "Z900",
        "Versys 300", "Versys 650", "Versys 1000", "Vulcan S",
        "KLX 110", "KLX 230", "KLX 300", "KX 125", "KX 250", "KX 450", "KLR 650",
    ],
    "Suzuki": [
        "GSX-R125", "GSX-R150", "GSX-R600", "GSX-R750", "GSX-R1000",
        "GSX-S125", "GSX-S750", "GSX-S1000",
        "V-Strom 250", "V-Strom 650", "V-Strom 800", "V-Strom 1050",
        "SV650", "Gixxer 150", "Gixxer 250",
        "Burgman 125", "Burgman 200", "Burgman 400", "Burgman 650",
        "DR650", "RM-Z250", "RM-Z450",
    ],
    "KTM": [
        "Duke 125", "Duke 200", "Duke 250", "Duke 390", "Duke 790", "Duke 890", "Duke 1290",
        "RC 125", "RC 200", "RC 390", "RC 990",
        "Adventure 390", "Adventure 790", "Adventure 890", "Adventure 1290",
        "EXC 125", "EXC 250", "EXC 300", "EXC 450", "EXC 500",
        "SX 125", "SX 250", "SX 350", "SX 450", "Supermoto 390", "Supermoto 690",
    ],
    "BMW": [
        "G 310 R", "G 310 GS", "F 750 GS", "F 850 GS", "F 900 R", "F 900 XR",
        "R 1250 GS", "R 1250 Adventure", "R 1250 R", "R 1250 RT", "R 1250 RS",
        "S 1000 RR", "S 1000 R", "S 1000 XR", "K 1600 GT", "K 1600 GTL", "K 1600 B", "CE 04",
    ],
    "Ducati": [
        "Panigale V2", "Panigale V4", "Panigale V4S",
        "Streetfighter V2", "Streetfighter V4",
        "Monster 797", "Monster 821", "Monster 937",
        "Multistrada V2", "Multistrada V4", "Multistrada V4S",
        "Scrambler Icon", "Scrambler Desert Sled",
        "Hypermotard 950", "Diavel V4", "XDiavel",
    ],
    "Harley-Davidson": [
        "Sportster S", "Iron 883", "Iron 1200", "Nightster", "Street Bob",
        "Fat Bob", "Fat Boy", "Heritage Classic", "Road King",
        "Street Glide", "Road Glide", "Pan America 1250",
    ],
    "Royal Enfield": [
        "Classic 350", "Classic 500", "Hunter 350", "Meteor 350", "Bullet 350",
        "Himalayan 411", "Himalayan 450", "Interceptor 650", "Continental GT 650",
        "Super Meteor 650", "Shotgun 650",
    ],
    "Triumph": [
        "Bonneville T100", "Bonneville T120", "Speed Twin 900", "Speed Twin 1200",
        "Scrambler 400X", "Scrambler 900", "Scrambler 1200",
        "Street Triple 765", "Speed Triple 1200 RS", "Rocket 3 R", "Rocket 3 GT",
        "Daytona 660", "Daytona 675", "Bobber", "Speedmaster",
    ],
    "Indian": [
        "Scout Bobber", "Scout Rogue", "Scout Sixty", "Chief Dark Horse", "Chief Bobber",
        "Springfield", "Chieftain", "Roadmaster", "FTR 1200",
    ],
    "Aprilia": [
        "RSV4", "Tuono 125", "Tuono 660", "Tuono V4",
        "Shiver 750", "Shiver 900", "Dorsoduro 750", "Dorsoduro 900", "SR GT 125", "SR GT 200",
    ],
    "Vespa": [
        "Primavera 50", "Primavera 125", "Primavera 150",
        "Sprint 50", "Sprint 125", "Sprint 150",
        "GTS 125", "GTS 300", "GTS 310", "GTV 300", "PX 125", "PX 150", "Elettrica",
    ],
    "Piaggio": [
        "Liberty 50", "Liberty 125", "Liberty 150",
        "Beverly 300", "Beverly 400", "Medley 125", "Medley 150",
        "MP3 300", "MP3 400", "MP3 500", "Typhoon 50", "Typhoon 125", "Zip 50", "Zip 100",
    ],
    "Husqvarna": [
        "Vitpilen 125", "Vitpilen 401", "Vitpilen 701",
        "Svartpilen 125", "Svartpilen 401", "Svartpilen 701",
        "Norden 901", "TE 125", "TE 250", "TE 300", "FE 250", "FE 350", "FE 450", "TC 125", "TC 250",
    ],
    "Bajaj": [
        "Pulsar 125", "Pulsar 150", "Pulsar 160", "Pulsar 180", "Pulsar 200", "Pulsar 220",
        "Dominar 250", "Dominar 400", "Avenger 160", "Avenger 220",
        "Boxer 100", "Boxer 150", "Platina 100", "Platina 110", "Platina 125",
    ],
    "TVS": ["Apache RTR 160", "Apache RTR 180", "Apache RTR 200", "Apache RTR 310", "Raider 125", "Ronin 225", "Ntorq 125", "iQube"],
    "Hero": ["Splendor Plus", "HF Deluxe", "Glamour 125", "Xtreme 160R", "Xtreme 200S", "XPulse 200", "Passion Pro"],
    "Benelli": [
        "TNT 125", "TNT 135", "TNT 150", "TNT 249", "TNT 300", "TNT 600",
        "Leoncino 250", "Leoncino 500", "Leoncino 800",
        "TRK 251", "TRK 502", "TRK 702", "TRK 800", "Imperiale 400", "302R",
    ],
    "CFMoto": [
        "150NK", "250NK", "300NK", "450NK", "650NK",
        "300SR", "450SR", "675SR", "650MT", "800MT", "450MT", "400GT", "650GT",
    ],
    "Kymco": [
        "Agility 125", "Agility 150", "Like 125", "Like 150", "Like 200",
        "Xciting 400", "Xciting 500", "Downtown 125", "Downtown 350", "AK 550",
    ],
    "SYM": [
        "Jet 14 125", "Jet 14 200", "Symphony 125", "Symphony 200",
        "Fiddle 125", "Fiddle 200", "Joymax 125", "Joymax 250", "Joymax 300",
        "Wolf 125", "Cruisym 250", "Cruisym 300",
    ],
    "Keeway": ["RKF 125", "RKF 150", "RKF 200", "RKS 125", "RKS 150", "Superlight 125", "Vieste 125", "Vieste 300", "K-Light 125"],
    "Lifan": ["LF100", "LF125", "LF150", "LF200", "LF250", "KPR 150", "KPT 200", "KPT 400", "V16 250"],
    "Loncin": ["LX125", "LX150", "LX200", "LX250", "CR Series", "GP Series"],
    "Zongshen": ["ZS125", "ZS150", "RX1 200", "RX3 250", "RX4 400", "ZS200GY", "ATV 250", "ATV 300", "ATV 400"],
    "Zontes": ["125U", "155U", "250R", "250U", "310R", "310X", "310T", "350R", "350X", "350T", "703F", "703RR"],
    "Voge": ["125R", "300R", "500R", "525R", "300AC", "500AC", "300DS", "525DS", "650DS", "SR4 Max"],
    "QJ": ["SRK 125", "SRK 250", "SRK 400", "SRK 550", "SRK 600", "SRK 700", "SRT 550", "SRT 700", "SRT 800", "Flash 300", "Flash 350", "SRV 300", "SRV 550"],
    "Jawa": ["Jawa 42", "Jawa 42 Bobber", "Jawa Perak", "Jawa Standard 300", "Jawa 350"],
    "Can-Am": ["Spyder RT", "Spyder F3", "Ryker 600", "Ryker 900", "Canyon"],
    "GasGas": ["EC 125", "EC 250", "EC 300", "MC 125", "MC 250", "MC 450", "EX 250", "EX 300", "SM 700"],
    "Sherco": ["SE 125", "SE 250", "SE 300", "SEF 250", "SEF 300", "SEF 450", "SM-R 125"],
    "Beta": ["RR 125", "RR 200", "RR 250", "RR 300", "Xtrainer 250", "Alp 200"],
    "Moto Guzzi": ["V7 Stone", "V7 Special", "V9 Bobber", "V9 Roamer", "California 1400", "V85 TT", "Griso 1200"],
    "Norton": ["Commando 961", "V4 RR", "V4 SV", "Atlas Ranger", "Atlas Nomad"],
    "MV Agusta": [
        "Brutale 800", "Brutale 1000", "Dragster 800", "F3 675", "F3 800",
        "F4", "Turismo Veloce", "Superveloce 800",
    ],
    "Hyosung": ["GT125", "GT250", "GT650", "GV125", "GV250", "GD250N", "GD250R"],
    "Brixton": ["Cromwell 125", "Cromwell 250", "Cromwell 500", "Felsberg 125", "Felsberg 250", "Crossfire 125", "Crossfire 250", "Crossfire 500"],
    "Royal Alloy": ["GP125", "GP300", "TG125", "TG300"],
    "Regal Raptor": ["DD125E", "DD250E", "DD350E", "Daytona 250", "Spyder 350"],
    "Daelim": ["S1 125", "S1 250", "S2 125", "Roadwin 125", "Roadwin 250", "Daystar 125", "Daystar 250"],
    "Kove": [],
    "Minsk": [],
    "Puch": [],
    "Lambretta": [],
    "Bimota": [],
    "Buell": [],
    "Energica": [],
    "Fantic": [],
    "Talaria": [],
    "MZ": [],
    "IZH": [],
    "BSA": [],
}


def generate() -> None:
    lines: list[str] = []
    seen: set[str] = set()
    brand_order = 0

    for brand, models in MOTORCYCLE_TREE.items():
        brand_order += 1
        brand_part = slugify(brand)
        brand_slug = f"{PREFIX}_br_{brand_part}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        url = sql_escape(logo_url(brand))
        lines.append(
            f"SELECT public._seed_moto_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, '{url}');"
        )
        for i, model in enumerate(models, start=1):
            model_slug = f"{brand_slug}_{slugify(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_moto_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {i}, NULL);"
            )

    header = f"""-- دراجات (veh_motorcycle) — rename + full brand/model tree
-- Replaces 20260607–20260610 motorcycle migrations (single source of truth).
-- Safe to re-run: cleans prior subtype/brand data then upserts by slug.

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;

UPDATE public.categories
SET name_ar = 'دراجات'
WHERE slug = 'veh_motorcycle';

CREATE OR REPLACE FUNCTION public._seed_moto_node(
  p_slug TEXT,
  p_name_ar TEXT,
  p_parent_slug TEXT,
  p_icon TEXT DEFAULT 'category',
  p_display_order INT DEFAULT 0,
  p_logo_url TEXT DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
  v_parent_id INT;
BEGIN
  SELECT id INTO v_parent_id FROM public.categories WHERE slug = p_parent_slug;
  IF v_parent_id IS NULL THEN
    RAISE EXCEPTION 'Parent category not found: %', p_parent_slug;
  END IF;

  INSERT INTO public.categories (slug, name_ar, name_ku, name_en, icon, parent_id, display_order, logo_url)
  VALUES (p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id, p_display_order, p_logo_url)
  ON CONFLICT (slug) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_ku = NULL,
    name_en = NULL,
    icon = EXCLUDED.icon,
    parent_id = EXCLUDED.parent_id,
    display_order = EXCLUDED.display_order,
    logo_url = EXCLUDED.logo_url;
END;
$$ LANGUAGE plpgsql;

-- Orphans from prior partial runs (models → brands → subtypes).
DELETE FROM public.categories WHERE icon = 'model' AND slug LIKE 'veh_moto_%';
DELETE FROM public.categories WHERE icon = 'brand' AND slug LIKE 'veh_moto_%';
DELETE FROM public.categories
WHERE slug IN ('veh_motorcycle_motor', 'veh_motorcycle_bicycle', 'veh_motorcycle_scooter');

DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE subtree AS (
    SELECT c.id FROM public.categories c
    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = '{PARENT_SLUG}')
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

"""
    footer = "\nDROP FUNCTION public._seed_moto_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);\n"
    OUT.write_text(header + "\n".join(lines) + footer, encoding="utf-8")
    print(f"Wrote {OUT} ({len(lines)} statements, {len(seen)} slugs)")


if __name__ == "__main__":
    generate()
