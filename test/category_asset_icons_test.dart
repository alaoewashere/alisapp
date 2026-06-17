import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/category_asset_icons.dart';

void main() {
  group('CategoryAssetIcons', () {
    test('resolves all root category packs including home_help', () {
      expect(
        CategoryAssetIcons.assetForSlug('cars'),
        'assets/car-icons/car-main-category.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('real_estate'),
        'assets/real-estate-icons/real-estate.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('electronics'),
        'assets/electronics-icons/Main.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('buy_sell'),
        'assets/usedandnewmarketicons/main-for-used-and-new-market.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('souq_mobile'),
        'assets/usedandnewmarketicons/موبايلات واكسسوارات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('tutoring'),
        'assets/special-lesson/main.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('jobs'),
        'assets/jobs-icons/main.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('pets'),
        'assets/animals-icons/main.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('home_help'),
        'assets/assistant/main.png',
      );
    });

    test('displayAssetForSlug uses default packet icon for unmapped slugs', () {
      expect(
        CategoryAssetIcons.displayAssetForSlug('jobs_it_web_dev'),
        'assets/Navigation-Menu-Horizontal--Streamline-Ultimate.png',
      );
      expect(CategoryAssetIcons.displayAssetForSlug('re_residential_sale_apartment'), isNull);
      expect(CategoryAssetIcons.displayAssetForSlug('veh_atv'), isNull);
    });
  });
}
