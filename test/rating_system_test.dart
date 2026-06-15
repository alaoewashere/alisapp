import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/models/rating.dart';

void main() {
  group('shouldShowSellerRatingBadge', () {
    test('shows when count >= 10 and avg >= 4.0', () {
      expect(
        shouldShowSellerRatingBadge(avgRating: 4.8, ratingCount: 18),
        isTrue,
      );
    });

    test('hides when count below 10', () {
      expect(
        shouldShowSellerRatingBadge(avgRating: 5.0, ratingCount: 9),
        isFalse,
      );
    });

    test('hides when avg below 4.0', () {
      expect(
        shouldShowSellerRatingBadge(avgRating: 3.9, ratingCount: 20),
        isFalse,
      );
    });
  });

  group('Rating.fromJson', () {
    test('parses joined reviewer and listing', () {
      final rating = Rating.fromJson({
        'id': 'r1',
        'listing_id': 'l1',
        'reviewer_id': 'u1',
        'reviewed_id': 'u2',
        'stars': 5,
        'review_text': 'ممتاز',
        'created_at': '2026-06-01T10:00:00Z',
        'reviewer': {'full_name': 'أحمد', 'avatar_seed': 'Felix'},
        'listing': {'title_ar': 'سيارة'},
      });

      expect(rating.stars, 5);
      expect(rating.reviewerName, 'أحمد');
      expect(rating.listingTitle, 'سيارة');
    });
  });

  group('RatingBreakdown', () {
    test('computes fractions', () {
      final breakdown = RatingBreakdown(
        counts: {5: 8, 4: 2, 3: 0, 2: 0, 1: 0},
        totalCount: 10,
        avgRating: 4.8,
      );

      expect(breakdown.fractionFor(5), closeTo(0.8, 0.001));
      expect(breakdown.fractionFor(4), closeTo(0.2, 0.001));
    });
  });
}
