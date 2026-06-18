import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/iraq_neighborhoods.dart';

void main() {
  test('iraqNeighborhoods mirrors seeded center count', () {
    expect(iraqNeighborhoods.length, 29);
  });

  test('nearestNeighborhood matches SQL-style nearest center', () {
    final nearest = nearestNeighborhood(
      latitude: 33.2989176206327,
      longitude: 44.3372610211372,
    );
    expect(nearest?.nameAr, 'المنصور');
  });

  test('neighborhoodsForGovernorate filters by governorate slug', () {
    final baghdad = neighborhoodsForGovernorate('baghdad');
    expect(baghdad.length, 18);
    expect(baghdad.every((n) => n.governorateSlug == 'baghdad'), isTrue);
  });
}
