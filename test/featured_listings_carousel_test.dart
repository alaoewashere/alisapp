import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/home/widgets/featured_listings_carousel.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  ListingModel sampleListing() {
    return ListingModel(
      id: 'listing-1',
      userId: 'user-1',
      categoryId: 1,
      titleAr: 'شقة للبيع',
      descriptionAr: 'وصف',
      price: 150000000,
      city: 'بغداد',
      governorate: 'baghdad',
      displayStatus: ListingDisplayStatus.active,
      isFeatured: true,
      createdAt: DateTime(2026, 6, 8),
    );
  }

  group('FeaturedListingsCarousel', () {
    testWidgets('hides when listings are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeaturedListingsCarousel(listings: []),
          ),
        ),
      );

      expect(find.text('إعلانات مميزة'), findsNothing);
    });

    testWidgets('shows header and cards when listings exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeaturedListingsCarousel(listings: [sampleListing()]),
          ),
        ),
      );

      expect(find.text('إعلانات مميزة'), findsOneWidget);
      expect(find.text('شقة للبيع'), findsOneWidget);
    });
  });
}
