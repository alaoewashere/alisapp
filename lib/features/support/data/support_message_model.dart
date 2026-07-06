class SupportMessageModel {
  const SupportMessageModel({
    required this.id,
    required this.userId,
    required this.isFromAdmin,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final String userId;
  final bool isFromAdmin;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final bool isPending;

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      isFromAdmin: json['sender_role'] == 'admin',
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
