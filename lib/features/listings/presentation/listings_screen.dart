import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/listing_card.dart';
import '../../listings/data/categories_repository.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({
    super.key,
    required this.categoryId,
    this.listingType,
  });

  final String categoryId;
  final String? listingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAll = categoryId == 'all';
    final queryKey = isAll
        ? categoryId
        : categoryListingsQueryKey(categoryId, listingType: listingType);
    final listingsAsync = isAll
        ? ref.watch(recentListingsProvider)
        : ref.watch(categoryListingsProvider(queryKey));

    final titleAsync = isAll
        ? null
        : ref.watch(_categoryTitleProvider(int.parse(categoryId)));

    final strings = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: isAll
            ? const Text('جميع الإعلانات')
            : titleAsync?.when(
                  data: (name) => Text(name ?? 'الإعلانات'),
                  loading: () => const Text('الإعلانات'),
                  error: (_, _) => const Text('الإعلانات'),
                ) ??
                const Text('الإعلانات'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isAll) {
            ref.invalidate(recentListingsProvider);
          } else {
            ref.invalidate(categoryListingsProvider(queryKey));
          }
        },
        child: listingsAsync.when(
          loading: () => const ListingGridShimmer(),
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: AppErrorWidget(
                  message: 'فشل تحميل الإعلانات',
                  onRetry: () {
                    if (isAll) {
                      ref.invalidate(recentListingsProvider);
                    } else {
                      ref.invalidate(categoryListingsProvider(queryKey));
                    }
                  },
                ),
              ),
            ],
          ),
          data: (listings) {
            if (listings.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  EmptyStateWidget(
                    message: strings.noListings,
                    icon: Icons.storefront_outlined,
                  ),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: listings.length,
              itemBuilder: (_, i) => ListingCard(listing: listings[i]),
            );
          },
        ),
      ),
    );
  }
}

final _categoryTitleProvider =
    FutureProvider.family<String?, int>((ref, categoryId) async {
  final category =
      await ref.watch(categoriesRepositoryProvider).fetchById(categoryId);
  return category?.nameAr;
});
