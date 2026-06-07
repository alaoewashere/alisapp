import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps Supabase auth errors to clear Arabic messages for users.
String authErrorMessage(Object error) {
  if (error is AuthException) {
    if (kDebugMode) {
      debugPrint('AuthException: code=${error.code} message=${error.message}');
    }

    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (code.contains('over_sms_send_rate_limit') ||
        message.contains('rate limit')) {
      return 'طلبات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.';
    }
    if (message.contains('messaging service') &&
        message.contains('no phone numbers')) {
      return 'خدمة Twilio لا تحتوي على أرقام إرسال.\n'
          'Twilio → Messaging → Services → souqiq-otp → Sender Pool → Add Senders';
    }
    if (code.contains('sms_send_failed') ||
        (message.contains('sms') && message.contains('fail'))) {
      return 'تعذّر إرسال الرسالة. تحقق من إعدادات SMS في Supabase.';
    }
    if (message.contains('phone') && message.contains('invalid')) {
      return 'رقم الهاتف غير صالح. استخدم الصيغة +9647XXXXXXXX.';
    }
    if (message.contains('provider') || message.contains('twilio')) {
      return 'مزود SMS غير مُعدّ في Supabase. راجع supabase/README.md';
    }

    return error.message;
  }

  if (kDebugMode) {
    debugPrint('Auth error: $error');
  }
  return 'تعذّر إرسال رمز التحقق. حاول مرة أخرى.';
}
