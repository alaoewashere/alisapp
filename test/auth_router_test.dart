import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/router/app_router.dart';

void main() {
  group('auth route constants', () {
    test('login and legacy phone paths are defined', () {
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.phone, '/phone');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.usernameSetup, '/username-setup');
      expect(AppRoutes.homeNav, '/home');
    });
  });

  group('guest home access', () {
    test('home paths allow guest browsing', () {
      expect(isGuestAllowedPath(AppRoutes.home), isTrue);
      expect(isGuestAllowedPath(AppRoutes.homeNav), isTrue);
    });

    test('login path is not guest-allowed', () {
      expect(isGuestAllowedPath(AppRoutes.login), isFalse);
    });
  });
}
