import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
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
  bool _loadingLevel = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final allAsync = ref.watch(allCategoriesProvider);
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);
    final isRoot = !state.canPopCategoryDrill;
    final drillStack = state.categoryDrillStack;

    return PopScope(
      canPop: isRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _loadingLevel) return;
        notifier.popCategoryDrillLevel();
      },
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRoot)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _loadingLevel ? null : notifier.popCategoryDrillLevel,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(strings.back),
                ),
              ),
            if (state.categoryPath.isNotEmpty)
              CategoryPathBreadcrumb(
                path: state.categoryPath,
                onSegmentTap: _loadingLevel
                    ? null
                    : (index) => notifier.jumpCategoryDrillToDepth(index + 1),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                strings.chooseCategoryTitle,
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
                  key: ValueKey(drillStack.length),
                  child: isRoot
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
                            categories: drillStack.last,
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
      ),
    );
  }

  Future<void> _onCategoryTap(CategoryModel category) async {
    if (_loadingLevel) return;

    final repo = ref.read(categoriesRepositoryProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final drillDepth = ref.read(postListingProvider).categoryDrillStack.length;

    notifier.selectCategoryAtDrillDepth(drillDepth, category);

    setState(() => _loadingLevel = true);

    try {
      final all = await ref.read(allCategoriesProvider.future);
      final children = await repo.getDrillDownChildren(category, all);
      if (!mounted) return;

      if (children.isNotEmpty) {
        notifier.pushCategoryDrillLevel(children);
        setState(() => _loadingLevel = false);
        return;
      }

      final fullPath = ref.read(postListingProvider).categoryPath;
      notifier.selectLeafCategory(fullPath);
      setState(() => _loadingLevel = false);
      notifier.goToStep(2);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingLevel = false);
      notifier.setValidationError(ref.read(appLocalizationsProvider).categoriesLoadError);
    }
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
