import '../core/utils/category_tree.dart';
import '../shared/models/category_model.dart';

/// Maps a drilled category path to smart-alert DB columns used by [notify_smart_alerts].
class SmartAlertCategoryFields {
  const SmartAlertCategoryFields({
    this.category,
    this.subcategory,
    this.make,
    this.model,
    this.year,
  });

  final String? category;
  final String? subcategory;
  final String? make;
  final String? model;
  final int? year;
}

bool isSmartAlertYearCategoryName(String name) {
  return RegExp(r'^(19|20)\d{2}$').hasMatch(name.trim());
}

String smartAlertPickerLabelForParent(CategoryModel? parent, int nextDepth) {
  if (parent == null) return 'الفئة الرئيسية';
  if (isVehicleBrandListParent(parent)) return 'الصانع';
  if (parent.icon == 'brand') return 'الموديل';
  if (nextDepth == 1) return 'الفئة الفرعية';
  return 'التفصيل';
}

List<CategoryModel> childrenOf(
  List<CategoryModel> all,
  int? parentId,
) {
  return all
      .where((c) => c.parentId == parentId)
      .toList()
    ..sort((a, b) {
      final order = a.displayOrder.compareTo(b.displayOrder);
      return order != 0 ? order : a.id.compareTo(b.id);
    });
}

SmartAlertCategoryFields categoryFieldsFromPath(List<CategoryModel> path) {
  if (path.isEmpty) return const SmartAlertCategoryFields();

  CategoryModel? subcategoryNode;
  CategoryModel? brandNode;
  CategoryModel? modelNode;
  int? year;

  for (final node in path.skip(1)) {
    if (node.icon == 'brand') {
      brandNode = node;
      continue;
    }
    if (node.icon == 'model') {
      modelNode = node;
      continue;
    }
    if (isSmartAlertYearCategoryName(node.nameAr)) {
      year = int.tryParse(node.nameAr.trim());
      continue;
    }
    if (subcategoryNode == null) {
      subcategoryNode = node;
    }
  }

  return SmartAlertCategoryFields(
    category: path.first.nameAr,
    subcategory: subcategoryNode?.nameAr,
    make: brandNode?.nameAr,
    model: modelNode?.nameAr,
    year: year,
  );
}

List<CategoryModel>? rebuildCategoryPathFromFields({
  required List<CategoryModel> all,
  String? category,
  String? subcategory,
  String? make,
  String? model,
}) {
  if (category == null || category.trim().isEmpty) return null;

  CategoryModel? findChild(CategoryModel parent, String name) {
    final matches = childrenOf(all, parent.id)
        .where((c) => c.nameAr.trim() == name.trim());
    return matches.isEmpty ? null : matches.first;
  }

  final roots = childrenOf(all, null)
      .where((c) => c.nameAr.trim() == category.trim());
  if (roots.isEmpty) return null;

  final path = <CategoryModel>[roots.first];
  var current = roots.first;

  for (final name in [subcategory, make, model]) {
    if (name == null || name.trim().isEmpty) break;
    final next = findChild(current, name);
    if (next == null) break;
    path.add(next);
    current = next;
  }

  return path;
}
