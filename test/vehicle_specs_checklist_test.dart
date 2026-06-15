import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/listings/constants/vehicle_listing_options.dart';
import 'package:my_app/features/listings/widgets/vehicle_specs_checklist.dart';

void main() {
  test('vehicleSpecGroups cover every spec exactly once', () {
    final grouped = VehicleListingOptions.vehicleSpecOptions;
    expect(grouped.length, 47);
    expect(grouped.toSet().length, 47);
    expect(
      VehicleListingOptions.vehicleSpecGroups.map((g) => g.title).toList(),
      ['الأمان', 'الراحة', 'الخارج'],
    );
  });

  testWidgets('VehicleSpecsChecklist accordion expands group and toggles spec',
      (tester) async {
    final selected = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: SingleChildScrollView(
                child: VehicleSpecsChecklist(
                  selected: selected,
                  onToggle: (spec) {
                    setState(() {
                      if (selected.contains(spec)) {
                        selected.remove(spec);
                      } else {
                        selected.add(spec);
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.textContaining('تم اختيار 0'), findsOneWidget);
    expect(find.text('ABS'), findsNothing);

    await tester.tap(find.text('الأمان'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ABS'), findsOneWidget);

    await tester.tap(find.text('ABS'));
    await tester.pump();

    expect(selected, ['ABS']);
    expect(find.textContaining('تم اختيار 1'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('VehicleSpecsChecklist collapses group when header tapped again', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: VehicleSpecsChecklist(
              selected: const [],
              onToggle: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('الأمان'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ABS'), findsOneWidget);

    await tester.tap(find.text('الأمان'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ABS'), findsNothing);
  });
}
