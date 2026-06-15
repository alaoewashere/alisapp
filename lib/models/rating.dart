class Rating {
  const Rating({
    required this.id,
    required this.listingId,
    required this.reviewerId,
    required this.reviewedId,
    required this.stars,
    this.reviewText,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatarSeed,
    this.listingTitle,
  });

  final String id;
  final String listingId;
  final String reviewerId;
  final String reviewedId;
  final int stars;
  final String? reviewText;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatarSeed;
  final String? listingTitle;

  factory Rating.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] as Map<String, dynamic>?;
    final listing = json['listing'] as Map<String, dynamic>?;

    return Rating(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewedId: json['reviewed_id'] as String,
      stars: (json['stars'] as num).toInt(),
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: reviewer?['full_name'] as String? ??
          reviewer?['display_name'] as String?,
      reviewerAvatarSeed: reviewer?['avatar_seed'] as String?,
      listingTitle: listing?['title_ar'] as String?,
    );
  }
}

/// Star count distribution for a profile (1–5).
class RatingBreakdown {
  const RatingBreakdown({
    required this.counts,
    required this.totalCount,
    required this.avgRating,
  });

  final Map<int, int> counts;
  final int totalCount;
  final double avgRating;

  int countFor(int stars) => counts[stars] ?? 0;

  double fractionFor(int stars) {
    if (totalCount == 0) return 0;
    return countFor(stars) / totalCount;
  }
}

/// Thrown when rating validation fails — message is user-facing Arabic.
class RatingException implements Exception {
  const RatingException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Whether a seller rating badge should appear on listing cards.
bool shouldShowSellerRatingBadge({
  required double avgRating,
  required int ratingCount,
}) {
  return ratingCount >= 10 && avgRating >= 4.0;
}

/// Minimum account age before leaving a rating.
const ratingMinAccountAgeDays = 7;

/// Max ratings a user may submit per calendar day.
const ratingDailyLimit = 10;
