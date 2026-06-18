import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/shared/models/profile_model.dart';

void main() {
  group('ProfileModel phoneVerified', () {
    test('parses phone_verified from json', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Test',
        'phone': '+9647901234567',
        'phone_verified': true,
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(profile.phoneVerified, isTrue);
      expect(profile.phone, '+9647901234567');
    });

    test('defaults phone_verified to false', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Test',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(profile.phoneVerified, isFalse);
    });
  });
}
