import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/public_profiles_query.dart';
import '../core/supabase/supabase_client.dart';
import '../models/rating.dart';

final ratingServiceProvider = Provider<RatingService>((ref) {
  return RatingService(ref.watch(supabaseClientProvider));
});

class RatingService {
  RatingService(this._client);

  final SupabaseClient _client;

  static const _ratingSelect = '''
    id,
    listing_id,
    reviewer_id,
    reviewed_id,
    stars,
    review_text,
    created_at,
    listing:listings(title_ar)
  ''';

  /// Submit a rating for another user on a listing.
  Future<void> submitRating({
    required String listingId,
    required String reviewedId,
    required int stars,
    String? reviewText,
  }) async {
    final reviewerId = _client.auth.currentUser?.id;
    if (reviewerId == null) {
      throw const RatingException('يجب تسجيل الدخول لتقييم المستخدم');
    }

    if (reviewedId == reviewerId) {
      throw const RatingException('لا يمكنك تقييم نفسك');
    }

    if (stars < 1 || stars > 5) {
      throw const RatingException('اختر عدد النجوم من 1 إلى 5');
    }

    final profile = await _client
        .from('profiles')
        .select('created_at')
        .eq('id', reviewerId)
        .maybeSingle();

    if (profile != null) {
      final createdAt = DateTime.tryParse(profile['created_at'] as String? ?? '');
      if (createdAt != null) {
        final age = DateTime.now().difference(createdAt).inDays;
        if (age < ratingMinAccountAgeDays) {
          throw const RatingException(
            'يجب أن يمر 7 أيام على إنشاء حسابك لتتمكن من التقييم',
          );
        }
      }
    }

    final todayStart = DateTime.now();
    final utcStart = DateTime.utc(todayStart.year, todayStart.month, todayStart.day);
    final todayCount = await _client
        .from('ratings')
        .select('id')
        .eq('reviewer_id', reviewerId)
        .gte('created_at', utcStart.toIso8601String());

    if ((todayCount as List).length >= ratingDailyLimit) {
      throw const RatingException('وصلت للحد الأقصى من التقييمات اليوم (10)');
    }

    if (await hasRated(listingId)) {
      throw const RatingException('لقد قيّمت هذا الإعلان مسبقاً');
    }

    final trimmedText = reviewText?.trim();
    await _client.from('ratings').insert({
      'listing_id': listingId,
      'reviewer_id': reviewerId,
      'reviewed_id': reviewedId,
      'stars': stars,
      if (trimmedText != null && trimmedText.isNotEmpty)
        'review_text': trimmedText.length > 200
            ? trimmedText.substring(0, 200)
            : trimmedText,
    });
  }

  /// Visible ratings for a profile, newest first.
  Future<List<Rating>> getProfileRatings(
    String profileId, {
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('ratings')
        .select(_ratingSelect)
        .eq('reviewed_id', profileId)
        .eq('hidden', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final rows = (data as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final reviewerIds =
        rows.map((r) => r['reviewer_id'] as String).toSet().toList();
    if (reviewerIds.isNotEmpty) {
      final reviewers = await fetchPublicProfiles(_client, reviewerIds);
      final byId = <String, Map<String, dynamic>>{
        for (final map in reviewers) map['id'] as String: map,
      };
      for (final row in rows) {
        row['reviewer'] = byId[row['reviewer_id'] as String];
      }
    }

    return rows
        .map((row) => Rating.fromJson(row))
        .toList();
  }

  Future<RatingBreakdown> getProfileRatingBreakdown(String profileId) async {
    final rows = await fetchPublicProfiles(_client, [profileId]);
    final profile = rows.isEmpty ? null : rows.first;

    final counts = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    final ratingRows = await _client
        .from('ratings')
        .select('stars')
        .eq('reviewed_id', profileId)
        .eq('hidden', false);

    for (final row in ratingRows as List) {
      final stars = (row['stars'] as num).toInt();
      counts[stars] = (counts[stars] ?? 0) + 1;
    }

    final total = (profile?['rating_count'] as num?)?.toInt() ??
        counts.values.fold<int>(0, (a, b) => a + b);
    final avg = profile?['avg_rating'] != null
        ? (profile!['avg_rating'] as num).toDouble()
        : 0.0;

    return RatingBreakdown(
      counts: counts,
      totalCount: total,
      avgRating: avg,
    );
  }

  /// Whether the signed-in user already rated this listing.
  Future<bool> hasRated(String listingId) async {
    final reviewerId = _client.auth.currentUser?.id;
    if (reviewerId == null) return false;

    final data = await _client
        .from('ratings')
        .select('id')
        .eq('listing_id', listingId)
        .eq('reviewer_id', reviewerId)
        .maybeSingle();

    return data != null;
  }

  /// Last buyer who messaged about this listing (for post-sale rating flow).
  Future<String?> getLastBuyerId({
    required String listingId,
    required String sellerId,
  }) async {
    final data = await _client
        .from('conversations')
        .select('buyer_id')
        .eq('listing_id', listingId)
        .eq('seller_id', sellerId)
        .order('last_message_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return data?['buyer_id'] as String?;
  }

  /// Notify buyer to rate seller after a sale is marked complete.
  Future<void> notifyBuyerToRate({
    required String buyerId,
    required String listingId,
  }) async {
    await _client.rpc('send_rating_request_notification', params: {
      'p_user_id': buyerId,
      'p_listing_id': listingId,
      'p_title': 'قيّم البائع',
      'p_body': 'كيف كانت تجربتك مع البائع؟ قيّمه الآن',
    });
  }
}
