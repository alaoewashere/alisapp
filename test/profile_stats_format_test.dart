import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/arabic_number.dart';

void main() {
  group('formatCompactArabic', () {
    test('formats thousands with Arabic decimal', () {
      expect(formatCompactArabic(1500), '1.5 ألف');
    });

    test('formats plain numbers', () {
      expect(formatCompactArabic(25), '25');
    });
  });
}
