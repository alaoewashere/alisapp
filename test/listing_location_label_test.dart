import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/utils/listing_location_label.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  String? areaName,
  String city = 'بغداد',
  String governorate = 'baghdad',
}) {
  return ListingModel(
    id: 'id',
    userId: 'user',
    categoryId: 1,
    titleAr: 'test',
    descriptionAr: '',
    price: 1000,
    currency: 'IQD',
    governorate: governorate,
    city: city,
    areaName: areaName,
    displayStatus: ListingDisplayStatus.active,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('listingLocationLabel prefers areaName over city', () {
    final listing = _listing(areaName: 'اليرموك', city: 'بغداد');
    expect(listingLocationLabel(listing), 'اليرموك');
  });

  test('listingLocationLabel falls back to city when areaName is empty', () {
    final listing = _listing(city: 'أربيل', governorate: 'erbil');
    expect(listingLocationLabel(listing), 'أربيل');
  });
}
