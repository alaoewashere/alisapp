import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/models/price_history.dart';

void main() {
  group('PriceHistoryEntry', () {
    test('computes drop difference and percent', () {
      final entry = PriceHistoryEntry(
        id: '1',
        listingId: 'l1',
        oldPrice: 60000000,
        newPrice: 52000000,
        changedAt: DateTime(2026, 5, 15),
      );

      expect(entry.difference, -8000000);
      expect(entry.isDropped, isTrue);
      expect(entry.percentChange, closeTo(-13.333, 0.01));
    });
  });

  group('buildPriceHistoryTimeline', () {
    test('prepends original and marks current price', () {
      final changes = [
        PriceHistoryEntry(
          id: '1',
          listingId: 'l1',
          oldPrice: 60000000,
          newPrice: 55000000,
          changedAt: DateTime(2026, 5, 10),
        ),
        PriceHistoryEntry(
          id: '2',
          listingId: 'l1',
          oldPrice: 55000000,
          newPrice: 52000000,
          changedAt: DateTime(2026, 5, 15),
        ),
      ];

      final timeline = buildPriceHistoryTimeline(
        originalPrice: 60000000,
        listedAt: DateTime(2026, 5, 1),
        changes: changes,
      );

      expect(timeline.length, 3);
      expect(timeline.first.isOriginal, isTrue);
      expect(timeline.first.price, 60000000);
      expect(timeline.last.isCurrent, isTrue);
      expect(timeline.last.price, 52000000);
    });

    test('returns empty when no changes', () {
      expect(
        buildPriceHistoryTimeline(
          originalPrice: 100,
          listedAt: DateTime(2026, 1, 1),
          changes: const [],
        ),
        isEmpty,
      );
    });
  });

  group('formatPriceHistoryDurationAr', () {
    test('formats weeks in Arabic', () {
      expect(
        formatPriceHistoryDurationAr(
          DateTime(2026, 5, 1),
          DateTime(2026, 5, 22),
        ),
        '3 أسابيع',
      );
    });
  });

  group('PriceHistoryData', () {
    test('detects overall drop from original', () {
      final data = PriceHistoryData(
        originalPrice: 60000000,
        listedAt: DateTime(2026, 5, 1),
        changes: [
          PriceHistoryEntry(
            id: '1',
            listingId: 'l1',
            oldPrice: 60000000,
            newPrice: 52000000,
            changedAt: DateTime(2026, 5, 15),
          ),
        ],
        timeline: const [],
      );

      expect(data.hasChanges, isTrue);
      expect(data.overallDropped, isTrue);
      expect(data.currentPrice, 52000000);
    });
  });
}
