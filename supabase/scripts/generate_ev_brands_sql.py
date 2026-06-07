#!/usr/bin/env python3
"""Generate EV brands/models seed migration for veh_electric."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260614000000_ev_brands_models.sql"

PARENT_SLUG = "veh_electric"
PREFIX = "veh_ev"

LOGO_SLUG_OVERRIDES: dict[str, str] = {
    "Mercedes-Benz": "mercedes-benz",
    "Li Auto": "li-auto",
    "MINI": "mini",
}

# brand -> (color_hex, models)
EV_TREE: dict[str, tuple[str, list[str]]] = {
    "Tesla": ("#CC0000", [
        "Model S", "Model 3", "Model X", "Model Y", "Cybertruck", "Model 2", "Roadster",
    ]),
    "BMW": ("#1C69D4", [
        "i3", "i4", "i5", "i7", "iX", "iX1", "iX2", "iX3", "iX M60",
    ]),
    "Mercedes-Benz": ("#333333", [
        "EQA", "EQB", "EQC", "EQE", "EQE SUV", "EQS", "EQS SUV", "EQV", "G 580 EQ",
    ]),
    "Audi": ("#BB0A30", [
        "e-tron", "e-tron GT", "e-tron S", "Q4 e-tron", "Q6 e-tron",
        "Q8 e-tron", "A6 e-tron", "RS e-tron GT",
    ]),
    "Porsche": ("#000000", [
        "Taycan", "Taycan 4S", "Taycan GTS", "Taycan Turbo", "Taycan Turbo S",
        "Taycan Cross Turismo", "Macan EV",
    ]),
    "Volkswagen": ("#001E50", [
        "ID.3", "ID.4", "ID.5", "ID.6", "ID.7", "ID. Buzz",
    ]),
    "Hyundai": ("#002C5F", [
        "IONIQ 5", "IONIQ 6", "IONIQ 9", "Kona Electric", "Nexo",
    ]),
    "Kia": ("#05141F", [
        "EV3", "EV6", "EV9", "Niro EV", "Soul EV",
    ]),
    "Rivian": ("#00A651", ["R1T", "R1S", "R2", "R3"]),
    "Lucid": ("#C41230", [
        "Air Pure", "Air Touring", "Air Grand Touring", "Air Sapphire", "Gravity",
    ]),
    "Volvo": ("#003057", [
        "XC40 Recharge", "C40 Recharge", "EX30", "EX40", "EX90", "EC40",
    ]),
    "Polestar": ("#000000", ["Polestar 2", "Polestar 3", "Polestar 4", "Polestar 6"]),
    "NIO": ("#00BEFF", [
        "ET5", "ET7", "EL6", "EL7", "EL8", "ES6", "ES8", "EC6",
    ]),
    "BYD": ("#1DB954", [
        "Atto 3", "Seal", "Dolphin", "Han", "Tang", "Song Plus EV", "Seagull", "Yangwang U8",
    ]),
    "Xpeng": ("#FF6B35", ["P5", "P7", "G3", "G6", "G9", "X9"]),
    "Li Auto": ("#0066CC", ["Li L6", "Li L7", "Li L8", "Li L9", "Li MEGA"]),
    "Zeekr": ("#000000", ["001", "007", "009", "X"]),
    "Jaguar": ("#231F20", ["I-PACE", "Type 00"]),
    "Lexus": ("#1A1A1A", ["RZ 300e", "RZ 450e", "UX 300e", "LF-ZC"]),
    "Toyota": ("#EB0A1E", ["bZ4X", "bZ3", "bZ3X", "Mirai"]),
    "Nissan": ("#C3002F", ["Leaf", "Ariya", "Sakura"]),
    "Chevrolet": ("#D4AC0D", [
        "Bolt EV", "Bolt EUV", "Equinox EV", "Blazer EV", "Silverado EV",
    ]),
    "Ford": ("#003478", [
        "Mustang Mach-E", "F-150 Lightning", "Explorer EV", "Capri EV",
    ]),
    "Jeep": ("#1E3A5F", [
        "Avenger EV", "Wrangler 4xe", "Grand Cherokee 4xe", "Recon EV",
    ]),
    "MINI": ("#000000", ["Cooper SE", "Countryman SE", "Aceman EV"]),
}

# Brands without a reliable carlogos.org asset — skip logo_url (UI shows initial).
NO_LOGO_BRANDS = {"Xpeng", "Li Auto", "Zeekr"}


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def logo_slug(brand: str) -> str:
    if brand in LOGO_SLUG_OVERRIDES:
        return LOGO_SLUG_OVERRIDES[brand]
    return slugify(brand).replace("_", "-")


def logo_url(brand: str) -> str | None:
    if brand in NO_LOGO_BRANDS:
        return None
    return f"https://www.carlogos.org/car-logos/{logo_slug(brand)}-logo.png"


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def main() -> None:
    lines: list[str] = [
        "-- سيارات كهربائية (veh_electric) — EV brands + models with logos",
        "-- Safe to re-run: cleans veh_electric subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_ev_node(",
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
    for brand, (color, models) in EV_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{slugify(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        logo = logo_url(brand)
        logo_sql = "NULL" if logo is None else f"'{logo}'"
        lines.append(
            f"SELECT public._seed_ev_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, {logo_sql}, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{slugify(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_ev_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_ev_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(EV_TREE)
    model_count = sum(len(m) for _, m in EV_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
