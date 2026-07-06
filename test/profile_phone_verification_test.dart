import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/shared/models/profile_model.dart';

void main() {
  group('ProfileModel phone', () {
    test('hasDisplayPhone when phone is set', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Test',
        'phone': '+9647901234567',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(profile.hasDisplayPhone, isTrue);
      expect(profile.phone, '+9647901234567');
    });

    test('hasDisplayPhone is false when phone missing', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Test',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(profile.hasDisplayPhone, isFalse);
    });
  });
}
