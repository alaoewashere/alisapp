import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/secure_log.dart';

/// Logs raw auth errors in development for debugging Supabase responses.
void logAuthError(Object error, [StackTrace? stackTrace]) {
  if (!kDebugMode) return;

  if (error is AuthException) {
    SecureLog.error(
      'AuthException: statusCode=${error.statusCode} code=${error.code}',
      error: error.message,
      stackTrace: stackTrace,
    );
  } else {
    SecureLog.error(
      'Auth error (${error.runtimeType})',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Maps Supabase auth errors to clear Arabic messages for users.
String authErrorMessage(Object error) {
  logAuthError(error);

  if (error is AuthException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (_isNetworkError(error, message, code)) {
      return 'تحقق من الاتصال بالإنترنت';
    }
    if (_isRateLimited(code, message, error.statusCode)) {
      return _rateLimitMessage(error.message);
    }
    if (message.contains('invalid login credentials') ||
        code.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (code.contains('email_address_invalid') ||
        code.contains('invalid_email') ||
        (message.contains('email') &&
            message.contains('invalid') &&
            !message.contains('credentials'))) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('email address is already') ||
        code.contains('user_already_exists') ||
        code.contains('email_exists')) {
      return 'هذا البريد مسجل مسبقاً';
    }
    if (code.contains('weak_password') ||
        message.contains('weak password') ||
        (message.contains('password') &&
            (message.contains('weak') ||
                message.contains('too short') ||
                message.contains('at least') ||
                message.contains('contain at least one') ||
                message.contains('pwned') ||
                message.contains('easy to guess')))) {
      return weakPasswordMessage;
    }
    if (message.contains('email not confirmed')) {
      return 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';
    }
    if (message.contains('signup') && message.contains('disabled')) {
      return 'التسجيل غير متاح حالياً.';
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
    if (message.contains('twilio')) {
      return 'مزود SMS غير مُعدّ في Supabase. راجع supabase/README.md';
    }

    return error.message.isNotEmpty
        ? error.message
        : 'حدث خطأ أثناء المصادقة. حاول مرة أخرى.';
  }

  if (_isNetworkError(error, error.toString().toLowerCase(), '')) {
    return 'تحقق من الاتصال بالإنترنت';
  }

  return 'تعذّر إكمال العملية. حاول مرة أخرى.';
}

const weakPasswordMessage =
    'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، '
    'حرفاً كبيراً وصغيراً، رقماً، ورمزاً خاصاً';

bool _isRateLimited(String code, String message, String? statusCode) {
  if (statusCode == '429') return true;
  return code.contains('over_sms_send_rate_limit') ||
      code.contains('over_email_send_rate_limit') ||
      code.contains('rate_limit') ||
      message.contains('rate limit') ||
      message.contains('rate limit exceeded') ||
      message.contains('you can only request this after');
}

String _rateLimitMessage(String rawMessage) {
  final secondsMatch =
      RegExp(r'after (\d+) seconds?', caseSensitive: false).firstMatch(rawMessage);
  final seconds = secondsMatch?.group(1);
  if (seconds != null) {
    return 'طلبات كثيرة. انتظر $seconds ثانية ثم حاول مرة أخرى.';
  }
  return 'طلبات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.';
}

bool _isNetworkError(Object error, String message, String code) {
  final type = error.runtimeType.toString().toLowerCase();
  if (type.contains('socketexception') ||
      type.contains('clientexception') ||
      type.contains('httpexception')) {
    return true;
  }
  return message.contains('network') ||
      message.contains('connection') ||
      message.contains('socket') ||
      message.contains('timed out') ||
      message.contains('timeout') ||
      message.contains('failed host lookup') ||
      message.contains('no internet') ||
      message.contains('offline') ||
      code.contains('network');
}
