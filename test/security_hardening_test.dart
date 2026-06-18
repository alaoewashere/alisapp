import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/supabase/public_profiles_query.dart';
import 'package:Sello/core/utils/secure_log.dart';
import 'package:Sello/shared/models/profile_model.dart';

void main() {
  group('publicProfileSelect', () {
    test('exposes seller fields without email or push ids', () {
      expect(publicProfileSelect, contains('rejection_reason'));
      expect(publicProfileSelect, isNot(contains('email')));
      expect(publicProfileSelect, isNot(contains('onesignal')));
    });
  });

  group('SecureLog', () {
    test('scrubs email and phone from messages', () {
      const raw =
          'user=test@example.com phone=+9647701234567 token=abc123secret';
      final scrubbed = SecureLog.scrub(raw);
      expect(scrubbed, isNot(contains('test@example.com')));
      expect(scrubbed, isNot(contains('+9647701234567')));
      expect(scrubbed, contains('[email]'));
      expect(scrubbed, contains('[phone]'));
    });
  });

  group('ProfileModel.toUpdateJson', () {
    test('omits protected verification and rating fields', () {
      final profile = ProfileModel(
        id: 'user-1',
        fullName: 'Seller',
        isVerified: true,
        verificationStatus: 'verified',
        avgRating: 4.5,
        ratingCount: 10,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = profile.toUpdateJson();
      expect(json.containsKey('is_verified'), isFalse);
      expect(json.containsKey('verification_status'), isFalse);
      expect(json.containsKey('avg_rating'), isFalse);
      expect(json.containsKey('rating_count'), isFalse);
    });
  });
}
