import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/shared/models/filter_model.dart';

void main() {
  test('FilterModel carries area_name for heat-map drill-down', () {
    const filter = FilterModel(
      governorate: 'baghdad',
      areaName: 'الكرادة',
      categoryId: 1,
    );

    expect(filter.activeFilterCount, 3);
    expect(filter.toQueryParams()['area_name'], 'الكرادة');
  });

  test('FilterModel copyWith can clear areaName', () {
    const filter = FilterModel(areaName: 'المنصور');
    final cleared = filter.copyWith(clearAreaName: true);

    expect(cleared.areaName, isNull);
    expect(cleared.isEmpty, isTrue);
  });
}
