import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/services/groq_service.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';

void main() {
  group('CarPriceEstimateInput', () {
    test('fromListingForm builds correct make/model from category path', () {
      final input = CarPriceEstimateInput.fromListingForm(
        categoryPath: const [
          CategoryModel(
            id: 1,
            slug: 'cars',
            nameAr: 'المركبات',
            icon: 'category',
          ),
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
        ],
        vehicle: const VehicleListingMetadata(
          mileage: 80000,
          color: 'أبيض',
          selectedSpecs: ['ABS'],
        ),
        condition: ListingCondition.used,
      );

      expect(input.make, 'Toyota');
      expect(input.model, 'Corolla');
      expect(input.kilometers, 80000);
    });
  });

  group('GroqService', () {
    test('estimatePrice throws GroqServiceException when no session', () {
      final service = GroqService();
      expect(
        () => service.estimatePrice(
          const CarPriceEstimateInput(make: 'Toyota', model: 'Corolla'),
        ),
        throwsA(isA<GroqServiceException>()),
      );
    });
  });
}
