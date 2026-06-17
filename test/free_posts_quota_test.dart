import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/utils/free_posts_quota.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  group('free_posts_quota', () {
    test('remainingFreePosts caps at zero', () {
      expect(remainingFreePosts(0), 2);
      expect(remainingFreePosts(1), 1);
      expect(remainingFreePosts(2), 0);
      expect(remainingFreePosts(5), 0);
    });

    test('standardListingRequiresPayment after two free posts', () {
      expect(standardListingRequiresPayment(0), isFalse);
      expect(standardListingRequiresPayment(1), isFalse);
      expect(standardListingRequiresPayment(2), isTrue);
    });
  });

  group('ListingPackage purchase types', () {
    test('paid standard uses standard package type', () {
      expect(
        ListingPackage.standard.purchasePackageTypeFor(paidStandard: true),
        'standard',
      );
      expect(
        ListingPackage.standard.purchasePackageTypeFor(paidStandard: false),
        isNull,
      );
      expect(
        ListingPackage.pro.purchasePackageTypeFor(paidStandard: true),
        'pro',
      );
    });
  });
}
