import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Maps API key from `.env` or `--dart-define=GOOGLE_MAPS_API_KEY=...`
abstract final class MapsConfig {
  static String get apiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) return _clean(fromDefine);

    final fromEnv = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return _clean(fromEnv);
    }

    // flutter_dotenv may miss keys if .env was updated without a full restart.
    for (final entry in dotenv.env.entries) {
      if (entry.key.trim() == 'GOOGLE_MAPS_API_KEY') {
        return _clean(entry.value);
      }
    }

    return '';
  }

  static bool get isConfigured => apiKey.isNotEmpty;

  static String _clean(String raw) {
    var value = raw.trim();
    if (value.startsWith('"') && value.endsWith('"') && value.length > 1) {
      value = value.substring(1, value.length - 1);
    }
    if (value.startsWith("'") && value.endsWith("'") && value.length > 1) {
      value = value.substring(1, value.length - 1);
    }
    return value.trim();
  }

  static void logStatus() {
    if (!kDebugMode) return;
    if (isConfigured) {
      debugPrint('MapsConfig: API key loaded (${apiKey.length} chars)');
    } else {
      debugPrint(
        'MapsConfig: GOOGLE_MAPS_API_KEY missing — check .env asset and full restart',
      );
    }
  }
}
