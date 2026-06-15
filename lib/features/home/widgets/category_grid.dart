import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
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

  static String emojiFor(String iconName) {
    return switch (iconName) {
      'home' => '🏢',
      'directions_car' => '🚗',
      'devices' => '📱',
      'work' => '💼',
      'handyman' => '🔧',
      _ => '📦',
    };
  }

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
    final displayCategories = categories.take(6).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < displayCategories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _CategoryPill(
              label: displayCategories[i].nameAr,
              emoji: emojiFor(displayCategories[i].icon),
              selected: selectedId == displayCategories[i].id,
              onTap: () {
                onSelected(displayCategories[i].id);
                onCategoryTap?.call(displayCategories[i]);
              },
            ),
          ],
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
      error: (e, _) =>
          AppErrorWidget(message: 'فشل تحميل التصنيفات', onRetry: () {}),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.chipRadius),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.premiumGradient : null,
            color: selected ? null : AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppDecorations.chipRadius),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder,
              width: 0.5,
            ),
            boxShadow: selected ? AppDecorations.cardShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
