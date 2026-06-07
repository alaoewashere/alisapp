#!/usr/bin/env python3
"""Generate vehicle brands/models seed migration SQL."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260604000000_vehicle_brands_models.sql"


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def mercedes_models() -> list[str]:
    return [
        "A-Class",
        "C-Class",
        "E-Class",
        "S-Class",
        "CLA",
        "CLS",
        "GLE",
        "AMG GT",
        "EQE",
        "EQS",
        "SL",
        "SLK",
        "CLK",
        "CL",
        "Maybach S-Class",
        "B-Class",
        "190",
        "200",
        "230",
        "280",
        "300",
        "500",
    ]


# parent_slug -> { brand_name: [models] }
AUTOMOBILE_TREE: dict[str, dict[str, list[str]]] = {
    "veh_automobile": {
        "Toyota": [
            "Corolla",
            "Camry",
            "Yaris",
            "Avensis",
            "Auris",
            "Verso",
            "Prius",
            "Supra",
            "Celica",
            "GT86",
            "Land Cruiser",
            "Urban Cruiser",
            "Starlet",
            "Previa",
        ],
        "Mercedes-Benz": mercedes_models(),
        "BMW": [
            "1-Series",
            "2-Series",
            "3-Series",
            "4-Series",
            "5-Series",
            "6-Series",
            "7-Series",
            "8-Series",
            "X1",
            "X2",
            "X3",
            "X4",
            "X5",
            "X6",
            "X7",
            "XM",
            "Z3",
            "Z4",
            "i3",
            "i4",
            "i5",
            "i8",
            "iX",
            "iX1",
            "iX3",
        ],
        "Kia": [
            "Cerato",
            "Sportage",
            "Sorento",
            "Picanto",
            "Rio",
            "Ceed",
            "Optima",
            "Stinger",
            "Carnival",
            "Carens",
            "Venga",
            "Magentis",
            "Capital",
            "Clarus",
        ],
        "Hyundai": [
            "Elantra",
            "Sonata",
            "Tucson",
            "Santa Fe",
            "i10",
            "i20",
            "i30",
            "i40",
            "Accent",
            "Getz",
            "Genesis",
            "Grandeur",
            "Ioniq",
            "Coupe",
            "Matrix",
            "Trajet",
        ],
        "Volkswagen": [
            "Golf",
            "Passat",
            "Jetta",
            "Polo",
            "Tiguan",
            "Touareg",
            "Arteon",
            "Beetle",
            "Bora",
            "Scirocco",
            "Sharan",
            "Touran",
            "Phaeton",
            "EOS",
            "ID.3",
            "ID.7",
        ],
        "Nissan": [
            "Patrol",
            "X-Trail",
            "Sunny",
            "Sentra",
            "Qashqai",
            "Navara",
            "Altima",
            "Maxima",
            "Murano",
            "Pathfinder",
            "Kicks",
            "Frontier",
            "Armada",
            "Tiida",
            "370Z",
            "GT-R",
            "350Z",
            "Leaf",
            "Juke",
            "Rogue",
            "Versa",
            "Z",
            "Ariya",
            "Almera",
        ],
        "Honda": [
            "Civic",
            "Accord",
            "CR-V",
            "HR-V",
            "Jazz",
            "City",
            "Pilot",
            "Odyssey",
            "Legend",
            "Passport",
            "Ridgeline",
            "Civic Type R",
            "ZR-V",
            "Prologue",
        ],
        "Ford": [
            "F-150",
            "Ranger",
            "Explorer",
            "Mustang",
            "Focus",
            "Fusion",
            "Escape",
            "Fiesta",
            "Expedition",
            "Transit",
            "Bronco",
            "Taurus",
            "Territory",
            "Everest",
            "Maverick",
            "EcoSport",
            "Mustang Mach-E",
            "F-250",
            "F-350",
        ],
        "Chevrolet": [
            "Camaro",
            "Corvette",
            "Cruze",
            "Impala",
            "Aveo",
            "Caprice",
            "Spark",
            "Lacetti",
            "Kalos",
            "Epica",
            "Evanda",
            "Monte Carlo",
        ],
        "Mitsubishi": [
            "Lancer",
            "Galant",
            "Colt",
            "Attrage",
            "Space Star",
            "Lancer Evolution",
            "Eclipse",
            "Grandis",
            "Carisma",
            "Sigma",
            "3000GT",
        ],
        "Land Rover": [
            "Range Rover",
            "Range Rover Sport",
            "Range Rover Vogue",
            "Defender",
            "Discovery",
            "Freelander",
            "Evoque",
            "Velar",
            "LR2",
            "LR3",
            "LR4",
        ],
        "Jeep": [
            "Grand Cherokee",
            "Wrangler",
            "Cherokee",
            "Compass",
            "Commander",
            "Gladiator",
            "Renegade",
            "Wagoneer",
            "Grand Wagoneer",
        ],
        "Lexus": [
            "LX",
            "LS",
            "ES",
            "GS",
            "GX",
            "RX",
            "IS",
            "IS F",
            "RC",
            "RC F",
            "NX",
            "CT",
            "SC",
            "UX",
            "TX",
            "LC",
            "LFA",
        ],
        "Audi": [
            "A1",
            "A3",
            "A4",
            "A5",
            "A6",
            "A7",
            "A8",
            "S4",
            "S5",
            "S6",
            "S7",
            "S8",
            "Q2",
            "Q3",
            "Q5",
            "Q7",
            "Q8",
            "RS3",
            "RS5",
            "RS6",
            "RS7",
            "R8",
            "TT",
            "SQ5",
            "SQ8",
        ],
        "Porsche": [
            "911",
            "Cayenne",
            "Panamera",
            "Macan",
            "Boxster",
            "Cayman",
            "Taycan",
            "911 Turbo",
            "911 GT3",
        ],
        "Dodge": [
            "Charger",
            "Challenger",
            "Durango",
            "Ram",
            "Journey",
            "Viper",
            "Dart",
            "Nitro",
            "Dakota",
            "Hornet",
            "Magnum",
        ],
        "Cadillac": [
            "Escalade",
            "CTS",
            "CT4",
            "CT5",
            "CT6",
            "ATS",
            "XT5",
            "XT6",
            "SRX",
            "DTS",
            "STS",
            "XTS",
            "Lyriq",
            "Optiq",
        ],
        "GMC": [
            "Yukon",
            "Sierra",
            "Terrain",
            "Acadia",
            "Canyon",
            "Envoy",
            "Jimmy",
            "Savana",
            "Yukon XL",
            "Hummer EV",
        ],
        "Volvo": [
            "S40",
            "S60",
            "S80",
            "S90",
            "V40",
            "V50",
            "V60",
            "V70",
            "V90",
            "XC40",
            "XC60",
            "XC70",
            "XC90",
            "C30",
            "C70",
        ],
        "Tesla": ["Model 3", "Model S", "Model X", "Model Y", "Cybertruck"],
        "Maserati": [
            "Quattroporte",
            "Ghibli",
            "Levante",
            "GranTurismo",
            "GranCabrio",
            "Grecale",
        ],
        "Lamborghini": [
            "Urus",
            "Aventador",
            "Huracan",
            "Gallardo",
            "Murcielago",
            "Temerario",
        ],
        "Ferrari": [
            "F8 Tributo",
            "458",
            "488",
            "F430",
            "California",
            "Roma",
            "812 Superfast",
            "Portofino",
            "LaFerrari",
        ],
        "Rolls-Royce": [
            "Phantom",
            "Ghost",
            "Wraith",
            "Dawn",
            "Cullinan",
            "Silver Shadow",
            "Spectre",
        ],
        "Bentley": [
            "Continental GT",
            "Flying Spur",
            "Bentayga",
            "Mulsanne",
            "Arnage",
            "Azure",
        ],
        "Aston Martin": [
            "DB9",
            "DB11",
            "Vantage",
            "DBS",
            "Rapide",
            "DBX",
            "Vanquish",
        ],
        "McLaren": ["720S", "570S", "650S", "GT", "P1", "675LT"],
        "Bugatti": ["Chiron", "Veyron"],
        "Renault": [
            "Megane",
            "Clio",
            "Duster",
            "Koleos",
            "Symbol",
            "Logan",
            "Sandero",
            "Captur",
            "Fluence",
            "Talisman",
            "Arkana",
            "Zoe",
        ],
        "Peugeot": [
            "206",
            "207",
            "208",
            "301",
            "307",
            "308",
            "3008",
            "5008",
            "2008",
            "408",
            "607",
            "RCZ",
        ],
        "Citroen": ["C2", "C3", "C4", "C5", "C8", "DS3", "DS4", "DS5", "Saxo"],
        "Fiat": ["500", "Punto", "Bravo", "Linea", "Ducato", "Tipo", "Egea"],
        "Alfa Romeo": [
            "147",
            "156",
            "159",
            "166",
            "Giulia",
            "Giulietta",
            "Stelvio",
            "Mito",
            "Brera",
        ],
        "Seat": ["Leon", "Altea", "Toledo", "Cordoba", "Cupra Formentor"],
        "Skoda": ["Octavia", "Fabia", "Superb", "Kodiaq", "Yeti", "Rapid", "Roomster"],
        "Mazda": [
            "2",
            "3",
            "6",
            "CX-3",
            "CX-5",
            "CX-7",
            "CX-9",
            "CX-30",
            "CX-50",
            "MX-5",
            "BT-50",
            "323",
            "626",
            "MX-30",
        ],
        "Subaru": [
            "Impreza",
            "Forester",
            "Outback",
            "Legacy",
            "XV",
            "BRZ",
            "WRX",
            "Crosstrek",
        ],
        "Suzuki": [
            "Swift",
            "Vitara",
            "Jimny",
            "Baleno",
            "Ciaz",
            "Ertiga",
            "Grand Vitara",
            "SX4",
            "Alto",
            "Celerio",
        ],
        "Isuzu": ["D-Max", "MU-X", "Trooper", "Rodeo"],
        "Infiniti": [
            "Q50",
            "Q60",
            "Q70",
            "QX50",
            "QX56",
            "QX60",
            "QX70",
            "QX80",
            "G35",
            "G37",
        ],
        "Acura": ["MDX", "RDX", "TLX", "NSX", "Integra", "ILX"],
        "Genesis": ["G70", "G80", "G90", "GV60", "GV70", "GV80"],
        "Lincoln": ["Navigator", "Continental", "MKZ", "MKX", "Aviator", "Nautilus"],
        "Mercury": ["Mariner", "Grand Marquis", "Milan", "Mountaineer"],
        "Opel": [
            "Astra",
            "Corsa",
            "Meriva",
            "Zafira",
            "Insignia",
            "Mokka",
            "Vectra",
            "Antara",
            "Grandland X",
            "Omega",
        ],
        "Saab": ["9-5", "9-7X"],
        "Daewoo": [
            "Lanos",
            "Leganza",
            "Nubira",
            "Lacetti",
            "Espero",
            "Magnus",
            "Cielo",
            "Gentra",
            "Kalos",
            "Tosca",
        ],
        "Chery": [
            "Tiggo 2",
            "Tiggo 3",
            "Tiggo 4",
            "Tiggo 5",
            "Tiggo 7",
            "Tiggo 8",
            "Arrizo 3",
            "Arrizo 6",
            "Arrizo 7",
            "Arrizo 8",
        ],
        "Changan": ["Alsvin", "CS35", "CS75", "CS95", "Eado", "Hunter", "UNI-K", "UNI-T"],
        "Haval": ["H6", "H7", "H9", "JOLION", "DARGO", "H2"],
        "MG": ["3", "5", "6", "7", "ZS", "HS", "RX5", "RX8", "GT", "MG4 EV"],
        "BYD": ["Dolphin", "Han", "Seal", "F3"],
        "GAC": ["GS3", "GS4", "GS5", "GS7", "GS8", "Empow", "EMKOO", "Aion ES"],
        "JAC": ["JS3", "JS4", "JS6", "J4", "J5", "J6", "J7", "T8"],
        "Geely": ["Echo", "Emgrand", "Familia", "FC"],
        "Great Wall": ["Wingle", "Haval H5", "Hover"],
        "Brilliance": ["FSV", "H530", "V5", "FRV"],
        "BAIC": ["BJ40", "BJ80", "X25", "X35", "Senova"],
        "Dongfeng": ["AX7", "S30", "H30", "Aeolus"],
        "FAW": ["Besturn B30", "Besturn X40", "Besturn X80"],
        "Foton": ["Tunland", "View"],
        "Maxus": ["T60", "V80", "D60", "D90"],
        "Lifan": ["320", "520", "620", "X50", "X60"],
        "Saipa": ["Tiba", "131", "132", "141", "Saina"],
        "Iran Khodro": ["Samand", "Dena", "Soren", "Runna", "Tara"],
        "Hummer": ["H2", "H3"],
        "Jaguar": ["XE", "XF", "XJ", "F-Type", "S-Type", "X-Type", "XK8"],
        "Daihatsu": ["Charade", "Terios", "Sirion", "Feroza"],
        "SsangYong": ["Rexton", "Tivoli", "Korando", "Musso", "Torres"],
        "Mini": ["Cooper", "Clubman", "Countryman", "Paceman"],
        "Pontiac": ["Grand Am", "Grand Prix", "Torrent", "Montana", "Vibe"],
        "Buick": ["Encore", "Enclave", "Regal", "LaCrosse", "Electra"],
        "Oldsmobile": ["Delta 88", "Silhouette", "Cutlass"],
        "Scion": ["tC", "iQ"],
    },
    "veh_suv_pickup": {
        "Toyota": [
            "Land Cruiser",
            "Land Cruiser Prado",
            "4Runner",
            "Sequoia",
            "RAV4",
            "Highlander",
            "FJ Cruiser",
        ],
        "Land Rover": [
            "Range Rover",
            "Range Rover Sport",
            "Range Rover Vogue",
            "Defender",
            "Discovery",
            "Freelander",
            "Evoque",
            "Velar",
            "LR2",
            "LR3",
            "LR4",
        ],
        "Jeep": [
            "Grand Cherokee",
            "Wrangler",
            "Cherokee",
            "Compass",
            "Commander",
            "Gladiator",
            "Renegade",
            "Wagoneer",
            "Grand Wagoneer",
        ],
        "Lexus": ["LX", "GX", "RX"],
    },
    "veh_electric": {
        "Tesla": ["Model 3", "Model S", "Model X", "Model Y", "Cybertruck"],
        "BMW": ["i3", "i4", "i5", "iX", "iX1", "iX3"],
        "Audi": ["Q4 e-tron"],
        "Mercedes-Benz": ["EQE", "EQS"],
    },
    "veh_commercial": {
        "IVECO": ["Daily"],
        "Hino": ["300"],
        "King Long": ["King Long"],
        "Jinbei": ["Haise"],
    },
}


def branch_prefix(parent_slug: str) -> str:
    return {
        "veh_automobile": "veh_auto",
        "veh_suv_pickup": "veh_suv",
        "veh_electric": "veh_ev",
        "veh_commercial": "veh_comm",
    }[parent_slug]


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def generate_seed_calls() -> list[str]:
    lines: list[str] = []
    seen_slugs: set[str] = set()

    for parent_slug, brands in AUTOMOBILE_TREE.items():
        prefix = branch_prefix(parent_slug)
        brand_order = 0
        for brand_name, models in brands.items():
            brand_order += 1
            brand_slug_part = slugify(brand_name)
            brand_slug = f"{prefix}_br_{brand_slug_part}"
            if brand_slug in seen_slugs:
                raise ValueError(f"duplicate slug: {brand_slug}")
            seen_slugs.add(brand_slug)
            lines.append(
                f"SELECT public._seed_car_node('{brand_slug}', "
                f"'{sql_escape(brand_name)}', '{parent_slug}', 'brand', {brand_order});"
            )
            model_order = 0
            for model_name in models:
                model_order += 1
                model_slug_part = slugify(model_name)
                model_slug = f"{brand_slug}_{model_slug_part}"
                if model_slug in seen_slugs:
                    raise ValueError(f"duplicate slug: {model_slug}")
                seen_slugs.add(model_slug)
                lines.append(
                    f"SELECT public._seed_car_node('{model_slug}', "
                    f"'{sql_escape(model_name)}', '{brand_slug}', 'model', {model_order});"
                )
    return lines


def main() -> None:
    seed_lines = generate_seed_calls()
    header = """-- سيارات — brands and models (Arabic display where applicable, Latin brand/model names)
-- Safe to re-run: ON CONFLICT (slug) upserts; replaces veh_automobile / suv / ev / commercial subtrees.

CREATE OR REPLACE FUNCTION public._seed_car_node(
  p_slug TEXT,
  p_name_ar TEXT,
  p_parent_slug TEXT,
  p_icon TEXT DEFAULT 'category',
  p_display_order INT DEFAULT 0
) RETURNS VOID AS $$
DECLARE
  v_parent_id INT;
BEGIN
  SELECT id INTO v_parent_id FROM public.categories WHERE slug = p_parent_slug;
  IF v_parent_id IS NULL THEN
    RAISE EXCEPTION 'Parent category not found: %', p_parent_slug;
  END IF;

  INSERT INTO public.categories (slug, name_ar, name_ku, name_en, icon, parent_id, display_order)
  VALUES (p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id, p_display_order)
  ON CONFLICT (slug) DO UPDATE SET
    name_ar = EXCLUDED.name_ar,
    name_ku = NULL,
    name_en = NULL,
    icon = EXCLUDED.icon,
    parent_id = EXCLUDED.parent_id,
    display_order = EXCLUDED.display_order;
END;
$$ LANGUAGE plpgsql;

-- Clear existing subtrees (sale types + any prior brand/model rows)
DELETE FROM public.categories
WHERE id IN (
  WITH RECURSIVE targets AS (
    SELECT unnest(ARRAY[
      'veh_automobile', 'veh_suv_pickup', 'veh_electric', 'veh_commercial'
    ]) AS slug
  ),
  roots AS (
    SELECT c.id FROM public.categories c
    INNER JOIN targets t ON c.slug = t.slug
  ),
  subtree AS (
    SELECT c.id FROM public.categories c
    INNER JOIN roots r ON c.parent_id = r.id
    UNION ALL
    SELECT c.id FROM public.categories c
    INNER JOIN subtree s ON c.parent_id = s.id
  )
  SELECT id FROM subtree
);

"""
    footer = "\nDROP FUNCTION public._seed_car_node(TEXT, TEXT, TEXT, TEXT, INT);\n"
    body = "\n".join(seed_lines)
    OUT.write_text(header + body + footer, encoding="utf-8")
    print(f"Wrote {OUT} ({len(seed_lines)} seed statements)")


if __name__ == "__main__":
    main()
