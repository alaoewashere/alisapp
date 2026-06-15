import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/app_constants.dart';
import 'package:my_app/core/utils/video_utils.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  group('formatVideoDuration', () {
    test('formats seconds as m:ss', () {
      expect(formatVideoDuration(42), '0:42');
      expect(formatVideoDuration(125), '2:05');
    });
  });

  group('validateVideoConstraints', () {
    test('accepts valid video', () {
      final result = validateVideoConstraints(
        durationSeconds: 45,
        fileSizeBytes: 50 * 1024 * 1024,
      );
      expect(result.isValid, isTrue);
      expect(result.durationSeconds, 45);
    });

    test('rejects over 60 seconds', () {
      final result = validateVideoConstraints(
        durationSeconds: 61,
        fileSizeBytes: 1024,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('60'));
    });

    test('rejects over 200MB', () {
      final result = validateVideoConstraints(
        durationSeconds: 30,
        fileSizeBytes: AppConstants.maxListingVideoBytes + 1,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('200'));
    });
  });

  group('ListingPackage video gate', () {
    test('pro and premium allow video', () {
      expect(ListingPackage.pro.allowsListingVideo, isTrue);
      expect(ListingPackage.premium.allowsListingVideo, isTrue);
      expect(ListingPackage.standard.allowsListingVideo, isFalse);
    });
  });
}
