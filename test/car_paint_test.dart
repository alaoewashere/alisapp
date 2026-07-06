import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/car_paint_panels.dart';
import 'package:Sello/core/utils/car_paint_utils.dart';
import 'package:Sello/features/listings/widgets/car_paint/car_paint_panel_layout.dart';
import 'package:Sello/features/listings/widgets/car_paint/car_paint_panel_overlay.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';

void main() {
  group('car paint panels', () {
    test('defines 13 layout panels with unique ids', () {
      expect(kCarPaintPanelLayouts.length, kCarPaintPanelCount);
      expect(
        kCarPaintPanelLayouts.map((p) => p.id).toSet().length,
        kCarPaintPanelCount,
      );
    });

    test('layout ids match metadata panel keys', () {
      for (final layout in kCarPaintPanelLayouts) {
        expect(
          kCarPaintPanels.any((p) => p.key == layout.id),
          isTrue,
          reason: layout.id,
        );
      }
    });

    test('panel center is inside panel bounds', () {
      const width = kCarPaintImageWidth;
      const height = kCarPaintImageHeight;
      for (final panel in kCarPaintPanelLayouts) {
        final center = panel.centerForSize(width, height);
        expect(center.dx, greaterThanOrEqualTo(panel.leftPct * width));
        expect(center.dx, lessThanOrEqualTo((panel.leftPct + panel.widthPct) * width));
        expect(center.dy, greaterThanOrEqualTo(panel.topPct * height));
        expect(center.dy, lessThanOrEqualTo((panel.topPct + panel.heightPct) * height));
      }
    });

    test('panel rects fit within image bounds', () {
      for (final panel in kCarPaintPanelLayouts) {
        expect(panel.leftPct + panel.widthPct, lessThanOrEqualTo(1.001));
        expect(panel.topPct + panel.heightPct, lessThanOrEqualTo(1.001));
      }
    });

    test('each panel has a PNG shape mask asset path', () {
      for (final panel in kCarPaintPanelLayouts) {
        expect(
          carPaintPanelMaskAsset(panel.id),
          'assets/images/car_paint_masks/${panel.id}.png',
        );
      }
    });
  });

  group('car paint summary', () {
    test('groups non-original panels by condition', () {
      const conditions = {
        'hood': CarPaintCondition.painted,
        'front_left_door': CarPaintCondition.localPaint,
        'rear_bumper': CarPaintCondition.replaced,
      };

      final groups = buildCarPaintSummaryGroups(conditions);
      expect(groups.length, 3);
      expect(groups[0].condition, CarPaintCondition.localPaint);
      expect(groups[0].panelKeys, contains('front_left_door'));
      expect(groups[1].condition, CarPaintCondition.painted);
      expect(groups[1].panelKeys, contains('hood'));
      expect(groups[2].condition, CarPaintCondition.replaced);
      expect(groups[2].panelKeys, contains('rear_bumper'));
    });

    test('all original when map is empty', () {
      expect(carPaintAllOriginal(const {}), isTrue);
      expect(buildCarPaintSummaryGroups(const {}), isEmpty);
    });
  });

  group('vehicle metadata panel_conditions', () {
    test('round-trips panel_conditions in json', () {
      const original = VehicleListingMetadata(
        trim: 'SE',
        panelConditions: {
          'front_left_fender': CarPaintCondition.painted,
          'rear_right_door': CarPaintCondition.localPaint,
        },
      );

      final json = original.toJson();
      expect(json['panel_conditions'], original.panelConditions);

      final restored = VehicleListingMetadata.fromJson(json);
      expect(restored.panelConditions, original.panelConditions);
    });

    test('omits empty panel_conditions from json', () {
      const original = VehicleListingMetadata(trim: 'Base');
      expect(original.toJson().containsKey('panel_conditions'), isFalse);
    });
  });
}
