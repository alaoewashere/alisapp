import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/home/utils/home_listing_search.dart';
import 'package:my_app/shared/models/listing_model.dart';

ListingModel _listing(String titleAr) {
  return ListingModel(
    id: 'test-id',
    userId: 'user-id',
    categoryId: 1,
    titleAr: titleAr,
    descriptionAr: '',
    price: 1000,
    currency: 'IQD',
    governorate: 'baghdad',
    city: 'بغداد',
    displayStatus: ListingDisplayStatus.active,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('normalizeForHomeSearch folds Arabic alef variants', () {
    expect(normalizeForHomeSearch('أ'), normalizeForHomeSearch('ا'));
    expect(normalizeForHomeSearch('إ'), normalizeForHomeSearch('ا'));
  });

  test('listingTitleMatchesHomeSearch is case-insensitive', () {
    final listing = _listing('Toyota Camry');
    expect(listingTitleMatchesHomeSearch(listing, 'toyota'), isTrue);
    expect(listingTitleMatchesHomeSearch(listing, 'CAMRY'), isTrue);
  });

  test('listingTitleMatchesHomeSearch matches Arabic titles', () {
    final listing = _listing('سيارة تويوتا');
    expect(listingTitleMatchesHomeSearch(listing, 'تويوتا'), isTrue);
    expect(listingTitleMatchesHomeSearch(listing, 'مرسيدس'), isFalse);
  });

  test('filterHomeListingsByTitle returns full list when query empty', () {
    final listings = [_listing('أ'), _listing('ب')];
    expect(filterHomeListingsByTitle(listings, ''), listings);
    expect(filterHomeListingsByTitle(listings, '   '), listings);
  });
}
