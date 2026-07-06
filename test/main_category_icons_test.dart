import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/main_category_icons.dart';

void main() {
  test('isMainCategoryAsset detects main category PNG paths', () {
    expect(
      MainCategoryIcons.isMainCategoryAsset(
        'assets/main_categories_icon/المركبات.png',
      ),
      isTrue,
    );
    expect(
      MainCategoryIcons.isMainCategoryAsset(
        'assets/car-icons/car-main-category.png',
      ),
      isFalse,
    );
  });
}
