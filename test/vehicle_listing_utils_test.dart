import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/utils/vehicle_listing_utils.dart';
import 'package:my_app/shared/models/category_model.dart';
import 'package:my_app/shared/models/listing_model.dart';
import 'package:my_app/shared/models/vehicle_listing_metadata.dart';

void main() {
  group('isAutomobileCarListingPath', () {
    test('returns true only for veh_automobile branch', () {
      expect(
        isAutomobileCarListingPath(const [
          CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
          CategoryModel(
            id: 2,
            slug: 'veh_automobile',
            nameAr: 'سيارات',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        isTrue,
      );
    });

    test('returns false for motorcycle branch', () {
      expect(
        isAutomobileCarListingPath(const [
          CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
          CategoryModel(
            id: 2,
            slug: 'veh_motorcycle',
            nameAr: 'دراجات',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        isFalse,
      );
    });
  });

  group('vehicleIdentityFromPath', () {
    test('extracts brand and model', () {
      const path = [
        CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
        CategoryModel(
          id: 2,
          slug: 'veh_automobile',
          nameAr: 'سيارات',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'veh_auto_br_toyota',
          nameAr: 'Toyota',
          icon: 'brand',
          parentId: 2,
        ),
        CategoryModel(
          id: 4,
          slug: 'veh_auto_br_toyota_corolla',
          nameAr: 'Corolla',
          icon: 'model',
          parentId: 3,
        ),
      ];

      final identity = vehicleIdentityFromPath(path);
      expect(identity.make, 'Toyota');
      expect(identity.model, 'Corolla');
    });
  });

  group('isVehicleCategoryPath', () {
    test('returns true for cars root path', () {
      expect(
        isVehicleCategoryPath(const [
          CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
          CategoryModel(
            id: 2,
            slug: 'veh_auto',
            nameAr: 'سيارات',
            icon: 'category',
            parentId: 1,
          ),
        ]),
        isTrue,
      );
    });

    test('returns false for non-vehicle path', () {
      expect(
        isVehicleCategoryPath(const [
          CategoryModel(id: 1, slug: 'jobs', nameAr: 'فرص العمل', icon: 'category'),
        ]),
        isFalse,
      );
    });
  });

  group('buildVehicleListingTitle', () {
    test('includes trim when provided', () {
      const path = [
        CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
        CategoryModel(
          id: 2,
          slug: 'toyota',
          nameAr: 'Toyota',
          icon: 'brand',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'camry',
          nameAr: 'Camry',
          icon: 'model',
          parentId: 2,
        ),
      ];
      const vehicle = VehicleListingMetadata(trim: 'SE');

      expect(buildVehicleListingTitle(path, vehicle), 'Camry SE');
    });
  });

  group('vehicle metadata json', () {
    test('round-trips selected specs', () {
      const original = VehicleListingMetadata(
        trim: 'Limited',
        mileage: 85000,
        fuel: 'بenzin',
        transmission: 'أوتوماتيك',
        selectedSpecs: ['كاميرا خلفية', 'ABS'],
      );

      final restored = VehicleListingMetadata.fromJson(original.toJson());
      expect(restored.trim, 'Limited');
      expect(restored.mileage, 85000);
      expect(restored.fuel, 'بenzin');
      expect(restored.transmission, 'أوتوماتيك');
      expect(restored.selectedSpecs, original.selectedSpecs);
    });
  });

  group('vehicle display formatting', () {
    test('formatVehicleMileageDisplay adds thousands separator', () {
      expect(
        formatVehicleMileageDisplay(22000, MileageUnit.km),
        '22,000 كم',
      );
    });

    test('formatVehicleEngineDisplay prefixes engine label', () {
      expect(formatVehicleEngineDisplay('2.0T'), 'محرك، 2.0T');
    });
  });
}
