import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/jobs_category_icons.dart';

void main() {
  test('every mapped jobs icon file exists on disk', () {
    for (final entry in JobsCategoryIcons.bySlug.entries) {
      final path = entry.value;
      expect(
        File(path).existsSync(),
        isTrue,
        reason: 'Missing asset for ${entry.key}: $path',
      );
    }
  });
}
