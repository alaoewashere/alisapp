class AnimalListingMetadata {
  const AnimalListingMetadata({
    this.listingKind = animalKind,
    this.animalType,
    this.breed,
    this.ageMonths,
    this.gender,
    this.vaccinated,
    this.hasPapers,
    this.trained,
    this.color,
  });

  static const listingKindKey = 'listing_kind';
  static const animalKind = 'animal';

  final String listingKind;
  final String? animalType;
  final String? breed;
  final int? ageMonths;
  final String? gender;
  final bool? vaccinated;
  final bool? hasPapers;
  final bool? trained;
  final String? color;

  AnimalListingMetadata copyWith({
    String? animalType,
    bool clearAnimalType = false,
    String? breed,
    bool clearBreed = false,
    int? ageMonths,
    bool clearAgeMonths = false,
    String? gender,
    bool clearGender = false,
    bool? vaccinated,
    bool? hasPapers,
    bool? trained,
    String? color,
    bool clearColor = false,
  }) {
    return AnimalListingMetadata(
      animalType: clearAnimalType ? null : (animalType ?? this.animalType),
      breed: clearBreed ? null : (breed ?? this.breed),
      ageMonths: clearAgeMonths ? null : (ageMonths ?? this.ageMonths),
      gender: clearGender ? null : (gender ?? this.gender),
      vaccinated: vaccinated ?? this.vaccinated,
      hasPapers: hasPapers ?? this.hasPapers,
      trained: trained ?? this.trained,
      color: clearColor ? null : (color ?? this.color),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: listingKind,
      if (animalType != null) 'animal_type': animalType,
      if (breed != null) 'breed': breed,
      if (ageMonths != null) 'age_months': ageMonths.toString(),
      if (gender != null) 'gender': gender,
      if (vaccinated != null) 'vaccinated': vaccinated,
      if (hasPapers != null) 'has_papers': hasPapers,
      if (trained != null) 'trained': trained,
      if (color != null) 'color': color,
    };
  }

  factory AnimalListingMetadata.fromJson(Map<String, dynamic> json) {
    return AnimalListingMetadata(
      animalType: json['animal_type'] as String?,
      breed: json['breed'] as String?,
      ageMonths: _parseInt(json['age_months']),
      gender: json['gender'] as String?,
      vaccinated: json['vaccinated'] as bool?,
      hasPapers: json['has_papers'] as bool?,
      trained: json['trained'] as bool?,
      color: json['color'] as String?,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static AnimalListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != animalKind) return null;
    return AnimalListingMetadata.fromJson(json);
  }
}
