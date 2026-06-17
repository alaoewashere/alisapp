import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/listings/constants/listing_package_config.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  test('package tier prices match business model', () {
    final standard = ListingPackageConfig.optionFor(ListingPackage.standard);
    final pro = ListingPackageConfig.optionFor(ListingPackage.pro);
    final premium = ListingPackageConfig.optionFor(ListingPackage.premium);

    expect(standard.priceIqd, 10000);
    expect(pro.priceIqd, 16000);
    expect(premium.priceIqd, 20000);
    expect(ListingPackageConfig.paidStandardPriceIqd, 10000);
  });

  test('purchasePriceIqd respects free monthly quota for standard', () {
    expect(
      ListingPackageConfig.purchasePriceIqd(
        ListingPackage.standard,
        standardOverQuota: false,
      ),
      0,
    );
    expect(
      ListingPackageConfig.purchasePriceIqd(
        ListingPackage.standard,
        standardOverQuota: true,
      ),
      10000,
    );
    expect(
      ListingPackageConfig.purchasePriceIqd(ListingPackage.pro),
      16000,
    );
  });
}
