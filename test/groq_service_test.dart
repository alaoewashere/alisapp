import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:Sello/services/groq_service.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';

void main() {
  group('GroqService', () {
    test('estimatePrice parses chat completion JSON', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.groq.com/openai/v1/chat/completions',
        );
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'llama-3.3-70b-versatile');

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'min': 45000000,
                    'max': 52000000,
                    'confidence': 'high',
                    'reasoning': 'سوق بغداد',
                  }),
                },
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = GroqService(client: client, apiKey: 'test-key');
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

      final estimate = await service.estimatePrice(input);
      expect(estimate.minPrice, 45000000);
      expect(estimate.maxPrice, 52000000);
      expect(estimate.confidence, 'high');
    });

    test('estimatePrice throws when API key missing', () async {
      final service = GroqService(
        client: MockClient((_) async {
          throw StateError('Should not call network without API key');
        }),
        apiKey: '',
      );

      expect(
        () => service.estimatePrice(
          const CarPriceEstimateInput(make: 'Toyota', model: 'Corolla'),
        ),
        throwsA(isA<GroqServiceException>()),
      );
    });
  });
}
