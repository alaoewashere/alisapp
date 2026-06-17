import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/category_asset_icons.dart';
import 'package:my_app/core/constants/category_fallback_icon.dart';

void main() {
  group('CategoryFallbackIcon', () {
    test('excludes المركبات and العقارات trees', () {
      expect(CategoryFallbackIcon.isExcludedTreeSlug('cars'), isTrue);
      expect(CategoryFallbackIcon.isExcludedTreeSlug('real_estate'), isTrue);
      expect(CategoryFallbackIcon.isExcludedTreeSlug('veh_automobile'), isTrue);
      expect(CategoryFallbackIcon.isExcludedTreeSlug('re_residential'), isTrue);
      expect(CategoryFallbackIcon.isExcludedTreeSlug('jobs_it'), isFalse);
    });

    test('returns default packet icon for other category slugs', () {
      expect(
        CategoryFallbackIcon.assetForSlug('jobs_it_web_dev'),
        CategoryFallbackIcon.assetPath,
      );
      expect(CategoryFallbackIcon.assetForSlug('re_residential_sale_apartment'), isNull);
      expect(CategoryFallbackIcon.assetForSlug('veh_atv'), isNull);
    });
  });

  group('CategoryAssetIcons displayAssetForSlug', () {
    test('prefers pack icons over default packet icon', () {
      expect(
        CategoryAssetIcons.displayAssetForSlug('elec_smartphones'),
        'assets/electronics-icons/هواتف ذكيه.png',
      );
    });

    test('uses default packet icon when pack icon is missing', () {
      expect(
        CategoryAssetIcons.displayAssetForSlug('jobs_it_web_dev'),
        CategoryFallbackIcon.assetPath,
      );
      expect(CategoryAssetIcons.displayAssetForSlug('re_residential_sale_apartment'), isNull);
      expect(CategoryAssetIcons.displayAssetForSlug('veh_atv'), isNull);
    });
  });
}
