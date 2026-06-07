#!/usr/bin/env python3
"""Generate minivan/van brands/models seed migration for veh_minivan."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260615000000_minivan_brands_models.sql"

PARENT_SLUG = "veh_minivan"
PREFIX = "veh_van"

LOGO_SLUG_OVERRIDES: dict[str, str] = {
    "Mercedes-Benz": "mercedes-benz",
}

VAN_TREE: dict[str, tuple[str, list[str]]] = {
    "Toyota": ("#EB0A1E", [
        "HiAce", "Hiace GL", "Hiace High Roof", "Hiace Commuter",
        "Noah", "Voxy", "Alphard", "Vellfire", "Sienna", "Innova", "Granvia",
    ]),
    "Kia": ("#05141F", [
        "Carnival", "Carnival Limousine", "Bongo", "Grand Carnival", "Pregio",
    ]),
    "Hyundai": ("#002C5F", [
        "Staria", "Staria Limousine", "H-1", "H-1 Van", "Starex", "Grand Starex", "County",
    ]),
    "Nissan": ("#C3002F", [
        "Urvan", "Urvan High Roof", "Serena", "Quest", "Elgrand", "Cabstar",
    ]),
    "Mercedes-Benz": ("#333333", [
        "Sprinter", "Sprinter 313", "Sprinter 315", "Sprinter 316",
        "Vito", "Vito Tourer", "V-Class", "V-Class Marco Polo", "Metris",
    ]),
    "Volkswagen": ("#001E50", [
        "Transporter T6", "Transporter T7", "Caravelle", "Multivan", "Crafter", "Touran",
    ]),
    "Ford": ("#003478", [
        "Transit", "Transit Custom", "Transit Connect", "Tourneo", "Tourneo Custom", "Econoline",
    ]),
    "GMC": ("#CC0000", ["Safari", "Savana", "Express", "Vandura"]),
    "Mitsubishi": ("#CC0000", [
        "Delica", "Delica D:5", "L300", "Express", "Rosa",
    ]),
    "Honda": ("#CC0000", [
        "Odyssey", "Elysion", "Stepwgn", "Freed", "BR-V",
    ]),
    "Chrysler": ("#1A1A1A", [
        "Pacifica", "Grand Caravan", "Voyager", "Town & Country",
    ]),
    "Renault": ("#FFCC00", ["Trafic", "Master", "Kangoo", "Espace"]),
    "Mazda": ("#1E1E1E", ["Bongo", "Bongo Friendee", "MPV", "Biante"]),
    "Isuzu": ("#CC0000", ["Traviz", "NLR", "Journey"]),
    "Opel": ("#FFD700", ["Vivaro", "Movano", "Zafira", "Combo"]),
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
    return f"https://www.carlogos.org/car-logos/{logo_slug(brand)}-logo.png"


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def main() -> None:
    lines: list[str] = [
        "-- ميني فان وفان (veh_minivan) — brands + models (Iraq market)",
        "-- Safe to re-run: cleans veh_minivan subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_van_node(",
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
    for brand, (color, models) in VAN_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{slugify(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_van_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, '{logo_url(brand)}', '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{slugify(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_van_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_van_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(VAN_TREE)
    model_count = sum(len(m) for _, m in VAN_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
