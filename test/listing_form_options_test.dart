import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/listings/constants/listing_form_options.dart';

void main() {
  group('ListingFormOptions', () {
    const predefined = ['أ', 'ب', 'ج'];

    test('withOther appends أخرى once', () {
      expect(
        ListingFormOptions.withOther(predefined),
        ['أ', 'ب', 'ج', ListingFormOptions.other],
      );
      expect(
        ListingFormOptions.withOther([...predefined, ListingFormOptions.other]),
        ['أ', 'ب', 'ج', ListingFormOptions.other],
      );
    });

    test('isCustomValue detects values outside predefined list', () {
      expect(ListingFormOptions.isCustomValue('أ', predefined), isFalse);
      expect(ListingFormOptions.isCustomValue('مخصص', predefined), isTrue);
      expect(ListingFormOptions.isCustomValue(null, predefined), isFalse);
    });

    test('replaceCustomInList keeps predefined and swaps custom entry', () {
      final result = ListingFormOptions.replaceCustomInList(
        selected: ['أ', 'مخصص قديم'],
        predefined: predefined,
        customValue: 'مخصص جديد',
      );
      expect(result, ['أ', 'مخصص جديد']);
    });

    test('replaceCustomInList removes custom when null', () {
      final result = ListingFormOptions.replaceCustomInList(
        selected: ['أ', 'مخصص'],
        predefined: predefined,
        customValue: null,
      );
      expect(result, ['أ']);
    });
  });
}
