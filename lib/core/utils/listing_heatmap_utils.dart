import '../../../core/constants/iraq_neighborhoods.dart';

/// Category chips shown on the listing heat map screen.
class HeatmapCategoryFilter {
  const HeatmapCategoryFilter({
    required this.slug,
    required this.labelAr,
  });

  /// `null` slug means all categories.
  final String? slug;
  final String labelAr;
}

const heatmapCategoryFilters = <HeatmapCategoryFilter>[
  HeatmapCategoryFilter(slug: null, labelAr: 'الكل'),
  HeatmapCategoryFilter(slug: 'cars', labelAr: 'سيارات'),
  HeatmapCategoryFilter(slug: 'real_estate', labelAr: 'عقارات'),
  HeatmapCategoryFilter(slug: 'electronics', labelAr: 'إلكترونيات'),
];

class HeatmapAreaMarkerData {
  const HeatmapAreaMarkerData({
    required this.neighborhood,
    required this.listingCount,
  });

  final IraqNeighborhood neighborhood;
  final int listingCount;
}

List<HeatmapAreaMarkerData> buildHeatmapMarkers({
  required Map<String, int> areaCounts,
}) {
  final markers = <HeatmapAreaMarkerData>[];
  for (final area in iraqNeighborhoods) {
    final count = areaCounts[area.nameAr] ?? 0;
    if (count <= 0) continue;
    markers.add(
      HeatmapAreaMarkerData(neighborhood: area, listingCount: count),
    );
  }
  return markers;
}

String heatmapDensitySubtitle({
  required String areaName,
  required int listingCount,
  String? categorySlug,
}) {
  return switch (categorySlug) {
    'cars' => 'يوجد $listingCount سيارة للبيع الآن في $areaName',
    'real_estate' => 'يوجد $listingCount إعلان عقاري الآن في $areaName',
    'electronics' => 'يوجد $listingCount إعلان إلكترونيات الآن في $areaName',
    _ => 'يوجد $listingCount إعلان نشط حالياً في $areaName',
  };
}

String heatmapSheetTitle(String areaName) => areaName;
