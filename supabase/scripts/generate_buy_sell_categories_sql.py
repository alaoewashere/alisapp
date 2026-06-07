#!/usr/bin/env python3
"""Generate سوق المستعمل والجديد (buy_sell) — subcategory → listing type (2-level tree)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260630000000_buy_sell_marketplace_categories.sql"

ROOT_SLUG = "buy_sell"
PREFIX = "souq"

ITEM_SLUG_OVERRIDES: dict[str, str] = {
    "Xbox Series X/S": "xbox_series_x_s",
    "VR هيدسيت": "vr_headset",
    "أخرى": "other",
}

# type_key → (name_ar, color_hex, [items])
SOUQ_TREE: dict[str, tuple[str, str, list[str]]] = {
    "mobile": ("موبايلات وإكسسوارات", "#1A1A1A", [
        "هواتف ذكية", "آيفون", "سامسونج", "هواوي", "شاومي وريدمي", "أوبو وفيفو",
        "هواتف عادية", "شواحن وكيبلات", "باور بانك", "كفرات وحماية", "سماعات بلوتوث",
        "ساعات ذكية", "قطع غيار هواتف", "بطاريات هواتف",
    ]),
    "computer": ("كمبيوتر ولابتوب", "#003478", [
        "لابتوب", "لابتوب ماك", "كمبيوتر مكتبي", "شاشات كمبيوتر", "كيبورد وماوس",
        "طابعات وسكانر", "هارد ديسك", "رام وقطع داخلية", "كرت شاشة GPU", "راوتر وشبكات",
        "UPS وبطاريات", "فلاشات وميموري",
    ]),
    "tv_audio": ("تلفزيونات وصوتيات", "#1A1A1A", [
        "تلفزيون سمارت", "تلفزيون OLED", "تلفزيون QLED", "تلفزيون عادي",
        "ريسيفر وستلايت", "مسرح منزلي", "مكبر صوت", "سماعات منزلية",
        "بروجيكتور", "ريموت وإكسسوار",
    ]),
    "appliances": ("أجهزة منزلية كهربائية", "#CC0000", [
        "غسالة ملابس", "غسالة صحون", "ثلاجة", "فريزر", "مكيف سبليت", "مكيف شباك",
        "مكيف محمول", "مروحة", "مدفأة كهربائية", "مكنسة كهربائية", "كوي ملابس", "ستيريلايزر",
    ]),
    "kitchen": ("أجهزة مطبخ", "#CC0000", [
        "غاز طبخ", "فرن كهربائي", "ميكروويف", "قلاية هوائية", "خلاط وعصارة",
        "شاور قهوة وشاي", "ساندويتش وتوستر", "طنجرة ضغط كهربائية", "خبازة", "أواني وإكسسوار مطبخ",
    ]),
    "gaming": ("ألعاب فيديو وترفيه", "#107C10", [
        "بلايستيشن 5", "بلايستيشن 4", "Xbox Series X/S", "Nintendo Switch",
        "ألعاب CD وكروت", "جوي ستيك وإكسسوار", "VR هيدسيت", "ألعاب أطفال إلكترونية",
    ]),
    "fashion": ("ملابس وأزياء", "#8B4513", [
        "ملابس رجالية", "ملابس نسائية", "ملابس أطفال", "عباءات ودشاديش",
        "أحذية رجالية", "أحذية نسائية", "أحذية أطفال", "حقائب يد",
        "حقائب سفر وشنط", "ساعات يد", "نظارات", "إكسسوارات أزياء",
    ]),
    "beauty": ("صحة وجمال", "#FF69B4", [
        "عطور رجالية", "عطور نسائية", "مستحضرات عناية بالبشرة", "مكياج وتجميل",
        "أجهزة تجميل", "أجهزة قياس صحية", "فيتامينات ومكملات", "كراسي تدليك",
        "نظارات طبية", "أدوات حلاقة",
    ]),
    "furniture": ("أثاث ومفروشات", "#8B4513", [
        "غرفة نوم", "صالة وجلوسية", "سفرة وطاولات أكل", "مكتب ودراسة",
        "ستائر وسجاد", "مطبخ وخزائن", "إضاءة وثريات", "ديكور ولوحات",
        "بياضات وفرش", "أدوات منزلية متنوعة",
    ]),
    "sports": ("رياضة ولياقة", "#006400", [
        "أجهزة رياضية منزلية", "مشاية ودراجة ثابتة", "أوزان ودمبل", "ملابس رياضية",
        "أحذية رياضية", "كرة قدم ومستلزماتها", "كرة سلة وطائرة", "سباحة وغوص",
        "دراجات هوائية", "ملاكمة وفنون قتالية", "تخييم وأنشطة خارجية", "صيد سمك",
    ]),
    "baby": ("أطفال وأمومة", "#FF69B4", [
        "عربات أطفال", "كراسي سيارة للأطفال", "سرير أطفال", "ملابس أطفال ورضّع",
        "ألعاب أطفال", "أدوات تغذية", "أجهزة مراقبة الطفل", "حليب وأغذية رضع",
        "حقائب ومستلزمات مدرسية", "دراجات ومركبات أطفال",
    ]),
    "books": ("كتب ومجلات وتعليم", "#003478", [
        "كتب عربية", "كتب إنجليزية", "كتب دراسية ومناهج", "كتب دينية",
        "روايات وقصص", "مجلات وجرائد", "قرطاسية ومستلزمات مكتبية", "أدوات رسم وفنون",
    ]),
    "music": ("موسيقى وآلات موسيقية", "#8B0000", [
        "غيتار", "عود وقانون", "بيانو وأورغ", "طبلة وإيقاع",
        "مكسر صوت DJ", "ميكروفون وتسجيل", "نايات وآلات نفخ", "جهاز كاريوكي",
    ]),
    "hobbies": ("هوايات وتحف ومقتنيات", "#8B4513", [
        "تحف وأنتيكات", "طوابع وعملات قديمة", "لوحات فنية", "ألعاب لوحية وورق",
        "نماذج وموديلات", "دورن ومسيّرات", "مجسمات وتماثيل", "مقتنيات رياضية",
    ]),
    "jewelry": ("مجوهرات وذهب وفضة", "#FFD700", [
        "ذهب عيار 21", "ذهب عيار 18", "فضة", "ألماس وأحجار كريمة",
        "خواتم وأساور", "قلائد وأطواق", "ساعات فاخرة", "مسابح",
    ]),
    "building": ("بناء ومواد إنشائية", "#808080", [
        "حديد وصلب", "أسمنت وبلوك", "طابوق وحجر", "بلاط وسيراميك",
        "دهانات وورق جدران", "أبواب ونوافذ", "سباكة وصحية", "كهرباء وإنارة",
        "أدوات يدوية وكهربائية", "مولدات وطاقة شمسية",
    ]),
    "garden": ("حدائق وزراعة", "#006400", [
        "نباتات وأشجار", "بذور وأسمدة", "أدوات حدائق", "مضخات مياه",
        "نباتات صناعية وديكور", "أصص وتربة", "نوافير حدائق",
    ]),
    "food": ("طعام ومشروبات", "#CC0000", [
        "تمور وحلويات عراقية", "عسل طبيعي", "زيت زيتون وزيوت", "منتجات ألبان",
        "مربى ومعلبات", "مشروبات طاقة ومياه", "بهارات وأعشاب", "أطعمة عضوية",
    ]),
    "misc": ("متفرقات وأخرى", "#808080", [
        "هدايا ومناسبات", "مستلزمات دينية", "أدوات مكتبية", "حقائب سفر",
        "مستلزمات تصوير", "معدات تصوير احترافي", "بضاعة جملة", "أخرى",
    ]),
}


def slugify_ascii(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("+", "_plus")
    text = text.replace("/", "_")
    text = text.replace("&", "and")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def item_slug(name: str, order: int) -> str:
    if name in ITEM_SLUG_OVERRIDES:
        return ITEM_SLUG_OVERRIDES[name]
    slug = slugify_ascii(name)
    if slug:
        return slug
    return f"item_{order:02d}"


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def main() -> None:
    lines: list[str] = [
        "-- سوق المستعمل والجديد (buy_sell) — rename + 19 subcategories → items",
        "-- Safe to re-run: cleans buy_sell subtree then upserts by slug.",
        "",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS color_hex TEXT;",
        "ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS sort_order INT NOT NULL DEFAULT 0;",
        "",
        "UPDATE public.categories",
        "SET name_ar = 'سوق المستعمل والجديد'",
        f"WHERE slug = '{ROOT_SLUG}';",
        "",
        "CREATE OR REPLACE FUNCTION public._seed_souq_node(",
        "  p_slug TEXT,",
        "  p_name_ar TEXT,",
        "  p_parent_slug TEXT,",
        "  p_icon TEXT DEFAULT 'category',",
        "  p_display_order INT DEFAULT 0,",
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
        "    slug, name_ar, name_ku, name_en, icon, parent_id, display_order, sort_order, color_hex",
        "  )",
        "  VALUES (",
        "    p_slug, p_name_ar, NULL, NULL, p_icon, v_parent_id,",
        "    p_display_order, p_display_order, p_color_hex",
        "  )",
        "  ON CONFLICT (slug) DO UPDATE SET",
        "    name_ar = EXCLUDED.name_ar,",
        "    name_ku = NULL,",
        "    name_en = NULL,",
        "    icon = EXCLUDED.icon,",
        "    parent_id = EXCLUDED.parent_id,",
        "    display_order = EXCLUDED.display_order,",
        "    sort_order = EXCLUDED.sort_order,",
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
    sub_count = 0
    item_count = 0

    for order, (type_key, (type_name, color, items)) in enumerate(SOUQ_TREE.items(), start=1):
        sub_count += 1
        type_slug = f"{PREFIX}_{type_key}"
        if type_slug in seen:
            raise ValueError(f"duplicate slug: {type_slug}")
        seen.add(type_slug)
        lines.append(
            f"SELECT public._seed_souq_node('{type_slug}', '{sql_escape(type_name)}', "
            f"'{ROOT_SLUG}', 'category', {order}, '{color}');"
        )
        for item_order, item in enumerate(items, start=1):
            item_count += 1
            item_slug_val = f"{type_slug}_{item_slug(item, item_order)}"
            if item_slug_val in seen:
                raise ValueError(f"duplicate slug: {item_slug_val} from {item!r}")
            seen.add(item_slug_val)
            lines.append(
                f"SELECT public._seed_souq_node('{item_slug_val}', '{sql_escape(item)}', "
                f"'{type_slug}', 'model', {item_order}, NULL);"
            )

    lines.extend([
        "",
        "DROP FUNCTION public._seed_souq_node(TEXT, TEXT, TEXT, TEXT, INT, TEXT);",
        "",
    ])

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT.name}: {sub_count} subcategories, {item_count} items, {len(lines)} lines")


if __name__ == "__main__":
    main()
