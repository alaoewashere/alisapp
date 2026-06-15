import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/auth/presentation/profile_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('fullNameFromAuthUser', () {
    test('reads full_name from user metadata', () {
      final user = User(
        id: 'user-1',
        appMetadata: const {},
        userMetadata: const {'full_name': 'Ali Hussain'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(fullNameFromAuthUser(user), 'Ali Hussain');
    });

    test('falls back to name then pending signup', () {
      final user = User(
        id: 'user-1',
        appMetadata: const {},
        userMetadata: const {'name': 'Sara'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      expect(fullNameFromAuthUser(user), 'Sara');
    });
  });
}
