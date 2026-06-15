import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/listings/providers/post_listing_provider.dart';
import 'package:my_app/features/listings/widgets/steps/step2_vehicle_details.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  testWidgets('Step2VehicleDetails hides sale/rent toggle and shows settings cards',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Step2VehicleDetails(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('نوع الإعلان *'), findsNothing);
    expect(find.text('للبيع'), findsNothing);
    expect(find.text('للإيجار'), findsNothing);
    expect(find.text('المعلومات الأساسية'), findsOneWidget);
    expect(find.text('الفئة'), findsOneWidget);
    expect(find.text('المسافة'), findsOneWidget);
    expect(find.text('المحرك'), findsOneWidget);
    expect(find.text('الأسطوانات'), findsOneWidget);
    expect(find.byType(SegmentedButton<ListingType>), findsNothing);

    final container = tester.element(find.text('الفئة'));
    final scope = ProviderScope.containerOf(container);
    expect(
      scope.read(postListingProvider).listingType,
      ListingType.sale,
    );
  });
}
