import 'package:flutter/foundation.dart';

/// Groq is proxied via the authenticated `groq-proxy` edge function.
/// No client API key is required.
abstract final class GroqConfig {
  static bool get isConfigured => true;

  static void logStatus() {
    if (!kDebugMode) return;
    debugPrint('GroqConfig: using server-side groq-proxy edge function');
  }
}
