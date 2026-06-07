import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/fallback_localizations.dart';
import 'core/l10n/l10n_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/widgets/auth_session_handler.dart';
import 'features/chat/widgets/onesignal_handler.dart';
import 'l10n/app_localizations.dart';

class SouqIqApp extends ConsumerWidget {
  const SouqIqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild entire app tree when locale or router config changes.
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final normalized = normalizeAppLocale(locale);
    final strings = ref.watch(appLocalizationsProvider);

    return MaterialApp.router(
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: normalized,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supported) {
        if (deviceLocale == null) return normalized;
        for (final supportedLocale in supported) {
          if (supportedLocale.languageCode == deviceLocale.languageCode) {
            return supportedLocale;
          }
        }
        return normalized;
      },
      localizationsDelegates: appLocalizationDelegates(
        CountryLocalizations.delegate,
      ),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: localeTextDirection(normalized),
          child: AuthSessionHandler(
            child: OneSignalHandler(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
