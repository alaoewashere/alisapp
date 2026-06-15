/// Real-estate-specific listing fields stored in `listings.metadata` JSONB.
class RealEstateListingMetadata {
  const RealEstateListingMetadata({
    this.propertyType,
    this.offerType,
    this.areaSqm,
    this.floor,
    this.totalFloors,
    this.rooms,
    this.bathrooms,
    this.ageYears,
    this.furnished,
    this.deedType,
    this.features = const [],
  });

  final String? propertyType;
  final String? offerType;
  final int? areaSqm;
  final int? floor;
  final int? totalFloors;
  final String? rooms;
  final String? bathrooms;
  final String? ageYears;
  final String? furnished;
  final String? deedType;
  final List<String> features;

  static const listingKindKey = 'listing_kind';
  static const realEstateKind = 'real_estate';

  RealEstateListingMetadata copyWith({
    String? propertyType,
    bool clearPropertyType = false,
    String? offerType,
    bool clearOfferType = false,
    int? areaSqm,
    bool clearAreaSqm = false,
    int? floor,
    bool clearFloor = false,
    int? totalFloors,
    bool clearTotalFloors = false,
    String? rooms,
    bool clearRooms = false,
    String? bathrooms,
    bool clearBathrooms = false,
    String? ageYears,
    bool clearAgeYears = false,
    String? furnished,
    bool clearFurnished = false,
    String? deedType,
    bool clearDeedType = false,
    List<String>? features,
  }) {
    return RealEstateListingMetadata(
      propertyType:
          clearPropertyType ? null : (propertyType ?? this.propertyType),
      offerType: clearOfferType ? null : (offerType ?? this.offerType),
      areaSqm: clearAreaSqm ? null : (areaSqm ?? this.areaSqm),
      floor: clearFloor ? null : (floor ?? this.floor),
      totalFloors: clearTotalFloors ? null : (totalFloors ?? this.totalFloors),
      rooms: clearRooms ? null : (rooms ?? this.rooms),
      bathrooms: clearBathrooms ? null : (bathrooms ?? this.bathrooms),
      ageYears: clearAgeYears ? null : (ageYears ?? this.ageYears),
      furnished: clearFurnished ? null : (furnished ?? this.furnished),
      deedType: clearDeedType ? null : (deedType ?? this.deedType),
      features: features ?? this.features,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: realEstateKind,
      if (propertyType != null) 'property_type': propertyType,
      if (offerType != null) 'listing_type': offerType,
      if (areaSqm != null) 'area_sqm': areaSqm.toString(),
      if (floor != null) 'floor': floor.toString(),
      if (totalFloors != null) 'total_floors': totalFloors.toString(),
      if (rooms != null) 'rooms': rooms,
      if (bathrooms != null) 'bathrooms': bathrooms,
      if (ageYears != null) 'age_years': ageYears,
      if (furnished != null) 'furnished': furnished,
      if (deedType != null) 'deed_type': deedType,
      'features': features,
    };
  }

  factory RealEstateListingMetadata.fromJson(Map<String, dynamic> json) {
    final featureList = json['features'];
    return RealEstateListingMetadata(
      propertyType: json['property_type'] as String?,
      offerType: json['listing_type'] as String?,
      areaSqm: int.tryParse('${json['area_sqm'] ?? ''}'),
      floor: int.tryParse('${json['floor'] ?? ''}'),
      totalFloors: int.tryParse('${json['total_floors'] ?? ''}'),
      rooms: json['rooms'] as String?,
      bathrooms: json['bathrooms'] as String?,
      ageYears: json['age_years'] as String?,
      furnished: json['furnished'] as String?,
      deedType: json['deed_type'] as String?,
      features: featureList is List
          ? featureList.map((e) => e.toString()).toList()
          : const [],
    );
  }

  static RealEstateListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != realEstateKind) return null;
    return RealEstateListingMetadata.fromJson(json);
  }
}
