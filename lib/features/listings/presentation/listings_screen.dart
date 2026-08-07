import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_tree.dart';
import '../../../core/utils/navigation_guard.dart';
import '../../../shared/models/filter_model.dart';
import '../../home/providers/home_provider.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/post_listing_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_sheet.dart';
import '../../../shared/widgets/app_back_button.dart';
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
        leading: AppBackButton(onPressed: () => context.pop()),
        title: isAll
            ? Text(strings.allListings)
            : Text(
                titleAsync ?? strings.listingsLabel,
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: strings.filtersTitle,
            onPressed: () {
              // Pre-seed the filter with the category being browsed so it
              // opens already matching where the user currently is, not blank.
              if (!isAll) {
                ref.read(filterProvider.notifier).setFilter(
                      FilterModel(categoryId: int.parse(categoryId)),
                    );
              }
              showFilterSheet(
                context,
                ref,
                // Deferred: FilterSheet._apply() already pops the sheet's
                // modal route right before calling onApplied. Pushing on
                // the same Navigator synchronously right after that pop
                // races its removal from the page list — both Pages can
                // end up sharing the same derived key → GoRouter's
                // "!keyReservation.contains(key)" duplicate-key assertion.
                onApplied: () => WidgetsBinding.instance.addPostFrameCallback(
                  (_) => context.pushGuarded(AppRoutes.searchResults),
                ),
              );
            },
          ),
        ],
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
                  message: strings.failedLoadListings,
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

final _categoryTitleProvider = Provider.family<String?, int>((ref, categoryId) {
  final localeCode = ref.watch(categoryLocaleCodeProvider);
  final allAsync = ref.watch(allCategoriesProvider);
  return allAsync.maybeWhen(
    data: (all) => categoryById(categoryId, all)?.localizedName(localeCode),
    orElse: () => null,
  );
});
