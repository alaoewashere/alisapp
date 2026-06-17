import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/home_help_category_icons.dart';

void main() {
  group('HomeHelpCategoryIcons', () {
    test('maps مساعدة منزلية root and level-1 branches', () {
      expect(
        HomeHelpCategoryIcons.assetForSlug('home_help'),
        'assets/assistant/main.png',
      );
      expect(
        HomeHelpCategoryIcons.assetForSlug('home_cleaning'),
        'assets/assistant/تنظيف المنزل.png',
      );
      expect(
        HomeHelpCategoryIcons.assetForSlug('home_driver'),
        'assets/assistant/driver.png',
      );
    });

    test('returns null for service detail slugs', () {
      expect(HomeHelpCategoryIcons.assetForSlug('home_cleaning_daily'), isNull);
    });
  });
}
