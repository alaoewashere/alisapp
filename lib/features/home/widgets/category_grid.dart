import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_asset_icons.dart';
import '../../../core/constants/category_fallback_icon.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/category_asset_image.dart';
import '../../../shared/models/category_model.dart';

class CategoryGrid extends ConsumerWidget {
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

  static const packagePlaceholderEmoji = '📦';

  static String emojiFor(String iconName) {
    return switch (iconName) {
      'home' => '🏢',
      'directions_car' => '🚗',
      'devices' => '📱',
      'work' => '💼',
      'handyman' => '🔧',
      _ => packagePlaceholderEmoji,
    };
  }

  /// True when [iconName] resolves to the generic package placeholder (not a dedicated emoji).
  static bool isPackagePlaceholderIcon(String iconName) {
    return emojiFor(iconName) == packagePlaceholderEmoji;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final displayCategories = categories.take(6).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < displayCategories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _CategoryPill(
              label: displayCategories[i].localizedName(localeCode),
              slug: displayCategories[i].slug,
              iconName: displayCategories[i].icon,
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.slug,
    required this.iconName,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String slug;
  final String iconName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assetPath = CategoryAssetIcons.displayAssetForSlug(slug);

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
              if (assetPath != null)
                CategoryAssetImage(
                  assetPath: assetPath,
                  size: 24,
                  showPlate: false,
                  fallback: Text(
                    CategoryGrid.emojiFor(iconName),
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              else if (CategoryGrid.isPackagePlaceholderIcon(iconName))
                CategoryAssetImage(
                  assetPath: CategoryFallbackIcon.assetPath,
                  size: 24,
                  showPlate: false,
                  fallback: Text(
                    CategoryGrid.packagePlaceholderEmoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              else
                Text(
                  CategoryGrid.emojiFor(iconName),
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.canvas : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
