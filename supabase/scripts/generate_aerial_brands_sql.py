#!/usr/bin/env python3
"""Generate aerial vehicle tree for veh_aircraft (planes + helicopters → brand → model)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260625000000_aerial_brands_models.sql"

ROOT_SLUG = "veh_aircraft"

TYPE_SLUG_OVERRIDES: dict[str, str] = {
    "طائرات": "planes",
    "مروحيات": "helicopters",
}

BRAND_SLUG_OVERRIDES: dict[str, str] = {
    "Dassault Falcon": "dassault_falcon",
    "Airbus Helicopters": "airbus_helicopters",
    "MD Helicopters": "md_helicopters",
}

MODEL_SLUG_OVERRIDES: dict[str, str] = {
    "H125 (AS350 Écureuil)": "h125_as350",
    "AW609 (Tiltrotor)": "aw609_tiltrotor",
    "Bell 47 (Classic)": "bell_47_classic",
}

AERIAL_TREE: dict[str, tuple[str, str, dict[str, tuple[str, list[str]]]]] = {
    "planes": (
        "طائرات",
        "#003478",
        {
            "Cessna": ("#003478", [
                "Cessna 172 Skyhawk", "Cessna 182 Skylane", "Cessna 206 Stationair",
                "Cessna 208 Caravan", "Cessna 210 Centurion", "Cessna 310",
                "Cessna 337 Skymaster", "Cessna Citation CJ3", "Cessna Citation XLS",
                "Cessna Citation Latitude",
            ]),
            "Piper": ("#CC0000", [
                "Piper PA-28 Cherokee", "Piper PA-32 Cherokee Six", "Piper PA-34 Seneca",
                "Piper PA-44 Seminole", "Piper PA-46 Malibu", "Piper PA-46 Meridian",
                "Piper M600", "Piper Archer TX",
            ]),
            "Beechcraft": ("#1A1A1A", [
                "Bonanza G36", "Baron G58", "King Air C90", "King Air 200", "King Air 350",
                "Beechjet 400A", "Premier I",
            ]),
            "Cirrus": ("#CC0000", [
                "SR20", "SR22", "SR22T", "Vision Jet SF50",
            ]),
            "Diamond": ("#003087", [
                "DA20", "DA40", "DA42 Twin Star", "DA62",
            ]),
            "Gulfstream": ("#1A1A1A", [
                "G280", "G450", "G550", "G600", "G650", "G700", "G800",
            ]),
            "Bombardier": ("#CC0000", [
                "Learjet 75", "Challenger 300", "Challenger 350", "Challenger 605",
                "Challenger 650", "Global 5500", "Global 6500", "Global 7500",
            ]),
            "Dassault Falcon": ("#003087", [
                "Falcon 2000", "Falcon 2000LX", "Falcon 6X", "Falcon 7X", "Falcon 8X",
                "Falcon 10X",
            ]),
            "Embraer": ("#003478", [
                "Phenom 100", "Phenom 300", "Praetor 500", "Praetor 600",
                "Legacy 450", "Legacy 500",
            ]),
        },
    ),
    "helicopters": (
        "مروحيات",
        "#CC0000",
        {
            "Robinson": ("#CC0000", [
                "R22 Beta II", "R44 Raven I", "R44 Raven II", "R44 Cadet", "R66 Turbine",
            ]),
            "Bell": ("#003478", [
                "Bell 206 JetRanger", "Bell 206L LongRanger", "Bell 407", "Bell 407GXi",
                "Bell 412", "Bell 429", "Bell 430", "Bell 505 Jet Ranger X",
                "Bell 525 Relentless", "Bell 47 (Classic)",
            ]),
            "Airbus Helicopters": ("#00205B", [
                "H125 (AS350 Écureuil)", "H130", "H135", "H145", "H155", "H160", "H175",
                "H215 Super Puma", "H225 Super Puma", "EC120 Colibri",
            ]),
            "Leonardo": ("#CC0000", [
                "AW109", "AW119 Koala", "AW139", "AW169", "AW189", "AW101 Merlin",
                "AW609 (Tiltrotor)",
            ]),
            "Sikorsky": ("#003478", [
                "S-76 Spirit", "S-76D", "S-92", "S-300C", "S-333", "S-434",
            ]),
            "MD Helicopters": ("#1A1A1A", [
                "MD 500E", "MD 520N NOTAR", "MD 530F", "MD 600N", "MD 902 Explorer",
            ]),
            "Mil": ("#CC0000", [
                "Mi-8", "Mi-17", "Mi-171", "Mi-26", "Mi-2",
            ]),
        },
    ),
}


def slugify_ascii(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def node_slug(name: str) -> str:
    if name in TYPE_SLUG_OVERRIDES:
        return TYPE_SLUG_OVERRIDES[name]
    if name in BRAND_SLUG_OVERRIDES:
        return BRAND_SLUG_OVERRIDES[name]
    if name in MODEL_SLUG_OVERRIDES:
        return MODEL_SLUG_OVERRIDES[name]
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


def main() -> None:
    lines: list[str] = [
        "-- مركبات جوية (veh_aircraft) — طائرات / مروحيات → brand → model",
        "-- Safe to re-run: cleans veh_aircraft subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_aerial_node(",
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
        f"    WHERE c.parent_id = (SELECT id FROM public.categories WHERE slug = '{ROOT_SLUG}')",
        "    UNION ALL",
        "    SELECT c.id FROM public.categories c",
        "    INNER JOIN subtree s ON c.parent_id = s.id",
        "  )",
        "  SELECT id FROM subtree",
        ");",
        "",
    ]

    seen: set[str] = set()
    type_order = 0
    brand_count = 0
    model_count = 0

    for type_key, (type_name, type_color, brands) in AERIAL_TREE.items():
        type_order += 1
        type_slug = f"{ROOT_SLUG}_{type_key}"
        if type_slug in seen:
            raise ValueError(f"duplicate slug: {type_slug}")
        seen.add(type_slug)
        lines.append(
            f"SELECT public._seed_aerial_node('{type_slug}', '{sql_escape(type_name)}', "
            f"'{ROOT_SLUG}', 'category', {type_order}, NULL, '{type_color}');"
        )

        brand_order = 0
        for brand, (color, models) in brands.items():
            brand_order += 1
            brand_count += 1
            brand_slug = f"{type_slug}_br_{node_slug(brand)}"
            if brand_slug in seen:
                raise ValueError(f"duplicate slug: {brand_slug}")
            seen.add(brand_slug)
            lines.append(
                f"SELECT public._seed_aerial_node('{brand_slug}', '{sql_escape(brand)}', "
                f"'{type_slug}', 'brand', {brand_order}, NULL, '{color}');"
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
                    f"SELECT public._seed_aerial_node('{model_slug}', '{sql_escape(model)}', "
                    f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
                )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_aerial_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        f"Wrote {OUT.name}: 2 types, {brand_count} brands, {model_count} models, "
        f"{len(lines)} lines"
    )


if __name__ == "__main__":
    main()
