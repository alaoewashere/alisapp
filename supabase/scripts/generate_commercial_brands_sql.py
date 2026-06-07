#!/usr/bin/env python3
"""Generate commercial vehicle brands/models seed migration for veh_commercial."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260617000000_commercial_brands_models.sql"

PARENT_SLUG = "veh_commercial"
PREFIX = "veh_comm"

# Supabase Storage public URLs (brands already in brand-logos bucket).
STORAGE_BASE = (
    "https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos"
)

STORAGE_LOGOS: dict[str, str] = {
    "Toyota": f"{STORAGE_BASE}/toyota.svg",
    "Isuzu": f"{STORAGE_BASE}/isuzu.svg",
    "Mercedes-Benz": f"{STORAGE_BASE}/mercedes-benz.svg",
    "Volvo": f"{STORAGE_BASE}/volvo.svg",
    "Ford": f"{STORAGE_BASE}/ford.svg",
    "Mitsubishi Fuso": f"{STORAGE_BASE}/mitsubishi.svg",
    "Nissan UD": f"{STORAGE_BASE}/nissan.svg",
}

# Wikipedia Commons SVGs for commercial-only brands (verified paths).
WIKI_LOGOS: dict[str, str] = {
    "Hino": "https://upload.wikimedia.org/wikipedia/commons/d/d4/Hino_logo.svg",
    "IVECO": "https://upload.wikimedia.org/wikipedia/commons/f/f7/Iveco_Logo_2023.svg",
    "MAN": "https://upload.wikimedia.org/wikipedia/commons/f/f7/MAN_Truck_%26_Bus_-_Logo_2.svg",
    "Renault Trucks": "https://upload.wikimedia.org/wikipedia/commons/b/b7/Renault_2021_Text.svg",
    "DAF": "https://upload.wikimedia.org/wikipedia/commons/1/12/DAF_logo.svg",
    "Foton": "https://upload.wikimedia.org/wikipedia/commons/f/fa/Foton_Motor_logo.svg",
    "Dongfeng": "https://upload.wikimedia.org/wikipedia/commons/e/eb/Dongfeng_Motor_logo.svg",
}

CARLOGOS_PNG: dict[str, str] = {
    "King Long": "https://www.carlogos.org/car-logos/king-long-logo.png",
    "Yutong": "https://www.carlogos.org/car-logos/yutong-logo.png",
    "FAW": "https://www.carlogos.org/car-logos/faw-logo.png",
    "Scania": "https://www.carlogos.org/car-logos/scania-logo.png",
}

COMMERCIAL_TREE: dict[str, tuple[str, str | None, list[str]]] = {
    "Toyota": ("#EB0A1E", STORAGE_LOGOS.get("Toyota"), [
        "Dyna", "Dyna 200", "Dyna 300", "Coaster", "Coaster Deluxe",
        "Land Cruiser 70", "Toyoace", "HiAce Van (Cargo)", "Hilux (Cargo)",
    ]),
    "Hino": ("#CC0000", WIKI_LOGOS["Hino"], [
        "Hino 300", "Hino 500", "Hino 700", "Hino 300 Dutro",
        "Hino 500 Ranger", "Hino 700 Profia", "Hino Bus", "Hino Poncho",
    ]),
    "Isuzu": ("#CC0000", STORAGE_LOGOS.get("Isuzu"), [
        "N-Series (NLR/NMR)", "F-Series (FRR/FVR)", "C&E-Series (CXZ)",
        "Isuzu Elf", "Isuzu Forward", "Isuzu Giga", "Isuzu D-Max (Cargo)", "Isuzu Bus",
    ]),
    "Mitsubishi Fuso": ("#CC0000", STORAGE_LOGOS.get("Mitsubishi Fuso"), [
        "Canter", "Canter Wide", "Fighter", "Super Great", "Rosa", "Aero Star Bus",
    ]),
    "IVECO": ("#003087", WIKI_LOGOS["IVECO"], [
        "Daily", "Daily Van", "Daily Chassis", "Eurocargo",
        "Stralis", "Trakker", "S-Way", "Bus Crossway",
    ]),
    "Mercedes-Benz": ("#333333", STORAGE_LOGOS.get("Mercedes-Benz"), [
        "Actros", "Axor", "Atego", "Arocs", "Sprinter Cargo", "Tourismo Bus", "Travego Bus",
    ]),
    "MAN": ("#E2001A", WIKI_LOGOS["MAN"], [
        "TGX", "TGS", "TGM", "TGL", "Lion's Coach Bus", "Lion's City Bus",
    ]),
    "Volvo": ("#003057", STORAGE_LOGOS.get("Volvo"), [
        "FH", "FM", "FMX", "FL", "FE", "B12 Bus", "9700 Bus",
    ]),
    "Scania": ("#003087", CARLOGOS_PNG["Scania"], [
        "R-Series", "S-Series", "G-Series", "P-Series", "L-Series",
        "Touring Bus", "Citywide Bus",
    ]),
    "DAF": ("#003087", WIKI_LOGOS["DAF"], ["XF", "XG", "CF", "LF"]),
    "King Long": ("#CC0000", CARLOGOS_PNG["King Long"], [
        "XMQ6127", "XMQ6900", "XMQ6119", "XMQ6800", "Kingo (minibus)", "Higer Bus",
    ]),
    "Yutong": ("#CC0000", CARLOGOS_PNG["Yutong"], [
        "ZK6127H", "ZK6119H", "ZK6852H", "ZK6109H", "ZK6122H9", "E12 Electric",
    ]),
    "Jinbei": ("#1A1A1A", None, [
        "Hiace (SY6548)", "Granse", "F50", "SY1027", "Big Sea",
    ]),
    "Foton": ("#CC0000", WIKI_LOGOS["Foton"], [
        "Aumark", "Aumark S", "Auman", "Auman GTL", "View (Minibus)", "Tornado",
    ]),
    "Dongfeng": ("#CC0000", WIKI_LOGOS["Dongfeng"], [
        "Captain T", "KR", "KX", "DFM Van", "Dolika",
    ]),
    "FAW": ("#CC0000", CARLOGOS_PNG["FAW"], [
        "J6P", "J7", "Tiger V", "CA1080", "CA1160",
    ]),
    "Nissan UD": ("#C3002F", STORAGE_LOGOS.get("Nissan UD"), [
        "Condor", "Quon", "Croner", "Kuzer",
    ]),
    "Ford": ("#003478", STORAGE_LOGOS.get("Ford"), [
        "Transit Cargo", "Transit Jumbo", "Cargo Truck", "F-Series Truck",
    ]),
    "Renault Trucks": ("#FFCC00", WIKI_LOGOS["Renault Trucks"], [
        "T-Series", "C-Series", "K-Series", "D-Series", "Master Cargo",
    ]),
}


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def sql_nullable(value: str | None) -> str:
    if value is None:
        return "NULL"
    return f"'{sql_escape(value)}'"


def main() -> None:
    lines: list[str] = [
        "-- مركبات تجارية (veh_commercial) — brands + models (Iraq market)",
        "-- Safe to re-run: cleans veh_commercial subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_comm_node(",
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
        "DELETE FROM public.categories",
        "WHERE id IN (",
        "  WITH RECURSIVE subtree AS (",
        "    SELECT c.id FROM public.categories c",
        f"    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = '{PARENT_SLUG}')",
        "    UNION ALL",
        "    SELECT c.id FROM public.categories c",
        "    INNER JOIN subtree s ON c.parent_id = s.id",
        "  )",
        "  SELECT id FROM subtree",
        ");",
        "",
    ]

    seen: set[str] = set()
    brand_order = 0
    for brand, (color, logo, models) in COMMERCIAL_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{slugify(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_comm_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, {sql_nullable(logo)}, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{slugify(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_comm_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_comm_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(COMMERCIAL_TREE)
    model_count = sum(len(m) for _, _, m in COMMERCIAL_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
