class Governorate {
  const Governorate({
    required this.slug,
    required this.nameAr,
    this.nameEn,
    this.nameKu,
  });

  final String slug;
  final String nameAr;
  final String? nameEn;
  final String? nameKu;

  String displayName(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr;
      case 'ku':
        if (nameKu != null && nameKu!.isNotEmpty) return nameKu!;
        return nameEn ?? nameAr;
      default:
        return nameEn ?? nameAr;
    }
  }
}

/// 18 Iraqi governorates with AR / EN / KU names (Turkish uses EN fallback).
const iraqiGovernorates = [
  Governorate(slug: 'baghdad',      nameAr: 'بغداد',        nameEn: 'Baghdad',       nameKu: 'بەغدا'),
  Governorate(slug: 'basra',        nameAr: 'البصرة',       nameEn: 'Basra',         nameKu: 'بەسرە'),
  Governorate(slug: 'nineveh',      nameAr: 'نينوى',        nameEn: 'Nineveh',       nameKu: 'نەینەوا'),
  Governorate(slug: 'erbil',        nameAr: 'أربيل',        nameEn: 'Erbil',         nameKu: 'هەولێر'),
  Governorate(slug: 'sulaymaniyah', nameAr: 'السليمانية',   nameEn: 'Sulaymaniyah',  nameKu: 'سلێمانی'),
  Governorate(slug: 'duhok',        nameAr: 'دهوك',         nameEn: 'Duhok',         nameKu: 'دهۆک'),
  Governorate(slug: 'kirkuk',       nameAr: 'كركوك',        nameEn: 'Kirkuk',        nameKu: 'کەرکوک'),
  Governorate(slug: 'anbar',        nameAr: 'الأنبار',      nameEn: 'Anbar',         nameKu: 'ئەنبار'),
  Governorate(slug: 'babil',        nameAr: 'بابل',         nameEn: 'Babil',         nameKu: 'بابل'),
  Governorate(slug: 'diyala',       nameAr: 'ديالى',        nameEn: 'Diyala',        nameKu: 'دیالە'),
  Governorate(slug: 'karbala',      nameAr: 'كربلاء',       nameEn: 'Karbala',       nameKu: 'کەربەلا'),
  Governorate(slug: 'najaf',        nameAr: 'النجف',        nameEn: 'Najaf',         nameKu: 'نجف'),
  Governorate(slug: 'wasit',        nameAr: 'واسط',         nameEn: 'Wasit',         nameKu: 'واسط'),
  Governorate(slug: 'maysan',       nameAr: 'ميسان',        nameEn: 'Maysan',        nameKu: 'میسان'),
  Governorate(slug: 'dhi_qar',      nameAr: 'ذي قار',       nameEn: 'Dhi Qar',       nameKu: 'ذی قار'),
  Governorate(slug: 'muthanna',     nameAr: 'المثنى',       nameEn: 'Muthanna',      nameKu: 'المثنى'),
  Governorate(slug: 'qadisiyyah',   nameAr: 'القادسية',     nameEn: 'Qadisiyyah',    nameKu: 'قادسیە'),
  Governorate(slug: 'saladin',      nameAr: 'صلاح الدين',   nameEn: 'Saladin',       nameKu: 'سەلاحەددین'),
];

Governorate? governorateBySlug(String slug) {
  for (final g in iraqiGovernorates) {
    if (g.slug == slug) return g;
  }
  return null;
}

String governorateNameAr(String slug) =>
    governorateBySlug(slug)?.nameAr ?? slug;

String governorateDisplayName(String slug, String localeCode) =>
    governorateBySlug(slug)?.displayName(localeCode) ?? slug;
