import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/real_estate_listing_utils.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/real_estate_listing_metadata.dart';

void main() {
  group('isRealEstateCategoryPath', () {
    test('returns true for real_estate root path', () {
      expect(
        isRealEstateCategoryPath(const [
          CategoryModel(
            id: 1,
            slug: 'real_estate',
            nameAr: 'العقارات',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 're_apartment',
            nameAr: 'شقق',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        isTrue,
      );
    });
  });

  group('RealEstateListingMetadata', () {
    test('serializes to expected metadata keys', () {
      const details = RealEstateListingMetadata(
        propertyType: 'شقة',
        offerType: 'بيع',
        areaSqm: 150,
        floor: 3,
        rooms: '3',
        bathrooms: '2',
        furnished: 'مفروش',
        deedType: 'طابo',
        features: ['مصعد', 'موقف سيارة'],
      );

      final json = details.toJson();
      expect(json['listing_kind'], 'real_estate');
      expect(json['property_type'], 'شقة');
      expect(json['listing_type'], 'بيع');
      expect(json['area_sqm'], '150');
      expect(json['features'], ['مصعد', 'موقف سيارة']);
    });
  });

  group('PostListingNotifier real estate validation', () {
    test('requires property type, offer type, and area', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'real_estate',
          nameAr: 'العقارات',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 're_apartment',
          nameAr: 'شقق',
          icon: 'category',
          parentId: 1,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر نوع العقار');

      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(propertyType: 'شقة'),
      );
      expect(notifier.validateStep(2), 'اختر نوع العرض');

      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'شقة',
          offerType: 'بيع',
        ),
      );
      expect(notifier.validateStep(2), 'أدخل المساحة بالمتر المربع');

      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'شقة',
          offerType: 'بيع',
          areaSqm: 120,
        ),
      );
      notifier.updateField('price', 500000000.0);
      expect(notifier.validateStep(2), isNull);
    });
  });
}
