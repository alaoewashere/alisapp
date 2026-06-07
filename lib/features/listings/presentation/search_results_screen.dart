import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../shared/models/filter_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/listing_list_tile.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final results = ref.watch(searchResultsProvider);
    final isGrid = ref.watch(searchViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: GestureDetector(
          onTap: () => context.push(AppRoutes.search),
          child: Text(
            filter.query?.trim().isNotEmpty == true
                ? filter.query!.trim()
                : 'نتائج البحث',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => showFilterSheet(context, ref),
              ),
              if (filter.activeFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${filter.activeFilterCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ResultsHeaderBar(
            totalCount: results.totalCount,
            sortBy: filter.sortBy,
            isGrid: isGrid,
            onSortChanged: (sort) {
              final updated = filter.copyWith(sortBy: sort);
              ref.read(filterProvider.notifier).setFilter(updated);
              ref.read(searchResultsProvider.notifier).search(updated, log: false);
            },
            onToggleView: () =>
                ref.read(searchViewModeProvider.notifier).toggle(),
          ),
          if (filter.activeFilterCount > 0)
            _ActiveFiltersRow(filter: filter),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(searchResultsProvider.notifier).refresh(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200) {
                    ref.read(searchResultsProvider.notifier).loadMore();
                  }
                  return false;
                },
                child: _ResultsBody(
                  results: results,
                  isGrid: isGrid,
                  filter: filter,
                  onClearFilters: () {
                    ref.read(filterProvider.notifier).resetFilters();
                    ref
                        .read(searchResultsProvider.notifier)
                        .search(const FilterModel(), log: false);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsHeaderBar extends StatelessWidget {
  const _ResultsHeaderBar({
    required this.totalCount,
    required this.sortBy,
    required this.isGrid,
    required this.onSortChanged,
    required this.onToggleView,
  });

  final int totalCount;
  final SearchSortBy sortBy;
  final bool isGrid;
  final ValueChanged<SearchSortBy> onSortChanged;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: onToggleView,
          ),
          Expanded(
            child: Text(
              '${arabicNumber(totalCount)} نتيجة',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DropdownButton<SearchSortBy>(
            value: sortBy,
            underline: const SizedBox.shrink(),
            items: SearchSortBy.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.labelAr),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onSortChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _ActiveFiltersRow extends ConsumerWidget {
  const _ActiveFiltersRow({required this.filter});

  final FilterModel filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = <Widget>[];

    void removeAndSearch(FilterModel updated) {
      ref.read(filterProvider.notifier).setFilter(updated);
      ref.read(searchResultsProvider.notifier).search(updated, log: false);
    }

    if (filter.categoryId != null) {
      chips.add(_FilterChip(
        label: 'فئة',
        onRemove: () => removeAndSearch(
          filter.copyWith(clearCategory: true, clearSubcategory: true),
        ),
      ));
    }
    if (filter.governorate != null) {
      chips.add(_FilterChip(
        label: governorateNameAr(filter.governorate!),
        onRemove: () =>
            removeAndSearch(filter.copyWith(clearGovernorate: true)),
      ));
    }
    if (filter.minPrice != null || filter.maxPrice != null) {
      chips.add(_FilterChip(
        label: 'السعر',
        onRemove: () => removeAndSearch(
          filter.copyWith(clearMinPrice: true, clearMaxPrice: true),
        ),
      ));
    }
    if (filter.condition != FilterCondition.all) {
      chips.add(_FilterChip(
        label: filter.condition.labelAr,
        onRemove: () => removeAndSearch(
          filter.copyWith(condition: FilterCondition.all),
        ),
      ));
    }
    if (filter.isFeaturedOnly) {
      chips.add(_FilterChip(
        label: 'مميز',
        onRemove: () =>
            removeAndSearch(filter.copyWith(isFeaturedOnly: false)),
      ));
    }
    if (filter.isNegotiableOnly) {
      chips.add(_FilterChip(
        label: 'قابل للتفاوض',
        onRemove: () =>
            removeAndSearch(filter.copyWith(isNegotiableOnly: false)),
      ));
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ...chips,
          ActionChip(
            label: const Text('مسح الكل'),
            onPressed: () {
              ref.read(filterProvider.notifier).resetFilters();
              ref.read(searchResultsProvider.notifier).search(
                    const FilterModel(),
                    log: false,
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InputChip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.results,
    required this.isGrid,
    required this.filter,
    required this.onClearFilters,
  });

  final SearchResultsState results;
  final bool isGrid;
  final FilterModel filter;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (results.isLoading && results.items.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 8,
        itemBuilder: (_, _) => const ShimmerBox(width: 160, height: 200),
      );
    }

    if (results.error != null && results.items.isEmpty) {
      return ListView(
        children: [
          AppErrorWidget(message: results.error!),
        ],
      );
    }

    if (results.items.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.search_off,
                    size: 72, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                Text(
                  filter.query != null
                      ? 'لا توجد نتائج لـ ${filter.query}'
                      : 'لا توجد نتائج',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('حاول تغيير كلمة البحث أو الفلاتر'),
                if (filter.activeFilterCount > 0) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: onClearFilters,
                    child: const Text('مسح الفلاتر'),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final itemCount = results.items.length + (results.isLoadingMore ? 1 : 0);

    if (isGrid) {
      return AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= results.items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 275),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: ListingCard(listing: results.items[index]),
                ),
              ),
            );
          },
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index >= results.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('جاري تحميل المزيد...')),
            );
          }
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 275),
            child: SlideAnimation(
              verticalOffset: 24,
              child: FadeInAnimation(
                child: ListingListTile(listing: results.items[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
