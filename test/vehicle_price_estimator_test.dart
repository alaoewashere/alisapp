import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/listings/widgets/vehicle_price_estimator_section.dart';
import 'package:Sello/models/price_estimate.dart';
import 'package:Sello/services/groq_service.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';

class _FakeGroqService extends GroqService {
  _FakeGroqService({this.result, this.error});

  final PriceEstimate? result;
  final Object? error;

  @override
  Future<PriceEstimate> estimatePrice(CarPriceEstimateInput input) async {
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  const automobilePath = [
    CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
    CategoryModel(
      id: 2,
      slug: 'veh_automobile',
      nameAr: 'سيارات',
      icon: 'category',
      parentId: 1,
    ),
  ];

  const motorcyclePath = [
    CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
    CategoryModel(
      id: 2,
      slug: 'veh_motorcycle',
      nameAr: 'دراجات',
      icon: 'category',
      parentId: 1,
    ),
  ];

  group('VehiclePriceEstimatorSection', () {
    testWidgets('shows button only for automobile cars path', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VehiclePriceEstimatorSection(
                categoryPath: automobilePath,
                vehicle: const VehicleListingMetadata(),
                condition: ListingCondition.used,
              ),
            ),
          ),
        ),
      );

      expect(find.text('✨ احسب السعر المقترح'), findsOneWidget);
    });

    testWidgets('hidden for motorcycle path', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VehiclePriceEstimatorSection(
                categoryPath: motorcyclePath,
                vehicle: const VehicleListingMetadata(),
                condition: ListingCondition.used,
              ),
            ),
          ),
        ),
      );

      expect(find.text('✨ احسب السعر المقترح'), findsNothing);
    });

    testWidgets('shows estimate card after successful request', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groqServiceProvider.overrideWithValue(
              _FakeGroqService(
                result: const PriceEstimate(
                  minPrice: 45000000,
                  maxPrice: 52000000,
                  confidence: 'high',
                  reasoning: 'سعر مناسب للسوق العراقي',
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclePriceEstimatorSection(
                categoryPath: automobilePath,
                vehicle: const VehicleListingMetadata(mileage: 70000),
                condition: ListingCondition.used,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('✨ احسب السعر المقترح'));
      await tester.pump();
      await tester.pump();

      expect(find.text('تقدير الذكاء الاصطناعي'), findsOneWidget);
      expect(find.textContaining('45,000,000'), findsOneWidget);
      expect(find.text('عالية'), findsOneWidget);
    });
  });
}
