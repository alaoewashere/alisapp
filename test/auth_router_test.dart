import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/router/app_router.dart';

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

    test('marketplace browse paths allow anonymous access', () {
      expect(isGuestAllowedPath('/search'), isTrue);
      expect(isGuestAllowedPath('/categories/1'), isTrue);
      expect(isGuestAllowedPath('/listing/abc-123'), isTrue);
      expect(isGuestAllowedPath('/seller/user-id'), isTrue);
    });

    test('protected paths require sign-in', () {
      expect(isGuestAllowedPath(AppRoutes.profile), isFalse);
      expect(isGuestAllowedPath(AppRoutes.settings), isFalse);
      expect(isGuestAllowedPath(AppRoutes.favorites), isFalse);
    });

    test('login path is not guest-allowed', () {
      expect(isGuestAllowedPath(AppRoutes.login), isFalse);
    });
  });
}
