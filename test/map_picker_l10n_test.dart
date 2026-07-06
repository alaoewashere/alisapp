import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/l10n/app_localizations.dart';

void main() {
  test('location picker strings exist in all supported locales', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.locationPickerTitle, isNotEmpty);
      expect(l10n.locationCoordinates, isNotEmpty);
      expect(l10n.locationUseCurrentLocation, isNotEmpty);
      expect(l10n.locationConfirm, isNotEmpty);
    }
  });

  test('location picker strings match expected translations', () {
    expect(
      lookupAppLocalizations(const Locale('en')).locationPickerTitle,
      'Set Location',
    );
    expect(
      lookupAppLocalizations(const Locale('en')).locationUseCurrentLocation,
      'Use My Current Location',
    );
    expect(
      lookupAppLocalizations(const Locale('tr')).locationConfirm,
      'Konumu Onayla',
    );
    expect(
      lookupAppLocalizations(const Locale('ar')).locationCoordinates,
      'الإحداثيات',
    );
  });
}
