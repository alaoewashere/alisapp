import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'app_bootstrap.dart';
import 'core/constants/app_strings.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.beforeSend = (event, hint) {
          final message = event.message?.formatted ?? '';
          if (message.contains('@') || message.contains('+964')) {
            return null;
          }
          return event;
        };
      },
      appRunner: () async {
        await bootstrapSelloApp();
        runApp(
          ProviderScope(
            child: SupabaseConfig.isConfigured
                ? const SouqIqApp()
                : const _SetupRequiredApp(),
          ),
        );
      },
    );
    return;
  }

  await bootstrapSelloApp();
  runApp(
    ProviderScope(
      child: SupabaseConfig.isConfigured
          ? const SouqIqApp()
          : const _SetupRequiredApp(),
    ),
  );
}

class _SetupRequiredApp extends StatelessWidget {
  const _SetupRequiredApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appNameAr,
      home: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appNameAr)),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.setupRequiredTitle,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'أنشئ ملف .env في جذر المشروع أو استخدم:\n\n'
                  'flutter run --dart-define-from-file=env.json\n\n'
                  'SUPABASE_URL=https://YOUR_PROJECT.supabase.co\n'
                  'SUPABASE_ANON_KEY=your-anon-key\n\n'
                  'راجع supabase/README.md للتفاصيل.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
