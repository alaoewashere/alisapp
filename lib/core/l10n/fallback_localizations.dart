import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../l10n/app_localizations.dart';

/// Flutter's built-in Material/Cupertino delegates do not support Kurdish (`ku`).
/// Map framework locales to the closest supported locale while [AppLocalizations]
/// continues to serve Kurdish strings from app_ku.arb.
Locale frameworkLocaleFor(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return const Locale('en');
    case 'ku':
    case 'ckb':
      // Arabic: RTL + full Material/Cupertino coverage for Kurdish UI mode.
      return const Locale('ar');
    default:
      return const Locale('ar');
  }
}

/// intl [DateFormat] does not support `ku`; reuse the framework fallback locale.
String intlLocaleFor(String languageCode) =>
    frameworkLocaleFor(Locale(languageCode)).languageCode;

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate
        .load(frameworkLocaleFor(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate
        .load(frameworkLocaleFor(locale));
  }

  @override
  bool shouldReload(
          covariant LocalizationsDelegate<CupertinoLocalizations> old) =>
      false;
}

class FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return GlobalWidgetsLocalizations.delegate
        .load(frameworkLocaleFor(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) =>
      false;
}

/// MaterialApp delegates: Kurdish app strings + framework fallback for `ku`.
List<LocalizationsDelegate<dynamic>> appLocalizationDelegates(
  LocalizationsDelegate<dynamic> extraDelegate,
) {
  return [
    AppLocalizations.delegate,
    const FallbackMaterialLocalizationsDelegate(),
    const FallbackCupertinoLocalizationsDelegate(),
    const FallbackWidgetsLocalizationsDelegate(),
    extraDelegate,
  ];
}
