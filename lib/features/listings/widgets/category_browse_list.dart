import 'package:flutter/material.dart';

import '../../../core/constants/browse_categories.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import 'category_browse_row.dart';

class CategoryBrowseList extends StatelessWidget {
  const CategoryBrowseList({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final void Function(BrowseCategoryItem item) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final items = buildBrowseCategoryItems(categories);

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return CategoryBrowseRow(
          item: item,
          onTap: () => onCategoryTap(item),
        );
      },
    );
  }
}

class CategoryBrowseListShimmer extends StatelessWidget {
  const CategoryBrowseListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 8,
      separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (_, _) => const SizedBox(
        height: 72,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              ShimmerBox(width: 48, height: 48),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: 200, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
