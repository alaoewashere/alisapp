import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/enum_localizations.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/web/sello_dom_probe.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/models/filter_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../home/widgets/listing_card.dart';
import '../../../models/smart_alert.dart';
import '../providers/post_listing_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_sheet.dart';
import '../../../screens/smart_alerts/my_alerts_screen.dart';
import '../widgets/listing_list_tile.dart';
import '../../../core/utils/navigation_guard.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final results = ref.watch(searchResultsProvider);
    final isGrid = ref.watch(searchViewModeProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(onPressed: () => context.pop()),
        title: GestureDetector(
          onTap: () => context.pushGuarded(AppRoutes.search),
          child: Text(
            filter.query?.trim().isNotEmpty == true
                ? filter.query!.trim()
                : strings.searchResultsTitle,
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
            strings: strings,
            onSortChanged: (sort) {
              final updated = filter.copyWith(sortBy: sort);
              ref.read(filterProvider.notifier).setFilter(updated);
              ref.read(searchResultsProvider.notifier).search(updated, log: false);
            },
            onToggleView: () =>
                ref.read(searchViewModeProvider.notifier).toggle(),
          ),
          if (filter.hasFilters)
            categoriesAsync.when(
              data: (categories) => SmartAlertSaveBanner(
                draft: smartAlertDraftFromFilter(
                  filter,
                  allCategories: categories,
                ),
              ),
              loading: () => SmartAlertSaveBanner(
                draft: smartAlertDraftFromFilter(filter),
              ),
              error: (_, _) => SmartAlertSaveBanner(
                draft: smartAlertDraftFromFilter(filter),
              ),
            ),
          if (filter.activeFilterCount > 0)
            _ActiveFiltersRow(filter: filter, strings: strings),
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
                  strings: strings,
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
    required this.strings,
    required this.onSortChanged,
    required this.onToggleView,
  });

  final int totalCount;
  final SearchSortBy sortBy;
  final bool isGrid;
  final AppLocalizations strings;
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
              strings.resultsCount(totalCount),
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
                    child: Text(s.localizedLabel(strings)),
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
  const _ActiveFiltersRow({required this.filter, required this.strings});

  final FilterModel filter;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final chips = <Widget>[];

    void removeAndSearch(FilterModel updated) {
      ref.read(filterProvider.notifier).setFilter(updated);
      ref.read(searchResultsProvider.notifier).search(updated, log: false);
    }

    if (filter.categoryId != null) {
      chips.add(_FilterChip(
        label: strings.filterCategoryLabel,
        onRemove: () => removeAndSearch(
          filter.copyWith(clearCategory: true, clearSubcategory: true),
        ),
      ));
    }
    if (filter.governorate != null) {
      chips.add(_FilterChip(
        label: governorateDisplayName(filter.governorate!, localeCode),
        onRemove: () =>
            removeAndSearch(filter.copyWith(clearGovernorate: true)),
      ));
    }
    if (filter.areaName != null && filter.areaName!.trim().isNotEmpty) {
      chips.add(_FilterChip(
        label: filter.areaName!,
        onRemove: () => removeAndSearch(filter.copyWith(clearAreaName: true)),
      ));
    }
    if (filter.minPrice != null || filter.maxPrice != null) {
      chips.add(_FilterChip(
        label: strings.priceLabel,
        onRemove: () => removeAndSearch(
          filter.copyWith(clearMinPrice: true, clearMaxPrice: true),
        ),
      ));
    }
    if (filter.condition != FilterCondition.all) {
      chips.add(_FilterChip(
        label: filter.condition.localizedLabel(strings),
        onRemove: () => removeAndSearch(
          filter.copyWith(condition: FilterCondition.all),
        ),
      ));
    }
    if (filter.isFeaturedOnly) {
      chips.add(_FilterChip(
        label: strings.featuredOnlyLabel,
        onRemove: () =>
            removeAndSearch(filter.copyWith(isFeaturedOnly: false)),
      ));
    }
    if (filter.isNegotiableOnly) {
      chips.add(_FilterChip(
        label: strings.negotiableOnlyLabel,
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
            label: Text(strings.clearAllFilters),
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
    required this.strings,
    required this.onClearFilters,
  });

  final SearchResultsState results;
  final bool isGrid;
  final FilterModel filter;
  final AppLocalizations strings;
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
      final query = filter.query?.trim();
      final domProbeText = _searchEmptyDomProbeText(query);
      return ListView(
        children: [
          _SearchEmptyDomSync(text: domProbeText),
          Semantics(
            label: strings.noResults,
            container: true,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.noResultsFound,
                    key: const Key('search_empty_results_message'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (query != null && query.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      strings.noResultsForQuery(query),
                      key: const Key('search_empty_results_detail'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    strings.tryDifferentSearchOrFilters,
                    textAlign: TextAlign.center,
                  ),
                  if (filter.activeFilterCount > 0) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: onClearFilters,
                      child: Text(strings.clearFilters),
                    ),
                  ],
                ],
              ),
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
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text(strings.loadingMore)),
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

String _searchEmptyDomProbeText(String? query) {
  final buffer = StringBuffer(AppStrings.noResults)
    ..writeln()
    ..writeln('لم يتم العثور على نتائج');
  if (query != null && query.isNotEmpty) {
    buffer.writeln('لم يتم العثور على نتائج لـ «$query»');
  }
  return buffer.toString().trim();
}

class _SearchEmptyDomSync extends StatefulWidget {
  const _SearchEmptyDomSync({required this.text});

  final String text;

  @override
  State<_SearchEmptyDomSync> createState() => _SearchEmptyDomSyncState();
}

class _SearchEmptyDomSyncState extends State<_SearchEmptyDomSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDom());
  }

  @override
  void didUpdateWidget(covariant _SearchEmptyDomSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncDom());
    }
  }

  @override
  void dispose() {
    syncSearchEmptyStateDom(null);
    super.dispose();
  }

  void _syncDom() {
    if (!mounted) return;
    syncSearchEmptyStateDom(widget.text);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
