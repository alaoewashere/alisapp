import 'package:timeago/timeago.dart' as timeago;

import '../../core/utils/currency_formatter.dart';

export 'filter_model.dart';

enum ListingCondition { newItem, used }

/// Sale vs rent listing (DB column `listing_type`).
enum ListingType {
  sale,
  rent;

  String get value => name;

  String get labelAr => switch (this) {
        ListingType.sale => 'للبيع',
        ListingType.rent => 'للإيجار',
      };

  static ListingType? fromQuery(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final type in ListingType.values) {
      if (type.value == value) return type;
    }
    return null;
  }

  static ListingType fromValue(String? value) {
    return fromQuery(value) ?? ListingType.sale;
  }
}

const listingTypeQueryKey = 'type';

extension ListingConditionX on ListingCondition {
  String get value => switch (this) {
        ListingCondition.newItem => 'new',
        ListingCondition.used => 'used',
      };

  static ListingCondition? fromString(String? value) {
    if (value == null) return null;
    return switch (value) {
      'new' => ListingCondition.newItem,
      'used' => ListingCondition.used,
      _ => null,
    };
  }
}

/// Moderation status in Supabase (`status` column).
enum ListingModerationStatus { pending, approved, rejected }

extension ListingModerationStatusX on ListingModerationStatus {
  String get labelAr => switch (this) {
        ListingModerationStatus.pending => 'قيد المراجعة',
        ListingModerationStatus.approved => 'منشور',
        ListingModerationStatus.rejected => 'مرفوض',
      };

  static ListingModerationStatus fromString(String value) {
    return ListingModerationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ListingModerationStatus.pending,
    );
  }
}

/// Public lifecycle status for UI (maps DB availability + moderation).
enum ListingDisplayStatus { active, sold, pending, deleted }

extension ListingDisplayStatusX on ListingDisplayStatus {
  String get labelAr => switch (this) {
        ListingDisplayStatus.active => 'نشط',
        ListingDisplayStatus.pending => 'قيد المراجعة',
        ListingDisplayStatus.sold => 'مباع',
        ListingDisplayStatus.deleted => 'محذوف',
      };

  static ListingDisplayStatus fromJson(Map<String, dynamic> json) {
    final availability = json['availability'] as String? ?? 'active';
    final moderation = json['status'] as String? ?? 'pending';
    if (availability == 'sold') return ListingDisplayStatus.sold;
    if (availability == 'deleted') return ListingDisplayStatus.deleted;
    if (moderation != 'approved') return ListingDisplayStatus.pending;
    return ListingDisplayStatus.active;
  }
}

class ListingImage {
  const ListingImage({
    required this.id,
    required this.listingId,
    required this.storagePath,
    required this.sortOrder,
    this.isPrimary = false,
    this.url,
  });

  final String id;
  final String listingId;
  final String storagePath;
  final int sortOrder;
  final bool isPrimary;
  final String? url;

  factory ListingImage.fromJson(Map<String, dynamic> json) {
    return ListingImage(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      storagePath: json['storage_path'] as String? ?? json['url'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? json['order'] as int? ?? 0,
      isPrimary: json['is_primary'] as bool? ?? false,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'storage_path': storagePath,
      'sort_order': sortOrder,
      'is_primary': isPrimary,
      'url': url,
    };
  }
}

class ListingModel {
  const ListingModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.titleAr,
    required this.descriptionAr,
    required this.price,
    this.currency = 'IQD',
    this.isNegotiable = false,
    this.condition,
    required this.city,
    required this.governorate,
    this.latitude,
    this.longitude,
    required this.displayStatus,
    this.moderationStatus = ListingModerationStatus.pending,
    this.viewsCount = 0,
    this.isFeatured = false,
    this.isBoosted = false,
    this.images = const [],
    this.sellerName,
    this.sellerAvatar,
    this.sellerPhone,
    required this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.rejectionReason,
    this.categoryNameAr,
    this.parentCategoryNameAr,
    this.coverImageUrl,
    this.isFavorite = false,
    this.sellerIsVerified = false,
    this.sellerCreatedAt,
  });

  final String id;
  final String userId;
  final int categoryId;
  final String titleAr;
  final String descriptionAr;
  final double price;
  final String currency;
  final bool isNegotiable;
  final ListingCondition? condition;
  final String city;
  final String governorate;
  final double? latitude;
  final double? longitude;
  final ListingDisplayStatus displayStatus;
  final ListingModerationStatus moderationStatus;
  final int viewsCount;
  final bool isFeatured;
  final bool isBoosted;
  final List<ListingImage> images;
  final String? sellerName;
  final String? sellerAvatar;
  final String? sellerPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final String? rejectionReason;
  final String? categoryNameAr;
  final String? parentCategoryNameAr;
  final String? coverImageUrl;
  final bool isFavorite;
  final bool sellerIsVerified;
  final DateTime? sellerCreatedAt;

  /// Backward-compatible accessors.
  String get title => titleAr;
  String get description => descriptionAr;
  int get priceIqd => price.round();
  ListingDisplayStatus get status => displayStatus;

  String get formattedPrice => formatIQD(price);

  String get timeAgo => timeago.format(createdAt, locale: 'ar');

  String get categoryBreadcrumb {
    if (parentCategoryNameAr != null && categoryNameAr != null) {
      return '$parentCategoryNameAr > $categoryNameAr';
    }
    return categoryNameAr ?? '';
  }

  String? get conditionLabelAr => switch (condition) {
        ListingCondition.newItem => 'جديد',
        ListingCondition.used => 'مستعمل',
        null => null,
      };

  ListingModel copyWith({
    String? id,
    String? userId,
    int? categoryId,
    String? titleAr,
    String? descriptionAr,
    double? price,
    String? currency,
    bool? isNegotiable,
    ListingCondition? condition,
    String? city,
    String? governorate,
    double? latitude,
    double? longitude,
    ListingDisplayStatus? displayStatus,
    ListingModerationStatus? moderationStatus,
    int? viewsCount,
    bool? isFeatured,
    bool? isBoosted,
    List<ListingImage>? images,
    String? sellerName,
    String? sellerAvatar,
    String? sellerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    String? rejectionReason,
    String? categoryNameAr,
    String? parentCategoryNameAr,
    String? coverImageUrl,
    bool? isFavorite,
    bool? sellerIsVerified,
    DateTime? sellerCreatedAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      titleAr: titleAr ?? this.titleAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      condition: condition ?? this.condition,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      displayStatus: displayStatus ?? this.displayStatus,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      viewsCount: viewsCount ?? this.viewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isBoosted: isBoosted ?? this.isBoosted,
      images: images ?? this.images,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      parentCategoryNameAr: parentCategoryNameAr ?? this.parentCategoryNameAr,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      sellerIsVerified: sellerIsVerified ?? this.sellerIsVerified,
      sellerCreatedAt: sellerCreatedAt ?? this.sellerCreatedAt,
    );
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'] as Map<String, dynamic>?;
    final parentCategory = category?['parent'] as Map<String, dynamic>?;
    final profile = json['profiles'] as Map<String, dynamic>?;
    final imagesJson = json['listing_images'] as List<dynamic>? ?? [];
    final images = imagesJson
        .map((e) => ListingImage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) return a.isPrimary ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    String? coverUrl;
    if (json['cover_image_url'] != null) {
      coverUrl = json['cover_image_url'] as String;
    } else if (images.isNotEmpty) {
      coverUrl = images.first.url ?? images.first.storagePath;
    }

    final priceValue = json['price'] ?? json['price_iqd'];

    return ListingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as int,
      titleAr: json['title_ar'] as String? ?? json['title'] as String? ?? '',
      descriptionAr:
          json['description_ar'] as String? ?? json['description'] as String? ?? '',
      price: (priceValue as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'IQD',
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      condition: ListingConditionX.fromString(json['condition'] as String?),
      city: json['city'] as String,
      governorate: json['governorate'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      displayStatus: ListingDisplayStatusX.fromJson(json),
      moderationStatus: ListingModerationStatusX.fromString(
        json['status'] as String? ?? 'pending',
      ),
      viewsCount: json['views_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isBoosted: json['is_boosted'] as bool? ?? false,
      images: images,
      sellerName: profile?['full_name'] as String? ??
          profile?['display_name'] as String?,
      sellerAvatar: profile?['avatar_url'] as String?,
      sellerPhone: profile?['phone'] as String?,
      sellerIsVerified: profile?['is_verified'] as bool? ?? false,
      sellerCreatedAt: profile?['created_at'] != null
          ? DateTime.tryParse(profile!['created_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      categoryNameAr: category?['name_ar'] as String?,
      parentCategoryNameAr: parentCategory?['name_ar'] as String?,
      coverImageUrl: coverUrl,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title_ar': titleAr,
      'description_ar': descriptionAr,
      'price': price.round(),
      'currency': currency,
      'is_negotiable': isNegotiable,
      'condition': condition?.value,
      'city': city,
      'governorate': governorate,
      'latitude': latitude,
      'longitude': longitude,
      'availability': displayStatus == ListingDisplayStatus.sold
          ? 'sold'
          : displayStatus == ListingDisplayStatus.deleted
              ? 'deleted'
              : 'active',
      'views_count': viewsCount,
      'is_featured': isFeatured,
      'is_boosted': isBoosted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

/// Backward-compatible alias.
typedef Listing = ListingModel;
