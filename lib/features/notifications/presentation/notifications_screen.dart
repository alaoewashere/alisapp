import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/listing_time_ago.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/sello_app_bar.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../models/app_notification.dart';
import '../providers/notifications_provider.dart';

/// Ids swiped-to-delete but not yet confirmed removed by the backend.
/// Dismissible requires the widget to be gone from the tree the instant its
/// dismiss animation finishes — waiting on the async delete + provider
/// refetch is too slow and throws "still part of the tree". Filtering the
/// list by this set removes it immediately; the real delete still runs in
/// the background via [NotificationsActions.delete].
class _LocallyDismissedIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void add(String id) => state = {...state, id};
}

final _locallyDismissedIdsProvider =
    NotifierProvider<_LocallyDismissedIds, Set<String>>(
      _LocallyDismissedIds.new,
    );

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return Scaffold(
        appBar: SelloAppBar(title: Text(strings.notifications)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(strings.loginToViewFavorites),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push(AppRoutes.login),
                child: Text(strings.login),
              ),
            ],
          ),
        ),
      );
    }

    final async = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: SelloAppBar(
        title: Text(strings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_outlined),
            tooltip: strings.contactSupport,
            onPressed: () => context.push(AppRoutes.supportChat),
          ),
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsActionsProvider).markAllAsRead(),
              child: Text(
                'تعليم الكل كمقروء',
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.volt,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: async.when(
          loading: () => const _NotificationsShimmer(),
          error: (e, _) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: AppErrorWidget(
                  message: strings.failedLoadListings,
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
              ),
            ],
          ),
          data: (allItems) {
            final dismissedIds = ref.watch(_locallyDismissedIdsProvider);
            final items = dismissedIds.isEmpty
                ? allItems
                : allItems.where((n) => !dismissedIds.contains(n.id)).toList();
            if (items.isEmpty) return const _EmptyNotifications();
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _NotificationTile(notification: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider).languageCode;
    final visual = notification.visualFor(AppColors.volt);
    final unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.horizontal,
      background: _dismissBackground(),
      secondaryBackground: _dismissBackground(),
      onDismissed: (_) {
        ref.read(_locallyDismissedIdsProvider.notifier).add(notification.id);
        ref.read(notificationsActionsProvider).delete(notification.id);
      },
      child: Material(
        color: unread
            ? AppColors.volt.withValues(alpha: 0.06)
            : AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (unread) {
              await ref
                  .read(notificationsActionsProvider)
                  .markAsRead(notification.id);
            }
            if (notification.hasListing && context.mounted) {
              context.push('/listing/${notification.listingId}');
            }
          },
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unread
                    ? AppColors.volt.withValues(alpha: 0.25)
                    : AppColors.glassBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(visual.icon, size: 22, color: visual.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (notification.body.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          notification.body,
                          style: AppFonts.cairo(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        formatListingTimeAgo(notification.createdAt, langCode),
                        style: AppFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.volt,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.rejected.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.delete_outline, color: AppColors.rejected),
          Icon(Icons.delete_outline, color: AppColors.rejected),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Icon(
          Icons.notifications_none_rounded,
          size: 72,
          color: AppColors.textMuted.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        Text(
          'لا توجد إشعارات بعد',
          textAlign: TextAlign.center,
          style: AppFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ستظهر هنا تنبيهات إعلاناتك ورسائل الإدارة',
          textAlign: TextAlign.center,
          style: AppFonts.cairo(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, _) =>
          const ShimmerBox(width: double.infinity, height: 84),
    );
  }
}
