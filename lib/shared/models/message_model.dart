class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
    this.isPending = false,
    this.listingId,
    this.listingTitle,
    this.listingImage,
    this.listingPrice,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;
  final bool isPending;

  /// Set when this message is a "listing share" — a snapshot of the listing
  /// at the moment it was shared, so it stays accurate even if the seller
  /// later edits price/title, or the buyer moves on to asking about another
  /// listing with the same seller in this same thread.
  final String? listingId;
  final String? listingTitle;
  final String? listingImage;
  final double? listingPrice;

  bool get isListingCard => listingId != null;

  bool isMine(String currentUserId) => senderId == currentUserId;

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
    bool? isPending,
    String? listingId,
    String? listingTitle,
    String? listingImage,
    double? listingPrice,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImage: listingImage ?? this.listingImage,
      listingPrice: listingPrice ?? this.listingPrice,
    );
  }

  /// [json] may carry a resolved `listing_title`/`listing_image`/`listing_price`
  /// snapshot (injected by the repository) when `listing_id` is set.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      listingId: json['listing_id'] as String?,
      listingTitle: json['listing_title'] as String?,
      listingImage: json['listing_image'] as String?,
      listingPrice: (json['listing_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'body': content,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'listing_id': listingId,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'body': content,
      if (listingId != null) 'listing_id': listingId,
    };
  }
}
