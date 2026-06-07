import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/browse_categories.dart';
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

    final filter = ref.read(filterProvider).copyWith(
          query: q.isEmpty ? null : q,
        );
    ref.read(filterProvider.notifier).setFilter(filter);
    ref.read(searchResultsProvider.notifier).search(filter);
    context.push(AppRoutes.searchResults);
  }

  Future<void> _openCategory(BrowseCategoryItem item, List<CategoryModel> all) async {
    var category = resolveBrowseCategory(
      item.style.slug,
      all,
      categoryId: item.categoryId,
    );

    category ??=
        await ref.read(categoriesRepositoryProvider).fetchBySlug(item.style.slug);

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
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.cairoTextTheme(baseTheme.textTheme),
    );

    return Theme(
      data: cairoTheme,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                          onCategoryTap: (item) => _openCategory(item, categories),
                        ),
                      ),
              ),
            ],
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'ابحث في سوق العراق...',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
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
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$filterCount',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
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
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('لا توجد اقتراحات', style: GoogleFonts.cairo()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => onSubmit(query),
                    child: Text('بحث عن "$query"', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
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
      return Text(text, style: GoogleFonts.cairo());
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.cairo(color: const Color(0xFF212121), fontSize: 15),
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
