import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/verification_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/video_utils.dart';
import 'animal_listing_metadata.dart';
import 'electronics_listing_metadata.dart';
import 'general_listing_metadata.dart';
import 'home_service_listing_metadata.dart';
import 'job_listing_metadata.dart';
import 'real_estate_listing_metadata.dart';
import 'tutoring_listing_metadata.dart';
import 'vehicle_listing_metadata.dart';

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

/// How buyers may reach the seller for this listing.
enum ListingContactPreference {
  phoneAndMessages,
  phoneOnly,
  messagesOnly;

  String get value => switch (this) {
        ListingContactPreference.phoneAndMessages => 'phone_and_messages',
        ListingContactPreference.phoneOnly => 'phone_only',
        ListingContactPreference.messagesOnly => 'messages_only',
      };

  String get labelAr => switch (this) {
        ListingContactPreference.phoneAndMessages => 'هاتف ورسائل',
        ListingContactPreference.phoneOnly => 'هاتف فقط',
        ListingContactPreference.messagesOnly => 'رسائل فقط',
      };

  static ListingContactPreference? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return switch (value) {
      'phone_and_messages' => ListingContactPreference.phoneAndMessages,
      'phone_only' => ListingContactPreference.phoneOnly,
      'messages_only' => ListingContactPreference.messagesOnly,
      _ => null,
    };
  }
}

/// Paid tier selected when posting a listing.
enum ListingPackage {
  standard,
  pro,
  premium;

  String get value => name;

  String get labelAr => switch (this) {
        ListingPackage.standard => 'إعلان عادي',
        ListingPackage.pro => 'إعلان برو',
        ListingPackage.premium => 'إعلان مميز',
      };

  /// Short pill label for package badges (مجاني / برو / مميز).
  String get badgeLabelAr => switch (this) {
        ListingPackage.standard => 'مجاني',
        ListingPackage.pro => 'برو',
        ListingPackage.premium => 'مميز',
      };

  static ListingPackage fromString(String? value) {
    if (value == null || value.isEmpty) return ListingPackage.standard;
    return switch (value) {
      'pro' || 'برو' => ListingPackage.pro,
      'premium' || 'مميز' || 'featured' => ListingPackage.premium,
      _ => ListingPackage.standard,
    };
  }

  bool get isFeatured => this == ListingPackage.premium;

  bool get isBoosted => this == ListingPackage.pro;

  bool get allowsListingVideo =>
      this == ListingPackage.pro || this == ListingPackage.premium;

  /// DB value for [listing_purchases.package_type]; null for free standard tier.
  String? get purchasePackageType => switch (this) {
        ListingPackage.pro => 'pro',
        ListingPackage.premium => 'premium',
        ListingPackage.standard => null,
      };

  /// Paid standard listing when monthly free quota is exhausted.
  String? purchasePackageTypeFor({required bool paidStandard}) {
    if (this == ListingPackage.standard && paidStandard) return 'standard';
    return purchasePackageType;
  }
}

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
    this.locationAddress,
    required this.displayStatus,
    this.moderationStatus = ListingModerationStatus.pending,
    this.viewsCount = 0,
    this.contactCount = 0,
    this.autoRenew = false,
    this.isVerifiedSeller = false,
    this.isFeatured = false,
    this.isBoosted = false,
    this.images = const [],
    this.sellerName,
    this.sellerAvatar,
    this.sellerAvatarSeed,
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
    this.sellerAvgRating = 0,
    this.sellerRatingCount = 0,
    this.contactPreference,
    this.referenceNo,
    this.videoUrl,
    this.videoThumbnailUrl,
    this.metadata = const {},
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
  final String? locationAddress;
  final ListingDisplayStatus displayStatus;
  final ListingModerationStatus moderationStatus;
  final int viewsCount;
  final int contactCount;
  final bool autoRenew;
  final bool isVerifiedSeller;
  final bool isFeatured;
  final bool isBoosted;
  final List<ListingImage> images;
  final String? sellerName;
  final String? sellerAvatar;
  final String? sellerAvatarSeed;
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
  final double sellerAvgRating;
  final int sellerRatingCount;
  final ListingContactPreference? contactPreference;
  final int? referenceNo;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final Map<String, dynamic> metadata;

  bool get hasListingVideo =>
      videoUrl != null && videoUrl!.trim().isNotEmpty;

  int? get videoDurationSeconds {
    final raw = metadata['video_duration_seconds'];
    if (raw is num) return raw.toInt();
    return null;
  }

  String? get formattedVideoDuration {
    final seconds = videoDurationSeconds;
    if (seconds == null) return null;
    return formatVideoDuration(seconds);
  }

  /// Parsed vehicle fields when [metadata] has `listing_kind: vehicle`.
  VehicleListingMetadata? get vehicleMetadata =>
      VehicleListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  RealEstateListingMetadata? get realEstateMetadata =>
      RealEstateListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  ElectronicsListingMetadata? get electronicsMetadata =>
      ElectronicsListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  GeneralListingMetadata? get generalMetadata =>
      GeneralListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  TutoringListingMetadata? get tutoringMetadata =>
      TutoringListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  JobListingMetadata? get jobMetadata =>
      JobListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  AnimalListingMetadata? get animalMetadata =>
      AnimalListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  HomeServiceListingMetadata? get homeServiceMetadata =>
      HomeServiceListingMetadata.fromMetadataMap(
        metadata.isEmpty ? null : metadata,
      );

  bool get isVehicleListing => vehicleMetadata != null;
  bool get isRealEstateListing => realEstateMetadata != null;
  bool get isElectronicsListing => electronicsMetadata != null;
  bool get isGeneralMarketplaceListing => generalMetadata != null;
  bool get isTutoringListing => tutoringMetadata != null;
  bool get isJobListing => jobMetadata != null;
  bool get isAnimalListing => animalMetadata != null;
  bool get isHomeServiceListing => homeServiceMetadata != null;

  /// Listings with structured metadata use التفاصيل instead of الوصف.
  bool get hasStructuredMetadata =>
      isVehicleListing ||
      isRealEstateListing ||
      isElectronicsListing ||
      isGeneralMarketplaceListing ||
      isTutoringListing ||
      isJobListing ||
      isAnimalListing ||
      isHomeServiceListing;

  /// Backward-compatible accessors.
  String get title => titleAr;
  String get description => descriptionAr;
  int get priceIqd => price.round();
  ListingDisplayStatus get status => displayStatus;

  bool get isPendingModeration =>
      moderationStatus != ListingModerationStatus.approved;

  /// Edit / delete / sold / share — only after admin approval.
  bool get isOwnerActionsEnabled => !isPendingModeration;

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

  /// Premium tier (`ListingPackage.premium` / `is_featured` / metadata).
  bool get isPremiumListing {
    if (isFeatured) return true;
    final pkg = metadata['listing_package'];
    if (pkg is! String || pkg.isEmpty) return false;
    return pkg == 'premium' || pkg == 'مميز' || pkg == 'featured';
  }

  /// Pro tier (`ListingPackage.pro` / `is_boosted` / metadata).
  bool get isProListing {
    if (isBoosted) return true;
    final pkg = metadata['listing_package'];
    if (pkg is! String || pkg.isEmpty) return false;
    return pkg == 'pro' || pkg == 'برو';
  }

  bool get isStandardListing => !isProListing && !isPremiumListing;

  /// Resolved package slug from metadata or feature flags.
  String get listingPackage {
    final pkg = metadata['listing_package'];
    if (pkg is String && pkg.isNotEmpty) return pkg;
    if (isFeatured) return 'premium';
    if (isBoosted) return 'pro';
    return 'standard';
  }

  bool get isPremium => isPremiumListing;
  bool get isPro => isProListing;
  bool get isStandard => isStandardListing;

  int get viewCount => viewsCount;

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
    String? locationAddress,
    ListingDisplayStatus? displayStatus,
    ListingModerationStatus? moderationStatus,
    int? viewsCount,
    int? contactCount,
    bool? autoRenew,
    bool? isVerifiedSeller,
    bool? isFeatured,
    bool? isBoosted,
    List<ListingImage>? images,
    String? sellerName,
    String? sellerAvatar,
    String? sellerAvatarSeed,
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
    ListingContactPreference? contactPreference,
    int? referenceNo,
    Map<String, dynamic>? metadata,
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
      locationAddress: locationAddress ?? this.locationAddress,
      displayStatus: displayStatus ?? this.displayStatus,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      viewsCount: viewsCount ?? this.viewsCount,
      contactCount: contactCount ?? this.contactCount,
      autoRenew: autoRenew ?? this.autoRenew,
      isVerifiedSeller: isVerifiedSeller ?? this.isVerifiedSeller,
      isFeatured: isFeatured ?? this.isFeatured,
      isBoosted: isBoosted ?? this.isBoosted,
      images: images ?? this.images,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      sellerAvatarSeed: sellerAvatarSeed ?? this.sellerAvatarSeed,
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
      contactPreference: contactPreference ?? this.contactPreference,
      referenceNo: referenceNo ?? this.referenceNo,
      metadata: metadata ?? this.metadata,
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
      locationAddress: json['location_address'] as String?,
      displayStatus: ListingDisplayStatusX.fromJson(json),
      moderationStatus: ListingModerationStatusX.fromString(
        json['status'] as String? ?? 'pending',
      ),
      viewsCount: json['views_count'] as int? ?? json['view_count'] as int? ?? 0,
      contactCount: json['contact_count'] as int? ?? 0,
      autoRenew: json['auto_renew'] as bool? ?? false,
      isVerifiedSeller: json['is_verified_seller'] as bool? ??
          (_parseMetadata(json['metadata'])['is_verified_seller'] == true),
      isFeatured: json['is_featured'] as bool? ?? false,
      isBoosted: json['is_boosted'] as bool? ?? false,
      images: images,
      sellerName: profile?['full_name'] as String? ??
          profile?['display_name'] as String?,
      sellerAvatar: profile?['avatar_url'] as String?,
      sellerAvatarSeed: profile?['avatar_seed'] as String?,
      sellerPhone: profile?['phone'] as String?,
      sellerIsVerified: _sellerIsVerified(profile),
      sellerCreatedAt: profile?['created_at'] != null
          ? DateTime.tryParse(profile!['created_at'] as String)
          : null,
      sellerAvgRating: (profile?['avg_rating'] as num?)?.toDouble() ?? 0,
      sellerRatingCount: (profile?['rating_count'] as num?)?.toInt() ?? 0,
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
      contactPreference: _parseContactPreference(json),
      referenceNo: (json['reference_no'] as num?)?.toInt(),
      videoUrl: json['video_url'] as String?,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      metadata: _parseMetadata(json['metadata']),
    );
  }

  static ListingContactPreference? _parseContactPreference(
    Map<String, dynamic> json,
  ) {
    final fromColumn = ListingContactPreference.fromString(
      json['contact_preference'] as String?,
    );
    if (fromColumn != null) return fromColumn;
    final metadata = _parseMetadata(json['metadata']);
    return ListingContactPreference.fromString(
      metadata['contact_preference'] as String?,
    );
  }

  static bool _sellerIsVerified(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    final status = profile['verification_status'] as String?;
    if (status == VerificationStatus.verified) return true;
    return profile['is_verified'] as bool? ?? false;
  }

  static Map<String, dynamic> _parseMetadata(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
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
      'location_address': locationAddress,
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
      if (contactPreference != null)
        'contact_preference': contactPreference!.value,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }
}

/// Backward-compatible alias.
typedef Listing = ListingModel;
