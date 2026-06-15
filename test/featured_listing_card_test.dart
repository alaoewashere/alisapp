import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/shared/models/listing_model.dart';
import 'package:my_app/widgets/featured_listing_card.dart';

void main() {
  ListingModel sampleListing({String? coverImageUrl}) {
    return ListingModel(
      id: 'listing-1',
      userId: 'user-1',
      categoryId: 1,
      titleAr: 'سيارة تويوتا كامري',
      descriptionAr: 'وصف',
      price: 25000000,
      city: 'بغداد',
      governorate: 'baghdad',
      displayStatus: ListingDisplayStatus.active,
      isFeatured: true,
      coverImageUrl: coverImageUrl,
      createdAt: DateTime(2026, 6, 8),
    );
  }

  group('FeaturedListingCard', () {
    testWidgets('shows title, price, and مميز badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              child: FeaturedListingCard(listing: sampleListing()),
            ),
          ),
        ),
      );

      expect(find.text('سيارة تويوتا كامري'), findsOneWidget);
      expect(find.textContaining('25,000,000'), findsOneWidget);
      expect(find.text('مميز'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              child: FeaturedListingCard(listing: sampleListing()),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
