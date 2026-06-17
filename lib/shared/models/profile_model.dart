import '../../../core/constants/verification_constants.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.phoneVerified = false,
    this.username,
    this.avatarSeed,
    this.avatarUrl,
    this.avatarIndex = 0,
    this.city,
    this.governorate,
    this.isVerified = false,
    this.verificationStatus = VerificationStatus.unverified,
    this.verificationSubmittedAt,
    this.verificationReviewedAt,
    this.verificationRejectionReason,
    this.isDeleted = false,
    this.avgRating = 0,
    this.ratingCount = 0,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final bool phoneVerified;
  final String? username;
  final String? avatarSeed;
  final String? avatarUrl;
  final int avatarIndex;
  final String? city;
  final String? governorate;
  final bool isVerified;
  final String verificationStatus;
  final DateTime? verificationSubmittedAt;
  final DateTime? verificationReviewedAt;
  final String? verificationRejectionReason;
  final bool isDeleted;
  final double avgRating;
  final int ratingCount;
  final DateTime createdAt;

  /// True when seller verification is approved.
  bool get isVerifiedSeller =>
      verificationStatus == VerificationStatus.verified || isVerified;

  /// Backward-compatible alias used by listing seller names.
  String get displayName => fullName;

  bool get hasUploadedAvatar =>
      avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  bool get hasUsername =>
      username != null && username!.trim().isNotEmpty;

  /// DiceBear seed used for illustrated avatar (defaults to Felix).
  String get effectiveAvatarSeed =>
      avatarSeed != null && avatarSeed!.trim().isNotEmpty
          ? avatarSeed!.trim()
          : 'Felix';

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      governorate != null &&
      governorate!.trim().isNotEmpty;

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    bool? phoneVerified,
    String? username,
    bool clearUsername = false,
    String? avatarSeed,
    String? avatarUrl,
    int? avatarIndex,
    bool clearAvatarUrl = false,
    String? city,
    String? governorate,
    bool? isVerified,
    String? verificationStatus,
    DateTime? verificationSubmittedAt,
    bool clearVerificationSubmittedAt = false,
    DateTime? verificationReviewedAt,
    bool clearVerificationReviewedAt = false,
    String? verificationRejectionReason,
    bool clearVerificationRejectionReason = false,
    bool? isDeleted,
    double? avgRating,
    int? ratingCount,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      username: clearUsername ? null : (username ?? this.username),
      avatarSeed: avatarSeed ?? this.avatarSeed,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      avatarIndex: avatarIndex ?? this.avatarIndex,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationSubmittedAt: clearVerificationSubmittedAt
          ? null
          : (verificationSubmittedAt ?? this.verificationSubmittedAt),
      verificationReviewedAt: clearVerificationReviewedAt
          ? null
          : (verificationReviewedAt ?? this.verificationReviewedAt),
      verificationRejectionReason: clearVerificationRejectionReason
          ? null
          : (verificationRejectionReason ?? this.verificationRejectionReason),
      isDeleted: isDeleted ?? this.isDeleted,
      avgRating: avgRating ?? this.avgRating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final verificationStatus =
        json['verification_status'] as String? ?? VerificationStatus.unverified;
    final legacyVerified = json['is_verified'] as bool? ?? false;
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ??
          json['display_name'] as String? ??
          '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      username: json['username'] as String?,
      avatarSeed: json['avatar_seed'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      avatarIndex: (json['avatar_index'] as num?)?.toInt() ?? 0,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      isVerified: legacyVerified,
      verificationStatus: verificationStatus == VerificationStatus.unverified &&
              legacyVerified
          ? VerificationStatus.verified
          : verificationStatus,
      verificationSubmittedAt: json['verification_submitted_at'] != null
          ? DateTime.tryParse(json['verification_submitted_at'] as String)
          : null,
      verificationReviewedAt: json['verification_reviewed_at'] != null
          ? DateTime.tryParse(json['verification_reviewed_at'] as String)
          : null,
      verificationRejectionReason: json['rejection_reason'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'display_name': fullName,
      'email': email,
      'phone': phone,
      'username': username,
      'avatar_seed': avatarSeed,
      'avatar_url': avatarUrl,
      'avatar_index': avatarIndex,
      'city': city,
      'governorate': governorate,
      'is_verified': isVerified,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'id': id,
      'full_name': fullName,
      'display_name': fullName,
      'email': email,
      'phone': phone,
      'username': username,
      'avatar_seed': avatarSeed,
      'avatar_url': avatarUrl,
      'avatar_index': avatarIndex,
      'city': city,
      'governorate': governorate,
      'is_deleted': isDeleted,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'display_name': fullName,
      'email': email,
      'avatar_seed': avatarSeed,
      'avatar_url': avatarUrl,
      'avatar_index': avatarIndex,
      'city': city,
      'governorate': governorate,
      'is_deleted': isDeleted,
    };
  }
}
