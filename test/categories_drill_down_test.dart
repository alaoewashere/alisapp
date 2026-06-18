import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/listings/data/categories_repository.dart';
import 'package:Sello/shared/models/category_model.dart';

class _FakeCategoriesRepository extends CategoriesRepository {
  _FakeCategoriesRepository(this._childrenByParent) : super(_NoOpClient());

  final Map<int, List<CategoryModel>> _childrenByParent;

  @override
  Future<List<CategoryModel>> getChildCategories(int parentId) async {
    return _childrenByParent[parentId] ?? [];
  }
}

class _NoOpClient {}

void main() {
  group('CategoriesRepository.getDrillDownChildren', () {
    test('loads automobile brands when rental has no direct children', () async {
      const rental = CategoryModel(
        id: 1,
        slug: 'veh_rental',
        nameAr: 'سيارات للإيجار',
        icon: '🔑',
        parentId: 100,
      );
      const automobile = CategoryModel(
        id: 2,
        slug: 'veh_automobile',
        nameAr: 'سيارات',
        icon: '🚗',
        parentId: 100,
      );
      const toyota = CategoryModel(
        id: 3,
        slug: 'veh_auto_br_toyota',
        nameAr: 'Toyota',
        icon: 'brand',
        parentId: 2,
      );

      final repo = _FakeCategoriesRepository({
        1: [],
        2: [toyota],
      });

      final children = await repo.getDrillDownChildren(
        rental,
        [rental, automobile, toyota],
      );

      expect(children, [toyota]);
    });

    test('returns direct children without alias when present', () async {
      const automobile = CategoryModel(
        id: 2,
        slug: 'veh_automobile',
        nameAr: 'سيارات',
        icon: '🚗',
        parentId: 100,
      );
      const toyota = CategoryModel(
        id: 3,
        slug: 'veh_auto_br_toyota',
        nameAr: 'Toyota',
        icon: 'brand',
        parentId: 2,
      );

      final repo = _FakeCategoriesRepository({2: [toyota]});

      final children = await repo.getDrillDownChildren(
        automobile,
        [automobile, toyota],
      );

      expect(children, [toyota]);
    });
  });
}
