enum FilterCondition { all, newItem, used }

enum SearchSortBy { newest, cheapest, expensive, mostViewed }

extension FilterConditionX on FilterCondition {
  String? get dbValue => switch (this) {
        FilterCondition.all => null,
        FilterCondition.newItem => 'new',
        FilterCondition.used => 'used',
      };

  String get labelAr => switch (this) {
        FilterCondition.all => 'الكل',
        FilterCondition.newItem => 'جديد',
        FilterCondition.used => 'مستعمل',
      };

  static FilterCondition fromDb(String? value) {
    if (value == 'new') return FilterCondition.newItem;
    if (value == 'used') return FilterCondition.used;
    return FilterCondition.all;
  }
}

extension SearchSortByX on SearchSortBy {
  String get labelAr => switch (this) {
        SearchSortBy.newest => 'الأحدث',
        SearchSortBy.cheapest => 'الأرخص',
        SearchSortBy.expensive => 'الأغلى',
        SearchSortBy.mostViewed => 'الأكثر مشاهدة',
      };
}

class FilterModel {
  const FilterModel({
    this.query,
    this.categoryId,
    this.subcategoryId,
    this.governorate,
    this.city,
    this.areaName,
    this.minPrice,
    this.maxPrice,
    this.condition = FilterCondition.all,
    this.sortBy = SearchSortBy.newest,
    this.isFeaturedOnly = false,
    this.isNegotiableOnly = false,
    // Car-category-only filters below — no-ops outside "سيارات" (see
    // isAutomobileCarListingPath). Stored in listings.metadata (JSONB).
    this.minYear,
    this.maxYear,
    this.fuel,
    this.transmission,
    this.vehicleColor,
    this.minMileage,
    this.maxMileage,
    // TODO(car-filters): the following have no metadata key yet — the
    // post-listing car form doesn't collect them. Query filters are wired
    // against these exact keys so they activate the moment that form does.
    this.bodyType,
    this.driveType,
    this.doors,
    this.minEnginePowerHp,
    this.maxEnginePowerHp,
    this.minEngineCapacityCc,
    this.maxEngineCapacityCc,
    this.hasWarranty,
    this.hasAccidentHistory,
    this.hasHeavyDamage,
    this.plateType,
    this.sellerType,
  });

  final String? query;
  final int? categoryId;
  final int? subcategoryId;
  final String? governorate;
  final String? city;
  final String? areaName;
  final double? minPrice;
  final double? maxPrice;
  final FilterCondition condition;
  final SearchSortBy sortBy;
  final bool isFeaturedOnly;
  final bool isNegotiableOnly;

  final int? minYear;
  final int? maxYear;
  final String? fuel;
  final String? transmission;
  final String? vehicleColor;
  final int? minMileage;
  final int? maxMileage;
  final String? bodyType;
  final String? driveType;
  final String? doors;
  final int? minEnginePowerHp;
  final int? maxEnginePowerHp;
  final int? minEngineCapacityCc;
  final int? maxEngineCapacityCc;
  final bool? hasWarranty;
  final bool? hasAccidentHistory;
  final bool? hasHeavyDamage;
  final String? plateType;
  final String? sellerType;

  bool get isEmpty =>
      (query == null || query!.trim().isEmpty) &&
      categoryId == null &&
      subcategoryId == null &&
      governorate == null &&
      (city == null || city!.trim().isEmpty) &&
      (areaName == null || areaName!.trim().isEmpty) &&
      minPrice == null &&
      maxPrice == null &&
      condition == FilterCondition.all &&
      !isFeaturedOnly &&
      !isNegotiableOnly &&
      minYear == null &&
      maxYear == null &&
      fuel == null &&
      transmission == null &&
      vehicleColor == null &&
      minMileage == null &&
      maxMileage == null &&
      bodyType == null &&
      driveType == null &&
      doors == null &&
      minEnginePowerHp == null &&
      maxEnginePowerHp == null &&
      minEngineCapacityCc == null &&
      maxEngineCapacityCc == null &&
      hasWarranty == null &&
      hasAccidentHistory == null &&
      hasHeavyDamage == null &&
      plateType == null &&
      sellerType == null;

  int get activeFilterCount {
    var count = 0;
    if (query != null && query!.trim().isNotEmpty) count++;
    if (categoryId != null) count++;
    if (subcategoryId != null) count++;
    if (governorate != null) count++;
    if (city != null && city!.trim().isNotEmpty) count++;
    if (areaName != null && areaName!.trim().isNotEmpty) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (condition != FilterCondition.all) count++;
    if (isFeaturedOnly) count++;
    if (isNegotiableOnly) count++;
    if (minYear != null) count++;
    if (maxYear != null) count++;
    if (fuel != null) count++;
    if (transmission != null) count++;
    if (vehicleColor != null) count++;
    if (minMileage != null) count++;
    if (maxMileage != null) count++;
    if (bodyType != null) count++;
    if (driveType != null) count++;
    if (doors != null) count++;
    if (minEnginePowerHp != null) count++;
    if (maxEnginePowerHp != null) count++;
    if (minEngineCapacityCc != null) count++;
    if (maxEngineCapacityCc != null) count++;
    if (hasWarranty != null) count++;
    if (hasAccidentHistory != null) count++;
    if (hasHeavyDamage != null) count++;
    if (plateType != null) count++;
    if (sellerType != null) count++;
    return count;
  }

  bool get hasFilters => !isEmpty;

  int? get effectiveCategoryId => subcategoryId ?? categoryId;

  FilterModel copyWith({
    String? query,
    int? categoryId,
    int? subcategoryId,
    String? governorate,
    String? city,
    String? areaName,
    double? minPrice,
    double? maxPrice,
    FilterCondition? condition,
    SearchSortBy? sortBy,
    bool? isFeaturedOnly,
    bool? isNegotiableOnly,
    bool clearQuery = false,
    bool clearCategory = false,
    bool clearSubcategory = false,
    bool clearGovernorate = false,
    bool clearCity = false,
    bool clearAreaName = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    int? minYear,
    bool clearMinYear = false,
    int? maxYear,
    bool clearMaxYear = false,
    String? fuel,
    bool clearFuel = false,
    String? transmission,
    bool clearTransmission = false,
    String? vehicleColor,
    bool clearVehicleColor = false,
    int? minMileage,
    bool clearMinMileage = false,
    int? maxMileage,
    bool clearMaxMileage = false,
    String? bodyType,
    bool clearBodyType = false,
    String? driveType,
    bool clearDriveType = false,
    String? doors,
    bool clearDoors = false,
    int? minEnginePowerHp,
    bool clearMinEnginePowerHp = false,
    int? maxEnginePowerHp,
    bool clearMaxEnginePowerHp = false,
    int? minEngineCapacityCc,
    bool clearMinEngineCapacityCc = false,
    int? maxEngineCapacityCc,
    bool clearMaxEngineCapacityCc = false,
    bool? hasWarranty,
    bool clearHasWarranty = false,
    bool? hasAccidentHistory,
    bool clearHasAccidentHistory = false,
    bool? hasHeavyDamage,
    bool clearHasHeavyDamage = false,
    String? plateType,
    bool clearPlateType = false,
    String? sellerType,
    bool clearSellerType = false,
  }) {
    return FilterModel(
      query: clearQuery ? null : (query ?? this.query),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      subcategoryId:
          clearSubcategory ? null : (subcategoryId ?? this.subcategoryId),
      governorate: clearGovernorate ? null : (governorate ?? this.governorate),
      city: clearCity ? null : (city ?? this.city),
      areaName: clearAreaName ? null : (areaName ?? this.areaName),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      condition: condition ?? this.condition,
      sortBy: sortBy ?? this.sortBy,
      isFeaturedOnly: isFeaturedOnly ?? this.isFeaturedOnly,
      isNegotiableOnly: isNegotiableOnly ?? this.isNegotiableOnly,
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      fuel: clearFuel ? null : (fuel ?? this.fuel),
      transmission: clearTransmission ? null : (transmission ?? this.transmission),
      vehicleColor: clearVehicleColor ? null : (vehicleColor ?? this.vehicleColor),
      minMileage: clearMinMileage ? null : (minMileage ?? this.minMileage),
      maxMileage: clearMaxMileage ? null : (maxMileage ?? this.maxMileage),
      bodyType: clearBodyType ? null : (bodyType ?? this.bodyType),
      driveType: clearDriveType ? null : (driveType ?? this.driveType),
      doors: clearDoors ? null : (doors ?? this.doors),
      minEnginePowerHp: clearMinEnginePowerHp
          ? null
          : (minEnginePowerHp ?? this.minEnginePowerHp),
      maxEnginePowerHp: clearMaxEnginePowerHp
          ? null
          : (maxEnginePowerHp ?? this.maxEnginePowerHp),
      minEngineCapacityCc: clearMinEngineCapacityCc
          ? null
          : (minEngineCapacityCc ?? this.minEngineCapacityCc),
      maxEngineCapacityCc: clearMaxEngineCapacityCc
          ? null
          : (maxEngineCapacityCc ?? this.maxEngineCapacityCc),
      hasWarranty: clearHasWarranty ? null : (hasWarranty ?? this.hasWarranty),
      hasAccidentHistory: clearHasAccidentHistory
          ? null
          : (hasAccidentHistory ?? this.hasAccidentHistory),
      hasHeavyDamage:
          clearHasHeavyDamage ? null : (hasHeavyDamage ?? this.hasHeavyDamage),
      plateType: clearPlateType ? null : (plateType ?? this.plateType),
      sellerType: clearSellerType ? null : (sellerType ?? this.sellerType),
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (query != null && query!.trim().isNotEmpty) 'q': query!.trim(),
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (governorate != null) 'governorate': governorate,
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (areaName != null && areaName!.trim().isNotEmpty)
        'area_name': areaName!.trim(),
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (condition != FilterCondition.all) 'condition': condition.dbValue,
      'sort': sortBy.name,
      if (isFeaturedOnly) 'featured': true,
      if (isNegotiableOnly) 'negotiable': true,
      if (minYear != null) 'min_year': minYear,
      if (maxYear != null) 'max_year': maxYear,
      if (fuel != null) 'fuel': fuel,
      if (transmission != null) 'transmission': transmission,
      if (vehicleColor != null) 'vehicle_color': vehicleColor,
      if (minMileage != null) 'min_mileage': minMileage,
      if (maxMileage != null) 'max_mileage': maxMileage,
      if (bodyType != null) 'body_type': bodyType,
      if (driveType != null) 'drive_type': driveType,
      if (doors != null) 'doors': doors,
      if (minEnginePowerHp != null) 'min_engine_power_hp': minEnginePowerHp,
      if (maxEnginePowerHp != null) 'max_engine_power_hp': maxEnginePowerHp,
      if (minEngineCapacityCc != null)
        'min_engine_capacity_cc': minEngineCapacityCc,
      if (maxEngineCapacityCc != null)
        'max_engine_capacity_cc': maxEngineCapacityCc,
      if (hasWarranty != null) 'has_warranty': hasWarranty,
      if (hasAccidentHistory != null) 'has_accident_history': hasAccidentHistory,
      if (hasHeavyDamage != null) 'has_heavy_damage': hasHeavyDamage,
      if (plateType != null) 'plate_type': plateType,
      if (sellerType != null) 'seller_type': sellerType,
    };
  }

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      query: json['query'] as String?,
      categoryId: json['category_id'] as int?,
      subcategoryId: json['subcategory_id'] as int?,
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      areaName: json['area_name'] as String?,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      condition: FilterConditionX.fromDb(json['condition'] as String?),
      sortBy: SearchSortBy.values.firstWhere(
        (s) => s.name == json['sort'],
        orElse: () => SearchSortBy.newest,
      ),
      isFeaturedOnly: json['featured'] as bool? ?? false,
      isNegotiableOnly: json['negotiable'] as bool? ?? false,
      minYear: json['min_year'] as int?,
      maxYear: json['max_year'] as int?,
      fuel: json['fuel'] as String?,
      transmission: json['transmission'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      minMileage: json['min_mileage'] as int?,
      maxMileage: json['max_mileage'] as int?,
      bodyType: json['body_type'] as String?,
      driveType: json['drive_type'] as String?,
      doors: json['doors'] as String?,
      minEnginePowerHp: json['min_engine_power_hp'] as int?,
      maxEnginePowerHp: json['max_engine_power_hp'] as int?,
      minEngineCapacityCc: json['min_engine_capacity_cc'] as int?,
      maxEngineCapacityCc: json['max_engine_capacity_cc'] as int?,
      hasWarranty: json['has_warranty'] as bool?,
      hasAccidentHistory: json['has_accident_history'] as bool?,
      hasHeavyDamage: json['has_heavy_damage'] as bool?,
      plateType: json['plate_type'] as String?,
      sellerType: json['seller_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toQueryParams();
}

/// Backward-compatible alias.
typedef ListingFilters = FilterModel;
