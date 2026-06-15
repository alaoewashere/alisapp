class TutoringListingMetadata {
  const TutoringListingMetadata({
    this.listingKind = tutoringKind,
    this.subject,
    this.curriculum,
    this.stages = const [],
    this.gender,
    this.sessionType,
    this.pricePerHour,
    this.experienceYears,
    this.qualifications,
  });

  static const listingKindKey = 'listing_kind';
  static const tutoringKind = 'tutoring';

  final String listingKind;
  final String? subject;
  final String? curriculum;
  final List<String> stages;
  final String? gender;
  final String? sessionType;
  final int? pricePerHour;
  final int? experienceYears;
  final String? qualifications;

  TutoringListingMetadata copyWith({
    String? subject,
    bool clearSubject = false,
    String? curriculum,
    bool clearCurriculum = false,
    List<String>? stages,
    String? gender,
    bool clearGender = false,
    String? sessionType,
    bool clearSessionType = false,
    int? pricePerHour,
    bool clearPricePerHour = false,
    int? experienceYears,
    bool clearExperienceYears = false,
    String? qualifications,
    bool clearQualifications = false,
  }) {
    return TutoringListingMetadata(
      subject: clearSubject ? null : (subject ?? this.subject),
      curriculum: clearCurriculum ? null : (curriculum ?? this.curriculum),
      stages: stages ?? this.stages,
      gender: clearGender ? null : (gender ?? this.gender),
      sessionType:
          clearSessionType ? null : (sessionType ?? this.sessionType),
      pricePerHour:
          clearPricePerHour ? null : (pricePerHour ?? this.pricePerHour),
      experienceYears: clearExperienceYears
          ? null
          : (experienceYears ?? this.experienceYears),
      qualifications:
          clearQualifications ? null : (qualifications ?? this.qualifications),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: listingKind,
      if (subject != null) 'subject': subject,
      if (curriculum != null) 'curriculum': curriculum,
      if (stages.isNotEmpty) 'stages': stages,
      if (gender != null) 'gender': gender,
      if (sessionType != null) 'session_type': sessionType,
      if (pricePerHour != null) 'price_per_hour': pricePerHour.toString(),
      if (experienceYears != null)
        'experience_years': experienceYears.toString(),
      if (qualifications != null) 'qualifications': qualifications,
    };
  }

  factory TutoringListingMetadata.fromJson(Map<String, dynamic> json) {
    return TutoringListingMetadata(
      subject: json['subject'] as String?,
      curriculum: json['curriculum'] as String?,
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          _stagesFromLegacy(json['stage']),
      gender: json['gender'] as String?,
      sessionType: json['session_type'] as String?,
      pricePerHour: _parseInt(json['price_per_hour']),
      experienceYears: _parseInt(json['experience_years']),
      qualifications: json['qualifications'] as String?,
    );
  }

  static List<String> _stagesFromLegacy(dynamic stage) {
    if (stage == null) return const [];
    final text = stage.toString().trim();
    if (text.isEmpty) return const [];
    return text.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static TutoringListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != tutoringKind) return null;
    return TutoringListingMetadata.fromJson(json);
  }
}
