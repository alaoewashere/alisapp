import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/secure_log.dart';
import '../../../l10n/app_localizations.dart';

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

/// Maps Supabase auth errors to localized user messages.
String authErrorMessage(Object error, AppLocalizations l10n) {
  logAuthError(error);

  if (error is AuthException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (_isNetworkError(error, message, code)) {
      return l10n.authNetworkError;
    }
    if (_isRateLimited(code, message, error.statusCode)) {
      return _rateLimitMessage(error.message, l10n);
    }
    if (message.contains('invalid login credentials') ||
        code.contains('invalid_credentials')) {
      return l10n.authInvalidCredentials;
    }
    if (code.contains('email_address_invalid') ||
        code.contains('invalid_email') ||
        (message.contains('email') &&
            message.contains('invalid') &&
            !message.contains('credentials'))) {
      return l10n.authInvalidEmail;
    }
    if (message.contains('user already registered') ||
        message.contains('already registered') ||
        message.contains('already been registered') ||
        message.contains('email address is already') ||
        code.contains('user_already_exists') ||
        code.contains('email_exists')) {
      return l10n.authEmailExists;
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
      return l10n.validationWeakPassword;
    }
    if (message.contains('email not confirmed')) {
      return l10n.authEmailNotConfirmed;
    }
    if (message.contains('signup') && message.contains('disabled')) {
      return l10n.authSignupDisabled;
    }
    if (code.contains('sms_send_failed') ||
        (message.contains('sms') && message.contains('fail'))) {
      return l10n.authSmsFailed;
    }
    if (message.contains('phone') && message.contains('invalid')) {
      return l10n.authPhoneInvalidFormat;
    }

    return error.message.isNotEmpty ? error.message : l10n.authGenericError;
  }

  if (_isNetworkError(error, error.toString().toLowerCase(), '')) {
    return l10n.authNetworkError;
  }

  return l10n.authOperationFailed;
}

bool _isRateLimited(String code, String message, String? statusCode) {
  if (statusCode == '429') return true;
  return code.contains('over_sms_send_rate_limit') ||
      code.contains('over_email_send_rate_limit') ||
      code.contains('rate_limit') ||
      message.contains('rate limit') ||
      message.contains('rate limit exceeded') ||
      message.contains('you can only request this after');
}

String _rateLimitMessage(String rawMessage, AppLocalizations l10n) {
  final secondsMatch =
      RegExp(r'after (\d+) seconds?', caseSensitive: false).firstMatch(rawMessage);
  final seconds = secondsMatch?.group(1);
  if (seconds != null) {
    return l10n.authRateLimitSeconds(seconds);
  }
  return l10n.authRateLimitGeneric;
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
