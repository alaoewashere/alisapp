import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
    default:
      return const Locale('ar');
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// For widgets without [BuildContext] — prefer [appLocalizationsProvider].
AppLocalizations l10nFromRef(WidgetRef ref) => ref.watch(appLocalizationsProvider);
