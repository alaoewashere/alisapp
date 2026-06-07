import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'app.dart';
import 'core/config/maps_config.dart';
import 'core/constants/app_strings.dart';
import 'core/supabase/supabase_client.dart';
import 'features/chat/widgets/onesignal_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  await dotenv.load(fileName: '.env');
  if (kDebugMode && !dotenv.isEveryDefined(['GOOGLE_MAPS_API_KEY'])) {
    debugPrint(
      'dotenv: GOOGLE_MAPS_API_KEY not in bundled .env — stop app and run '
      'flutter run (hot restart does not reload .env assets)',
    );
  }
  await initializeSupabase();
  final oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'];
  await OneSignalService.initialize(oneSignalAppId);
  if (kDebugMode && oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    debugPrint('OneSignal: initialized with app id ${oneSignalAppId.substring(0, 8)}...');
  } else if (kDebugMode) {
    debugPrint('OneSignal: ONESIGNAL_APP_ID not set in .env — push disabled');
  }
  MapsConfig.logStatus();

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
                  'أنشئ ملف .env في جذر المشروع:\n\n'
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
