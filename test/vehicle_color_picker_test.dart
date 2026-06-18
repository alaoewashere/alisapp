import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/listings/constants/vehicle_listing_options.dart';
import 'package:Sello/features/listings/widgets/vehicle_color_picker.dart';

void main() {
  testWidgets('VehicleColorPicker selects standard color and shows label', (
    tester,
  ) async {
    String? selected;
    var custom = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehicleColorPicker(
            selectedColor: selected,
            customColor: custom,
            onColorSelected: (label) => selected = label,
            onCustomColorSelected: (hex) => custom = hex,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    expect(selected, 'أبيض');
    expect(custom, isEmpty);
  });

  testWidgets('VehicleColorPicker shows selected color name in green', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VehicleColorPicker(
            selectedColor: 'أسود',
            customColor: '',
            onColorSelected: (_) {},
            onCustomColorSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('أسود'), findsNWidgets(2));
  });

  test('VehicleCarColors includes أخرى and ordered presets', () {
    final labels = VehicleCarColors.options.map((o) => o.labelAr).toList();
    expect(labels.first, 'أبيض');
    expect(labels.last, VehicleCarColors.otherLabel);
    expect(labels, contains('رمادي'));
    expect(labels, contains('ذهبي'));
  });
}
