import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_provider.dart';

const appLanguageKey = 'app_language';
const languageOnboardingCompleteKey = 'language_onboarding_complete';
const _legacyLocaleKey = 'locale';

const supportedAppLocales = [
  Locale('ar'),
  Locale('en'),
  Locale('ku'),
  Locale('tr'),
];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    Future.microtask(_loadSaved);
    return const Locale('ar');
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(appLanguageKey) ??
        prefs.getString(_legacyLocaleKey) ??
        'ar';
    state = _localeFromCode(code);
  }

  Locale _localeFromCode(String code) {
    return switch (code) {
      'en' => const Locale('en'),
      'ku' || 'ckb' => const Locale('ku'),
      'tr' => const Locale('tr'),
      _ => const Locale('ar'),
    };
  }

  String get currentCode => switch (normalizeAppLocale(state).languageCode) {
        'en' => 'en',
        'ku' => 'ku',
        'tr' => 'tr',
        _ => 'ar',
      };

  Future<void> setLocale(Locale locale) async {
    final normalized = normalizeAppLocale(locale);
    state = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLanguageKey, normalized.languageCode);
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(languageOnboardingCompleteKey, true);
  }
}

/// True after the user finishes the first-launch language picker.
Future<bool> isLanguageOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(languageOnboardingCompleteKey) ?? false;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

TextDirection localeTextDirection(Locale locale) {
  return switch (normalizeAppLocale(locale).languageCode) {
    'en' || 'tr' => TextDirection.ltr,
    _ => TextDirection.rtl,
  };
}

String localeDisplayName(String code) {
  return switch (code) {
    'en' => 'English',
    'ku' => 'کوردی',
    'tr' => 'Türkçe',
    _ => 'العربية',
  };
}

/// Updates timeago locale messages when app language changes.
void syncTimeagoLocale(String languageCode) {
  // timeago is configured in main.dart; call from app when locale changes if needed.
}
