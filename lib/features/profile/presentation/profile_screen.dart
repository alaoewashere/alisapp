import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/validators.dart';
import '../../../services/share_service.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_stats_model.dart';
import '../../../widgets/profile_share_card.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../widgets/user_avatar.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_menu_tile.dart';
import '../../verification/widgets/verification_status_banner.dart';
import '../../../shared/widgets/verified_badge.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../widgets/star_display.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  /// When null, shows the signed-in user's profile.
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final targetId = userId ?? currentUserId;
    final isOwnProfile = userId == null || userId == currentUserId;
    final strings = ref.watch(appLocalizationsProvider);

    if (targetId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(strings.profile),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64),
              const SizedBox(height: 16),
              Text(strings.loginToAccessProfile),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push(AppRoutes.login),
                child: Text(strings.login),
              ),
            ],
          ),
        ),
      );
    }

    final profileAsync = isOwnProfile
        ? ref.watch(myProfileProvider)
        : ref.watch(sellerProfileProvider(targetId));
    final statsAsync = ref.watch(profileStatsProvider(targetId));
    final listingsAsync = ref.watch(sellerListingsPreviewProvider(targetId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: '$e',
          onRetry: () {
            if (isOwnProfile) {
              ref.invalidate(myProfileProvider);
            } else {
              ref.invalidate(sellerProfileProvider(targetId));
            }
          },
        ),
        data: (profile) {
          if (profile == null) {
            return AppErrorWidget(message: strings.profileNotFound);
          }

          if (isOwnProfile) {
            return _OwnProfileView(
              profile: profile,
              statsAsync: statsAsync,
              strings: strings,
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textDark,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  profile.fullName,
                  style: AppFonts.cairo(fontWeight: FontWeight.bold),
                ),
                leading: AppBackButton(onPressed: () => context.pop()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _ProfileHeaderCard(
                    profile: profile,
                    statsAsync: statsAsync,
                    isOwnProfile: false,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.listingsOf(profile.fullName),
                          style: AppFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      listingsAsync.when(
                        data: (items) => Text(
                          arabicNumber(items.length),
                          style: AppFonts.cairo(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              listingsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: ListingGridShimmer(count: 4),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('$e'),
                  ),
                ),
                data: (listings) {
                  if (listings.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyListings(
                        isOwnProfile: false,
                        emptyOwnMessage: strings.noListingsYet,
                        emptyOtherMessage: strings.noActiveListings,
                        addFirstLabel: strings.addFirstListing,
                        onAdd: () => context.push(AppRoutes.post),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ListingCard(listing: listings[i]),
                        childCount: listings.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _OwnProfileView extends ConsumerStatefulWidget {
  const _OwnProfileView({
    required this.profile,
    required this.statsAsync,
    required this.strings,
  });

  final ProfileModel profile;
  final AsyncValue<ProfileStats> statsAsync;
  final AppLocalizations strings;

  @override
  ConsumerState<_OwnProfileView> createState() => _OwnProfileViewState();
}

class _OwnProfileViewState extends ConsumerState<_OwnProfileView> {
  final GlobalKey _profileShareRepaintKey = GlobalKey();
  bool _sharing = false;

  int get _activeListings =>
      widget.statsAsync.value?.activeListings ?? 0;

  bool get _canShareProfile => _activeListings >= 1;

  Future<void> _shareProfile() async {
    if (_sharing || !_canShareProfile) return;

    setState(() => _sharing = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareProfileCard(
        repaintKey: _profileShareRepaintKey,
        profile: widget.profile,
        listingCount: _activeListings,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.strings.shareCardFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final strings = widget.strings;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textDark,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Text(
                strings.myAccount,
                style: AppFonts.cairo(fontWeight: FontWeight.bold),
              ),
              actions: [
                if (_canShareProfile)
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: _sharing ? null : _shareProfile,
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ProfileHeaderCard(
                  profile: profile,
                  statsAsync: widget.statsAsync,
                  isOwnProfile: true,
                  onAvatarTap: () => context.push(AppRoutes.editProfile),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: VerificationStatusBanner(profile: profile),
              ),
            ),
            SliverToBoxAdapter(
              child: _OwnProfileMenu(
                statsAsync: widget.statsAsync,
                onMyListings: () => context.push(AppRoutes.myListings),
                onSmartAlerts: () => context.push(AppRoutes.smartAlerts),
              ),
            ),
            AppBottomNavSliverSpacer(),
          ],
        ),
        if (_sharing)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
        if (_canShareProfile)
          Positioned(
            left: -10000,
            top: 0,
            child: ProfileShareCard(
              repaintKey: _profileShareRepaintKey,
              profile: profile,
              listingCount: _activeListings,
            ),
          ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.statsAsync,
    required this.isOwnProfile,
    this.onAvatarTap,
  });

  final ProfileModel profile;
  final AsyncValue<ProfileStats> statsAsync;
  final bool isOwnProfile;
  final VoidCallback? onAvatarTap;

  String get _locationLine {
    final parts = <String>[];
    if (profile.governorate != null) {
      parts.add(governorateNameAr(profile.governorate!));
    }
    if (profile.city != null && profile.city!.trim().isNotEmpty) {
      parts.add(profile.city!.trim());
    }
    return parts.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.microShadow,
            blurRadius: 40,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      width: 3,
                    ),
                  ),
                  child: UserAvatar(
                    avatarSeed: profile.effectiveAvatarSeed,
                    size: 72,
                  ),
                ),
                if (isOwnProfile)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.fieldCarbon, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.microShadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 14,
                      color: AppColors.canvas,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.fullName,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (profile.isVerifiedSeller) ...[
                const SizedBox(width: 6),
                const VerifiedBadge(size: 20),
              ],
            ],
          ),
          if (profile.ratingCount > 0) ...[
            const SizedBox(height: 8),
            starDisplay(
              rating: profile.avgRating,
              count: profile.ratingCount,
              starSize: 16,
              onTap: () => context.push('/ratings/${profile.id}'),
            ),
          ],
          if (_locationLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _locationLine,
              textAlign: TextAlign.center,
              style: AppFonts.cairo(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (isOwnProfile && profile.hasDisplayPhone) ...[
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                Validators.normalizeE164(profile.phone!),
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          statsAsync.when(
            loading: () => const SizedBox(
              height: 52,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => _ProfileStatsRow(
              stats: stats,
              avgRating: profile.avgRating,
              ratingCount: profile.ratingCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({
    required this.stats,
    required this.avgRating,
    required this.ratingCount,
  });

  final ProfileStats stats;
  final double avgRating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: arabicNumber(stats.activeListings),
              label: strings.listingsLabel,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          Expanded(
            child: _StatColumn(
              value: formatCompactArabic(stats.totalViews),
              label: strings.viewsLabel,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.borderLight),
          Expanded(
            child: _StatColumn(
              // Real seller rating instead of a placeholder followers count.
              value: ratingCount > 0 ? '${avgRating.toStringAsFixed(1)} ★' : '—',
              label: strings.ratingsTitle,
              highlight: ratingCount > 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.volt : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFonts.cairo(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _OwnProfileMenu extends StatelessWidget {
  const _OwnProfileMenu({
    required this.statsAsync,
    required this.onMyListings,
    required this.onSmartAlerts,
  });

  final AsyncValue<ProfileStats> statsAsync;
  final VoidCallback onMyListings;
  final VoidCallback onSmartAlerts;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final adsBadge = statsAsync.maybeWhen(
      data: (s) => arabicNumber(s.activeListings),
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          ProfileMenuEmojiTile(
            title: strings.myListedAds,
            emoji: '📋',
            badge: adsBadge,
            onTap: onMyListings,
          ),
          const SizedBox(height: 10),
          ProfileMenuTile(
            title: strings.mySmartAlerts,
            icon: Icons.notifications_none_outlined,
            onTap: onSmartAlerts,
          ),
        ],
      ),
    );
  }
}

class _EmptyListings extends StatelessWidget {
  const _EmptyListings({
    required this.isOwnProfile,
    required this.emptyOwnMessage,
    required this.emptyOtherMessage,
    required this.addFirstLabel,
    required this.onAdd,
  });

  final bool isOwnProfile;
  final String emptyOwnMessage;
  final String emptyOtherMessage;
  final String addFirstLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.post_add,
            size: 72,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isOwnProfile ? emptyOwnMessage : emptyOtherMessage,
            style: AppFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          if (isOwnProfile) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAdd,
              child: Text(addFirstLabel),
            ),
          ],
        ],
      ),
    );
  }
}
