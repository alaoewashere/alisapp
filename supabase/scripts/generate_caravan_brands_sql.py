#!/usr/bin/env python3
"""Generate caravan/RV brands/models seed migration for veh_caravan."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260622000000_caravan_brands_models.sql"

PARENT_SLUG = "veh_caravan"
PREFIX = "veh_caravan"

BRAND_SLUG_OVERRIDES: dict[str, str] = {
    "كرفان محلي": "local",
}

MODEL_SLUG_OVERRIDES: dict[str, str] = {
    "كرفان على شاسيه تويوتا": "toyota_chassis",
    "كرفان على شاسيه ميتسوبيشي": "mitsubishi_chassis",
    "كرفان على شاسيه فورد": "ford_chassis",
    "كرفان ثابت (للمخيمات)": "static_camp",
    "كرفان مكتب متنقل": "mobile_office",
    "كرفان عيادة متنقلة": "mobile_clinic",
    "كرفان للبيع بالتقسيط": "installment_sale",
}

CARAVAN_TREE: dict[str, tuple[str, list[str]]] = {
    "Coachmen": ("#CC0000", [
        "Freelander 27QB", "Freelander 32BH", "Apex Ultra-Lite", "Apex 213RDS",
        "Catalina 184BHS", "Catalina 243RBS", "Mirada 35ES", "Pursuit 31BH",
    ]),
    "Airstream": ("#C0C0C0", [
        "Bambi 16RB", "Sport 22FB", "Flying Cloud 25FB", "Flying Cloud 30RB",
        "Classic 33FB", "Interstate 24GT", "Atlas", "Basecamp 20",
    ]),
    "Jayco": ("#003478", [
        "Jay Feather 22RB", "Jay Flight 28BHS", "Eagle 330RSTS", "North Point 382FLRB",
        "Redhawk 31F", "Greyhawk 31F", "Pinnacle 36FBTS",
    ]),
    "Thor": ("#1A1A1A", [
        "Ace 27.2", "Chateau 28A", "Magnitude SV34", "Windsport 34J",
        "Venetian J40", "Axis 24.1", "Four Winds 28Z",
    ]),
    "Winnebago": ("#CC0000", [
        "Micro Minnie 2108DS", "Minnie Plus 27BHSS", "Voyage 2831RL", "Vista 29VE",
        "Intent 29L", "Travato 59GL", "Ekko 22A", "Revel 44E",
    ]),
    "Forest River": ("#006400", [
        "Rockwood Mini Lite", "Rockwood Signature", "Salem 27REI", "Georgetown 5 Series",
        "Cherokee Wolf Pup", "Sunseeker 2860DS", "Forester 3011DS",
    ]),
    "Hymer": ("#003087", [
        "B-Class 580", "B-Class 680", "T-Class 674", "S-Class 650",
        "Exsis-T 588", "Tramp 650", "Free 600 Campus",
    ]),
    "Hobby": ("#CC0000", [
        "De Luxe 460UFe", "De Luxe 540UL", "Excellent 560WFU", "Prestige 720 WFKT",
        "Optima 540 OFc", "Landhaus 770 KMFe",
    ]),
    "Dethleffs": ("#003087", [
        "Camper 500 QMK", "Camper 650 VFK", "Trend T 6857 EB", "Globebus T1", "Pulse i7",
    ]),
    "Adria": ("#CC0000", [
        "Altea 432 PX", "Adora 613 HT", "Astella 804 HP", "Sonic Axess 600 SL",
        "Matrix Plus 670 SL", "Twin Axess 640 SLB",
    ]),
    "Knaus": ("#003087", [
        "Sport 420 QD", "Sun TI 650 MEG", "Südwind 590 QF", "BoxStar 600 MQ",
        "Van TI Plus 650 MEG",
    ]),
    "كرفان محلي": ("#8B4513", [
        "كرفان على شاسيه تويوتا", "كرفان على شاسيه ميتسوبيشي", "كرفان على شاسيه فورد",
        "كرفان ثابت (للمخيمات)", "كرفان مكتب متنقل", "كرفان عيادة متنقلة",
        "كرفان للبيع بالتقسيط",
    ]),
    "Gulf Stream": ("#006699", [
        "Conquest 6237", "Envision 225RB", "Kingsport 299QB", "Innsbruck 295QB",
        "BT Cruiser 5270",
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
        "-- كرفان (veh_caravan) — RV & caravan brands + models (Iraq market)",
        "-- Safe to re-run: cleans veh_caravan subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_caravan_node(",
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
    for brand, (color, models) in CARAVAN_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{node_slug(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_caravan_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, NULL, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{node_slug(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_caravan_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_caravan_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(CARAVAN_TREE)
    model_count = sum(len(m) for _, m in CARAVAN_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
