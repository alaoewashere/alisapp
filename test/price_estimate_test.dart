import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/models/price_estimate.dart';

void main() {
  group('PriceEstimate', () {
    test('fromJson parses valid payload', () {
      final estimate = PriceEstimate.fromJson(const {
        'min': 45000000,
        'max': 52000000,
        'confidence': 'high',
        'reasoning': 'سيارة بحالة جيدة',
      });

      expect(estimate.minPrice, 45000000);
      expect(estimate.maxPrice, 52000000);
      expect(estimate.confidence, 'high');
      expect(estimate.reasoning, 'سيارة بحالة جيدة');
    });

    test('parseResponseContent handles fenced JSON', () {
      const content = '''
Here is the estimate:
```json
{"min": 10000000, "max": 12000000, "confidence": "medium", "reasoning": "سعر معقول"}
```
''';

      final estimate = PriceEstimate.parseResponseContent(content);
      expect(estimate.minPrice, 10000000);
      expect(estimate.maxPrice, 12000000);
      expect(estimate.confidence, 'medium');
    });

    test('fromJson rejects invalid confidence', () {
      expect(
        () => PriceEstimate.fromJson(const {
          'min': 1,
          'max': 2,
          'confidence': 'maybe',
          'reasoning': 'x',
        }),
        throwsFormatException,
      );
    });
  });
}
