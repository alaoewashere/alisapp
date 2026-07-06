import 'dart:async';

import '../core/supabase/supabase_client.dart';
import '../core/utils/secure_log.dart';

/// On-the-fly translation for user-generated listing text via the authenticated
/// `groq-proxy` edge function. The Groq API key stays server-side (Supabase
/// secret) and is never shipped in the app binary.
class TranslationService {
  TranslationService._();

  static final Map<String, String> _cache = {};
  static const _timeout = Duration(seconds: 20);

  static String _cacheKey(String text, String targetLang) =>
      '${text.hashCode}_$targetLang';

  static String _targetLanguageName(String code) => switch (code) {
        'en' => 'English',
        'ku' => 'Kurdish (Sorani)',
        'tr' => 'Turkish',
        _ => code,
      };

  /// Returns [text] unchanged when target is Arabic, empty, the user is not
  /// signed in (the proxy is authenticated), or translation fails.
  static Future<String> translate(String text, String targetLang) async {
    final trimmed = text.trim();
    if (targetLang == 'ar' || trimmed.isEmpty) return text;

    final cacheKey = _cacheKey(trimmed, targetLang);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final langName = _targetLanguageName(targetLang);
    final body = {
      'temperature': 0.1,
      'max_tokens': 300,
      'messages': [
        {
          'role': 'system',
          'content': 'Translate the following text to $langName. '
              'Return ONLY the translated text with no explanation.',
        },
        {'role': 'user', 'content': trimmed},
      ],
    };

    try {
      // The groq-proxy requires a signed-in session; guests (and any context
      // where Supabase is not initialised, e.g. tests) fall back to source.
      if (supabase.auth.currentSession == null) return text;

      final response = await supabase.functions
          .invoke('groq-proxy', body: body)
          .timeout(_timeout);

      if (response.status < 200 || response.status >= 300) {
        SecureLog.debug('TranslationService: proxy ${response.status}');
        return text;
      }

      final decoded = response.data;
      if (decoded is! Map<String, dynamic>) return text;

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) return text;

      final message = (choices.first as Map)['message'];
      if (message is! Map<String, dynamic>) return text;

      final content = message['content'];
      if (content is! String) return text;

      final translated = content.trim();
      if (translated.isEmpty) return text;

      _cache[cacheKey] = translated;
      return translated;
    } on TimeoutException {
      SecureLog.debug('TranslationService: timed out');
      return text;
    } catch (e) {
      SecureLog.debug('TranslationService: failed: $e');
      return text;
    }
  }

  /// Clears in-memory translation cache (e.g. on locale change).
  static void clearCache() => _cache.clear();

  /// Clears in-memory cache (for tests).
  static void clearCacheForTesting() => clearCache();
}
