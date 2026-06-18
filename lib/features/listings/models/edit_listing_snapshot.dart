import '../../../core/constants/app_governorates.dart';
import '../../../shared/models/listing_model.dart';

/// Snapshot of listing fields at load time — used to diff on save.
class EditListingSnapshot {
  const EditListingSnapshot({
    required this.title,
    required this.description,
    required this.price,
    required this.isNegotiable,
    required this.condition,
    required this.governorate,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    required this.areaName,
    required this.contactPreference,
    required this.metadata,
    required this.imageIds,
  });

  final String title;
  final String description;
  final double price;
  final bool isNegotiable;
  final ListingCondition? condition;
  final String governorate;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? areaName;
  final ListingContactPreference? contactPreference;
  final Map<String, dynamic>? metadata;
  final List<String> imageIds;

  factory EditListingSnapshot.fromListing(ListingModel listing) {
    return EditListingSnapshot(
      title: listing.titleAr.trim(),
      description: listing.descriptionAr.trim(),
      price: listing.price,
      isNegotiable: listing.isNegotiable,
      condition: listing.condition,
      governorate: listing.governorate,
      city: normalizeEditListingCity(
        governorate: listing.governorate,
        city: listing.city,
      ),
      latitude: listing.latitude,
      longitude: listing.longitude,
      locationAddress: listing.locationAddress,
      areaName: listing.areaName,
      contactPreference: listing.contactPreference,
      metadata: metadataForEditSnapshot(listing.metadata),
      imageIds: listing.images.map((i) => i.id).toList(),
    );
  }
}

/// City stored the same way as edit save (governorate Arabic name when set).
String normalizeEditListingCity({
  required String governorate,
  required String city,
}) {
  if (governorate.trim().isNotEmpty) {
    return governorateNameAr(governorate);
  }
  return city.trim();
}

/// Metadata copy for diffing — excludes column-backed contact_preference.
Map<String, dynamic>? metadataForEditSnapshot(Map<String, dynamic> raw) {
  if (raw.isEmpty) return null;
  final copy = Map<String, dynamic>.from(raw);
  copy.remove('contact_preference');
  return copy.isEmpty ? null : copy;
}

/// Merges category form metadata into the original DB metadata.
Map<String, dynamic>? mergeEditListingMetadata({
  required Map<String, dynamic>? original,
  required Map<String, dynamic>? categoryMetadata,
}) {
  final merged = Map<String, dynamic>.from(original ?? {});
  merged.remove('contact_preference');
  if (categoryMetadata != null) {
    merged.addAll(categoryMetadata);
  }
  return merged.isEmpty ? null : merged;
}

/// Builds a Supabase update map containing only changed scalar fields.
Map<String, dynamic> buildEditListingFieldUpdates({
  required EditListingSnapshot original,
  required String title,
  required String description,
  required double price,
  required bool isNegotiable,
  required ListingCondition? condition,
  required String governorate,
  required String city,
  required double? latitude,
  required double? longitude,
  required String? locationAddress,
  required String? areaName,
  required ListingContactPreference? contactPreference,
  required Map<String, dynamic>? metadata,
}) {
  final updates = <String, dynamic>{};

  void setIfChanged(String key, dynamic value, dynamic originalValue) {
    if (value != originalValue) {
      updates[key] = value;
    }
  }

  final trimmedTitle = title.trim();
  final trimmedDescription = description.trim();
  final priceInt = price.round();

  setIfChanged('title', trimmedTitle, original.title);
  setIfChanged('title_ar', trimmedTitle, original.title);
  setIfChanged('description', trimmedDescription, original.description);
  setIfChanged('description_ar', trimmedDescription, original.description);

  if (priceInt != original.price.round()) {
    updates['price_iqd'] = priceInt;
    updates['price'] = priceInt;
  }

  setIfChanged('is_negotiable', isNegotiable, original.isNegotiable);

  if (condition != original.condition) {
    if (condition != null) {
      updates['condition'] = condition.value;
    }
  }

  setIfChanged('governorate', governorate, original.governorate);
  setIfChanged(
    'city',
    normalizeEditListingCity(governorate: governorate, city: city),
    original.city,
  );
  setIfChanged('latitude', latitude, original.latitude);
  setIfChanged('longitude', longitude, original.longitude);
  setIfChanged('location_address', locationAddress, original.locationAddress);
  setIfChanged('area_name', areaName, original.areaName);

  if (contactPreference != original.contactPreference) {
    if (contactPreference != null) {
      updates['contact_preference'] = contactPreference.value;
    }
  }

  if (!_mapsEqual(metadata, original.metadata)) {
    if (metadata != null) {
      updates['metadata'] = metadata;
    }
  }

  return updates;
}

bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (a[key].toString() != b[key].toString()) return false;
  }
  return true;
}

bool imagesChanged({
  required EditListingSnapshot original,
  required List<String> currentImageIds,
  required List<String> removedImageIds,
  required int newImageCount,
}) {
  if (removedImageIds.isNotEmpty || newImageCount > 0) return true;
  if (currentImageIds.length != original.imageIds.length) return true;
  for (var i = 0; i < currentImageIds.length; i++) {
    if (currentImageIds[i] != original.imageIds[i]) return true;
  }
  return false;
}
