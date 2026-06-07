import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/category_model.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../home/widgets/category_grid.dart';
import '../../providers/post_listing_provider.dart';

class Step1Category extends ConsumerWidget {
  const Step1Category({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);

    return categoriesAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: ShimmerBox(height: 200, width: MediaQuery.sizeOf(context).width - 32),
      ),
      error: (e, _) => AppErrorWidget(
        message: '$e',
        onRetry: () => ref.invalidate(allCategoriesProvider),
      ),
      data: (all) {
        final parents = all.where((c) => c.isParent).toList();
        final expandedId = state.expandedParentId;
        final subcategories = expandedId == null
            ? <CategoryModel>[]
            : all.where((c) => c.parentId == expandedId).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر الفئة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: parents.length,
                itemBuilder: (context, index) {
                  final category = parents[index];
                  final selected = state.selectedCategory?.id == category.id ||
                      state.selectedSubcategory?.parentId == category.id;
                  return _ParentCategoryTile(
                    category: category,
                    selected: selected,
                    expanded: expandedId == category.id,
                    onTap: () => notifier.selectParentCategory(category, all),
                  );
                },
              ),
              if (subcategories.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'الفئة الفرعية',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subcategories.map((sub) {
                    final selected = state.selectedSubcategory?.id == sub.id;
                    return FilterChip(
                      label: Text(sub.nameAr),
                      selected: selected,
                      onSelected: (_) => notifier.selectSubcategory(sub),
                    );
                  }).toList(),
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ParentCategoryTile extends StatelessWidget {
  const _ParentCategoryTile({
    required this.category,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CategoryGrid.iconFor(category.icon),
                size: 32,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                category.nameAr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (expanded)
                Icon(
                  Icons.expand_less,
                  size: 16,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
