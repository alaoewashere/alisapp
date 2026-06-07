class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.city,
    this.governorate,
    this.isVerified = false,
    this.isDeleted = false,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? city;
  final String? governorate;
  final bool isVerified;
  final bool isDeleted;
  final DateTime createdAt;

  /// Backward-compatible alias used by listing seller names.
  String get displayName => fullName;

  bool get isComplete =>
      fullName.trim().isNotEmpty &&
      governorate != null &&
      governorate!.trim().isNotEmpty;

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? city,
    String? governorate,
    bool? isVerified,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      isVerified: isVerified ?? this.isVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ??
          json['display_name'] as String? ??
          '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String?,
      governorate: json['governorate'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'display_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
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
      'phone': phone,
      'avatar_url': avatarUrl,
      'city': city,
      'governorate': governorate,
      'is_deleted': isDeleted,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'display_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'city': city,
      'governorate': governorate,
      'is_deleted': isDeleted,
    };
  }
}
