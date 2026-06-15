import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Groq API key from `.env` or `--dart-define=GROQ_API_KEY=...`
abstract final class GroqConfig {
  static String get apiKey {
    const fromDefine = String.fromEnvironment('GROQ_API_KEY');
    if (fromDefine.isNotEmpty) return _clean(fromDefine);

    final fromEnv = dotenv.env['GROQ_API_KEY'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return _clean(fromEnv);
    }

    for (final entry in dotenv.env.entries) {
      if (entry.key.trim() == 'GROQ_API_KEY') {
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
      debugPrint('GroqConfig: API key loaded (${apiKey.length} chars)');
    } else {
      debugPrint(
        'GroqConfig: GROQ_API_KEY missing — check .env asset and full restart',
      );
    }
  }
}
