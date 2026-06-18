import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/home/widgets/recent_listings_row.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  ListingModel sampleListing({required String id, required String title}) {
    return ListingModel(
      id: id,
      userId: 'user-1',
      categoryId: 1,
      titleAr: title,
      descriptionAr: 'وصف',
      price: 150000000,
      city: 'بغداد',
      governorate: 'baghdad',
      displayStatus: ListingDisplayStatus.active,
      createdAt: DateTime(2026, 6, 8),
    );
  }

  group('RecentListingsRow', () {
    testWidgets('renders horizontal list of listing cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecentListingsRow(
                listings: [
                  sampleListing(id: '1', title: 'سيارة للبيع'),
                  sampleListing(id: '2', title: 'شقة للإيجار'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('سيارة للبيع'), findsOneWidget);
      expect(find.text('شقة للإيجار'), findsOneWidget);
    });

    testWidgets('shimmer shows horizontal placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecentListingsRowShimmer()),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
