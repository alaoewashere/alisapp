import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/groq_config.dart';
import '../core/utils/vehicle_listing_utils.dart';
import '../models/price_estimate.dart';
import '../shared/models/category_model.dart';
import '../shared/models/listing_model.dart';
import '../shared/models/vehicle_listing_metadata.dart';

/// Input for the Groq car price estimator.
class CarPriceEstimateInput {
  const CarPriceEstimateInput({
    required this.make,
    required this.model,
    this.year,
    this.kilometers,
    this.mileageUnit,
    this.condition,
    this.color,
    this.trim,
    this.engine,
    this.fuel,
    this.transmission,
    this.specs = const [],
  });

  final String? make;
  final String? model;
  final String? year;
  final int? kilometers;
  final String? mileageUnit;
  final String? condition;
  final String? color;
  final String? trim;
  final String? engine;
  final String? fuel;
  final String? transmission;
  final List<String> specs;

  factory CarPriceEstimateInput.fromListingForm({
    required List<CategoryModel> categoryPath,
    required VehicleListingMetadata vehicle,
    required ListingCondition? condition,
  }) {
    final identity = vehicleIdentityFromPath(categoryPath);

    final colorLabel = vehicle.color;
    final resolvedColor = colorLabel != null && colorLabel.isNotEmpty
        ? (vehicle.customColor.isNotEmpty ? vehicle.customColor : colorLabel)
        : null;

    return CarPriceEstimateInput(
      make: identity.make,
      model: identity.model,
      year: identity.year,
      kilometers: vehicle.mileage,
      mileageUnit: vehicle.mileage != null ? vehicle.mileageUnit.labelAr : null,
      condition: switch (condition) {
        ListingCondition.newItem => 'جديد',
        ListingCondition.used => 'مستعمل',
        null => null,
      },
      color: resolvedColor,
      trim: vehicle.trim.trim().isEmpty ? null : vehicle.trim.trim(),
      engine: vehicle.engine.trim().isEmpty ? null : vehicle.engine.trim(),
      fuel: vehicle.fuel,
      transmission: vehicle.transmission,
      specs: vehicle.selectedSpecs,
    );
  }

  String toUserMessage() {
    final lines = <String>[
      'قدّر سعر هذه السيارة في السوق العراقي بالدينار العراقي:',
      'الشركة: ${make ?? 'غير محدد'}',
      'الموديل: ${model ?? 'غير محدد'}',
      'سنة الصنع: ${year ?? 'غير محددة'}',
      if (kilometers != null)
        'المسافة المقطوعة: $kilometers ${mileageUnit ?? 'كم'}',
      'الحالة: ${condition ?? 'غير محددة'}',
      'اللون: ${color ?? 'غير محدد'}',
      if (trim != null) 'الفئة/الطراز: $trim',
      if (engine != null) 'المحرك: $engine',
      if (fuel != null) 'الوقود: $fuel',
      if (transmission != null) 'ناقل الحركة: $transmission',
      if (specs.isNotEmpty) 'المواصفات: ${specs.join('، ')}',
    ];
    return lines.join('\n');
  }
}

class GroqServiceException implements Exception {
  const GroqServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Calls Groq chat completions for Iraqi car price estimation.
class GroqService {
  GroqService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKeyOverride = apiKey;

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  /// Groq decommissioned `llama3-70b-8192`; use the official 70B replacement.
  static const _model = 'llama-3.3-70b-versatile';
  static const _timeout = Duration(seconds: 10);

  static const _systemPrompt = '''
أنت خبير في أسعار السيارات في السوق العراقي. تفهم أسعار الدينار العراقي وظروف السوق المحلية في بغداد والمحافظات العراقية.
مهمتك تقدير نطاق سعر واقعي للسيارة بناءً على بيانات المستخدم.
يجب أن ترد فقط بكائن JSON صالح بدون أي نص إضافي أو markdown، بالشكل التالي:
{"min": 45000000, "max": 52000000, "confidence": "high", "reasoning": "شرح مختصر بالعربية"}
- min و max: أعداد صحيحة بالدينار العراقي (IQD)
- confidence: high أو medium أو low فقط
- reasoning: جملة أو جملتان بالعربية تشرح التقدير
''';

  final http.Client _client;
  final String? _apiKeyOverride;

  Future<PriceEstimate> estimatePrice(CarPriceEstimateInput input) async {
    final apiKey = (_apiKeyOverride ?? GroqConfig.apiKey).trim();
    if (apiKey.isEmpty) {
      throw const GroqServiceException('Groq API key is not configured');
    }

    final body = jsonEncode({
      'model': _model,
      'temperature': 0.2,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': input.toUserMessage()},
      ],
    });

    if (kDebugMode) {
      debugPrint('GroqService: requesting price estimate');
    }

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const GroqServiceException('Groq request timed out');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GroqService: request failed: $e');
      }
      throw GroqServiceException('Groq request failed: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (kDebugMode) {
        debugPrint(
          'GroqService: API error ${response.statusCode}: ${response.body}',
        );
      }
      throw GroqServiceException(
        'Groq API error (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const GroqServiceException('Invalid Groq response shape');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const GroqServiceException('Groq response missing choices');
    }

    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw const GroqServiceException('Invalid Groq choice');
    }

    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw const GroqServiceException('Groq response missing message');
    }

    final content = message['content'];
    if (content is! String || content.trim().isEmpty) {
      throw const GroqServiceException('Groq response missing content');
    }

    try {
      return PriceEstimate.parseResponseContent(content);
    } on FormatException catch (e) {
      throw GroqServiceException('Failed to parse Groq JSON: $e');
    }
  }
}
