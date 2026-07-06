import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/widgets/category_icon.dart';

/// 2-column bento card for category pickers — souqly-redesign-studio categories mockup.
class CategoryBentoCard extends StatelessWidget {
  const CategoryBentoCard({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.showBrandStyle = false,
    this.listingCount,
  });

  final CategoryModel category;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool selected;
  final bool showBrandStyle;
  final int? listingCount;

  @override
  Widget build(BuildContext context) {
    final isBrandRow = showBrandStyle && isVehicleBrand(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.fieldCarbon,
            borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.glassBorder,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CategoryBentoIcon(
                  category: category,
                  showBrandStyle: showBrandStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
                if (subtitle.isNotEmpty && !isBrandRow) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
                if (listingCount != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    arabicNumber(listingCount!),
                    style: AppFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBentoIcon extends StatelessWidget {
  const _CategoryBentoIcon({
    required this.category,
    required this.showBrandStyle,
  });

  final CategoryModel category;
  final bool showBrandStyle;

  @override
  Widget build(BuildContext context) {
    return CategoryIcon(
      category: category,
      showBrandStyle: showBrandStyle,
    );
  }
}

/// Two-column grid of [CategoryBentoCard] widgets with consistent spacing.
class CategoryBentoGrid extends ConsumerWidget {
  const CategoryBentoGrid({
    super.key,
    required this.categories,
    required this.all,
    required this.onTap,
    this.loading = false,
    this.selectedId,
    this.showBrandStyle = false,
    this.listingCounts,
  });

  final List<CategoryModel> categories;
  final List<CategoryModel> all;
  final void Function(CategoryModel category) onTap;
  final bool loading;
  final int? selectedId;
  final bool showBrandStyle;
  final Map<int, int>? listingCounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final strings = ref.watch(appLocalizationsProvider);

    if (categories.isEmpty) {
      return Center(
        child: Text(
          strings.noCategories,
          style: AppFonts.cairo(color: AppColors.textMuted),
        ),
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.88,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final subtitle = subtitleForCategory(
              category,
              all,
              localeCode: localeCode,
            );
            final selected = selectedId != null && selectedId == category.id;
            final count = showBrandStyle && isVehicleBrand(category)
                ? subtreeListingCount(category.id, all, listingCounts ?? {})
                : null;

            return CategoryBentoCard(
              category: category,
              title: category.localizedName(localeCode),
              subtitle: subtitle,
              selected: selected,
              showBrandStyle: showBrandStyle,
              listingCount: count,
              onTap: loading ? null : () => onTap(category),
            );
          },
        ),
        if (loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x99131315),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class CategoryBentoGridShimmer extends StatelessWidget {
  const CategoryBentoGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.fieldCarbon,
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          border: Border.all(color: AppColors.glassBorder),
        ),
      ),
    );
  }
}
