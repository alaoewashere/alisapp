import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/pets_category_icons.dart';

void main() {
  group('PetsCategoryIcons', () {
    test('maps الحيوانات root and level-1 branches', () {
      expect(
        PetsCategoryIcons.assetForSlug('pets'),
        'assets/animals-icons/main.png',
      );
      expect(
        PetsCategoryIcons.assetForSlug('pets_dogs'),
        'assets/animals-icons/كلاب.png',
      );
      expect(
        PetsCategoryIcons.assetForSlug('pets_reptiles'),
        'assets/animals-icons/reptiles.png',
      );
    });

    test('returns null for breed slugs', () {
      expect(PetsCategoryIcons.assetForSlug('pets_dog_husky'), isNull);
    });
  });
}
