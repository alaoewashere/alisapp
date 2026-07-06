import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/category_asset_icons.dart';

void main() {
  group('CategoryAssetIcons', () {
    test('resolves all root category packs including home_help', () {
      expect(
        CategoryAssetIcons.assetForSlug('cars'),
        'assets/main_categories_icon/المركبات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('real_estate'),
        'assets/main_categories_icon/العقارات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('electronics'),
        'assets/main_categories_icon/الالكترونيات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('buy_sell'),
        'assets/main_categories_icon/سوق المستعمل والجديد.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('souq_mobile'),
        'assets/usedandnewmarketicons/موبايلات واكسسوارات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('tutoring'),
        'assets/main_categories_icon/دروس خصوصيه.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('jobs'),
        'assets/main_categories_icon/فرص عمل.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('pets'),
        'assets/main_categories_icon/الحيوانات.png',
      );
      expect(
        CategoryAssetIcons.assetForSlug('home_help'),
        'assets/main_categories_icon/مساعده منزليه.png',
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
