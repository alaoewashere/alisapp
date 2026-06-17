import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/real_estate_category_icons.dart';

void main() {
  group('RealEstateCategoryIcons', () {
    test('maps العقارات root and all level-1 branches', () {
      expect(
        RealEstateCategoryIcons.assetForSlug('real_estate'),
        'assets/real-estate-icons/real-estate.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_residential'),
        'assets/real-estate-icons/سكني.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_tourism'),
        'assets/real-estate-icons/منشات سياحيه.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_shared'),
        'assets/real-estate-icons/ملكيه مشتركة.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_land'),
        'assets/real-estate-icons/اراضي.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_projects'),
        'assets/real-estate-icons/مشاريع سكنيه.png',
      );
      expect(
        RealEstateCategoryIcons.assetForSlug('re_commercial'),
        'assets/real-estate-icons/محلات تجاريه.png',
      );
    });

    test('returns null for deeper real-estate slugs', () {
      expect(
        RealEstateCategoryIcons.assetForSlug('re_residential_sale_apartment'),
        isNull,
      );
    });
  });
}
