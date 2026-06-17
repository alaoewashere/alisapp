import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/features/listings/widgets/vehicle_stats_row.dart';
import 'package:my_app/shared/models/vehicle_listing_metadata.dart';

void main() {
  testWidgets('VehicleStatsRow uses dark styling and clean stat values', (tester) async {
    const vehicle = VehicleListingMetadata(
      trim: 'Preston',
      mileage: 1200,
      mileageUnit: MileageUnit.km,
      year: 2022,
      engine: '1600',
      cylinders: '4',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VehicleStatsRow(vehicle: vehicle),
        ),
      ),
    );

    expect(find.text('Preston'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    expect(find.text('1,200'), findsOneWidget);
    expect(find.text('1600'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1,200كم'), findsNothing);
    expect(find.text('محرك 1600'), findsNothing);
    expect(find.text('أسطوانة 4'), findsNothing);
    expect(find.text('كم'), findsOneWidget);
    expect(find.text('السنة'), findsOneWidget);
    expect(find.text('محرك'), findsOneWidget);
    expect(find.text('أسطوانة'), findsOneWidget);

    final card = tester.widget<Container>(
      find.descendant(
        of: find.byType(VehicleStatsRow),
        matching: find.byType(Container).first,
      ),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.fieldCarbon);
    expect(decoration.borderRadius, BorderRadius.circular(10));
  });
}
