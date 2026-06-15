import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_navigation.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredListingsProvider);
    final recentAsync = ref.watch(recentListingsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final strings = ref.watch(appLocalizationsProvider);

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
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(child: AppLogo(size: 46)),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: const HomeHeroSection()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SouqlySearchBar(
                    hint: 'ابحث عن سيارات، شقق، إلكترونيات...',
                    onTap: () => context.push(AppRoutes.search),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
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
                ),
              ),
              SliverToBoxAdapter(
                child: categoriesAsync.when(
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
                ),
              ),
              SliverToBoxAdapter(
                child: featuredAsync.when(
                  data: (listings) => FeaturedListingsCarousel(listings: listings),
                  loading: () => const FeaturedListingsCarouselShimmer(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text(
                    'أحدث النشرات والمعروضات',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              recentAsync.when(
                loading: () =>
                    const SliverToBoxAdapter(child: ListingGridShimmer()),
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
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ListingCard(listing: listings[index]),
                        childCount: listings.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
