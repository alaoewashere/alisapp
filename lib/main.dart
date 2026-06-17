import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/config/groq_config.dart';
import 'core/config/maps_config.dart';
import 'core/constants/app_strings.dart';
import 'core/supabase/supabase_client.dart';
import 'core/utils/secure_log.dart';
import 'features/chat/widgets/onesignal_handler.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (kDebugMode) {
      SecureLog.debug(
        'dotenv: no bundled .env — use --dart-define-from-file=env.json for release',
      );
    }
  }

  await initializeSupabase();
  await SharedPreferences.getInstance();

  final oneSignalAppId = const String.fromEnvironment('ONESIGNAL_APP_ID').isNotEmpty
      ? const String.fromEnvironment('ONESIGNAL_APP_ID')
      : dotenv.env['ONESIGNAL_APP_ID'];
  await OneSignalService.initialize(oneSignalAppId);
  if (kDebugMode && oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    SecureLog.debug('OneSignal: initialized');
  } else if (kDebugMode) {
    SecureLog.debug('OneSignal: ONESIGNAL_APP_ID not set — push disabled');
  }
  MapsConfig.logStatus();
  GroqConfig.logStatus();
}

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
        await _bootstrap();
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

  await _bootstrap();
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
