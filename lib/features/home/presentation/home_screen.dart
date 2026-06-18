import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_navigation.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/souqly_search_bar.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _iconFadeInTimer;
  bool _heatmapIconVisible = true;
  bool _showHeatmapTutorial = false;
  final _heatmapButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadHeatmapTutorialState();
  }

  @override
  void dispose() {
    _iconFadeInTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHeatmapTutorialState() async {
    final seen = await hasSeenHeatmapTutorial();
    if (!mounted || seen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showHeatmapTutorial = true);
    });
  }

  Future<void> _dismissHeatmapTutorial() async {
    if (!_showHeatmapTutorial) return;
    await markHeatmapTutorialSeen();
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
    final isSearchActive = ref.watch(isHomeSearchActiveProvider);
    final heatmapIconOpaque = isSearchActive || _heatmapIconVisible;

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
                        tooltip: 'المفضلة',
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                    ),
                    leadingWidth: 56,
                    title: const AppLogo(size: 46),
                    centerTitle: true,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: heatmapIconOpaque ? 1 : 0.28,
                          child: HomeTopBarIconButton(
                            key: _heatmapButtonKey,
                            icon: Icons.map_outlined,
                            tooltip: 'كثافة الإعلانات',
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
                            SliverToBoxAdapter(child: _HomeFeaturedSection()),
                            SliverToBoxAdapter(
                              child: _HomeRecentListingsHeader(),
                            ),
                            _HomeRecentListingsSection(),
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
    return SouqlySearchBar(
      hint: 'ابحث عن سيارات، شقق، إلكترونيات...',
      controller: _controller,
      onChanged: (value) {
        ref.read(homeSearchQueryProvider.notifier).update(value);
      },
    );
  }
}

class _HomeCategoriesHeader extends StatelessWidget {
  const _HomeCategoriesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            'تصفح الفئات',
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
            child: const Text(
              'عرض الكل',
              style: TextStyle(
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

    return categoriesAsync.when(
      data: (categories) => CategoryGrid(
        categories: categories,
        selectedId: selectedCategory,
        onSelected: (id) =>
            ref.read(selectedCategoryProvider.notifier).select(id),
        onCategoryTap: (category) {
          openCategoryDestination(context, category);
        },
      ),
      loading: () => const CategoryGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: 'فشل تحميل التصنيفات',
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            'أحدث النشرات والمعروضات',
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
          message: 'فشل تحميل الإعلانات',
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
          message: 'فشل تحميل الإعلانات',
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
                  '${arabicNumber(filtered.length)} نتائج',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  message: 'لا توجد نتائج',
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
