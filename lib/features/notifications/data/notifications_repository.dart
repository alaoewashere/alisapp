import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../models/app_notification.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(supabaseClientProvider));
});

class NotificationsRepository {
  NotificationsRepository(this._client);

  final dynamic _client;

  static const _maxRows = 100;

  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id, user_id, listing_id, type, title, body, is_read, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(_maxRows);

    return (data as List)
        .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<int> unreadCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
