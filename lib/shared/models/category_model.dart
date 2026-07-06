class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.slug,
    required this.nameAr,
    this.nameKu,
    this.nameEn,
    this.nameTr,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionKu,
    this.descriptionTr,
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
  final String? nameTr;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionKu;
  final String? descriptionTr;
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

  static bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  static String? _localizedColumn(String? value, String localeCode) {
    if (value == null || value.isEmpty) return null;
    if (localeCode != 'ar' && localeCode != 'ku' && _containsArabic(value)) {
      return null;
    }
    return value;
  }

  String displayName(String locale) {
    final code = normalizeAppLocaleCode(locale);
    return switch (code) {
      'ku' =>
        _localizedColumn(nameKu, code) ??
            _localizedColumn(nameEn, code) ??
            _localizedColumn(nameTr, code) ??
            slug.replaceAll('_', ' '),
      'en' =>
        _localizedColumn(nameEn, code) ?? slug.replaceAll('_', ' '),
      'tr' =>
        _localizedColumn(nameTr, code) ??
            _localizedColumn(nameEn, code) ??
            slug.replaceAll('_', ' '),
      _ => nameAr,
    };
  }

  String displayDescription(String locale) {
    final code = normalizeAppLocaleCode(locale);
    return switch (code) {
      'ku' =>
        _localizedColumn(descriptionKu, code) ??
            _localizedColumn(descriptionEn, code) ??
            '',
      'en' => _localizedColumn(descriptionEn, code) ?? '',
      'tr' => _localizedColumn(descriptionTr, code) ?? '',
      _ => descriptionAr ?? '',
    };
  }

  static String normalizeAppLocaleCode(String locale) {
    switch (locale) {
      case 'en':
        return 'en';
      case 'ku':
      case 'ckb':
        return 'ku';
      case 'tr':
        return 'tr';
      default:
        return 'ar';
    }
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
      nameTr: json['name_tr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionKu: json['description_ku'] as String?,
      descriptionTr: json['description_tr'] as String?,
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
      'name_tr': nameTr,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'description_ku': descriptionKu,
      'description_tr': descriptionTr,
      'icon': icon,
      'parent_id': parentId,
      'display_order': displayOrder,
      'color_hex': colorHex,
      'logo_url': logoUrl,
    };
  }
}
