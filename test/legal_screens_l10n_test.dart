import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/l10n/app_localizations.dart';

void main() {
  test('terms and privacy legal content exists in all locales', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.termsTitle, isNotEmpty);
      expect(l10n.termsSection1Body, isNotEmpty);
      expect(l10n.termsSection5Body, isNotEmpty);
      expect(l10n.privacyTitle, isNotEmpty);
      expect(l10n.privacySection1Body, isNotEmpty);
      expect(l10n.privacySection5Body, isNotEmpty);
      expect(l10n.agreeToTerms, isNotEmpty);
      expect(l10n.agreeToPrivacy, isNotEmpty);
    }
  });

  test('English legal pages use English copy', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.termsTitle, 'Terms of Use');
    expect(l10n.termsSection1Title, 'Introduction');
    expect(l10n.privacyTitle, 'Privacy Policy');
    expect(l10n.privacySection1Title, 'What Information We Collect');
    expect(l10n.agreeToTerms, 'I agree to the terms');
  });
}
