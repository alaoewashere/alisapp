import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/utils/listing_display_title.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  String titleAr = '',
  Map<String, dynamic> metadata = const {},
  String? categoryNameAr,
}) {
  return ListingModel(
    id: '1',
    userId: 'u1',
    categoryId: 10,
    titleAr: titleAr,
    descriptionAr: '',
    price: 1000,
    city: 'بغداد',
    governorate: 'baghdad',
    displayStatus: ListingDisplayStatus.active,
    createdAt: DateTime(2026, 1, 1),
    categoryNameAr: categoryNameAr,
    metadata: metadata,
  );
}

void main() {
  group('listingDisplayTitle', () {
    test('returns user-written title when present', () {
      final listing = _listing(titleAr: 'شقة للإيجار في الكرادة');

      expect(listingDisplayTitle(listing), 'شقة للإيجار في الكرادة');
    });

    test('falls back to real estate metadata when title is empty', () {
      final listing = _listing(
        metadata: const {
          'listing_kind': 'real_estate',
          'property_type': 'فيلا',
          'rooms': '2',
          'area_sqm': 90000,
        },
      );

      expect(listingDisplayTitle(listing), 'فيلا — 2 غرف — 90000 م²');
    });

    test('falls back to category name for generic listings', () {
      final listing = _listing(categoryNameAr: 'إلكترونيات');

      expect(listingDisplayTitle(listing), 'إلكترونيات');
    });
  });
}
