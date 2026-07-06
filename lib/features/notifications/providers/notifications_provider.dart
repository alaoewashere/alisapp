import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../data/notifications_repository.dart';
import '../models/app_notification.dart';

export '../data/notifications_repository.dart';

/// All notifications for the signed-in user (newest first).
final notificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(notificationsRepositoryProvider).fetchNotifications(userId);
});

/// Unread badge count. Derives from [notificationsProvider] when it has data so
/// the badge clears instantly after marking read; otherwise queries directly.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

/// Actions: mark one / all as read, then refresh the list.
class NotificationsActions {
  NotificationsActions(this._ref);

  final Ref _ref;

  Future<void> markAsRead(String id) async {
    await _ref.read(notificationsRepositoryProvider).markAsRead(id);
    _ref.invalidate(notificationsProvider);
  }

  Future<void> markAllAsRead() async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;
    await _ref.read(notificationsRepositoryProvider).markAllAsRead(userId);
    _ref.invalidate(notificationsProvider);
  }
}

final notificationsActionsProvider = Provider<NotificationsActions>((ref) {
  return NotificationsActions(ref);
});
