import 'package:flutter/material.dart';

import '../../shared/models/category_model.dart';

/// Sahibinden-style browse rows — visual config keyed by category slug.
class BrowseCategoryStyle {
  const BrowseCategoryStyle({
    required this.slug,
    required this.nameAr,
    required this.fallbackSubtitle,
    required this.color,
    required this.icon,
    this.fallbackOrder = 99,
  });

  final String slug;
  final String nameAr;
  final String fallbackSubtitle;
  final Color color;
  final IconData icon;
  /// Used when the slug is not yet in Supabase.
  final int fallbackOrder;
}

const browseCategoryStyles = [
  BrowseCategoryStyle(
    slug: 'real_estate',
    nameAr: 'العقارات',
    fallbackSubtitle: 'سكني ، أراضي ، محلات تجارية...',
    color: Color(0xFFFF9800),
    icon: Icons.home_rounded,
    fallbackOrder: 1,
  ),
  BrowseCategoryStyle(
    slug: 'cars',
    nameAr: 'المركبات',
    fallbackSubtitle: 'سيارات ، سيارات للإيجار ، سيارات كهربائية ، دراجات...',
    color: Color(0xFFE53935),
    icon: Icons.directions_car_rounded,
    fallbackOrder: 2,
  ),
  BrowseCategoryStyle(
    slug: 'electronics',
    nameAr: 'الإلكترونيات',
    fallbackSubtitle: 'جوالات ، لابتوب ، تلفزيونات...',
    color: Color(0xFF00897B),
    icon: Icons.smartphone_rounded,
    fallbackOrder: 3,
  ),
  BrowseCategoryStyle(
    slug: 'buy_sell',
    nameAr: 'سوق المستعمل والجديد',
    fallbackSubtitle: 'موبايلات ، كمبيوتر ، ملابس ، أثاث...',
    color: Color(0xFF8E24AA),
    icon: Icons.shopping_bag_rounded,
    fallbackOrder: 4,
  ),
  BrowseCategoryStyle(
    slug: 'industry',
    nameAr: 'الآلات والصناعة',
    fallbackSubtitle: 'معدات ، زراعة ، طاقة...',
    color: Color(0xFF1A237E),
    icon: Icons.precision_manufacturing_rounded,
    fallbackOrder: 5,
  ),
  BrowseCategoryStyle(
    slug: 'services',
    nameAr: 'الخدمات والحرف',
    fallbackSubtitle: 'صيانة ، نقل ، تصميم...',
    color: Color(0xFF1E88E5),
    icon: Icons.handyman_rounded,
    fallbackOrder: 6,
  ),
  BrowseCategoryStyle(
    slug: 'tutoring',
    nameAr: 'دروس خصوصية',
    fallbackSubtitle: 'رياضيات ، لغات ، جامعي...',
    color: Color(0xFF43A047),
    icon: Icons.menu_book_rounded,
    fallbackOrder: 7,
  ),
  BrowseCategoryStyle(
    slug: 'jobs',
    nameAr: 'فرص العمل',
    fallbackSubtitle: 'محاماة ، تعليم ، تقنية...',
    color: Color(0xFF7CB342),
    icon: Icons.work_rounded,
    fallbackOrder: 8,
  ),
  BrowseCategoryStyle(
    slug: 'pets',
    nameAr: 'الحيوانات',
    fallbackSubtitle: 'حيوانات أليفة ، أعلاف...',
    color: Color(0xFF00ACC1),
    icon: Icons.pets_rounded,
    fallbackOrder: 9,
  ),
  BrowseCategoryStyle(
    slug: 'home_help',
    nameAr: 'مساعدة منزلية',
    fallbackSubtitle: 'مربيات ، تنظيف ، طباخين...',
    color: Color(0xFFFB8C00),
    icon: Icons.child_care_rounded,
    fallbackOrder: 10,
  ),
];

class BrowseCategoryItem {
  const BrowseCategoryItem({
    required this.style,
    required this.subtitle,
    this.categoryId,
  });

  final BrowseCategoryStyle style;
  final String subtitle;
  final int? categoryId;
}

int _browseDisplayOrder(
  BrowseCategoryStyle style,
  Map<String, CategoryModel> bySlug,
) {
  final direct = bySlug[style.slug];
  if (direct != null) return direct.displayOrder;
  return style.fallbackOrder;
}

/// Merges static browse styles with live Supabase categories (slug match).
List<BrowseCategoryItem> buildBrowseCategoryItems(List<CategoryModel> all) {
  final bySlug = {for (final c in all) c.slug: c};
  final childrenByParent = <int, List<CategoryModel>>{};
  for (final c in all.where((c) => c.parentId != null)) {
    childrenByParent.putIfAbsent(c.parentId!, () => []).add(c);
  }
  for (final entry in childrenByParent.entries) {
    entry.value.sort((a, b) {
      final order = a.displayOrder.compareTo(b.displayOrder);
      if (order != 0) return order;
      return a.id.compareTo(b.id);
    });
  }

  String subtitleFor(BrowseCategoryStyle style, CategoryModel? parent) {
    if (parent != null) {
      final subs = childrenByParent[parent.id] ?? [];
      if (subs.isNotEmpty) {
        return subs.take(4).map((c) => c.nameAr).join(' ، ');
      }
    }
    return style.fallbackSubtitle;
  }

  final items = browseCategoryStyles.map((style) {
    final parent = bySlug[style.slug];
    return BrowseCategoryItem(
      style: style,
      subtitle: subtitleFor(style, parent),
      categoryId: parent?.id,
    );
  }).toList();

  items.sort((a, b) {
    final order = _browseDisplayOrder(a.style, bySlug)
        .compareTo(_browseDisplayOrder(b.style, bySlug));
    if (order != 0) return order;
    return a.style.slug.compareTo(b.style.slug);
  });

  return items;
}
