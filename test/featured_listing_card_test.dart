import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/widgets/featured_listing_card.dart';

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

  Future<void> pumpCard(WidgetTester tester, ListingModel listing) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              child: FeaturedListingCard(listing: listing),
            ),
          ),
        ),
      ),
    );
  }

  group('FeaturedListingCard', () {
    testWidgets('shows title, price, and مميز badge', (tester) async {
      await pumpCard(tester, sampleListing());

      expect(find.text('سيارة تويوتا كامري'), findsOneWidget);
      expect(find.textContaining('25,000,000'), findsOneWidget);
      expect(find.text('مميز'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (tester) async {
      await pumpCard(tester, sampleListing());

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('shows favorite button on image', (tester) async {
      await pumpCard(tester, sampleListing());

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('long title uses two lines before ellipsis', (tester) async {
      final listing = sampleListing().copyWith(
        titleAr: 'sportage model 2025 prestige full option pack',
      );

      await pumpCard(tester, listing);

      final titleText = tester.widget<Text>(
        find.textContaining('sportage model 2025'),
      );
      expect(titleText.maxLines, 2);
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(titleText.textDirection, TextDirection.rtl);
    });
  });
}
