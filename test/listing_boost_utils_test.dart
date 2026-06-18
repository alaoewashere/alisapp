import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/profile/utils/listing_boost_utils.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listingWithPackage(String package) {
  return ListingModel.fromJson({
    'id': 'test-id',
    'user_id': 'user-id',
    'category_id': 1,
    'title_ar': 'اختبار',
    'description_ar': 'وصف',
    'price': 1000000,
    'city': 'بغداد',
    'governorate': 'baghdad',
    'status': 'approved',
    'availability': 'active',
    'metadata': {'listing_package': package},
    'created_at': '2026-06-01T00:00:00Z',
    'listing_images': [],
  });
}

void main() {
  group('UserSubscriptionTier.fromPurchases', () {
    test('returns premium when any purchase is premium', () {
      expect(
        UserSubscriptionTier.fromPurchases(['pro', 'premium']),
        UserSubscriptionTier.premium,
      );
    });

    test('returns pro when highest is pro', () {
      expect(
        UserSubscriptionTier.fromPurchases(['standard', 'pro']),
        UserSubscriptionTier.pro,
      );
    });
  });

  group('isListingBoostEligible', () {
    test('true for standard post', () {
      final listing = _listingWithPackage('standard');
      expect(
        isListingBoostEligible(
          listing: listing,
          userTier: UserSubscriptionTier.standard,
        ),
        isTrue,
      );
    });

    test('true for pro post regardless of user tier', () {
      final listing = _listingWithPackage('pro');
      expect(
        isListingBoostEligible(
          listing: listing,
          userTier: UserSubscriptionTier.standard,
        ),
        isTrue,
      );
    });

    test('false for premium post at max tier', () {
      final listing = _listingWithPackage('premium');
      expect(
        isListingBoostEligible(
          listing: listing,
          userTier: UserSubscriptionTier.premium,
        ),
        isFalse,
      );
    });
  });

  group('listingBoostOptions', () {
    test('standard post offers pro and premium upgrades', () {
      final options = listingBoostOptions(
        postPackage: ListingPackage.standard,
      );
      expect(options, hasLength(2));
      expect(options[0].targetPackage, ListingPackage.pro);
      expect(options[0].setBoosted, isTrue);
      expect(options[1].targetPackage, ListingPackage.premium);
      expect(options[1].setFeatured, isTrue);
    });

    test('pro post offers premium upgrade only', () {
      final options = listingBoostOptions(
        postPackage: ListingPackage.pro,
      );
      expect(options, hasLength(1));
      expect(options.single.targetPackage, ListingPackage.premium);
      expect(options.single.setFeatured, isTrue);
      expect(options.single.upgradePackage, isTrue);
    });

    test('premium post has no upgrade options', () {
      final options = listingBoostOptions(
        postPackage: ListingPackage.premium,
      );
      expect(options, isEmpty);
    });
  });

  group('listingPackageFor', () {
    test('reads package from metadata', () {
      final listing = _listingWithPackage('pro');
      expect(listingPackageFor(listing), ListingPackage.pro);
    });
  });
}
