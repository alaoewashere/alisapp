import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/listing_package_utils.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  required String id,
  bool isFeatured = false,
  bool isBoosted = false,
  Map<String, dynamic>? metadata,
  DateTime? createdAt,
}) {
  return ListingModel(
    id: id,
    userId: 'u1',
    categoryId: 1,
    titleAr: id,
    descriptionAr: '',
    price: 1000,
    city: 'بغداد',
    governorate: 'baghdad',
    displayStatus: ListingDisplayStatus.active,
    createdAt: createdAt ?? DateTime(2026, 6, 1),
    isFeatured: isFeatured,
    isBoosted: isBoosted,
    metadata: metadata ?? const {},
  );
}

void main() {
  group('sortLatestHomeFeedListings', () {
    test('excludes مميز and orders برو before مجاني regardless of date', () {
      final input = [
        _listing(id: 'free-newest', createdAt: DateTime(2026, 6, 20)),
        _listing(
          id: 'pro-oldest',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 1),
        ),
        _listing(
          id: 'premium',
          isFeatured: true,
          createdAt: DateTime(2026, 6, 15),
        ),
        _listing(
          id: 'pro-newest',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 18),
        ),
        _listing(id: 'free-oldest', createdAt: DateTime(2026, 6, 2)),
      ];

      final sorted = sortLatestHomeFeedListings(input);

      expect(sorted.map((e) => e.id).toList(), [
        'pro-newest',
        'pro-oldest',
        'free-newest',
        'free-oldest',
      ]);
      expect(sorted.any((e) => e.id == 'premium'), isFalse);
    });

    test('pro via metadata ranks before free when is_boosted is false', () {
      final input = [
        _listing(id: 'free-new', createdAt: DateTime(2026, 6, 20)),
        _listing(
          id: 'pro-meta-old',
          metadata: const {'listing_package': 'pro'},
          createdAt: DateTime(2026, 6, 3),
        ),
      ];

      final sorted = sortLatestHomeFeedListings(input);
      expect(sorted.first.id, 'pro-meta-old');
      expect(sorted.last.id, 'free-new');
    });

    test('newest-first within برو and within مجاني groups', () {
      final input = [
        _listing(
          id: 'pro-a',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 5),
        ),
        _listing(
          id: 'pro-b',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 10),
        ),
        _listing(id: 'free-a', createdAt: DateTime(2026, 6, 8)),
        _listing(id: 'free-b', createdAt: DateTime(2026, 6, 12)),
      ];

      final sorted = sortLatestHomeFeedListings(input);
      expect(sorted.map((e) => e.id).toList(), [
        'pro-b',
        'pro-a',
        'free-b',
        'free-a',
      ]);
    });
  });

  group('sliceLatestHomeFeedPage', () {
    test('page 0 and page 1 preserve global برو-before-مجاني order', () {
      final input = [
        _listing(id: 'free-1', createdAt: DateTime(2026, 6, 20)),
        _listing(
          id: 'pro-1',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 1),
        ),
        _listing(id: 'free-2', createdAt: DateTime(2026, 6, 19)),
        _listing(
          id: 'pro-2',
          isBoosted: true,
          createdAt: DateTime(2026, 6, 2),
        ),
      ];

      final page0 = sliceLatestHomeFeedPage(input, page: 0, pageSize: 2);
      final page1 = sliceLatestHomeFeedPage(input, page: 1, pageSize: 2);

      expect(page0.map((e) => e.id).toList(), ['pro-2', 'pro-1']);
      expect(page1.map((e) => e.id).toList(), ['free-1', 'free-2']);
    });
  });
}
