import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/general_listing_utils.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/general_listing_metadata.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  group('isGeneralMarketplaceCategoryPath', () {
    test('returns true for buy_sell root path', () {
      expect(
        isGeneralMarketplaceCategoryPath(const [
          CategoryModel(
            id: 1,
            slug: 'buy_sell',
            nameAr: 'سوق المستعمل والجديد',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'souq_mobile',
            nameAr: 'موبايلات وإكسسوارات',
            icon: 'category',
            parentId: 1,
          ),
          CategoryModel(
            id: 3,
            slug: 'souq_mobile_item_01',
            nameAr: 'هواتف ذكية',
            icon: 'model',
            parentId: 2,
          ),
        ]),
        isTrue,
      );
    });
  });

  group('GeneralListingMetadata', () {
    test('serializes to expected metadata keys', () {
      const details = GeneralListingMetadata(
        itemCondition: 'ممتاز',
        brand: 'Samsung',
        exchangePossible: true,
        deliveryAvailable: true,
        deliveryCost: 'مجاني',
      );

      final json = details.toJson();
      expect(json['listing_kind'], 'general');
      expect(json['item_condition'], 'ممتاز');
      expect(json['brand'], 'Samsung');
      expect(json['exchange_possible'], isTrue);
      expect(json['delivery_available'], isTrue);
      expect(json['delivery_cost'], 'مجاني');
    });

    test('omits delivery_cost when delivery unavailable', () {
      const details = GeneralListingMetadata(
        itemCondition: 'جديد',
        deliveryAvailable: false,
        deliveryCost: 'مدفوع',
      );

      final json = details.toJson();
      expect(json.containsKey('delivery_cost'), isFalse);
    });
  });

  group('generalDbCondition', () {
    test('maps item condition to ListingCondition', () {
      expect(generalDbCondition('جديد'), ListingCondition.newItem);
      expect(generalDbCondition('مستعمل'), ListingCondition.used);
      expect(generalDbCondition('ممتاز'), ListingCondition.used);
      expect(generalDbCondition('جيد'), ListingCondition.used);
      expect(generalDbCondition('مقبول'), ListingCondition.used);
    });
  });

  group('buildGeneralListingTitle', () {
    test('combines brand and leaf category name', () {
      final title = buildGeneralListingTitle(
        const [
          CategoryModel(
            id: 1,
            slug: 'buy_sell',
            nameAr: 'سوق',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'souq_mobile_item_01',
            nameAr: 'هواتف ذكية',
            icon: 'model',
            parentId: 1,
          ),
        ],
        const GeneralListingMetadata(brand: 'Samsung'),
      );
      expect(title, 'Samsung هواتف ذكية');
    });
  });

  group('PostListingNotifier general marketplace validation', () {
    test('requires item condition, delivery cost when enabled, and price', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'buy_sell',
          nameAr: 'سوق المستعمل والجديد',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'souq_mobile',
          nameAr: 'موبايلات',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'souq_mobile_item_01',
          nameAr: 'هواتف ذكية',
          icon: 'model',
          parentId: 2,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر الحالة');

      notifier.updateGeneralDetails(
        container.read(postListingProvider).generalDetails.copyWith(
              itemCondition: 'ممتاز',
              deliveryAvailable: true,
            ),
      );
      expect(notifier.validateStep(2), 'اختر تكلفة التوصيل');

      notifier.updateGeneralDetails(
        container.read(postListingProvider).generalDetails.copyWith(
              deliveryCost: 'مجاني',
            ),
      );
      expect(notifier.validateStep(2), 'أدخل سعراً صالحاً');

      notifier.updateField('price', 250000.0);
      expect(notifier.validateStep(2), isNull);
    });
  });
}
