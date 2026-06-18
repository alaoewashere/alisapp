import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/utils/listing_heatmap_utils.dart';
import 'package:Sello/features/listings/utils/heatmap_map_markers.dart';
import 'package:Sello/features/listings/widgets/heatmap_density_badge.dart';

void main() {
  group('buildHeatmapMarkers', () {
    test('merges density rows with neighborhoods and hides zero counts', () {
      final markers = buildHeatmapMarkers(
        areaCounts: const {
          'اليرموك': 2,
          'الكرخ': 1,
          'منطقة غير معروفة': 5,
        },
      );

      expect(markers.length, 2);
      expect(
        markers.map((m) => m.neighborhood.nameAr).toSet(),
        {'اليرموك', 'الكرخ'},
      );
      expect(
        markers.singleWhere((m) => m.neighborhood.nameAr == 'اليرموك').listingCount,
        2,
      );
    });
  });

  group('buildHeatmapMapMarkers', () {
    test('uses fixed badge size for every marker', () {
      final data = buildHeatmapMarkers(
        areaCounts: const {'اليرموك': 2, 'الكرخ': 1},
      );
      final markers = buildHeatmapMapMarkers(markers: data);

      expect(
        markers.every((m) => m.width == HeatmapDensityBadge.badgeSize),
        isTrue,
      );
      expect(
        markers.every((m) => m.height == HeatmapDensityBadge.badgeSize),
        isTrue,
      );
    });
  });

  group('heatmapClusterListingCount', () {
    test('sums listing counts not marker count', () {
      final data = buildHeatmapMarkers(
        areaCounts: const {'اليرموك': 2, 'الكرخ': 1},
      );
      final lookup = heatmapMarkerLookup(data);
      final markers = buildHeatmapMapMarkers(markers: data);

      expect(heatmapClusterListingCount(markers, lookup), 3);
    });
  });

  group('heatmapDensitySubtitle', () {
    test('uses category-aware copy', () {
      expect(
        heatmapDensitySubtitle(
          areaName: 'الكرادة',
          listingCount: 3,
          categorySlug: 'cars',
        ),
        'يوجد 3 سيارة للبيع الآن في الكرادة',
      );
      expect(
        heatmapDensitySubtitle(
          areaName: 'الكرادة',
          listingCount: 3,
          categorySlug: null,
        ),
        'يوجد 3 إعلان نشط حالياً في الكرادة',
      );
    });
  });

  test('heatmap markers use seeded neighborhood coordinates', () {
    final markers = buildHeatmapMarkers(
      areaCounts: const {'الكرادة': 1},
    );

    expect(markers.single.neighborhood.latitude, 33.3152);
    expect(markers.single.neighborhood.longitude, 44.4560);
  });

  test('heatmap map interaction flags include pinch zoom and drag', () {
    expect(InteractiveFlag.hasPinchZoom(heatmapMapInteractionFlags), isTrue);
    expect(InteractiveFlag.hasDrag(heatmapMapInteractionFlags), isTrue);
    expect(InteractiveFlag.hasDoubleTapZoom(heatmapMapInteractionFlags), isTrue);
    expect(InteractiveFlag.hasRotate(heatmapMapInteractionFlags), isFalse);
  });

  testWidgets('HeatmapDensityBadge keeps fixed footprint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeatmapDensityBadge(count: 12),
        ),
      ),
    );

    final box = tester.getSize(find.byType(HeatmapDensityBadge));
    expect(box.width, HeatmapDensityBadge.badgeSize);
    expect(box.height, HeatmapDensityBadge.badgeSize);
  });
}
