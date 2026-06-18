import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/listing_package_utils.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  final repoSource = File(
    'lib/features/listings/data/listings_repository.dart',
  ).readAsStringSync();

  group('Home latest listings sort', () {
    test('getLatestHomeListings uses shared latest feed sort + slice', () {
      expect(repoSource, contains('Future<List<ListingModel>> getLatestHomeListings'));
      final start = repoSource.indexOf('getLatestHomeListings(');
      final end = repoSource.indexOf('getLatestHomeListingsPage(', start);
      final block = repoSource.substring(start, end);
      expect(block, contains('sliceLatestHomeFeedPage'));
      expect(block, contains('_latestListingsBaseQuery'));
    });

    test('getLatestHomeListingsPage uses same sort then slice (not raw range)', () {
      final start = repoSource.indexOf('getLatestHomeListingsPage(');
      final end = repoSource.indexOf('Future<List<ListingModel>> getListingsByCategory', start);
      final block = repoSource.substring(start, end);
      expect(block, contains('sliceLatestHomeFeedPage'));
      expect(block, contains('.limit(fetchLimit)'));
      expect(block, isNot(contains('.range(')));
    });

    test('_latestListingsBaseQuery excludes مميز listings', () {
      final start = repoSource.indexOf('dynamic _latestListingsBaseQuery');
      final end = repoSource.indexOf('dynamic _applyLatestListingsOrder', start);
      final block = repoSource.substring(start, end);
      expect(block, contains(".eq('is_featured', false)"));
      expect(block, contains('metadata->>listing_package.eq.pro'));
      expect(
        block,
        isNot(contains('metadata->>listing_package.eq.premium')),
      );
    });

    test('_applyLatestListingsOrder sorts pro before free then date', () {
      final start = repoSource.indexOf('dynamic _applyLatestListingsOrder');
      final end = repoSource.indexOf('dynamic _filteredListingsQuery', start);
      final block = repoSource.substring(start, end);
      expect(block, contains(".order('is_boosted', ascending: false)"));
      expect(block, isNot(contains(".order('is_featured'")));
      expect(block, contains(".order('created_at', ascending: false)"));
    });

    test('getRecentListings unchanged for category browse all', () {
      final start = repoSource.indexOf('Future<List<ListingModel>> getRecentListings');
      final end = repoSource.indexOf('getLatestHomeListings(', start);
      final block = repoSource.substring(start, end);
      expect(block, contains(".eq('is_featured', false)"));
    });
  });

  group('sortListingsByPackagePriority integration', () {
    ListingModel listing({
      required String id,
      bool isFeatured = false,
      bool isBoosted = false,
      DateTime? createdAt,
    }) {
      return ListingModel(
        id: id,
        userId: 'u1',
        categoryId: 1,
        titleAr: id,
        descriptionAr: '',
        price: 1000,
        city: 'بغداد',
        governorate: 'baghdad',
        displayStatus: ListingDisplayStatus.active,
        createdAt: createdAt ?? DateTime(2026, 6, 1),
        isFeatured: isFeatured,
        isBoosted: isBoosted,
      );
    }

    test('pro before free regardless of date (latest feed tiers only)', () {
      final items = [
        listing(id: 'free-new', createdAt: DateTime(2026, 6, 10)),
        listing(id: 'pro-old', isBoosted: true, createdAt: DateTime(2026, 6, 1)),
      ];
      sortListingsByPackagePriority(items);
      expect(items.map((e) => e.id).toList(), ['pro-old', 'free-new']);
    });

    test('premium before pro before free regardless of date', () {
      final items = [
        listing(id: 'free-new', createdAt: DateTime(2026, 6, 10)),
        listing(id: 'pro-old', isBoosted: true, createdAt: DateTime(2026, 6, 1)),
        listing(
          id: 'premium-mid',
          isFeatured: true,
          createdAt: DateTime(2026, 6, 5),
        ),
      ];
      sortListingsByPackagePriority(items);
      expect(items.map((e) => e.id).toList(), [
        'premium-mid',
        'pro-old',
        'free-new',
      ]);
    });

    test('newest first within the same tier', () {
      final items = [
        listing(id: 'free-old', createdAt: DateTime(2026, 6, 1)),
        listing(id: 'free-new', createdAt: DateTime(2026, 6, 10)),
      ];
      sortListingsByPackagePriority(items);
      expect(items.first.id, 'free-new');
    });
  });
}
