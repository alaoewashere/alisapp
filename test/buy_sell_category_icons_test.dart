import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/buy_sell_category_icons.dart';

void main() {
  group('BuySellCategoryIcons', () {
    test('maps سوق المستعمل والجديد root and level-1 branches', () {
      expect(
        BuySellCategoryIcons.assetForSlug('buy_sell'),
        'assets/usedandnewmarketicons/main-for-used-and-new-market.png',
      );
      expect(
        BuySellCategoryIcons.assetForSlug('souq_mobile'),
        'assets/usedandnewmarketicons/موبايلات واكسسوارات.png',
      );
      expect(
        BuySellCategoryIcons.assetForSlug('souq_fashion'),
        'assets/usedandnewmarketicons/ملابس وازياء.png',
      );
      expect(
        BuySellCategoryIcons.assetForSlug('souq_building'),
        'assets/usedandnewmarketicons/building-materials.png',
      );
    });

    test('returns null for item slugs without icons', () {
      expect(BuySellCategoryIcons.assetForSlug('souq_mobile_iphone'), isNull);
    });
  });
}
