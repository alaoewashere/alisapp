import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/shared/models/category_model.dart';

void main() {
  test('fromJson prefers display_order over sort_order', () {
    final category = CategoryModel.fromJson({
      'id': 1,
      'slug': 'cars',
      'name_ar': 'المركبات',
      'display_order': 2,
      'sort_order': 99,
    });

    expect(category.displayOrder, 2);
  });

  test('fromJson falls back to sort_order when display_order missing', () {
    final category = CategoryModel.fromJson({
      'id': 2,
      'slug': 'veh_rental',
      'name_ar': 'سيارات للإيجار',
      'sort_order': 2,
    });

    expect(category.displayOrder, 2);
  });
}
