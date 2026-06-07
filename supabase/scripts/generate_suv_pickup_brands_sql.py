#!/usr/bin/env python3
"""Generate SUV & pickup brands/models seed migration for veh_suv_pickup."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260619000000_suv_pickup_brands_models.sql"

PARENT_SLUG = "veh_suv_pickup"
PREFIX = "veh_suv"

STORAGE_BASE = (
    "https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos"
)

STORAGE_LOGOS: dict[str, str] = {
    "Toyota": f"{STORAGE_BASE}/toyota.svg",
    "Nissan": f"{STORAGE_BASE}/nissan.svg",
    "Land Rover": f"{STORAGE_BASE}/land-rover.svg",
    "Jeep": f"{STORAGE_BASE}/jeep.svg",
    "Lexus": f"{STORAGE_BASE}/lexus.svg",
    "GMC": f"{STORAGE_BASE}/gmc.svg",
    "Ford": f"{STORAGE_BASE}/ford.svg",
    "Chevrolet": f"{STORAGE_BASE}/chevrolet.svg",
    "Mitsubishi": f"{STORAGE_BASE}/mitsubishi.svg",
    "Kia": f"{STORAGE_BASE}/kia.svg",
    "Hyundai": f"{STORAGE_BASE}/hyundai.svg",
    "Mercedes-Benz": f"{STORAGE_BASE}/mercedes-benz.svg",
    "BMW": f"{STORAGE_BASE}/bmw.svg",
    "Audi": f"{STORAGE_BASE}/audi.svg",
    "Porsche": f"{STORAGE_BASE}/porsche.svg",
    "Volkswagen": f"{STORAGE_BASE}/volkswagen.svg",
    "Isuzu": f"{STORAGE_BASE}/isuzu.svg",
    "Volvo": f"{STORAGE_BASE}/volvo.svg",
}

CARLOGOS_PNG: dict[str, str] = {
    "Dodge": "https://www.carlogos.org/car-logos/dodge-logo.png",
    "Infiniti": "https://www.carlogos.org/car-logos/infiniti-logo.png",
    "Cadillac": "https://www.carlogos.org/car-logos/cadillac-logo.png",
    "Lincoln": "https://www.carlogos.org/car-logos/lincoln-logo.png",
    "Haval": "https://www.carlogos.org/car-logos/haval-logo.png",
    "MG": "https://www.carlogos.org/car-logos/mg-logo.png",
    "Hummer": "https://www.carlogos.org/car-logos/hummer-logo.png",
    "Subaru": "https://www.carlogos.org/car-logos/subaru-logo.png",
    "Suzuki": "https://www.carlogos.org/car-logos/suzuki-logo.png",
}


def logo_for(brand: str) -> str | None:
    return STORAGE_LOGOS.get(brand) or CARLOGOS_PNG.get(brand)


SUV_TREE: dict[str, tuple[str, list[str]]] = {
    "Toyota": ("#EB0A1E", [
        "Land Cruiser 70", "Land Cruiser 76", "Land Cruiser 78",
        "Land Cruiser 79 (Pick Up)", "Land Cruiser 200", "Land Cruiser 300",
        "Land Cruiser Prado 150", "Land Cruiser Prado 120", "FJ Cruiser",
        "4Runner", "RAV4", "Fortuner", "Hilux (Pick Up)", "Hilux Revo",
        "Hilux Champ", "Rush", "Sequoia",
    ]),
    "Nissan": ("#C3002F", [
        "Patrol Y61", "Patrol Y62", "Patrol Safari", "Xterra", "Pathfinder",
        "Navara (Pick Up)", "Frontier (Pick Up)", "Murano", "Terra", "X-Terra",
    ]),
    "Land Rover": ("#005A2B", [
        "Defender 90", "Defender 110", "Defender 130", "Discovery 3",
        "Discovery 4", "Discovery 5", "Discovery Sport", "Range Rover",
        "Range Rover Sport", "Range Rover Vogue", "Range Rover Evoque",
        "Range Rover Velar", "Freelander",
    ]),
    "Jeep": ("#1E3A5F", [
        "Wrangler", "Wrangler Unlimited", "Grand Cherokee", "Grand Cherokee L",
        "Cherokee", "Compass", "Renegade", "Gladiator (Pick Up)", "Commander",
    ]),
    "Lexus": ("#1A1A1A", [
        "LX 570", "LX 600", "GX 460", "GX 550", "RX 350", "RX 500h",
        "NX 250", "NX 350h", "UX 200", "TX 550h",
    ]),
    "GMC": ("#CC0000", [
        "Yukon", "Yukon XL", "Tahoe", "Suburban", "Envoy", "Terrain",
        "Sierra (Pick Up)", "Canyon (Pick Up)", "Jimmy",
    ]),
    "Ford": ("#003478", [
        "F-150 (Pick Up)", "F-250", "F-350", "Raptor", "Explorer", "Expedition",
        "Bronco", "Bronco Sport", "Edge", "Escape", "EcoSport",
        "Ranger (Pick Up)", "Everest",
    ]),
    "Chevrolet": ("#D4AC0D", [
        "Tahoe", "Suburban", "Silverado (Pick Up)", "Colorado (Pick Up)",
        "Blazer", "TrailBlazer", "Captiva", "Equinox", "Traverse",
    ]),
    "Mitsubishi": ("#CC0000", [
        "Pajero", "Pajero Sport", "Pajero Full", "L200 (Pick Up)",
        "Triton (Pick Up)", "Outlander", "Eclipse Cross", "ASX", "Montero",
    ]),
    "Kia": ("#05141F", [
        "Telluride", "Sorento", "Sportage", "Mohave", "Stonic", "Seltos",
    ]),
    "Hyundai": ("#002C5F", [
        "Santa Fe", "Tucson", "Palisade", "Creta", "Venue", "Kona", "Terracan",
    ]),
    "Mercedes-Benz": ("#333333", [
        "G-Class G63", "G-Class G500", "G-Class G350d", "GLS 450",
        "GLS 600 Maybach", "GLE 450", "GLE 63 AMG", "GLC 300", "GLA 200",
        "GLB 200", "X-Class (Pick Up)",
    ]),
    "BMW": ("#1C69D4", [
        "X1", "X2", "X3", "X4", "X5", "X6", "X7", "XM",
    ]),
    "Audi": ("#BB0A30", [
        "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8", "SQ7", "RSQ8",
    ]),
    "Porsche": ("#000000", [
        "Cayenne", "Cayenne GTS", "Cayenne Turbo", "Macan", "Macan S", "Macan GTS",
    ]),
    "Dodge": ("#CC0000", [
        "Durango", "Journey", "Ram 1500 (Pick Up)", "Ram 2500", "Ram 3500",
    ]),
    "Infiniti": ("#1A1A1A", [
        "QX80", "QX60", "QX55", "QX50", "FX35", "FX37", "FX50", "EX35",
    ]),
    "Cadillac": ("#2C2C2C", [
        "Escalade", "Escalade ESV", "XT4", "XT5", "XT6", "SRX",
    ]),
    "Lincoln": ("#2C2C2C", [
        "Navigator", "Navigator L", "Aviator", "Nautilus", "MKX", "MKT",
    ]),
    "Volkswagen": ("#001E50", [
        "Touareg", "Tiguan", "T-Roc", "Amarok (Pick Up)", "Teramont",
    ]),
    "Haval": ("#CC0000", [
        "H6", "H9", "Jolion", "Dargo", "Big Dog", "Shenshou",
    ]),
    "MG": ("#CC0000", [
        "MG HS", "MG ZS", "MG RX8", "MG VS HEV", "Extender (Pick Up)",
    ]),
    "Isuzu": ("#CC0000", [
        "D-Max (Pick Up)", "D-Max V-Cross", "MU-X",
    ]),
    "Hummer": ("#2C2C2C", [
        "H1", "H2", "H3", "EV (Pick Up)",
    ]),
    "Subaru": ("#003399", [
        "Forester", "Outback", "XV", "Ascent",
    ]),
    "Volvo": ("#003057", [
        "XC40", "XC60", "XC90", "V90 Cross Country",
    ]),
    "Suzuki": ("#1A1A1A", [
        "Vitara", "Grand Vitara", "Jimny", "S-Cross", "Equator (Pick Up)",
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
        "-- دفع رباعي وبيك أب (veh_suv_pickup) — brands + models (Iraq market)",
        "-- Safe to re-run: cleans veh_suv_pickup subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_suv_node(",
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
    for brand, (color, models) in SUV_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{slugify(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_suv_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, {sql_nullable(logo_for(brand))}, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{slugify(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_suv_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_suv_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(SUV_TREE)
    model_count = sum(len(m) for _, m in SUV_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
