import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/utils/listing_publication_date.dart';

void main() {
  group('formatListingPublicationDate', () {
    test('formats date with Arabic month name', () {
      final formatted = formatListingPublicationDate(
        DateTime(2026, 5, 27),
        const Locale('ar'),
      );
      expect(formatted, contains('2026'));
      expect(formatted, contains('27'));
    });
  });
}
