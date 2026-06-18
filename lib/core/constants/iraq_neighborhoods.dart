import 'dart:math' as math;

/// Canonical Iraqi neighborhood/area centers for heat-map plotting and area_name.
class IraqNeighborhood {
  const IraqNeighborhood({
    required this.slug,
    required this.nameAr,
    required this.governorateSlug,
    required this.latitude,
    required this.longitude,
    this.displayOrder = 0,
  });

  final String slug;
  final String nameAr;
  final String governorateSlug;
  final double latitude;
  final double longitude;
  final int displayOrder;
}

/// Static neighborhood list — mirrors `public.listing_area_centers` seed data.
const iraqNeighborhoods = <IraqNeighborhood>[
  IraqNeighborhood(
    slug: 'baghdad_karrada',
    nameAr: 'الكرادة',
    governorateSlug: 'baghdad',
    latitude: 33.3152,
    longitude: 44.4560,
    displayOrder: 1,
  ),
  IraqNeighborhood(
    slug: 'baghdad_mansour',
    nameAr: 'المنصور',
    governorateSlug: 'baghdad',
    latitude: 33.3128,
    longitude: 44.3375,
    displayOrder: 2,
  ),
  IraqNeighborhood(
    slug: 'baghdad_jadriya',
    nameAr: 'الجادرية',
    governorateSlug: 'baghdad',
    latitude: 33.2778,
    longitude: 44.4000,
    displayOrder: 3,
  ),
  IraqNeighborhood(
    slug: 'baghdad_zayona',
    nameAr: 'زيونة',
    governorateSlug: 'baghdad',
    latitude: 33.3050,
    longitude: 44.4450,
    displayOrder: 4,
  ),
  IraqNeighborhood(
    slug: 'baghdad_dora',
    nameAr: 'الدورة',
    governorateSlug: 'baghdad',
    latitude: 33.2380,
    longitude: 44.3850,
    displayOrder: 5,
  ),
  IraqNeighborhood(
    slug: 'baghdad_kadhimiya',
    nameAr: 'الكاظمية',
    governorateSlug: 'baghdad',
    latitude: 33.3808,
    longitude: 44.3403,
    displayOrder: 6,
  ),
  IraqNeighborhood(
    slug: 'baghdad_adhamiya',
    nameAr: 'الأعظمية',
    governorateSlug: 'baghdad',
    latitude: 33.3614,
    longitude: 44.3842,
    displayOrder: 7,
  ),
  IraqNeighborhood(
    slug: 'baghdad_sadr_city',
    nameAr: 'مدينة الصدر',
    governorateSlug: 'baghdad',
    latitude: 33.3667,
    longitude: 44.4167,
    displayOrder: 8,
  ),
  IraqNeighborhood(
    slug: 'baghdad_shuala',
    nameAr: 'الشعلة',
    governorateSlug: 'baghdad',
    latitude: 33.3950,
    longitude: 44.3600,
    displayOrder: 9,
  ),
  IraqNeighborhood(
    slug: 'baghdad_hurriya',
    nameAr: 'الحرية',
    governorateSlug: 'baghdad',
    latitude: 33.3300,
    longitude: 44.4200,
    displayOrder: 10,
  ),
  IraqNeighborhood(
    slug: 'baghdad_ghazaliya',
    nameAr: 'الغزالية',
    governorateSlug: 'baghdad',
    latitude: 33.3150,
    longitude: 44.2800,
    displayOrder: 11,
  ),
  IraqNeighborhood(
    slug: 'baghdad_rusafa',
    nameAr: 'الرصافة',
    governorateSlug: 'baghdad',
    latitude: 33.3400,
    longitude: 44.4100,
    displayOrder: 12,
  ),
  IraqNeighborhood(
    slug: 'baghdad_karkh',
    nameAr: 'الكرخ',
    governorateSlug: 'baghdad',
    latitude: 33.3200,
    longitude: 44.3700,
    displayOrder: 13,
  ),
  IraqNeighborhood(
    slug: 'baghdad_bab_al_muadham',
    nameAr: 'باب المعظم',
    governorateSlug: 'baghdad',
    latitude: 33.3520,
    longitude: 44.3920,
    displayOrder: 14,
  ),
  IraqNeighborhood(
    slug: 'baghdad_amriya',
    nameAr: 'العامرية',
    governorateSlug: 'baghdad',
    latitude: 33.2680,
    longitude: 44.3180,
    displayOrder: 15,
  ),
  IraqNeighborhood(
    slug: 'baghdad_yarmouk',
    nameAr: 'اليرموك',
    governorateSlug: 'baghdad',
    latitude: 33.2980,
    longitude: 44.3580,
    displayOrder: 16,
  ),
  IraqNeighborhood(
    slug: 'baghdad_bayaa',
    nameAr: 'البياع',
    governorateSlug: 'baghdad',
    latitude: 33.2550,
    longitude: 44.3680,
    displayOrder: 17,
  ),
  IraqNeighborhood(
    slug: 'baghdad_shaab',
    nameAr: 'الشعب',
    governorateSlug: 'baghdad',
    latitude: 33.3780,
    longitude: 44.4320,
    displayOrder: 18,
  ),
  IraqNeighborhood(
    slug: 'basra_ashar',
    nameAr: 'العشار',
    governorateSlug: 'basra',
    latitude: 30.5085,
    longitude: 47.7804,
    displayOrder: 30,
  ),
  IraqNeighborhood(
    slug: 'basra_jumhuriya',
    nameAr: 'الجمهورية',
    governorateSlug: 'basra',
    latitude: 30.5250,
    longitude: 47.8150,
    displayOrder: 31,
  ),
  IraqNeighborhood(
    slug: 'basra_zubair',
    nameAr: 'الزبير',
    governorateSlug: 'basra',
    latitude: 30.3890,
    longitude: 47.7080,
    displayOrder: 32,
  ),
  IraqNeighborhood(
    slug: 'basra_tanuma',
    nameAr: 'التنومة',
    governorateSlug: 'basra',
    latitude: 30.5450,
    longitude: 47.8350,
    displayOrder: 33,
  ),
  IraqNeighborhood(
    slug: 'erbil_center',
    nameAr: 'مركز أربيل',
    governorateSlug: 'erbil',
    latitude: 36.1911,
    longitude: 44.0092,
    displayOrder: 40,
  ),
  IraqNeighborhood(
    slug: 'erbil_ankawa',
    nameAr: 'عنكاوا',
    governorateSlug: 'erbil',
    latitude: 36.2380,
    longitude: 44.0080,
    displayOrder: 41,
  ),
  IraqNeighborhood(
    slug: 'erbil_italian_village',
    nameAr: 'القرية الإيطالية',
    governorateSlug: 'erbil',
    latitude: 36.1750,
    longitude: 44.0450,
    displayOrder: 42,
  ),
  IraqNeighborhood(
    slug: 'nineveh_mosul_center',
    nameAr: 'مركز الموصل',
    governorateSlug: 'nineveh',
    latitude: 36.3450,
    longitude: 43.1450,
    displayOrder: 50,
  ),
  IraqNeighborhood(
    slug: 'nineveh_tel_afar',
    nameAr: 'تلعفر',
    governorateSlug: 'nineveh',
    latitude: 36.3790,
    longitude: 42.4470,
    displayOrder: 51,
  ),
  IraqNeighborhood(
    slug: 'najaf_center',
    nameAr: 'مركز النجف',
    governorateSlug: 'najaf',
    latitude: 32.0000,
    longitude: 44.3330,
    displayOrder: 60,
  ),
  IraqNeighborhood(
    slug: 'karbala_center',
    nameAr: 'مركز كربلاء',
    governorateSlug: 'karbala',
    latitude: 32.6160,
    longitude: 44.0240,
    displayOrder: 61,
  ),
];

IraqNeighborhood? neighborhoodBySlug(String slug) {
  for (final area in iraqNeighborhoods) {
    if (area.slug == slug) return area;
  }
  return null;
}

IraqNeighborhood? neighborhoodByNameAr(String nameAr) {
  final trimmed = nameAr.trim();
  for (final area in iraqNeighborhoods) {
    if (area.nameAr == trimmed) return area;
  }
  return null;
}

List<IraqNeighborhood> neighborhoodsForGovernorate(String? governorateSlug) {
  if (governorateSlug == null || governorateSlug.trim().isEmpty) {
    return iraqNeighborhoods;
  }
  return iraqNeighborhoods
      .where((area) => area.governorateSlug == governorateSlug)
      .toList();
}

/// Nearest neighborhood by squared Euclidean distance on lat/lng (same as SQL backfill).
IraqNeighborhood? nearestNeighborhood({
  required double latitude,
  required double longitude,
  String? governorateSlug,
}) {
  final candidates = neighborhoodsForGovernorate(governorateSlug);
  if (candidates.isEmpty) return null;

  IraqNeighborhood? best;
  var bestDistance = double.infinity;

  for (final area in candidates) {
    final distance = math.pow(latitude - area.latitude, 2) +
        math.pow(longitude - area.longitude, 2);
    if (distance < bestDistance) {
      bestDistance = distance.toDouble();
      best = area;
    }
  }

  return best;
}

/// Baghdad map default center (midpoint of major Baghdad neighborhoods).
const baghdadMapCenterLat = 33.3152;
const baghdadMapCenterLng = 44.4000;
