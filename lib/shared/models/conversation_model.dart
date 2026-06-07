class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    this.listingTitle,
    this.listingImage,
    this.listingPrice,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserPhone,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String? listingTitle;
  final String? listingImage;
  final double? listingPrice;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? otherUserPhone;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;

  String otherUserId(String currentUserId) =>
      currentUserId == buyerId ? sellerId : buyerId;

  ConversationModel copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    String? listingTitle,
    String? listingImage,
    double? listingPrice,
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserPhone,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImage: listingImage ?? this.listingImage,
      listingPrice: listingPrice ?? this.listingPrice,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserPhone: otherUserPhone ?? this.otherUserPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ConversationModel.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    int unreadCount = 0,
    String? listingImageUrl,
  }) {
    final listing = json['listings'] as Map<String, dynamic>?;
    final buyer = json['buyer'] as Map<String, dynamic>?;
    final seller = json['seller'] as Map<String, dynamic>?;
    final buyerId = json['buyer_id'] as String;
    final sellerId = json['seller_id'] as String;
    final otherProfile = buyerId == currentUserId ? seller : buyer;

    final priceRaw = listing?['price_iqd'] ?? listing?['price'];
    final price = priceRaw is num ? priceRaw.toDouble() : null;

    return ConversationModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: buyerId,
      sellerId: sellerId,
      listingTitle: listing?['title_ar'] as String? ?? listing?['title'] as String?,
      listingImage: listingImageUrl,
      listingPrice: price,
      otherUserName: otherProfile?['full_name'] as String? ??
          otherProfile?['display_name'] as String? ??
          'مستخدم',
      otherUserAvatar: otherProfile?['avatar_url'] as String?,
      otherUserPhone: otherProfile?['phone'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: unreadCount,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'last_message': lastMessage,
      'last_message_at': lastMessageTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
