import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/router/app_router.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  test('categoryBrowsePath builds resolved path without route pattern', () {
    expect(AppRoutes.categoryBrowsePath(1), '/categories/1');
    expect(AppRoutes.categoryBrowsePath(42), '/categories/42');
    expect(AppRoutes.categoryBrowsePath(1), isNot(contains(':categoryId')));
  });

  test('categoryBrowsePath includes listing type query', () {
    expect(
      AppRoutes.categoryBrowsePath(5, listingType: 'rent'),
      '/categories/5?$listingTypeQueryKey=rent',
    );
  });

  test('listingsPath builds resolved path without route pattern', () {
    expect(AppRoutes.listingsPath('5'), '/listings/5');
    expect(AppRoutes.listingsPath('all'), '/listings/all');
    expect(AppRoutes.listingsPath('5'), isNot(contains(':categoryId')));
  });

  test('listingsPath includes listing type query', () {
    expect(
      AppRoutes.listingsPath('10', listingType: 'sale'),
      '/listings/10?$listingTypeQueryKey=sale',
    );
  });

  test('guest allowed paths include category browse', () {
    expect(isGuestAllowedPath('/categories/1'), isTrue);
    expect(isGuestAllowedPath('/listings/5'), isTrue);
    expect(isGuestAllowedPath('/categories/1?type=rent'), isTrue);
  });
}
