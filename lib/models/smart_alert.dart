import '../core/constants/notification_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../shared/models/category_model.dart';
import '../shared/models/filter_model.dart';
import '../core/constants/app_governorates.dart';

/// Optional pre-fill when navigating from search results.
class SmartAlertDraft {
  const SmartAlertDraft({
    this.title,
    this.category,
    this.subcategory,
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.priceMin,
    this.priceMax,
    this.location,
    this.condition,
  });

  final String? title;
  final String? category;
  final String? subcategory;
  final String? make;
  final String? model;
  final int? yearMin;
  final int? yearMax;
  final int? priceMin;
  final int? priceMax;
  final String? location;
  final String? condition;
}

SmartAlertDraft smartAlertDraftFromFilter(
  FilterModel filter, {
  String? categoryName,
  List<CategoryModel>? allCategories,
}) {
  final resolvedCategory = categoryName ??
      rootCategoryNameForId(allCategories, filter.effectiveCategoryId);
  String? location;
  if (filter.governorate != null) {
    location = governorateNameAr(filter.governorate!);
  } else if (filter.city != null && filter.city!.trim().isNotEmpty) {
    location = filter.city!.trim();
  }

  return SmartAlertDraft(
    title: filter.query?.trim().isNotEmpty == true ? filter.query!.trim() : null,
    category: resolvedCategory,
    priceMin: filter.minPrice?.round(),
    priceMax: filter.maxPrice?.round(),
    location: location,
    condition: filter.condition == FilterCondition.all
        ? null
        : filter.condition.labelAr,
  );
}

String? rootCategoryNameForId(
  List<CategoryModel>? all,
  int? categoryId,
) {
  if (all == null || categoryId == null) return null;
  final byId = {for (final c in all) c.id: c};
  var current = byId[categoryId];
  if (current == null) return null;
  CategoryModel node = current;
  while (node.parentId != null) {
    final parent = byId[node.parentId];
    if (parent == null) break;
    node = parent;
  }
  return node.nameAr;
}

class SmartAlert {
  const SmartAlert({
    required this.id,
    required this.userId,
    required this.title,
    this.category,
    this.subcategory,
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.priceMin,
    this.priceMax,
    this.location,
    this.condition,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggeredAt,
    this.triggerCount = 0,
  });

  final String id;
  final String userId;
  final String title;
  final String? category;
  final String? subcategory;
  final String? make;
  final String? model;
  final int? yearMin;
  final int? yearMax;
  final int? priceMin;
  final int? priceMax;
  final String? location;
  final String? condition;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final int triggerCount;

  bool get isVehicleCategory =>
      category != null &&
      category!.trim() == kSmartAlertVehicleCategory;

  String get summaryLine => buildSmartAlertSummary(this);

  String get lastTriggeredLabel => formatSmartAlertLastTriggered(lastTriggeredAt);

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      yearMin: (json['year_min'] as num?)?.toInt(),
      yearMax: (json['year_max'] as num?)?.toInt(),
      priceMin: (json['price_min'] as num?)?.toInt(),
      priceMax: (json['price_max'] as num?)?.toInt(),
      location: json['location'] as String?,
      condition: json['condition'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastTriggeredAt: json['last_triggered_at'] != null
          ? DateTime.tryParse(json['last_triggered_at'] as String)
          : null,
      triggerCount: (json['trigger_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertRow(String userId) {
    return {
      'user_id': userId,
      'title': title.trim(),
      if (category != null && category!.trim().isNotEmpty)
        'category': category!.trim(),
      if (subcategory != null && subcategory!.trim().isNotEmpty)
        'subcategory': subcategory!.trim(),
      if (make != null && make!.trim().isNotEmpty) 'make': make!.trim(),
      if (model != null && model!.trim().isNotEmpty) 'model': model!.trim(),
      if (yearMin != null) 'year_min': yearMin,
      if (yearMax != null) 'year_max': yearMax,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      if (condition != null && condition!.trim().isNotEmpty)
        'condition': condition!.trim(),
      'is_active': isActive,
    };
  }

  SmartAlert copyWith({
    String? title,
    String? category,
    String? subcategory,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    int? priceMin,
    int? priceMax,
    String? location,
    String? condition,
    bool? isActive,
    DateTime? lastTriggeredAt,
    int? triggerCount,
    bool clearCategory = false,
    bool clearSubcategory = false,
    bool clearMake = false,
    bool clearModel = false,
    bool clearYearMin = false,
    bool clearYearMax = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    bool clearLocation = false,
    bool clearCondition = false,
  }) {
    return SmartAlert(
      id: id,
      userId: userId,
      title: title ?? this.title,
      category: clearCategory ? null : (category ?? this.category),
      subcategory: clearSubcategory ? null : (subcategory ?? this.subcategory),
      make: clearMake ? null : (make ?? this.make),
      model: clearModel ? null : (model ?? this.model),
      yearMin: clearYearMin ? null : (yearMin ?? this.yearMin),
      yearMax: clearYearMax ? null : (yearMax ?? this.yearMax),
      priceMin: clearPriceMin ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceMax ? null : (priceMax ?? this.priceMax),
      location: clearLocation ? null : (location ?? this.location),
      condition: clearCondition ? null : (condition ?? this.condition),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      triggerCount: triggerCount ?? this.triggerCount,
    );
  }
}

String buildSmartAlertSummary(SmartAlert alert) {
  final parts = <String>[];

  if (alert.make != null && alert.make!.trim().isNotEmpty) {
    parts.add(alert.make!.trim());
  } else if (alert.model != null && alert.model!.trim().isNotEmpty) {
    parts.add(alert.model!.trim());
  } else if (alert.category != null && alert.category!.trim().isNotEmpty) {
    parts.add(alert.category!.trim());
  }

  if (alert.yearMin != null || alert.yearMax != null) {
    final from = alert.yearMin?.toString() ?? '…';
    final to = alert.yearMax?.toString() ?? '…';
    parts.add('$from-$to');
  }

  if (alert.priceMin != null || alert.priceMax != null) {
    final minLabel = alert.priceMin != null
        ? _compactPriceLabel(alert.priceMin!)
        : '…';
    final maxLabel = alert.priceMax != null
        ? _compactPriceLabel(alert.priceMax!)
        : '…';
    parts.add('$minLabel-$maxLabel');
  }

  if (alert.location != null && alert.location!.trim().isNotEmpty) {
    parts.add(alert.location!.trim());
  }

  return parts.isEmpty ? 'بدون فلاتر إضافية' : parts.join(' • ');
}

String _compactPriceLabel(int amount) {
  if (amount >= 1000000) {
    final millions = amount / 1000000;
    final rounded = millions == millions.roundToDouble()
        ? millions.toInt()
        : double.parse(millions.toStringAsFixed(1));
    return '${rounded}M';
  }
  return formatIqd(amount).replaceAll(' د.ع', '');
}

String formatSmartAlertLastTriggered(DateTime? at) {
  if (at == null) return 'لم يُفعَّل بعد';

  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) return 'آخر تطابق: الآن';
  if (diff.inHours < 1) {
    return 'آخر تطابق: منذ ${diff.inMinutes} دقيقة';
  }
  if (diff.inDays < 1) {
    return 'آخر تطابق: منذ ${diff.inHours} ساعة';
  }
  if (diff.inDays < 7) {
    return 'آخر تطابق: منذ ${diff.inDays} يوم';
  }
  return 'آخر تطابق: منذ ${(diff.inDays / 7).floor()} أسبوع';
}

bool isSmartAlertFreeLimitReached({
  required int activeAlertCount,
  required bool hasProEntitlement,
}) {
  if (hasProEntitlement) return false;
  return activeAlertCount >= kSmartAlertFreeLimit;
}

class SmartAlertException implements Exception {
  const SmartAlertException(this.message);

  final String message;

  @override
  String toString() => message;
}
