import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/verification_constants.dart';
import 'package:my_app/shared/models/listing_model.dart';
import 'package:my_app/shared/models/profile_model.dart';

void main() {
  final createdAt = DateTime.parse('2026-06-01T00:00:00Z');

  group('ProfileModel verification', () {
    test('isVerifiedSeller when verification_status is verified', () {
      final profile = ProfileModel(
        id: 'u1',
        fullName: 'Ali',
        verificationStatus: VerificationStatus.verified,
        createdAt: createdAt,
      );
      expect(profile.isVerifiedSeller, isTrue);
    });

    test('isVerifiedSeller from legacy is_verified flag', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Ali',
        'is_verified': true,
        'verification_status': 'unverified',
        'created_at': '2026-06-01T00:00:00Z',
      });
      expect(profile.isVerifiedSeller, isTrue);
      expect(profile.verificationStatus, VerificationStatus.verified);
    });
  });

  group('ListingModel seller verification', () {
    test('sellerIsVerified reads verification_status from profile join', () {
      final listing = ListingModel.fromJson({
        'id': 'l1',
        'user_id': 'u1',
        'category_id': 1,
        'title_ar': 'سيارة',
        'description_ar': 'وصف',
        'price': 1000000,
        'city': 'بغداد',
        'governorate': 'baghdad',
        'status': 'approved',
        'availability': 'active',
        'created_at': '2026-06-01T00:00:00Z',
        'profiles': {
          'full_name': 'Ali',
          'verification_status': 'verified',
          'is_verified': false,
        },
      });
      expect(listing.sellerIsVerified, isTrue);
    });
  });
}
