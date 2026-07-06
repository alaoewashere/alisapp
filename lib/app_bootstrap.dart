import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/config/maps_config.dart';
import 'core/supabase/supabase_client.dart';
import 'core/utils/secure_log.dart';
import 'features/chat/widgets/onesignal_handler.dart';

/// Shared startup used by [main] and Patrol / integration tests.
Future<void> bootstrapSelloApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('tr', timeago.TrMessages());

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
      : (dotenv.isInitialized ? dotenv.env['ONESIGNAL_APP_ID'] : null);
  await OneSignalService.initialize(oneSignalAppId);
  if (kDebugMode && oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    SecureLog.debug('OneSignal: initialized');
  } else if (kDebugMode) {
    SecureLog.debug('OneSignal: ONESIGNAL_APP_ID not set — push disabled');
  }
  MapsConfig.logStatus();
}
