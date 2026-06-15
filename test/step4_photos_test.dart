import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/listings/providers/post_listing_provider.dart';
import 'package:my_app/features/listings/widgets/steps/step4_photos.dart';

void main() {
  testWidgets('Step4Photos shows header badge and tips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Step4Photos(),
          ),
        ),
      ),
    );

    expect(find.text('الصور'), findsOneWidget);
    expect(find.text('الصورة الأولى هي الغلاف'), findsOneWidget);
    expect(find.text('لم تضف أي صور بعد'), findsOneWidget);
    expect(find.text('إضاءة جيدة'), findsOneWidget);
    expect(find.text('إضافة صورة'), findsOneWidget);
  });

  test('photos validation requires at least one image', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(postListingProvider.notifier);

    expect(notifier.validateStep(4), isNotNull);
  });
}
