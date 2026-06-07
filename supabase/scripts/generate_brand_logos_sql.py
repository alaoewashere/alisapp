#!/usr/bin/env python3
"""Generate SQL migration for car brand logo_url values."""
from __future__ import annotations

import re
from pathlib import Path

# Re-use brand names from vehicle brands generator.
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_vehicle_brands_sql import AUTOMOBILE_TREE, sql_escape  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260605000000_category_brand_logos.sql"

LOGO_SLUG_OVERRIDES: dict[str, str] = {
    "Mercedes-Benz": "mercedes-benz",
    "Land Rover": "land-rover",
    "Rolls-Royce": "rolls-royce",
    "Alfa Romeo": "alfa-romeo",
    "Aston Martin": "aston-martin",
    "Great Wall": "great-wall",
    "Iran Khodro": "iran-khodro",
    "Mini": "mini",
}


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def logo_slug(brand_name: str) -> str:
    if brand_name in LOGO_SLUG_OVERRIDES:
        return LOGO_SLUG_OVERRIDES[brand_name]
    return slugify(brand_name).replace("_", "-")


def logo_url(brand_name: str) -> str:
    return f"https://www.carlogos.org/car-logos/{logo_slug(brand_name)}-logo.png"


def unique_brand_names() -> list[str]:
    names: set[str] = set()
    for brands in AUTOMOBILE_TREE.values():
        names.update(brands.keys())
    return sorted(names)


def main() -> None:
    brands = unique_brand_names()
    case_lines = [
        f"    WHEN '{sql_escape(name)}' THEN '{logo_url(name)}'"
        for name in brands
    ]
    case_sql = "\n".join(case_lines)

    sql = f"""-- Car brand logos (carlogos.org CDN) + listing count RPC for browse screen

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS logo_url TEXT;

UPDATE public.categories
SET logo_url = CASE name_ar
{case_sql}
    ELSE logo_url
END
WHERE icon = 'brand';

CREATE OR REPLACE FUNCTION public.category_listing_counts()
RETURNS TABLE(category_id INT, listing_count BIGINT)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT l.category_id, COUNT(*)::BIGINT
  FROM public.listings l
  WHERE l.status = 'approved'
    AND l.availability = 'active'
  GROUP BY l.category_id;
$$;

GRANT EXECUTE ON FUNCTION public.category_listing_counts() TO anon, authenticated;
"""
    OUT.write_text(sql, encoding="utf-8")
    print(f"Wrote {OUT} ({len(brands)} brand logo mappings)")


if __name__ == "__main__":
    main()
