class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.slug,
    required this.nameAr,
    this.nameKu,
    this.nameEn,
    required this.icon,
    this.parentId,
    this.displayOrder = 0,
    this.colorHex,
    this.logoUrl,
  });

  final int id;
  final String slug;
  final String nameAr;
  final String? nameKu;
  final String? nameEn;
  final String icon;
  final int? parentId;
  final int displayOrder;
  final String? colorHex;
  final String? logoUrl;

  bool get isParent => parentId == null;

  bool get isEmojiIcon {
    const materialIcons = {
      'home',
      'directions_car',
      'devices',
      'work',
      'handyman',
      'category',
      'brand',
      'model',
    };
    return !materialIcons.contains(icon);
  }

  String displayName(String locale) {
    return switch (locale) {
      'ku' when nameKu != null && nameKu!.isNotEmpty => nameKu!,
      'en' when nameEn != null && nameEn!.isNotEmpty => nameEn!,
      _ => nameAr,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final displayOrder = json['display_order'] as int?;
    final sortOrder = json['sort_order'] as int?;
    return CategoryModel(
      id: json['id'] as int,
      slug: json['slug'] as String,
      nameAr: json['name_ar'] as String,
      nameKu: json['name_ku'] as String?,
      nameEn: json['name_en'] as String?,
      icon: json['icon'] as String? ?? 'category',
      parentId: json['parent_id'] as int?,
      displayOrder: displayOrder ?? sortOrder ?? 0,
      colorHex: json['color_hex'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name_ar': nameAr,
      'name_ku': nameKu,
      'name_en': nameEn,
      'icon': icon,
      'parent_id': parentId,
      'display_order': displayOrder,
      'color_hex': colorHex,
      'logo_url': logoUrl,
    };
  }
}
