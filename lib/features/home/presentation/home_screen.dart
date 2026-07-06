import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/secure_log.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/souqly_search_bar.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../providers/home_provider.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_listings_carousel.dart';
import '../widgets/home_heatmap_banner.dart';
import '../widgets/home_heatmap_prefs.dart';
import '../widgets/home_heatmap_tutorial.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/home_section_view_all_link.dart';
import '../models/home_listings_feed_type.dart';
import '../widgets/home_top_bar_icon_button.dart';
import '../widgets/listing_card.dart';
import '../widgets/recent_listings_row.dart';
import '../../notifications/providers/notifications_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _iconFadeInTimer;
  bool _heatmapIconVisible = true;
  bool _showHeatmapTutorial = false;
  bool _heatmapTutorialChecked = false;
  final _heatmapButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleHeatmapTutorialCheck();
    });
  }

  @override
  void dispose() {
    _iconFadeInTimer?.cancel();
    super.dispose();
  }

  void _scheduleHeatmapTutorialCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _heatmapTutorialChecked) return;

      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        SecureLog.debug('Heatmap tutorial: waiting for user id');
        return;
      }

      _heatmapTutorialChecked = true;
      final seen = await hasSeenHeatmapTutorial(userId);
      if (!mounted || seen) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showHeatmapTutorial = true);
      });
    });
  }

  Future<void> _dismissHeatmapTutorial() async {
    if (!_showHeatmapTutorial) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await markHeatmapTutorialSeen(userId);
    }
    if (!mounted) return;
    setState(() => _showHeatmapTutorial = false);
  }

  void _onHeatmapTap(BuildContext context) {
    if (_showHeatmapTutorial) {
      unawaited(_dismissHeatmapTutorial());
    }
    openHomeHeatmap(context);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (ref.read(isHomeSearchActiveProvider)) return false;

    if (notification is ScrollUpdateNotification) {
      _iconFadeInTimer?.cancel();
      final delta = notification.scrollDelta ?? 0;
      if (delta != 0 && _heatmapIconVisible) {
        setState(() => _heatmapIconVisible = false);
      }
    } else if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0) {
        _iconFadeInTimer?.cancel();
        if (!_heatmapIconVisible) {
          setState(() => _heatmapIconVisible = true);
        }
      } else {
        _scheduleHeatmapIconFadeIn();
      }
    }
    return false;
  }

  void _scheduleHeatmapIconFadeIn() {
    _iconFadeInTimer?.cancel();
    _iconFadeInTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (!_heatmapIconVisible) {
        setState(() => _heatmapIconVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserIdProvider, (prev, next) {
      if (next != null && !_heatmapTutorialChecked) {
        _scheduleHeatmapTutorialCheck();
      }
    });

    final isSearchActive = ref.watch(isHomeSearchActiveProvider);
    final isFilterActive = ref.watch(homeFilterActiveProvider);
    final heatmapIconOpaque = isSearchActive || _heatmapIconVisible;
    final strings = ref.watch(appLocalizationsProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: HomeTopBarIconButton(
                        icon: Icons.favorite_border_rounded,
                        tooltip: strings.favoritesTooltip,
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                    ),
                    leadingWidth: 56,
                    title: Text(
                      AppConstants.appNameAr,
                      style: AppFonts.brandNameArDisplay(
                        fontSize: 32,
                        color: AppColors.pureWhite,
                        letterSpacing: 1.0,
                        height: 1.1,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: _NotificationsBell(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: heatmapIconOpaque ? 1 : 0.28,
                          child: HomeTopBarIconButton(
                            key: _heatmapButtonKey,
                            icon: Icons.map_outlined,
                            tooltip: strings.heatmapTooltip,
                            onTap: () => _onHeatmapTap(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => refreshHomeProviders(ref),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverToBoxAdapter(child: HomeHeroSection()),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: _HomeSearchBar(),
                            ),
                          ),
                          if (!isSearchActive) ...[
                            SliverToBoxAdapter(child: _HomeCategoriesHeader()),
                            SliverToBoxAdapter(child: _HomeCategoriesSection()),
                            const SliverToBoxAdapter(child: _HomeTierFilterRow()),
                            if (isFilterActive) ...[
                              const _HomeFilteredSection(),
                            ] else ...[
                              SliverToBoxAdapter(child: _HomeFeaturedSection()),
                              SliverToBoxAdapter(
                                child: _HomeRecentListingsHeader(),
                              ),
                              _HomeRecentListingsSection(),
                            ],
                          ] else ...[
                            _HomeSearchResultsSection(),
                          ],
                          AppBottomNavSliverSpacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showHeatmapTutorial && !isSearchActive)
              HomeHeatmapTutorialOverlay(
                targetKey: _heatmapButtonKey,
                onDismiss: _dismissHeatmapTutorial,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeSearchBar extends ConsumerStatefulWidget {
  const _HomeSearchBar();

  @override
  ConsumerState<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends ConsumerState<_HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(homeSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return SouqlySearchBar(
      hint: strings.homeExtendedSearchHint,
      controller: _controller,
      onChanged: (value) {
        ref.read(homeSearchQueryProvider.notifier).update(value);
      },
    );
  }
}

/// Header bell that opens the notifications inbox, with an unread-count badge.
class _NotificationsBell extends ConsumerWidget {
  const _NotificationsBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        HomeTopBarIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: strings.notifications,
          onTap: () => context.push(AppRoutes.notifications),
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.volt,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.canvas,
                  height: 1.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeCategoriesHeader extends StatelessWidget {
  const _HomeCategoriesHeader();

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            strings.browseCategories,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.push(AppRoutes.search),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              strings.viewAll,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoriesSection extends ConsumerWidget {
  const _HomeCategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    // Warm the parent map so category filtering resolves instantly on tap.
    ref.watch(categoryParentMapProvider);

    return categoriesAsync.when(
      data: (categories) => CategoryGrid(
        categories: categories,
        // Tapping a pill filters the home feed in place; tapping it again clears.
        selectedId: selectedCategory,
        onSelected: (id) {
          if (id != null) {
            ref.read(selectedCategoryProvider.notifier).toggle(id);
          }
        },
      ),
      loading: () => const CategoryGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: context.l10n.failedLoadCategories,
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
    );
  }
}

/// Package-tier filter chips (مميز / برو / عادي) for the home feed.
class _HomeTierFilterRow extends ConsumerWidget {
  const _HomeTierFilterRow();

  static String _label(HomeTierFilter tier) => switch (tier) {
        HomeTierFilter.premium => 'مميز',
        HomeTierFilter.pro => 'برو',
        HomeTierFilter.standard => 'عادي',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeTierFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < HomeTierFilter.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _TierChip(
                label: _label(HomeTierFilter.values[i]),
                selected: selected == HomeTierFilter.values[i],
                onTap: () => ref
                    .read(homeTierFilterProvider.notifier)
                    .toggle(HomeTierFilter.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.volt : AppColors.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.canvas : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// In-place filtered grid shown on the home screen when a category and/or
/// tier filter is active. Sources from the loaded featured + latest pools.
class _HomeFilteredSection extends ConsumerWidget {
  const _HomeFilteredSection();

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.68,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final featured = ref.watch(featuredListingsProvider);
    final latest = ref.watch(latestHomeListingsProvider);
    final parentMap = ref.watch(categoryParentMapProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filtered = ref.watch(homeFilteredFeedProvider);

    final stillLoading = featured.isLoading ||
        latest.isLoading ||
        (selectedCategory != null && parentMap.isLoading);

    if (stillLoading && filtered.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (_, _) => const ShimmerBox(width: 160, height: 200),
            childCount: 4,
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              strings.searchResultsCount('${filtered.length}'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              message: strings.noListings,
              icon: Icons.storefront_outlined,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            sliver: SliverGrid(
              gridDelegate: _gridDelegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) => StaggeredEntrance(
                  index: index,
                  child: ListingCard(listing: filtered[index]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeFeaturedSection extends ConsumerWidget {
  const _HomeFeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredListingsProvider);

    return featuredAsync.when(
      data: (listings) {
        if (listings.isEmpty) return const SizedBox.shrink();
        return FeaturedListingsCarousel(
          listings: listings,
          viewAllLink: HomeSectionViewAllLink(
            onPressed: () => context.push(
              AppRoutes.homeFeedPath(HomeListingsFeedType.featured),
            ),
          ),
        );
      },
      loading: () => const FeaturedListingsCarouselShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _HomeRecentListingsHeader extends StatelessWidget {
  const _HomeRecentListingsHeader();

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            strings.latestListingsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const Spacer(),
          HomeSectionViewAllLink(
            onPressed: () => context.push(
              AppRoutes.homeFeedPath(HomeListingsFeedType.latest),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRecentListingsSection extends ConsumerWidget {
  const _HomeRecentListingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(latestHomeListingsProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return recentAsync.when(
      loading: () => const SliverToBoxAdapter(child: RecentListingsRowShimmer()),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorWidget(
          message: strings.failedLoadListings,
          onRetry: () => ref.invalidate(latestHomeListingsProvider),
        ),
      ),
      data: (listings) {
        if (listings.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              message: strings.noListings,
              icon: Icons.storefront_outlined,
            ),
          );
        }
        return SliverToBoxAdapter(
          child: RecentListingsRow(listings: listings),
        );
      },
    );
  }
}

class _HomeSearchResultsSection extends ConsumerWidget {
  const _HomeSearchResultsSection();

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.68,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(latestHomeListingsProvider);
    final filtered = ref.watch(filteredHomeListingsProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return recentAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (_, _) => const ShimmerBox(width: 160, height: 200),
            childCount: 4,
          ),
        ),
      ),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorWidget(
          message: strings.failedLoadListings,
          onRetry: () => ref.invalidate(latestHomeListingsProvider),
        ),
      ),
      data: (_) {
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  strings.searchResultsCount('${filtered.length}'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  message: strings.noResults,
                  icon: Icons.search_off_rounded,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                sliver: SliverGrid(
                  gridDelegate: _gridDelegate,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ListingCard(listing: filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
