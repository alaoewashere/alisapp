import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/utils/listing_publication_date.dart';

void main() {
  group('formatListingPublicationDateAr', () {
    test('formats date with Arabic month name', () {
      final formatted = formatListingPublicationDateAr(DateTime(2026, 5, 27));
      expect(formatted, '27 مايو 2026');
    });
  });
}
