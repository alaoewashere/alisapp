import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/l10n/listing_attribute_locale.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  group('localizeListingAttribute', () {
    test('returns English labels for stored Arabic values', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(localizeListingAttribute('أسود', en), 'Black');
      expect(localizeListingAttribute('جديد', en), 'New');
      expect(localizeListingAttribute('بنزين', en), 'Petrol');
    });

    test('returns Turkish labels when locale is tr', () {
      final tr = lookupAppLocalizations(const Locale('tr'));
      expect(localizeListingAttribute('أسود', tr), 'Siyah');
      expect(localizeListingAttribute('مستعمل', tr), 'İkinci el');
    });

    test('returns Arabic unchanged for ar locale', () {
      final ar = lookupAppLocalizations(const Locale('ar'));
      expect(localizeListingAttribute('أسود', ar), 'أسود');
      expect(localizeListingAttribute('شقة', ar), 'شقة');
    });

    test('passes through unknown custom values', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(localizeListingAttribute('Apple', en), 'Apple');
      expect(localizeListingAttribute('64GB', en), '64GB');
    });
  });
}
