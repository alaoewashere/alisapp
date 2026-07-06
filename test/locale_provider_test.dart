import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sello/core/providers/locale_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setLocale persists to SharedPreferences app_locale key', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await pumpMicrotasks();

    await container.read(localeProvider.notifier).setLocale(const Locale('en'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(appLocaleKey), 'en');
    expect(container.read(localeProvider), const Locale('en'));
  });

  test('loads from app_language when app_locale is missing', () async {
    SharedPreferences.setMockInitialValues({
      appLanguageKey: 'tr',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await pumpMicrotasks();

    expect(container.read(localeProvider), const Locale('tr'));
  });

  test('prefers app_locale over app_language', () async {
    SharedPreferences.setMockInitialValues({
      appLocaleKey: 'en',
      appLanguageKey: 'tr',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await pumpMicrotasks();

    expect(container.read(localeProvider), const Locale('en'));
  });
}

Future<void> pumpMicrotasks() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
