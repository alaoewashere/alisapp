import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../constants/display_locale.dart';
import '../providers/locale_provider.dart';

/// Resolves localized strings for the current [localeProvider] value.
/// Watch this in any widget that must rebuild when language changes.
final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return lookupAppLocalizations(normalizeAppLocale(locale));
});

/// Normalizes saved / device locales to supported app locales.
Locale normalizeAppLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return const Locale('en');
    case 'ku':
    case 'ckb':
      return const Locale('ku');
    case 'tr':
      return const Locale('tr');
    default:
      return const Locale('ar');
  }
}

/// [MaterialApp.locale] — Arabic/Kurdish UI strings with Western digits (0–9).
Locale materialDisplayLocale(Locale appLocale) {
  switch (normalizeAppLocale(appLocale).languageCode) {
    case 'en':
      return const Locale('en');
    case 'tr':
      return const Locale('tr');
    default:
      return const Locale('ar', 'US');
  }
}

/// intl [DateFormat] locale tag — Western digits for Arabic/Kurdish modes.
String intlDisplayLocale(Locale appLocale) {
  switch (normalizeAppLocale(appLocale).languageCode) {
    case 'en':
      return DisplayLocale.intlEnglish;
    case 'tr':
      return 'tr';
    default:
      return DisplayLocale.intlWesternArabic;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// For widgets without [BuildContext] — prefer [appLocalizationsProvider].
AppLocalizations l10nFromRef(WidgetRef ref) => ref.watch(appLocalizationsProvider);
