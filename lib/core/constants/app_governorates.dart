class Governorate {
  const Governorate({
    required this.slug,
    required this.nameAr,
    this.nameEn,
  });

  final String slug;
  final String nameAr;
  final String? nameEn;
}

/// 18 Iraqi governorates
const iraqiGovernorates = [
  Governorate(slug: 'baghdad', nameAr: 'بغداد', nameEn: 'Baghdad'),
  Governorate(slug: 'basra', nameAr: 'البصرة', nameEn: 'Basra'),
  Governorate(slug: 'nineveh', nameAr: 'نينوى', nameEn: 'Nineveh'),
  Governorate(slug: 'erbil', nameAr: 'أربيل', nameEn: 'Erbil'),
  Governorate(slug: 'sulaymaniyah', nameAr: 'السليمانية', nameEn: 'Sulaymaniyah'),
  Governorate(slug: 'duhok', nameAr: 'دهوك', nameEn: 'Duhok'),
  Governorate(slug: 'kirkuk', nameAr: 'كركوك', nameEn: 'Kirkuk'),
  Governorate(slug: 'anbar', nameAr: 'الأنبار', nameEn: 'Anbar'),
  Governorate(slug: 'babil', nameAr: 'بابل', nameEn: 'Babil'),
  Governorate(slug: 'diyala', nameAr: 'ديالى', nameEn: 'Diyala'),
  Governorate(slug: 'karbala', nameAr: 'كربلاء', nameEn: 'Karbala'),
  Governorate(slug: 'najaf', nameAr: 'النجف', nameEn: 'Najaf'),
  Governorate(slug: 'wasit', nameAr: 'واسط', nameEn: 'Wasit'),
  Governorate(slug: 'maysan', nameAr: 'ميسان', nameEn: 'Maysan'),
  Governorate(slug: 'dhi_qar', nameAr: 'ذي قار', nameEn: 'Dhi Qar'),
  Governorate(slug: 'muthanna', nameAr: 'المثنى', nameEn: 'Muthanna'),
  Governorate(slug: 'qadisiyyah', nameAr: 'القادسية', nameEn: 'Qadisiyyah'),
  Governorate(slug: 'saladin', nameAr: 'صلاح الدين', nameEn: 'Saladin'),
];

Governorate? governorateBySlug(String slug) {
  for (final g in iraqiGovernorates) {
    if (g.slug == slug) return g;
  }
  return null;
}

String governorateNameAr(String slug) =>
    governorateBySlug(slug)?.nameAr ?? slug;
