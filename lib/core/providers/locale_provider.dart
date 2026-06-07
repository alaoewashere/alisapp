import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_provider.dart';

const _localeKey = 'locale';

const supportedAppLocales = [
  Locale('ar'),
  Locale('en'),
  Locale('ku'),
];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    Future.microtask(_loadSaved);
    return const Locale('ar');
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'ar';
    state = _localeFromCode(code);
  }

  Locale _localeFromCode(String code) {
    return switch (code) {
      'en' => const Locale('en'),
      'ku' || 'ckb' => const Locale('ku'),
      _ => const Locale('ar'),
    };
  }

  String get currentCode => switch (normalizeAppLocale(state).languageCode) {
        'en' => 'en',
        'ku' => 'ku',
        _ => 'ar',
      };

  Future<void> setLocale(Locale locale) async {
    final normalized = normalizeAppLocale(locale);
    state = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, normalized.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

TextDirection localeTextDirection(Locale locale) {
  return normalizeAppLocale(locale).languageCode == 'en'
      ? TextDirection.ltr
      : TextDirection.rtl;
}

String localeDisplayName(String code) {
  return switch (code) {
    'en' => 'English',
    'ku' => 'کوردی',
    _ => 'العربية',
  };
}

/// Updates timeago locale messages when app language changes.
void syncTimeagoLocale(String languageCode) {
  // timeago is configured in main.dart; call from app when locale changes if needed.
}
