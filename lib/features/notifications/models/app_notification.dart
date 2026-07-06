import 'package:flutter/material.dart';

/// A single in-app notification row from the `notifications` table.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.listingId,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? listingId;

  bool get hasListing => listingId != null && listingId!.isNotEmpty;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: (json['type'] as String?) ?? 'general',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      listingId: json['listing_id'] as String?,
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      listingId: listingId,
    );
  }

  /// Icon + accent chosen from the notification [type].
  ({IconData icon, Color color}) visualFor(Color fallback) {
    return switch (type) {
      'warning' => (icon: Icons.warning_amber_rounded, color: const Color(0xFFFF9800)),
      'listing_approved' || 'approved' => (
          icon: Icons.check_circle_outline,
          color: const Color(0xFF34C759),
        ),
      'listing_rejected' || 'rejected' => (
          icon: Icons.cancel_outlined,
          color: const Color(0xFFFF453A),
        ),
      'new_listing' || 'smart_alert' => (
          icon: Icons.notifications_active_outlined,
          color: fallback,
        ),
      'message' => (icon: Icons.chat_bubble_outline, color: fallback),
      _ => (icon: Icons.notifications_none_rounded, color: fallback),
    };
  }
}
