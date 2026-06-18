import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/app_governorates.dart';
import 'package:Sello/features/listings/models/edit_listing_snapshot.dart';
import 'package:Sello/shared/models/listing_model.dart';

void main() {
  group('buildEditListingFieldUpdates', () {
    final original = EditListingSnapshot(
      title: 'عنوان',
      description: 'وصف',
      price: 100000,
      isNegotiable: false,
      condition: ListingCondition.used,
      governorate: 'baghdad',
      city: governorateNameAr('baghdad'),
      latitude: 33.3,
      longitude: 44.4,
      locationAddress: 'شارع',
      areaName: 'الكرادة',
      contactPreference: ListingContactPreference.messagesOnly,
      metadata: const {'make': 'Toyota'},
      imageIds: const ['img-1'],
    );

    test('returns empty map when nothing changed', () {
      final updates = buildEditListingFieldUpdates(
        original: original,
        title: 'عنوان',
        description: 'وصف',
        price: 100000,
        isNegotiable: false,
        condition: ListingCondition.used,
        governorate: 'baghdad',
        city: 'بغداد',
        latitude: 33.3,
        longitude: 44.4,
        locationAddress: 'شارع',
        areaName: 'الكرادة',
        contactPreference: ListingContactPreference.messagesOnly,
        metadata: const {'make': 'Toyota'},
      );

      expect(updates, isEmpty);
    });

    test('includes price fields when price changed', () {
      final updates = buildEditListingFieldUpdates(
        original: original,
        title: 'عنوان',
        description: 'وصف',
        price: 90000,
        isNegotiable: false,
        condition: ListingCondition.used,
        governorate: 'baghdad',
        city: 'بغداد',
        latitude: 33.3,
        longitude: 44.4,
        locationAddress: 'شارع',
        areaName: 'الكرادة',
        contactPreference: ListingContactPreference.messagesOnly,
        metadata: const {'make': 'Toyota'},
      );

      expect(updates['price_iqd'], 90000);
      expect(updates['price'], 90000);
    });

    test('includes only changed scalar fields', () {
      final updates = buildEditListingFieldUpdates(
        original: original,
        title: 'عنوان جديد',
        description: 'وصف',
        price: 100000,
        isNegotiable: true,
        condition: ListingCondition.used,
        governorate: 'baghdad',
        city: 'بغداد',
        latitude: 33.3,
        longitude: 44.4,
        locationAddress: 'شارع',
        areaName: 'الكرادة',
        contactPreference: ListingContactPreference.messagesOnly,
        metadata: const {'make': 'Toyota'},
      );

      expect(updates['title'], 'عنوان جديد');
      expect(updates['title_ar'], 'عنوان جديد');
      expect(updates['is_negotiable'], isTrue);
      expect(updates.containsKey('price'), isFalse);
      expect(updates.containsKey('city'), isFalse);
    });
  });

  group('mergeEditListingMetadata', () {
    test('preserves original keys when merging category metadata', () {
      final merged = mergeEditListingMetadata(
        original: const {
          'listing_package': 'premium',
          'listing_kind': 'vehicle',
          'trim': 'Sport',
        },
        categoryMetadata: const {
          'listing_kind': 'vehicle',
          'trim': 'Sport',
          'mileage': 50000,
        },
      );

      expect(merged?['listing_package'], 'premium');
      expect(merged?['mileage'], 50000);
    });

    test('strips contact_preference from metadata', () {
      final merged = mergeEditListingMetadata(
        original: const {'contact_preference': 'phone_only'},
        categoryMetadata: const {'listing_kind': 'general'},
      );

      expect(merged?.containsKey('contact_preference'), isFalse);
      expect(merged?['listing_kind'], 'general');
    });
  });

  group('normalizeEditListingCity', () {
    test('uses governorate Arabic name when governorate slug is set', () {
      expect(
        normalizeEditListingCity(governorate: 'baghdad', city: 'الكرخ'),
        governorateNameAr('baghdad'),
      );
    });
  });

  group('imagesChanged', () {
    const original = EditListingSnapshot(
      title: '',
      description: '',
      price: 0,
      isNegotiable: false,
      condition: null,
      governorate: '',
      city: '',
      latitude: null,
      longitude: null,
      locationAddress: null,
      areaName: null,
      contactPreference: null,
      metadata: null,
      imageIds: ['a', 'b'],
    );

    test('false when images unchanged', () {
      expect(
        imagesChanged(
          original: original,
          currentImageIds: const ['a', 'b'],
          removedImageIds: const [],
          newImageCount: 0,
        ),
        isFalse,
      );
    });

    test('true when image removed', () {
      expect(
        imagesChanged(
          original: original,
          currentImageIds: const ['a'],
          removedImageIds: const ['b'],
          newImageCount: 0,
        ),
        isTrue,
      );
    });

    test('true when new images added', () {
      expect(
        imagesChanged(
          original: original,
          currentImageIds: const ['a', 'b'],
          removedImageIds: const [],
          newImageCount: 1,
        ),
        isTrue,
      );
    });
  });
}
