import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/l10n/fallback_localizations.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_stats_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/profile_provider.dart';

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
        appBar: AppBar(title: Text(strings.profile)),
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

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(isOwnProfile ? strings.myAccount : profile.fullName),
                leading: isOwnProfile
                    ? null
                    : BackButton(onPressed: () => context.pop()),
                automaticallyImplyLeading: !isOwnProfile,
                actions: isOwnProfile
                    ? [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => context.push(AppRoutes.settings),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.push(AppRoutes.editProfile),
                        ),
                      ]
                    : null,
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  profile: profile,
                  statsAsync: statsAsync,
                  isOwnProfile: isOwnProfile,
                  memberSinceLabel: strings.memberSince(
                    DateFormat('MMMM yyyy', intlLocaleFor(strings.localeName))
                        .format(profile.createdAt),
                  ),
                  listingsLabel: strings.listingsLabel,
                  viewsLabel: strings.viewsLabel,
                  activeLabel: strings.activeLabel,
                  onAvatarTap: isOwnProfile
                      ? () => context.push(AppRoutes.editProfile)
                      : null,
                ),
              ),
              if (isOwnProfile)
                SliverToBoxAdapter(
                  child: _QuickActionsRow(
                    myListingsLabel: strings.myListings,
                    favoritesLabel: strings.favorites,
                    messagesLabel: strings.messages,
                    onMyListings: () => context.push(AppRoutes.myListings),
                    onFavorites: () => context.push(AppRoutes.favorites),
                    onMessages: () => context.go(AppRoutes.conversations),
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      listingsAsync.when(
                        data: (items) => Text(
                          arabicNumber(items.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      if (isOwnProfile)
                        TextButton(
                          onPressed: () => context.push(AppRoutes.myListings),
                          child: Text(strings.viewAllListings),
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
                        isOwnProfile: isOwnProfile,
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.statsAsync,
    required this.isOwnProfile,
    required this.memberSinceLabel,
    required this.listingsLabel,
    required this.viewsLabel,
    required this.activeLabel,
    this.onAvatarTap,
  });

  final ProfileModel profile;
  final AsyncValue<ProfileStats> statsAsync;
  final bool isOwnProfile;
  final String memberSinceLabel;
  final String listingsLabel;
  final String viewsLabel;
  final String activeLabel;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: profile.avatarUrl != null
                      ? CachedNetworkImageProvider(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 36),
                        )
                      : null,
                ),
                if (isOwnProfile)
                  const CircleAvatar(
                    radius: 14,
                    child: Icon(Icons.camera_alt, size: 14),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                Icon(Icons.verified, color: theme.colorScheme.primary, size: 22),
              ],
            ],
          ),
          if (isOwnProfile && profile.phone != null) ...[
            const SizedBox(height: 4),
            Text(profile.phone!, style: theme.textTheme.bodyMedium),
          ],
          if (profile.governorate != null) ...[
            const SizedBox(height: 4),
            Text(governorateNameAr(profile.governorate!)),
          ],
          const SizedBox(height: 4),
          Text(
            memberSinceLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  value: arabicNumber(stats.totalListings),
                  label: listingsLabel,
                ),
                _StatItem(
                  value: arabicNumber(stats.totalViews),
                  label: viewsLabel,
                ),
                _StatItem(
                  value: arabicNumber(stats.activeListings),
                  label: activeLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.myListingsLabel,
    required this.favoritesLabel,
    required this.messagesLabel,
    required this.onMyListings,
    required this.onFavorites,
    required this.onMessages,
  });

  final String myListingsLabel;
  final String favoritesLabel;
  final String messagesLabel;
  final VoidCallback onMyListings;
  final VoidCallback onFavorites;
  final VoidCallback onMessages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionChip(
              icon: Icons.list_alt,
              label: myListingsLabel,
              onTap: onMyListings,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.favorite_border,
              label: favoritesLabel,
              onTap: onFavorites,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionChip(
              icon: Icons.chat_bubble_outline,
              label: messagesLabel,
              onTap: onMessages,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
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
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            isOwnProfile ? emptyOwnMessage : emptyOtherMessage,
            style: Theme.of(context).textTheme.titleMedium,
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
