class HomeServiceListingMetadata {
  const HomeServiceListingMetadata({
    this.listingKind = homeServiceKind,
    this.serviceType,
    this.gender,
    this.nationality,
    this.availability,
    this.daysPerWeek,
    this.experienceYears,
    this.salaryExpected,
    this.languages = const [],
  });

  static const listingKindKey = 'listing_kind';
  static const homeServiceKind = 'home_service';

  final String listingKind;
  final String? serviceType;
  final String? gender;
  final String? nationality;
  final String? availability;
  final int? daysPerWeek;
  final int? experienceYears;
  final int? salaryExpected;
  final List<String> languages;

  HomeServiceListingMetadata copyWith({
    String? serviceType,
    bool clearServiceType = false,
    String? gender,
    bool clearGender = false,
    String? nationality,
    bool clearNationality = false,
    String? availability,
    bool clearAvailability = false,
    int? daysPerWeek,
    bool clearDaysPerWeek = false,
    int? experienceYears,
    bool clearExperienceYears = false,
    int? salaryExpected,
    bool clearSalaryExpected = false,
    List<String>? languages,
  }) {
    return HomeServiceListingMetadata(
      serviceType:
          clearServiceType ? null : (serviceType ?? this.serviceType),
      gender: clearGender ? null : (gender ?? this.gender),
      nationality:
          clearNationality ? null : (nationality ?? this.nationality),
      availability:
          clearAvailability ? null : (availability ?? this.availability),
      daysPerWeek:
          clearDaysPerWeek ? null : (daysPerWeek ?? this.daysPerWeek),
      experienceYears: clearExperienceYears
          ? null
          : (experienceYears ?? this.experienceYears),
      salaryExpected: clearSalaryExpected
          ? null
          : (salaryExpected ?? this.salaryExpected),
      languages: languages ?? this.languages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: listingKind,
      if (serviceType != null) 'service_type': serviceType,
      if (gender != null) 'gender': gender,
      if (nationality != null) 'nationality': nationality,
      if (availability != null) 'availability': availability,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek.toString(),
      if (experienceYears != null)
        'experience_years': experienceYears.toString(),
      if (salaryExpected != null)
        'salary_expected': salaryExpected.toString(),
      if (languages.isNotEmpty) 'languages': languages,
    };
  }

  factory HomeServiceListingMetadata.fromJson(Map<String, dynamic> json) {
    return HomeServiceListingMetadata(
      serviceType: json['service_type'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      availability: json['availability'] as String?,
      daysPerWeek: _parseInt(json['days_per_week']),
      experienceYears: _parseInt(json['experience_years']),
      salaryExpected: _parseInt(json['salary_expected']),
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static HomeServiceListingMetadata? fromMetadataMap(
    Map<String, dynamic>? json,
  ) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != homeServiceKind) return null;
    return HomeServiceListingMetadata.fromJson(json);
  }
}
