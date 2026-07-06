import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/listing_translation.dart';
import 'package:Sello/services/translation_service.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  String titleAr = 'سيارة للبيع',
  String descriptionAr = 'وصف الإعلان',
}) {
  return ListingModel(
    id: '1',
    userId: 'u1',
    categoryId: 1,
    titleAr: titleAr,
    descriptionAr: descriptionAr,
    price: 1000,
    city: 'بغداد',
    governorate: 'baghdad',
    displayStatus: ListingDisplayStatus.active,
    createdAt: DateTime(2024),
  );
}

void main() {
  tearDown(TranslationService.clearCacheForTesting);

  test('returns listings unchanged for Arabic locale', () async {
    final listings = [_listing()];
    final result = await translateListingsForLocale(listings, 'ar');
    expect(result, same(listings));
    expect(result.first.titleAr, 'سيارة للبيع');
  });

  test('returns same instances when locale is Arabic', () async {
    final listing = _listing();
    final result = await translateListingForLocale(listing, 'ar');
    expect(identical(result, listing), isTrue);
  });

  test('clearCache clears translation cache', () async {
    const text = 'cache probe';
    await TranslationService.translate(text, 'en');
    TranslationService.clearCache();
    await TranslationService.translate(text, 'en');
    // Without Groq configured both calls return original; test only ensures no throw.
    expect(await TranslationService.translate(text, 'en'), text);
  });
}
