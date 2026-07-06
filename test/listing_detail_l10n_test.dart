import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:Sello/core/utils/listing_publication_date.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('tr');
    await initializeDateFormatting('ar');
  });
  test('listing detail labels exist in all supported locales', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.statYear, isNotEmpty);
      expect(l10n.statCategory, isNotEmpty);
      expect(l10n.statKm, isNotEmpty);
      expect(l10n.sectionDetails, isNotEmpty);
      expect(l10n.sectionSpecs, isNotEmpty);
      expect(l10n.sectionBodyCondition, isNotEmpty);
      expect(l10n.listedOn, isNotEmpty);
      expect(l10n.fieldCondition, isNotEmpty);
      expect(l10n.fieldTransmission, isNotEmpty);
    }
  });

  test('publication date uses locale-aware intl formatting', () {
    final date = DateTime(2026, 6, 17);

    expect(
      formatListingPublicationDate(date, const Locale('en')),
      contains('2026'),
    );
    expect(
      formatListingPublicationDate(date, const Locale('en')),
      isNot(contains('يونيو')),
    );
    expect(
      formatListingPublicationDate(date, const Locale('tr')),
      contains('2026'),
    );
  });

  test('English stat and field labels match expected copy', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.statYear, 'Year');
    expect(l10n.statEngine, 'Engine');
    expect(l10n.sectionDetails, 'Details');
    expect(l10n.listedOn, 'Listed on');
    expect(l10n.fieldFuel, 'Fuel');
  });
}
