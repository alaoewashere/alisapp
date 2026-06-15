import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/auth/data/auth_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('authErrorMessage', () {
    test('maps invalid credentials to Arabic', () {
      const error = AuthException('Invalid login credentials');
      expect(
        authErrorMessage(error),
        'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      );
    });

    test('maps duplicate email signup to Arabic', () {
      const error = AuthException('User already registered');
      expect(
        authErrorMessage(error),
        'هذا البريد مسجل مسبقاً',
      );
    });

    test('maps weak password to Arabic', () {
      const error = AuthException(
        'Password should contain at least one character of each: '
        'abcdefghijklmnopqrstuvwxyz, ABCDEFGHIJKLMNOPQRSTUVWXYZ, 0123456789.',
        statusCode: '422',
        code: 'weak_password',
      );
      expect(
        authErrorMessage(error),
        weakPasswordMessage,
      );
    });

    test('maps email rate limit exceeded to Arabic', () {
      const error = AuthException(
        'email rate limit exceeded',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );
      expect(
        authErrorMessage(error),
        'طلبات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.',
      );
    });

    test('maps network errors to Arabic', () {
      const error = AuthException('Network request failed');
      expect(
        authErrorMessage(error),
        'تحقق من الاتصال بالإنترنت',
      );
    });

    test('maps email signup rate limit to Arabic with wait time', () {
      const error = AuthException(
        'For security purposes, you can only request this after 51 seconds.',
        statusCode: '429',
        code: 'over_email_send_rate_limit',
      );
      expect(
        authErrorMessage(error),
        'طلبات كثيرة. انتظر 51 ثانية ثم حاول مرة أخرى.',
      );
    });

    test('maps invalid email address to Arabic', () {
      const error = AuthException(
        'Email address "appflutter00@gmail.com" is invalid',
        statusCode: '400',
        code: 'email_address_invalid',
      );
      expect(
        authErrorMessage(error),
        'البريد الإلكتروني غير صالح',
      );
    });

    test('returns raw AuthException message when unmapped', () {
      const error = AuthException('Custom provider error');
      expect(authErrorMessage(error), 'Custom provider error');
    });
  });
}
