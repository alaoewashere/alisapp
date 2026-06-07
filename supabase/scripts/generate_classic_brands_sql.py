#!/usr/bin/env python3
"""Generate classic car brands/models seed migration for veh_classic."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260623000000_classic_brands_models.sql"

PARENT_SLUG = "veh_classic"
PREFIX = "veh_classic"

STORAGE_BASE = (
    "https://riaazqhgknsnymjzzjou.supabase.co/storage/v1/object/public/brand-logos"
)

STORAGE_LOGOS: dict[str, str] = {
    "Mercedes-Benz": f"{STORAGE_BASE}/mercedes-benz.svg",
    "BMW": f"{STORAGE_BASE}/bmw.svg",
    "Toyota": f"{STORAGE_BASE}/toyota.svg",
    "Ford": f"{STORAGE_BASE}/ford.svg",
    "Chevrolet": f"{STORAGE_BASE}/chevrolet.svg",
    "Volkswagen": f"{STORAGE_BASE}/volkswagen.svg",
    "Porsche": f"{STORAGE_BASE}/porsche.svg",
    "Jaguar": f"{STORAGE_BASE}/jaguar.svg",
    "Nissan / Datsun": f"{STORAGE_BASE}/nissan.svg",
    "Land Rover": f"{STORAGE_BASE}/land-rover.svg",
    "Audi": f"{STORAGE_BASE}/audi.svg",
    "Opel": f"{STORAGE_BASE}/opel.svg",
}

WIKI_LOGOS: dict[str, str] = {}

CARLOGOS_PNG: dict[str, str] = {
    "Dodge": "https://www.carlogos.org/car-logos/dodge-logo.png",
    "Rolls-Royce": "https://www.carlogos.org/car-logos/rolls-royce-logo.png",
    "Cadillac": "https://www.carlogos.org/car-logos/cadillac-logo.png",
    "Alfa Romeo": "https://www.carlogos.org/car-logos/alfa-romeo-logo.png",
    "Ferrari": "https://www.carlogos.org/car-logos/ferrari-logo.png",
    "Lincoln": "https://www.carlogos.org/car-logos/lincoln-logo.png",
    "Pontiac": "https://www.carlogos.org/car-logos/pontiac-logo.png",
    "Oldsmobile": "https://www.carlogos.org/car-logos/oldsmobile-logo.png",
}

STORAGE_PNG_LOGOS: dict[str, str] = {
    "Dodge": f"{STORAGE_BASE}/dodge.png",
    "Rolls-Royce": f"{STORAGE_BASE}/rolls-royce.png",
    "Cadillac": f"{STORAGE_BASE}/cadillac.png",
    "Alfa Romeo": f"{STORAGE_BASE}/alfa-romeo.png",
    "Ferrari": f"{STORAGE_BASE}/ferrari.png",
    "Lincoln": f"{STORAGE_BASE}/lincoln.png",
    "Pontiac": f"{STORAGE_BASE}/pontiac.png",
    "Oldsmobile": f"{STORAGE_BASE}/oldsmobile.png",
}

BRAND_SLUG_OVERRIDES: dict[str, str] = {
    "Nissan / Datsun": "nissan_datsun",
}

CLASSIC_TREE: dict[str, tuple[str, list[str]]] = {
    "Mercedes-Benz": ("#333333", [
        "W123 (1976–1985)", "W124 (1984–1997)", "W126 (1979–1991)", "W114/W115 (1968–1976)",
        "W108/W109 (1965–1972)", "W111 Fintail (1959–1968)", "190E 2.3-16 (1984)",
        "300SL Gullwing (1954–1957)", "Pagoda 230SL (1963–1971)", "600 Grosser (1963–1981)",
        "R107 SL (1971–1989)", "G-Class W460 (1979–1991)",
    ]),
    "BMW": ("#1C69D4", [
        "E10 2002 (1968–1976)", "E21 3-Series (1975–1983)", "E30 3-Series (1982–1994)",
        "E28 5-Series (1981–1988)", "E34 5-Series (1988–1996)", "E24 6-Series (1976–1989)",
        "E32 7-Series (1986–1994)", "E38 7-Series (1994–2001)", "M1 (1978–1981)",
        "507 Roadster (1956–1959)",
    ]),
    "Toyota": ("#EB0A1E", [
        "Land Cruiser FJ40 (1960–1984)", "Land Cruiser FJ55 (1967–1980)",
        "Land Cruiser BJ60 (1980–1987)", "Land Cruiser HJ61 (1987–1990)",
        "Celica (1970–1977)", "Corolla E20 (1970–1979)", "Corolla E30 (1979–1983)",
        "Corona (1957–1982)", "Crown (1955–1979)", "Cressida (1976–1992)",
        "Hilux 1st–3rd Gen (1968–1983)", "Supra A60 (1981–1986)",
    ]),
    "Ford": ("#003478", [
        "Mustang 1st Gen (1964–1973)", "Mustang Mach 1 (1969–1973)",
        "Mustang Boss 302 (1969–1970)", "Thunderbird (1955–1976)", "Falcon (1960–1970)",
        "Galaxy (1959–1974)", "F-100 Pickup (1953–1979)", "Bronco 1st Gen (1966–1977)",
        "Capri (1968–1986)", "Cortina (1962–1982)",
    ]),
    "Chevrolet": ("#D4AC0D", [
        "Corvette C1 (1953–1962)", "Corvette C2 (1963–1967)", "Corvette C3 (1968–1982)",
        "Camaro 1st Gen (1966–1969)", "Camaro 2nd Gen (1970–1981)", "Impala (1958–1976)",
        "Bel Air (1950–1975)", "Nova (1962–1979)", "El Camino (1959–1987)",
        "Blazer K5 (1969–1994)",
    ]),
    "Dodge": ("#CC0000", [
        "Charger (1966–1978)", "Challenger (1970–1974)", "Dart (1960–1976)",
        "Coronet (1949–1976)", "Super Bee (1968–1971)", "Plymouth Barracuda (1964–1974)",
        "Plymouth Road Runner (1968–1980)", "Chrysler 300 Letter (1955–1965)",
    ]),
    "Volkswagen": ("#001E50", [
        "Beetle (1938–2003)", "Golf GTI Mk1 (1974–1984)", "Golf GTI Mk2 (1984–1992)",
        "Karmann Ghia (1955–1974)", "Type 2 Bus (1950–1979)", "Scirocco Mk1 (1974–1981)",
        "Polo Mk1 (1975–1981)",
    ]),
    "Porsche": ("#000000", [
        "356 (1948–1965)", "911 2.0 (1963–1969)", "911 Carrera RS (1972–1973)",
        "911 SC (1978–1983)", "911 Carrera 3.2 (1984–1989)", "914 (1969–1976)",
        "924 (1976–1988)", "944 (1982–1991)", "928 (1977–1995)",
    ]),
    "Jaguar": ("#231F20", [
        "E-Type (1961–1975)", "XK120 (1948–1954)", "XK140 (1954–1957)", "XK150 (1957–1961)",
        "Mark 2 (1959–1967)", "XJ6 Series 1 (1968–1973)", "XJ6 Series 2 (1973–1979)",
        "XJS (1975–1996)",
    ]),
    "Nissan / Datsun": ("#C3002F", [
        "Datsun 240Z (1969–1973)", "Datsun 260Z (1973–1978)", "Datsun 280Z (1975–1978)",
        "Nissan 300ZX Z31 (1983–1989)", "Datsun 510 (1967–1973)", "Datsun 1200 (1970–1973)",
        "Nissan Skyline GT-R C10", "Nissan Patrol 60 Series",
    ]),
    "Pontiac": ("#CC0000", [
        "GTO (1964–1974)", "Firebird (1967–1981)", "Trans Am (1969–1981)",
        "Bonneville (1957–1970)", "Catalina (1950–1981)",
    ]),
    "Rolls-Royce": ("#2C2C2C", [
        "Silver Shadow (1965–1980)", "Silver Ghost (1906–1926)", "Silver Cloud (1955–1966)",
        "Corniche (1971–1996)", "Camargue (1975–1986)", "Silver Spirit (1980–1998)",
    ]),
    "Land Rover": ("#005A2B", [
        "Series I (1948–1958)", "Series II (1958–1971)", "Series III (1971–1985)",
        "Range Rover Classic (1970–1996)", "Defender 90 (1983–2016)", "Defender 110 (1983–2016)",
    ]),
    "Cadillac": ("#2C2C2C", [
        "Eldorado (1953–1978)", "DeVille (1959–1977)", "Fleetwood (1955–1996)",
        "Seville (1975–1985)", "Series 62 (1940–1964)",
    ]),
    "Alfa Romeo": ("#CC0000", [
        "Spider Duetto (1966–1993)", "GTV (1963–1977)", "Montreal (1970–1977)",
        "Giulia Sprint (1963–1978)", "Alfetta (1972–1987)", "33 (1983–1995)",
        "75 / Milano (1985–1992)",
    ]),
    "Ferrari": ("#CC0000", [
        "250 GTO (1962–1964)", "275 GTB (1964–1968)", "308 GTB/GTS (1975–1985)",
        "328 GTB/GTS (1985–1989)", "348 (1989–1995)", "Testarossa (1984–1991)",
        "Dino 246 (1969–1974)", "365 GTB/4 Daytona (1968–1973)",
    ]),
    "Audi": ("#BB0A30", [
        "Audi Quattro (1980–1991)", "Audi 80 B1 (1972–1978)", "Audi 100 C1 (1968–1976)",
        "Audi 100 C2 (1976–1982)", "Audi Coupe GT (1980–1988)", "NSU Ro 80 (1967–1977)",
    ]),
    "Oldsmobile": ("#CC0000", [
        "442 (1964–1980)", "Toronado (1966–1992)", "Cutlass Supreme (1966–1988)",
        "Delta 88 (1965–1985)", "Ninety-Eight (1941–1996)",
    ]),
    "Opel": ("#FFD700", [
        "Rekord (1953–1986)", "Kadett B (1965–1973)", "Manta A (1970–1975)", "GT (1968–1973)",
        "Commodore (1967–1982)", "Senator A (1978–1987)",
    ]),
    "Lincoln": ("#2C2C2C", [
        "Continental (1961–1969)", "Mark III (1969–1971)", "Mark IV (1972–1976)",
        "Mark V (1977–1979)", "Capri (1952–1959)", "Town Car (1981–1997)",
    ]),
}


def logo_for(brand: str) -> str | None:
    return (
        STORAGE_LOGOS.get(brand)
        or STORAGE_PNG_LOGOS.get(brand)
        or WIKI_LOGOS.get(brand)
        or CARLOGOS_PNG.get(brand)
    )


def slugify_ascii(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def node_slug(name: str) -> str:
    if name in BRAND_SLUG_OVERRIDES:
        return BRAND_SLUG_OVERRIDES[name]
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


def main() -> None:
    lines: list[str] = [
        "-- سيارات كلاسيكية (veh_classic) — classic car brands + models (Iraq market)",
        "-- Safe to re-run: cleans veh_classic subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS logo_url TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_classic_node(",
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
    for brand, (color, models) in CLASSIC_TREE.items():
        brand_order += 1
        brand_slug = f"{PREFIX}_br_{node_slug(brand)}"
        if brand_slug in seen:
            raise ValueError(f"duplicate slug: {brand_slug}")
        seen.add(brand_slug)
        lines.append(
            f"SELECT public._seed_classic_node('{brand_slug}', '{sql_escape(brand)}', "
            f"'{PARENT_SLUG}', 'brand', {brand_order}, {sql_nullable(logo_for(brand))}, '{color}');"
        )
        model_order = 0
        for model in models:
            model_order += 1
            model_slug = f"{brand_slug}_{node_slug(model)}"
            if model_slug in seen:
                raise ValueError(f"duplicate slug: {model_slug} from {model!r}")
            seen.add(model_slug)
            lines.append(
                f"SELECT public._seed_classic_node('{model_slug}', '{sql_escape(model)}', "
                f"'{brand_slug}', 'model', {model_order}, NULL, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_classic_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    brand_count = len(CLASSIC_TREE)
    model_count = sum(len(m) for _, m in CLASSIC_TREE.values())
    print(f"Wrote {OUT.name}: {brand_count} brands, {model_count} models, {len(lines)} lines")


if __name__ == "__main__":
    main()
