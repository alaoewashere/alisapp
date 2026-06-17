import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/pets_category_icons.dart';

void main() {
  test('every mapped pets icon file exists on disk', () {
    for (final entry in PetsCategoryIcons.bySlug.entries) {
      final path = entry.value;
      expect(
        File(path).existsSync(),
        isTrue,
        reason: 'Missing asset for ${entry.key}: $path',
      );
    }
  });
}
