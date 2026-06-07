import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/error_widget.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final ValueChanged<CategoryModel>? onCategoryTap;

  static IconData iconFor(String iconName) {
    return switch (iconName) {
      'home' => Icons.home_outlined,
      'directions_car' => Icons.directions_car_outlined,
      'devices' => Icons.devices_outlined,
      'work' => Icons.work_outline,
      'handyman' => Icons.handyman_outlined,
      _ => Icons.category_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _CategoryChip(
            label: context.l10n.all,
            icon: Icons.apps,
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _CategoryChip(
                label: c.nameAr,
                icon: iconFor(c.icon),
                selected: selectedId == c.id,
                onTap: () {
                  onSelected(c.id);
                  onCategoryTap?.call(c);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryGridSection extends StatelessWidget {
  const CategoryGridSection({
    super.key,
    required this.categoriesAsync,
    required this.selectedId,
    required this.onSelected,
    this.onCategoryTap,
  });

  final AsyncValue<List<CategoryModel>> categoriesAsync;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final ValueChanged<CategoryModel>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) => CategoryGrid(
        categories: categories,
        selectedId: selectedId,
        onSelected: onSelected,
        onCategoryTap: onCategoryTap,
      ),
      loading: () => const CategoryGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: 'فشل تحميل التصنيفات',
        onRetry: () {},
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FilterChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? scheme.onPrimary : scheme.primary,
      ),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
