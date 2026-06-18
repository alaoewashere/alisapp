import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/listing_package_utils.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  bool isFeatured = false,
  bool isBoosted = false,
  Map<String, dynamic> metadata = const {},
  DateTime? createdAt,
}) {
  return ListingModel(
    id: '1',
    userId: 'u1',
    categoryId: 1,
    titleAr: 'test',
    descriptionAr: '',
    price: 1000,
    city: 'بغداد',
    governorate: 'baghdad',
    displayStatus: ListingDisplayStatus.active,
    createdAt: createdAt ?? DateTime(2026, 6, 1),
    isFeatured: isFeatured,
    isBoosted: isBoosted,
    metadata: metadata,
  );
}

void main() {
  group('calculateListingExpiry', () {
    test('standard is 20 days', () {
      final before = DateTime.now();
      final expiry = calculateListingExpiry(ListingPackage.standard);
      expect(expiry.difference(before).inDays, 20);
    });

    test('pro is 25 days', () {
      final before = DateTime.now();
      final expiry = calculateListingExpiry(ListingPackage.pro);
      expect(expiry.difference(before).inDays, 25);
    });

    test('premium is 35 days', () {
      final before = DateTime.now();
      final expiry = calculateListingExpiry(ListingPackage.premium);
      expect(expiry.difference(before).inDays, 35);
    });
  });

  group('sortListingsByPackagePriority', () {
    test('orders premium, pro, then standard', () {
      final listings = [
        _listing(createdAt: DateTime(2026, 6, 3)),
        _listing(isBoosted: true, createdAt: DateTime(2026, 6, 2)),
        _listing(isFeatured: true, createdAt: DateTime(2026, 6, 1)),
      ];

      sortListingsByPackagePriority(listings);

      expect(listings[0].isPremiumListing, isTrue);
      expect(listings[1].isProListing, isTrue);
      expect(listings[2].isStandardListing, isTrue);
    });

    test('newest first within same tier', () {
      final listings = [
        _listing(createdAt: DateTime(2026, 6, 1)),
        _listing(createdAt: DateTime(2026, 6, 5)),
      ];

      sortListingsByPackagePriority(listings);

      expect(listings.first.createdAt.day, 5);
    });
  });

  group('ListingModel package getters', () {
    test('isPro and isPremium helpers', () {
      expect(_listing(isBoosted: true).isPro, isTrue);
      expect(_listing(isFeatured: true).isPremium, isTrue);
      expect(_listing().isStandard, isTrue);
    });
  });

  group('ListingModel moderation', () {
    test('pending listings disable owner actions', () {
      final pending = _listing().copyWith(
        moderationStatus: ListingModerationStatus.pending,
      );
      final approved = pending.copyWith(
        moderationStatus: ListingModerationStatus.approved,
      );

      expect(pending.isPendingModeration, isTrue);
      expect(pending.isOwnerActionsEnabled, isFalse);
      expect(approved.isOwnerActionsEnabled, isTrue);
    });
  });
}
