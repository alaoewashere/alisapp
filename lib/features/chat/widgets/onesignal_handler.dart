import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../data/chat_repository.dart';

/// Initializes OneSignal when [appId] is configured in `.env`.
class OneSignalService {
  OneSignalService._();

  static bool _initialized = false;

  static Future<void> initialize(String? appId) async {
    if (appId == null || appId.trim().isEmpty || _initialized) return;

    OneSignal.initialize(appId.trim());
    _initialized = true;

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      final conversationId = data?['conversation_id'] as String?;
      if (conversationId != null && conversationId.isNotEmpty) {
        _pendingDeepLink = '/chat/$conversationId';
      }
    });

    OneSignal.User.pushSubscription.addObserver((state) {
      _onSubscriptionChanged?.call(state.current.id);
    });
  }

  static void Function(String? playerId)? _onSubscriptionChanged;

  static void setSubscriptionListener(void Function(String? playerId)? listener) {
    _onSubscriptionChanged = listener;
  }

  static String? _pendingDeepLink;

  static Future<void> requestPermission() async {
    if (!_initialized) return;
    await OneSignal.Notifications.requestPermission(true);
  }

  static Future<void> syncPlayerId(WidgetRef ref) async {
    if (!_initialized) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId == null || playerId.isEmpty) return;

    await ref.read(chatRepositoryProvider).saveOneSignalPlayerId(userId, playerId);
  }

  static void handlePendingDeepLink(BuildContext context) {
    final link = _pendingDeepLink;
    if (link == null) return;
    _pendingDeepLink = null;
    context.push(link);
  }
}

/// Wires OneSignal permission + player id sync after login.
class OneSignalHandler extends ConsumerStatefulWidget {
  const OneSignalHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OneSignalHandler> createState() => _OneSignalHandlerState();
}

class _OneSignalHandlerState extends ConsumerState<OneSignalHandler> {
  @override
  void initState() {
    super.initState();
    OneSignalService.setSubscriptionListener((playerId) {
      if (playerId != null && mounted) {
        OneSignalService.syncPlayerId(ref);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await OneSignalService.requestPermission();
      if (mounted) await OneSignalService.syncPlayerId(ref);
      if (mounted) OneSignalService.handlePendingDeepLink(context);
    });
  }

  @override
  void dispose() {
    OneSignalService.setSubscriptionListener(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserIdProvider, (prev, next) async {
      if (next != null && next != prev) {
        await OneSignalService.requestPermission();
        await OneSignalService.syncPlayerId(ref);
      }
    });

    return widget.child;
  }
}
