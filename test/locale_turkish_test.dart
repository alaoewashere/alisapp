import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/l10n/l10n_provider.dart';
import 'package:Sello/core/providers/locale_provider.dart';

void main() {
  group('Turkish locale', () {
    test('normalizeAppLocale accepts tr', () {
      expect(normalizeAppLocale(const Locale('tr')), const Locale('tr'));
    });

    test('localeTextDirection is LTR for Turkish', () {
      expect(
        localeTextDirection(const Locale('tr')),
        TextDirection.ltr,
      );
    });

    test('localeDisplayName returns Türkçe', () {
      expect(localeDisplayName('tr'), 'Türkçe');
    });
  });
}
