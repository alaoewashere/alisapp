import 'package:flutter/foundation.dart';

/// Redacts secrets/PII before logging. Errors only in release builds.
abstract final class SecureLog {
  static final _secretPattern = RegExp(
    r'(api[_-]?key|token|password|secret|authorization|bearer)'
    r'[\s:=]+[\S]+',
    caseSensitive: false,
  );

  static final _emailPattern = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
  );

  static final _phonePattern = RegExp(r'\+964\d{10}');

  static String scrub(String message) {
    var out = message;
    out = out.replaceAll(_phonePattern, '[phone]');
    out = out.replaceAll(_emailPattern, '[email]');
    out = out.replaceAll(_secretPattern, r'$1=[redacted]');
    return out;
  }

  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint(scrub(message));
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode) {
      debugPrint(scrub('ERROR: $message'));
      return;
    }
    debugPrint(scrub('ERROR: $message'));
    if (error != null) {
      debugPrint(scrub(error.toString()));
    }
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }
}
