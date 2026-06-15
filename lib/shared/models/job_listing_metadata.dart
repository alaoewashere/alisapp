class JobListingMetadata {
  const JobListingMetadata({
    this.listingKind = jobKind,
    this.jobType,
    this.sector,
    this.experienceRequired,
    this.educationRequired,
    this.genderPreference,
    this.salaryType,
    this.salaryMin,
    this.salaryMax,
    this.benefits = const [],
  });

  static const listingKindKey = 'listing_kind';
  static const jobKind = 'job';

  final String listingKind;
  final String? jobType;
  final String? sector;
  final String? experienceRequired;
  final String? educationRequired;
  final String? genderPreference;
  final String? salaryType;
  final int? salaryMin;
  final int? salaryMax;
  final List<String> benefits;

  JobListingMetadata copyWith({
    String? jobType,
    bool clearJobType = false,
    String? sector,
    bool clearSector = false,
    String? experienceRequired,
    bool clearExperienceRequired = false,
    String? educationRequired,
    bool clearEducationRequired = false,
    String? genderPreference,
    bool clearGenderPreference = false,
    String? salaryType,
    bool clearSalaryType = false,
    int? salaryMin,
    bool clearSalaryMin = false,
    int? salaryMax,
    bool clearSalaryMax = false,
    List<String>? benefits,
  }) {
    return JobListingMetadata(
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      sector: clearSector ? null : (sector ?? this.sector),
      experienceRequired: clearExperienceRequired
          ? null
          : (experienceRequired ?? this.experienceRequired),
      educationRequired: clearEducationRequired
          ? null
          : (educationRequired ?? this.educationRequired),
      genderPreference: clearGenderPreference
          ? null
          : (genderPreference ?? this.genderPreference),
      salaryType: clearSalaryType ? null : (salaryType ?? this.salaryType),
      salaryMin: clearSalaryMin ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalaryMax ? null : (salaryMax ?? this.salaryMax),
      benefits: benefits ?? this.benefits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: listingKind,
      if (jobType != null) 'job_type': jobType,
      if (sector != null) 'sector': sector,
      if (experienceRequired != null)
        'experience_required': experienceRequired,
      if (educationRequired != null)
        'education_required': educationRequired,
      if (genderPreference != null) 'gender_preference': genderPreference,
      if (salaryType != null) 'salary_type': salaryType,
      if (salaryMin != null) 'salary_min': salaryMin.toString(),
      if (salaryMax != null) 'salary_max': salaryMax.toString(),
      if (benefits.isNotEmpty) 'benefits': benefits,
    };
  }

  factory JobListingMetadata.fromJson(Map<String, dynamic> json) {
    return JobListingMetadata(
      jobType: json['job_type'] as String?,
      sector: json['sector'] as String?,
      experienceRequired: json['experience_required'] as String?,
      educationRequired: json['education_required'] as String?,
      genderPreference: json['gender_preference'] as String?,
      salaryType: json['salary_type'] as String?,
      salaryMin: _parseInt(json['salary_min']),
      salaryMax: _parseInt(json['salary_max']),
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static JobListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != jobKind) return null;
    return JobListingMetadata.fromJson(json);
  }
}
