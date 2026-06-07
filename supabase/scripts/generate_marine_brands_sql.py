#!/usr/bin/env python3
"""Generate marine vehicle brands/models seed migration for veh_marine."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260620000000_marine_brands_models.sql"

PARENT_SLUG = "veh_marine"
PREFIX = "veh_marine"

STORAGE_BASE = (
    "https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos"
)

STORAGE_LOGOS: dict[str, str] = {
    "Honda Marine": f"{STORAGE_BASE}/honda.svg",
}

WIKI_LOGOS: dict[str, str] = {
    "Yamaha": "https://upload.wikimedia.org/wikipedia/commons/d/de/Yamaha_Motor_logo.svg",
    "Sea-Doo": "https://upload.wikimedia.org/wikipedia/commons/d/d9/BRP-Rotax_Logo.svg",
    "Suzuki Marine": "https://upload.wikimedia.org/wikipedia/commons/b/be/Suzuki_logo.svg",
    "Kawasaki": "https://upload.wikimedia.org/wikipedia/commons/d/da/Kawasaki-logo.svg",
    "Tohatsu": "https://upload.wikimedia.org/wikipedia/commons/8/8c/Tohatsu_company_logo.svg",
}

CARLOGOS_PNG: dict[str, str] = {
    "Mercury": "https://www.carlogos.org/car-logos/mercury-logo.png",
}

BRAND_SLUG_OVERRIDES: dict[str, str] = {
    "قوارب تقليدية": "traditional",
    "قوارب سرعة": "speed_boats",
}

MODEL_SLUG_OVERRIDES: dict[str, str] = {
    "مشحوف (Mashhouf)": "mashhouf",
    "تَرَادة (Tarada)": "tarada",
    "بلم (Balam)": "balam",
    "قارب صيد خشبي": "wooden_fishing_boat",
    "قارب صيد فايبر": "fiberglass_fishing_boat",
    "زلامة": "zlama",
    "عبّارة نهرية": "river_ferry",
    "قارب سرعة 17 قدم": "speed_17ft",
    "قارب سرعة 20 قدم": "speed_20ft",
    "قارب سرعة 24 قدم": "speed_24ft",
    "قارب سرعة 28 قدم": "speed_28ft",
    "لنش سياحي": "pleasure_launch",
    "لنش صيد": "fishing_launch",
    "قارب مطاطي": "inflatable_boat",
    "قارب ألومنيوم": "aluminum_boat",
}


def logo_for(brand: str) -> str | None:
    return STORAGE_LOGOS.get(brand) or WIKI_LOGOS.get(brand) or CARLOGOS_PNG.get(brand)


MARINE_TREE: dict[str, tuple[str, list[str]]] = {
    "Yamaha": ("#1A1A1A", [
        "FX Cruiser HO", "FX Cruiser SVHO", "VX Cruiser", "VX Deluxe", "EX Deluxe",
        "EX Sport", "SuperJet", "WaveRunner VX", "F115 Outboard", "F200 Outboard",
        "F250 Outboard", "40HP Outboard", "60HP Outboard",
    ]),
    "Sea-Doo": ("#FF6B00", [
        "Spark", "Spark Trixx", "GTI 130", "GTI SE 170", "GTR 230", "GTX 230",
        "GTX 300", "RXT-X 300", "RXP-X 300", "Wake Pro 230", "Fish Pro Scout",
    ]),
    "Honda Marine": ("#CC0000", [
        "BF2.3 Outboard", "BF15 Outboard", "BF40 Outboard", "BF60 Outboard",
        "BF100 Outboard", "BF115 Outboard", "BF150 Outboard", "BF200 Outboard",
        "BF250 Outboard",
    ]),
    "Mercury": ("#CC0000", [
        "Mercury 40HP", "Mercury 60HP", "Mercury 75HP", "Mercury 90HP",
        "Mercury 115HP", "Mercury 150HP", "Mercury 200HP", "Mercury 250HP",
        "Mercury 300HP", "Verado 350HP",
    ]),
    "Suzuki Marine": ("#1A1A1A", [
        "DF40A Outboard", "DF60A Outboard", "DF90A Outboard", "DF115A Outboard",
        "DF140A Outboard", "DF200A Outboard", "DF250AP Outboard", "DF300AP Outboard",
    ]),
    "Kawasaki": ("#009900", [
        "Jet Ski STX 160", "Jet Ski STX 160LX", "Jet Ski Ultra 160X",
        "Jet Ski Ultra 310X", "Jet Ski Ultra 310LX", "Jet Ski SX-R 160",
    ]),
    "Tohatsu": ("#003087", [
        "MFS6 Outboard", "MFS9.8 Outboard", "MFS15 Outboard", "MFS25 Outboard",
        "MFS40 Outboard", "MFS60 Outboard", "MFS90 Outboard",
    ]),
    "Boston Whaler": ("#003478", [
        "130 Super Sport", "170 Montauk", "190 Montauk", "210 Montauk",
        "270 Dauntless", "320 Outrage", "420 Outrage",
    ]),
    "Bayliner": ("#003478", [
        "Element E16", "Element E18", "VR4", "VR5", "VR6", "DX2050", "Trophy 2052",
    ]),
    "Zodiac": ("#003087", [
        "Cadet Aero 230", "Cadet Aero 310", "Medline 500", "Pro 420", "Pro 550",
        "Rescue Boat",
    ]),
    "Lund": ("#003478", [
        "Jon 1236", "Jon 1448", "Pro-V 1875", "Fury 1600", "Impact 1775",
    ]),
    "قوارب تقليدية": ("#8B4513", [
        "مشحوف (Mashhouf)", "تَرَادة (Tarada)", "بلم (Balam)", "قارب صيد خشبي",
        "قارب صيد فايبر", "زلامة", "عبّارة نهرية",
    ]),
    "Sunseeker": ("#1A1A1A", [
        "Portofino 40", "Manhattan 55", "Predator 65", "Ocean 75", "Yacht 90",
    ]),
    "Azimut": ("#003087", [
        "Azimut 40", "Azimut 50", "Azimut 60", "Azimut 72", "Azimut S6",
        "Azimut Grande 25",
    ]),
    "قوارب سرعة": ("#CC0000", [
        "قارب سرعة 17 قدم", "قارب سرعة 20 قدم", "قارب سرعة 24 قدم",
        "قارب سرعة 28 قدم", "لنش سياحي", "لنش صيد", "قارب مطاطي", "قارب ألومنيوم",
    ]),
}


def slugify_ascii(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def node_slug(name: str) -> str:
    if name in BRAND_SLUG_OVERRIDES:
        return BRAND_SLUG_OVERRIDES[name]
    if name in MODEL_SLUG_OVERRIDES:
        return MODEL_SLUG_OVERRIDES[name]
    paren = re.search(r"\(([^)]+)\)", name)
    if paren:
        inner = slugify_ascii(paren.group(1))
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


def main() -> None:
    lines: list[str] = [
        "-- مركبات بحرية (veh_marine) — brands + models (Iraq: Shatt al-Arab, rivers, Gulf)",
        "-- Safe to re-run: cleans veh_marine subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_marine_node(",
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
    for brand, (color, models) in MARINE_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{node_slug(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_marine_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, {sql_nullable(logo_for(brand))}, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{node_slug(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_marine_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_marine_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(MARINE_TREE)
    model_count = sum(len(m) for _, m in MARINE_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
