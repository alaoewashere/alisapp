import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/services/share_service.dart';
import 'package:Sello/shared/models/listing_model.dart';

ListingModel _listing({
  String? coverImageUrl,
  List<ListingImage> images = const [],
  int? referenceNo,
}) {
  return ListingModel(
    id: 'abc-123',
    userId: 'u1',
    categoryId: 1,
    titleAr: 'سيارة للبيع',
    descriptionAr: '',
    price: 15000000,
    city: 'بغداد',
    governorate: 'baghdad',
    displayStatus: ListingDisplayStatus.active,
    createdAt: DateTime(2026, 6, 1),
    coverImageUrl: coverImageUrl,
    images: images,
    referenceNo: referenceNo,
  );
}

void main() {
  group('listingShareImageUrl', () {
    test('prefers coverImageUrl', () {
      final listing = _listing(
        coverImageUrl: 'https://cdn.example.com/cover.jpg',
        images: [
          ListingImage(
            id: '1',
            listingId: 'abc-123',
            storagePath: 'https://cdn.example.com/other.jpg',
            sortOrder: 0,
          ),
        ],
      );

      expect(
        listingShareImageUrl(listing),
        'https://cdn.example.com/cover.jpg',
      );
    });

    test('falls back to first image url', () {
      final listing = _listing(
        images: [
          ListingImage(
            id: '1',
            listingId: 'abc-123',
            url: 'https://cdn.example.com/first.jpg',
            storagePath: 'path/first.jpg',
            sortOrder: 0,
          ),
        ],
      );

      expect(
        listingShareImageUrl(listing),
        'https://cdn.example.com/first.jpg',
      );
    });

    test('falls back to storagePath when url is null', () {
      final listing = _listing(
        images: [
          ListingImage(
            id: '1',
            listingId: 'abc-123',
            storagePath: 'https://cdn.example.com/storage.jpg',
            sortOrder: 0,
          ),
        ],
      );

      expect(
        listingShareImageUrl(listing),
        'https://cdn.example.com/storage.jpg',
      );
    });

    test('returns null when no images', () {
      expect(listingShareImageUrl(_listing()), isNull);
    });
  });
}
