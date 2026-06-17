import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/browse_categories.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../features/auth/widgets/guest_bottom_sheet.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_navigation.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/filter_model.dart';
import '../data/categories_repository.dart';
import '../providers/post_listing_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/category_browse_list.dart';
import '../widgets/filter_sheet.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit([String? query]) {
    final q = (query ?? _controller.text).trim();
    ref.read(searchQueryProvider.notifier).set(q);
    _controller.text = q;

    final filter = ref
        .read(filterProvider)
        .copyWith(query: q.isEmpty ? null : q);
    ref.read(filterProvider.notifier).setFilter(filter);
    ref.read(searchResultsProvider.notifier).search(filter);
    context.push(AppRoutes.searchResults);
  }

  Future<void> _openCategory(
    BrowseCategoryItem item,
    List<CategoryModel> all,
  ) async {
    var category = resolveBrowseCategory(
      item.style.slug,
      all,
      categoryId: item.categoryId,
    );

    category ??= await ref
        .read(categoriesRepositoryProvider)
        .fetchBySlug(item.style.slug);

    if (category != null) {
      if (mounted) openCategoryDestination(context, category);
      return;
    }

    if (categoryBrowseRootSlugs.contains(item.style.slug)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لم يتم العثور على "${item.style.nameAr}" في قاعدة البيانات. '
              'طبّق migrations في Supabase ثم أعد تحميل التطبيق.',
              textAlign: TextAlign.right,
            ),
          ),
        );
      }
      return;
    }

    final filter = FilterModel(query: item.style.nameAr);
    ref.read(filterProvider.notifier).setFilter(filter);
    ref.read(searchResultsProvider.notifier).search(filter, log: false);
    if (mounted) context.push(AppRoutes.searchResults);
  }

  void _openFilters() {
    showFilterSheet(
      context,
      ref,
      onApplied: () {
        if (mounted) context.push(AppRoutes.searchResults);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    ref.listen(searchQueryProvider, (prev, next) {
      if (_controller.text != next) _controller.text = next;
    });

    final debounced = ref.watch(debouncedSearchQueryProvider);
    final showSuggestions = query.trim().length >= 2;
    final suggestionsAsync = showSuggestions
        ? ref.watch(searchSuggestionsProvider(debounced))
        : null;
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final canPop = GoRouter.of(context).canPop();
    final filter = ref.watch(filterProvider);

    final baseTheme = Theme.of(context);
    final cairoTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppFonts.cairoTextTheme(baseTheme.textTheme),
    );

    return Theme(
      data: cairoTheme,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SearchHeader(
                  controller: _controller,
                  focusNode: _focusNode,
                  query: query,
                  canPop: canPop,
                  filterCount: filter.activeFilterCount,
                  onQueryChanged: ref.read(searchQueryProvider.notifier).set,
                  onClear: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                  onSubmit: _submit,
                  onFilterTap: _openFilters,
                  onAlertsTap: () {
                    final userId = ref.read(currentUserIdProvider);
                    if (userId == null) {
                      showGuestBottomSheet(context);
                      return;
                    }
                    context.push(AppRoutes.smartAlerts);
                  },
                ),
                Expanded(
                  child: showSuggestions
                      ? _SuggestionsBody(
                          query: debounced,
                          suggestionsAsync: suggestionsAsync,
                          onSubmit: _submit,
                        )
                      : categoriesAsync.when(
                          loading: () => const CategoryBrowseListShimmer(),
                          error: (e, _) => Center(child: Text('$e')),
                          data: (categories) => CategoryBrowseList(
                            categories: categories,
                            onCategoryTap: (item) =>
                                _openCategory(item, categories),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.canPop,
    required this.filterCount,
    required this.onQueryChanged,
    required this.onClear,
    required this.onSubmit,
    required this.onFilterTap,
    required this.onAlertsTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final bool canPop;
  final int filterCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final void Function([String? query]) onSubmit;
  final VoidCallback onFilterTap;
  final VoidCallback onAlertsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.pop(),
              tooltip: 'رجوع',
            ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: AppFonts.cairo(
                  fontSize: 15,
                  color: AppColors.pureWhite,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في Sello...',
                  hintStyle: AppFonts.cairo(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: onClear,
                        )
                      : null,
                ),
                onChanged: onQueryChanged,
                onSubmitted: onSubmit,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            tooltip: 'تنبيهاتي الذكية',
            onPressed: onAlertsTap,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'الفلاتر',
                onPressed: onFilterTap,
              ),
              if (filterCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$filterCount',
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionsBody extends StatelessWidget {
  const _SuggestionsBody({
    required this.query,
    required this.suggestionsAsync,
    required this.onSubmit,
  });

  final String query;
  final AsyncValue<List<String>>? suggestionsAsync;
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    if (suggestionsAsync == null) return const SizedBox.shrink();

    return suggestionsAsync!.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('لا توجد اقتراحات', style: AppFonts.cairo()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => onSubmit(query),
                    child: Text('بحث عن "$query"', style: AppFonts.cairo()),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(
            bottom: AppBottomNavLayout.scrollBottomPadding(context),
          ),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (_, i) {
            final s = suggestions[i];
            return ListTile(
              leading: Icon(Icons.search, color: Colors.grey.shade600),
              title: _HighlightedText(text: s, query: query),
              onTap: () => onSubmit(s),
            );
          },
        );
      },
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final index = text.toLowerCase().indexOf(query.toLowerCase());
    if (index < 0) {
      return Text(text, style: AppFonts.cairo());
    }

    return RichText(
      text: TextSpan(
        style: AppFonts.cairo(color: const Color(0xFF212121), fontSize: 15),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
