import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../data/categories_repository.dart';
import '../providers/post_listing_provider.dart';
import 'category_bento_grid.dart';
import 'category_path_breadcrumb.dart';

/// Post-listing category picker with internal drill-down stack (no routing).
class CategoryDrillScreen extends ConsumerStatefulWidget {
  const CategoryDrillScreen({super.key});

  @override
  ConsumerState<CategoryDrillScreen> createState() =>
      _CategoryDrillScreenState();
}

class _CategoryDrillScreenState extends ConsumerState<CategoryDrillScreen> {
  final List<List<CategoryModel>> _levelStack = [];
  bool _loadingLevel = false;

  bool get _isRoot => _levelStack.isEmpty;

  @override
  Widget build(BuildContext context) {
    ref.listen(postListingProvider, (previous, next) {
      if (next.categoryPath.isEmpty &&
          (previous?.categoryPath.isNotEmpty ?? false) &&
          _levelStack.isNotEmpty) {
        setState(_levelStack.clear);
      }
    });

    final state = ref.watch(postListingProvider);
    final allAsync = ref.watch(allCategoriesProvider);
    final theme = Theme.of(context);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isRoot)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loadingLevel ? null : _onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('رجوع'),
              ),
            ),
          if (state.categoryPath.isNotEmpty)
            CategoryPathBreadcrumb(
              path: state.categoryPath,
              onSegmentTap: _loadingLevel ? null : _onBreadcrumbTap,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'اختر الفئة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ));
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_levelStack.length),
                child: _isRoot
                    ? _RootCategoryGrid(
                        onCategoryTap: _onCategoryTap,
                        loading: _loadingLevel,
                        allAsync: allAsync,
                        selectedRootId: state.categoryPath.isNotEmpty
                            ? state.categoryPath.first.id
                            : null,
                      )
                    : allAsync.when(
                        loading: () => const CategoryBentoGridShimmer(),
                        error: (e, _) => AppErrorWidget(
                          message: '$e',
                          onRetry: () => ref.invalidate(allCategoriesProvider),
                        ),
                        data: (all) => CategoryBentoGrid(
                          categories: _levelStack.last,
                          all: all,
                          loading: _loadingLevel,
                          onTap: (c) => _onCategoryTap(c),
                        ),
                      ),
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    if (_loadingLevel) return;

    final repo = ref.read(categoriesRepositoryProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final drillDepth = _levelStack.length;

    notifier.selectCategoryAtDrillDepth(drillDepth, category);

    setState(() => _loadingLevel = true);

    try {
      final children = await repo.getChildCategories(category.id);
      if (!mounted) return;

      if (children.isNotEmpty) {
        setState(() {
          _levelStack.add(children);
          _loadingLevel = false;
        });
        return;
      }

      final fullPath = ref.read(postListingProvider).categoryPath;
      notifier.selectLeafCategory(fullPath);
      setState(() => _loadingLevel = false);
      notifier.goToStep(2);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLevel = false);
      notifier.setValidationError('تعذّر تحميل الفئات');
    }
  }

  void _onBack() {
    if (_levelStack.isEmpty) return;

    final notifier = ref.read(postListingProvider.notifier);
    final pathLength = ref.read(postListingProvider).categoryPath.length;
    final newPathLength = pathLength > 0 ? pathLength - 1 : 0;

    setState(() {
      if (_levelStack.isNotEmpty) {
        _levelStack.removeLast();
      }
    });

    notifier.trimCategoryPath(newPathLength);
  }

  void _onBreadcrumbTap(int index) {
    if (_loadingLevel) return;
    final notifier = ref.read(postListingProvider.notifier);
    final targetDepth = index + 1;

    setState(() {
      if (targetDepth < _levelStack.length) {
        _levelStack.removeRange(targetDepth, _levelStack.length);
      }
    });

    notifier.trimCategoryPath(targetDepth);
  }
}

class _RootCategoryGrid extends ConsumerWidget {
  const _RootCategoryGrid({
    required this.onCategoryTap,
    required this.loading,
    required this.allAsync,
    required this.selectedRootId,
  });

  final Future<void> Function(CategoryModel category) onCategoryTap;
  final bool loading;
  final AsyncValue<List<CategoryModel>> allAsync;
  final int? selectedRootId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(postCategoryRootProvider);

    return parentsAsync.when(
      loading: () => const CategoryBentoGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: '$e',
        onRetry: () => ref.invalidate(postCategoryRootProvider),
      ),
      data: (parents) {
        return allAsync.when(
          loading: () => const CategoryBentoGridShimmer(),
          error: (e, _) => AppErrorWidget(
            message: '$e',
            onRetry: () => ref.invalidate(allCategoriesProvider),
          ),
          data: (all) => CategoryBentoGrid(
            categories: parents,
            all: all,
            loading: loading,
            selectedId: selectedRootId,
            onTap: (c) => onCategoryTap(c),
          ),
        );
      },
    );
  }
}

final postCategoryRootProvider =
    FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  return ref.read(categoriesRepositoryProvider).fetchParentCategories();
});
