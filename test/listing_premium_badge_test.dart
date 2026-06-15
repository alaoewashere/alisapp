import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/shared/models/listing_model.dart';

ListingModel _listing({
  bool isFeatured = false,
  bool isBoosted = false,
  Map<String, dynamic> metadata = const {},
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
    createdAt: DateTime(2026, 1, 1),
    isFeatured: isFeatured,
    isBoosted: isBoosted,
    metadata: metadata,
  );
}

void main() {
  group('ListingModel.isPremiumListing', () {
    test('true when is_featured is set', () {
      expect(_listing(isFeatured: true).isPremiumListing, isTrue);
    });

    test('true for premium metadata package values', () {
      expect(
        _listing(metadata: const {'listing_package': 'premium'}).isPremiumListing,
        isTrue,
      );
      expect(
        _listing(metadata: const {'listing_package': 'مميز'}).isPremiumListing,
        isTrue,
      );
      expect(
        _listing(metadata: const {'listing_package': 'featured'}).isPremiumListing,
        isTrue,
      );
    });

    test('false for standard listings', () {
      expect(_listing().isPremiumListing, isFalse);
      expect(_listing(isBoosted: true).isPremiumListing, isFalse);
      expect(_listing(isBoosted: true).isProListing, isTrue);
      expect(
        _listing(metadata: const {'listing_package': 'pro'}).isProListing,
        isTrue,
      );
      expect(
        _listing(metadata: const {'listing_package': 'pro'}).isPremiumListing,
        isFalse,
      );
      expect(
        _listing(metadata: const {'listing_package': 'standard'}).isPremiumListing,
        isFalse,
      );
    });
  });
}
