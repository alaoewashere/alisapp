class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final bool isPending;

  bool isMine(String currentUserId) => senderId == currentUserId;

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
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
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'body': content,
    };
  }
}
