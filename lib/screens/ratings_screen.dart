import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../core/constants/app_colors.dart';
import '../core/constants/display_locale.dart';
import '../core/utils/arabic_number.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';
import '../widgets/star_display.dart';
import '../widgets/user_avatar.dart';
import '../features/profile/providers/profile_provider.dart';

/// Full ratings list for a user profile.
class RatingsScreen extends ConsumerStatefulWidget {
  const RatingsScreen({super.key, required this.profileId});

  final String profileId;

  @override
  ConsumerState<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends ConsumerState<RatingsScreen> {
  static const _pageSize = 20;

  RatingBreakdown? _breakdown;
  List<Rating> _ratings = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(ratingServiceProvider);
      final results = await Future.wait([
        service.getProfileRatingBreakdown(widget.profileId),
        service.getProfileRatings(widget.profileId, limit: _pageSize),
      ]);
      if (!mounted) return;
      setState(() {
        _breakdown = results[0] as RatingBreakdown;
        _ratings = results[1] as List<Rating>;
        _hasMore = _ratings.length >= _pageSize;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final more = await ref.read(ratingServiceProvider).getProfileRatings(
            widget.profileId,
            offset: _ratings.length,
            limit: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _ratings = [..._ratings, ...more];
        _hasMore = more.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(sellerProfileProvider(widget.profileId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'التقييمات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('الملف غير موجود'));
          }

          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadInitial,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final breakdown = _breakdown!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RatingsHeader(
                profileName: profile.fullName,
                avatarSeed: profile.effectiveAvatarSeed,
                breakdown: breakdown,
              ),
              const SizedBox(height: 20),
              _StarBreakdownChart(breakdown: breakdown),
              const SizedBox(height: 24),
              if (_ratings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'لا توجد تقييمات بعد',
                      style: GoogleFonts.cairo(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ..._ratings.map((r) => _ReviewTile(rating: r)),
              if (_hasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  child: OutlinedButton(
                    onPressed: _loadingMore ? null : _loadMore,
                    child: _loadingMore
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('تحميل المزيد'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingsHeader extends StatelessWidget {
  const _RatingsHeader({
    required this.profileName,
    required this.avatarSeed,
    required this.breakdown,
  });

  final String profileName;
  final String avatarSeed;
  final RatingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(avatarSeed: avatarSeed, size: 72),
        const SizedBox(height: 12),
        Text(
          profileName,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        starDisplay(
          rating: breakdown.avgRating,
          count: breakdown.totalCount,
          starSize: 24,
        ),
      ],
    );
  }
}

class _StarBreakdownChart extends StatelessWidget {
  const _StarBreakdownChart({required this.breakdown});

  final RatingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = breakdown.countFor(stars);
        final fraction = breakdown.fractionFor(stars);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$stars ★',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: AppColors.borderLight,
                    color: const Color(0xFFF5A623),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  arabicNumber(count),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.rating});

  final Rating rating;

  String get _dateLabel {
    return DateFormat('d MMM yyyy', DisplayLocale.intlWesternArabic)
        .format(rating.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final reviewText = rating.reviewText?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(
                avatarSeed: rating.reviewerAvatarSeed,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.reviewerName ?? 'مستخدم',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    starDisplay(
                      rating: rating.stars.toDouble(),
                      count: 1,
                      starSize: 12,
                      showCount: false,
                    ),
                  ],
                ),
              ),
              Text(
                _dateLabel,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reviewText != null && reviewText.isNotEmpty
                ? reviewText
                : 'لم يترك تعليقاً',
            style: GoogleFonts.cairo(
              fontSize: 13,
              height: 1.5,
              color: reviewText != null && reviewText.isNotEmpty
                  ? AppColors.textDark
                  : AppColors.textMuted,
              fontStyle: reviewText != null && reviewText.isNotEmpty
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
