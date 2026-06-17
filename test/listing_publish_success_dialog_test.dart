import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/listings/widgets/listing_publish_success_dialog.dart';

void main() {
  testWidgets('ListingPublishSuccessDialog shows done and review message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingPublishSuccessDialog(onDone: () {}),
        ),
      ),
    );

    expect(find.text('تم ✓'), findsOneWidget);
    expect(find.text('إعلانك قيد المراجعة'), findsOneWidget);
    expect(find.text('موافق'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
