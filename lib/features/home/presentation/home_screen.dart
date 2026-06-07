import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_navigation.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/home_provider.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_banner.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(strings.appName),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('0'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshHomeProviders(ref),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push(AppRoutes.search),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ابحث عن إعلان...',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (listings) => FeaturedBanner(listings: listings),
                loading: () => const FeaturedBannerShimmer(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'الفئات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'أحدث الإعلانات',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.listingsPath('all')),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
            ),
            recentAsync.when(
              loading: () => SliverToBoxAdapter(
                child: ListingGridShimmer(),
              ),
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
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
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
    );
  }
}
