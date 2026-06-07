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
    this.minPrice,
    this.maxPrice,
    this.condition = FilterCondition.all,
    this.sortBy = SearchSortBy.newest,
    this.isFeaturedOnly = false,
    this.isNegotiableOnly = false,
  });

  final String? query;
  final int? categoryId;
  final int? subcategoryId;
  final String? governorate;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final FilterCondition condition;
  final SearchSortBy sortBy;
  final bool isFeaturedOnly;
  final bool isNegotiableOnly;

  bool get isEmpty =>
      (query == null || query!.trim().isEmpty) &&
      categoryId == null &&
      subcategoryId == null &&
      governorate == null &&
      (city == null || city!.trim().isEmpty) &&
      minPrice == null &&
      maxPrice == null &&
      condition == FilterCondition.all &&
      !isFeaturedOnly &&
      !isNegotiableOnly;

  int get activeFilterCount {
    var count = 0;
    if (query != null && query!.trim().isNotEmpty) count++;
    if (categoryId != null) count++;
    if (subcategoryId != null) count++;
    if (governorate != null) count++;
    if (city != null && city!.trim().isNotEmpty) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (condition != FilterCondition.all) count++;
    if (isFeaturedOnly) count++;
    if (isNegotiableOnly) count++;
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
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return FilterModel(
      query: clearQuery ? null : (query ?? this.query),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      subcategoryId:
          clearSubcategory ? null : (subcategoryId ?? this.subcategoryId),
      governorate: clearGovernorate ? null : (governorate ?? this.governorate),
      city: clearCity ? null : (city ?? this.city),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      condition: condition ?? this.condition,
      sortBy: sortBy ?? this.sortBy,
      isFeaturedOnly: isFeaturedOnly ?? this.isFeaturedOnly,
      isNegotiableOnly: isNegotiableOnly ?? this.isNegotiableOnly,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (query != null && query!.trim().isNotEmpty) 'q': query!.trim(),
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (governorate != null) 'governorate': governorate,
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (condition != FilterCondition.all) 'condition': condition.dbValue,
      'sort': sortBy.name,
      if (isFeaturedOnly) 'featured': true,
      if (isNegotiableOnly) 'negotiable': true,
    };
  }

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      query: json['query'] as String?,
      categoryId: json['category_id'] as int?,
      subcategoryId: json['subcategory_id'] as int?,
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      condition: FilterConditionX.fromDb(json['condition'] as String?),
      sortBy: SearchSortBy.values.firstWhere(
        (s) => s.name == json['sort'],
        orElse: () => SearchSortBy.newest,
      ),
      isFeaturedOnly: json['featured'] as bool? ?? false,
      isNegotiableOnly: json['negotiable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => toQueryParams();
}

/// Backward-compatible alias.
typedef ListingFilters = FilterModel;
