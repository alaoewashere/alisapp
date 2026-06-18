import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/category_tree.dart';
import 'package:Sello/shared/models/category_model.dart';

void main() {
  group('buildCategoryPath', () {
    final all = [
      const CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
      const CategoryModel(
        id: 2,
        slug: 'veh_auto',
        nameAr: 'سيارات',
        icon: 'category',
        parentId: 1,
      ),
      const CategoryModel(
        id: 3,
        slug: 'toyota',
        nameAr: 'Toyota',
        icon: 'brand',
        parentId: 2,
      ),
      const CategoryModel(
        id: 4,
        slug: 'camry',
        nameAr: 'Camry',
        icon: 'model',
        parentId: 3,
      ),
    ];

    test('builds root-to-leaf path for four levels', () {
      final path = buildCategoryPath(4, all);
      expect(path.map((c) => c.nameAr).toList(),
          ['المركبات', 'سيارات', 'Toyota', 'Camry']);
    });

    test('returns empty for unknown id', () {
      expect(buildCategoryPath(999, all), isEmpty);
    });
  });
}
