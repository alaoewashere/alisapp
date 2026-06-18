import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/electronics_listing_utils.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/electronics_listing_metadata.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  group('electronicsFormKind', () {
    test('detects phone branch from category path', () {
      expect(
        electronicsFormKind(const [
          CategoryModel(
            id: 1,
            slug: 'electronics',
            nameAr: 'الإلكترونيات',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'elec_smartphones',
            nameAr: 'هواتف ذكية',
            icon: 'category',
            parentId: 1,
          ),
          CategoryModel(
            id: 3,
            slug: 'elec_smartphones_br_apple',
            nameAr: 'Apple',
            icon: 'brand',
            parentId: 2,
          ),
          CategoryModel(
            id: 4,
            slug: 'elec_smartphones_br_apple_iphone_15_pro',
            nameAr: 'iPhone 15 Pro',
            icon: 'model',
            parentId: 3,
          ),
        ]),
        ElectronicsFormKind.phone,
      );
    });

    test('detects laptop branch', () {
      expect(
        electronicsFormKind(const [
          CategoryModel(
            id: 1,
            slug: 'electronics',
            nameAr: 'الإلكترونيات',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'elec_laptops',
            nameAr: 'لابتوب وكمبيوتر',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        ElectronicsFormKind.laptop,
      );
    });

    test('detects tv branch', () {
      expect(
        electronicsFormKind(const [
          CategoryModel(
            id: 1,
            slug: 'electronics',
            nameAr: 'الإلكترونيات',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'elec_displays',
            nameAr: 'شاشات وتلفزيونات',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        ElectronicsFormKind.tv,
      );
    });
  });

  group('deriveElectronicsDetailsFromPath', () {
    test('extracts brand and model from path', () {
      final details = deriveElectronicsDetailsFromPath(
        const [
          CategoryModel(
            id: 1,
            slug: 'electronics',
            nameAr: 'الإلكترونيات',
            icon: 'category',
          ),
          CategoryModel(
            id: 2,
            slug: 'elec_smartphones',
            nameAr: 'هواتف ذكية',
            icon: 'category',
            parentId: 1,
          ),
          CategoryModel(
            id: 3,
            slug: 'elec_smartphones_br_apple',
            nameAr: 'Apple',
            icon: 'brand',
            parentId: 2,
          ),
          CategoryModel(
            id: 4,
            slug: 'elec_smartphones_br_apple_iphone_15_pro',
            nameAr: 'iPhone 15 Pro',
            icon: 'model',
            parentId: 3,
          ),
        ],
        ElectronicsFormKind.phone,
      );

      expect(details.listingKind, ElectronicsListingMetadata.phoneKind);
      expect(details.brand, 'Apple');
      expect(details.model, 'iPhone 15 Pro');
    });
  });

  group('ElectronicsListingMetadata', () {
    test('serializes phone fields to metadata json', () {
      const details = ElectronicsListingMetadata(
        listingKind: ElectronicsListingMetadata.phoneKind,
        brand: 'Apple',
        model: 'iPhone 15 Pro',
        storage: '256GB',
        ram: '8GB',
        color: 'أسود',
        condition: 'مستعمل',
        batteryHealth: '95%',
        hasBox: true,
        hasCharger: false,
        warranty: 'ضمان',
      );

      final json = details.toJson();
      expect(json['listing_kind'], 'phone');
      expect(json['brand'], 'Apple');
      expect(json['storage'], '256GB');
      expect(json['battery_health'], '95%');
      expect(json['has_box'], isTrue);
      expect(json['has_charger'], isFalse);
    });
  });

  group('electronicsDbCondition', () {
    test('maps Arabic condition labels to ListingCondition', () {
      expect(electronicsDbCondition('جديد'), ListingCondition.newItem);
      expect(electronicsDbCondition('مستعمل'), ListingCondition.used);
      expect(electronicsDbCondition('مكسور الشاشة'), ListingCondition.used);
    });
  });

  group('PostListingNotifier electronics validation', () {
    test('requires condition and price for phone listings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'electronics',
          nameAr: 'الإلكترونيات',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'elec_smartphones',
          nameAr: 'هواتف ذكية',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'elec_smartphones_br_apple',
          nameAr: 'Apple',
          icon: 'brand',
          parentId: 2,
        ),
        CategoryModel(
          id: 4,
          slug: 'elec_smartphones_br_apple_iphone_15_pro',
          nameAr: 'iPhone 15 Pro',
          icon: 'model',
          parentId: 3,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر الحالة');

      notifier.updateElectronicsDetails(
        container.read(postListingProvider).electronicsDetails.copyWith(
              condition: 'جديد',
            ),
      );
      expect(notifier.validateStep(2), 'أدخل سعراً صالحاً');

      notifier.updateField('price', 500000.0);
      expect(notifier.validateStep(2), isNull);
    });
  });
}
