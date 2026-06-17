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
import '../widgets/home_hero_section.dart';
import '../widgets/listing_card.dart';
import '../widgets/recent_listings_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearchActive = ref.watch(isHomeSearchActiveProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => refreshHomeProviders(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _HomeTopBarIconButton(
                        icon: Icons.favorite_border_rounded,
                        tooltip: 'المفضلة',
                        onTap: () => context.push(AppRoutes.favorites),
                      ),
                    ),
                    leadingWidth: 56,
                    title: const AppLogo(size: 46),
                    centerTitle: true,
                  ),
                ),
              ),
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
                SliverToBoxAdapter(child: _HomeRecentListingsHeader()),
                _HomeRecentListingsSection(),
              ] else ...[
                _HomeSearchResultsSection(),
              ],
              AppBottomNavSliverSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTopBarIconButton extends StatelessWidget {
  const _HomeTopBarIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  static const _size = 40.0;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: _size,
      height: _size,
      child: Icon(icon, size: 22, color: AppColors.textDark),
    );

    return Material(
      color: AppColors.fieldCarbon,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: tooltip != null
            ? Tooltip(message: tooltip!, child: button)
            : button,
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
      data: (listings) => FeaturedListingsCarousel(listings: listings),
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
      child: Text(
        'أحدث النشرات والمعروضات',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
      ),
    );
  }
}

class _HomeRecentListingsSection extends ConsumerWidget {
  const _HomeRecentListingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentListingsProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return recentAsync.when(
      loading: () => const SliverToBoxAdapter(child: RecentListingsRowShimmer()),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorWidget(
          message: 'فشل تحميل الإعلانات',
          onRetry: () => ref.invalidate(recentListingsProvider),
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
    final recentAsync = ref.watch(recentListingsProvider);
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
          onRetry: () => ref.invalidate(recentListingsProvider),
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
