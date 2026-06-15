import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import '../models/smart_alert.dart';

final smartAlertServiceProvider = Provider<SmartAlertService>((ref) {
  return SmartAlertService(ref.watch(supabaseClientProvider));
});

final userSmartAlertsProvider =
    FutureProvider.autoDispose<List<SmartAlert>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.read(smartAlertServiceProvider).getUserAlerts(userId);
});

class SmartAlertService {
  SmartAlertService(this._client);

  final SupabaseClient _client;

  Future<List<SmartAlert>> getUserAlerts(String userId) async {
    final rows = await _client
        .from('smart_alerts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => SmartAlert.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<int> countActiveAlerts(String userId) async {
    final rows = await _client
        .from('smart_alerts')
        .select('id')
        .eq('user_id', userId)
        .eq('is_active', true);

    return (rows as List).length;
  }

  /// Pro/Premium entitlement: user has purchased a listing package before.
  Future<bool> hasProAlertsEntitlement(String userId) async {
    final rows = await _client
        .from('listing_purchases')
        .select('id')
        .eq('user_id', userId)
        .limit(1);

    return (rows as List).isNotEmpty;
  }

  Future<void> createAlert({
    required String userId,
    required SmartAlert alert,
  }) async {
    final activeCount = await countActiveAlerts(userId);
    final pro = await hasProAlertsEntitlement(userId);
    if (isSmartAlertFreeLimitReached(
      activeAlertCount: activeCount,
      hasProEntitlement: pro,
    )) {
      throw const SmartAlertException('free_limit_reached');
    }

    if (alert.title.trim().isEmpty) {
      throw const SmartAlertException('اسم التنبيه مطلوب');
    }

    await _client.from('smart_alerts').insert(alert.toInsertRow(userId));
    if (kDebugMode) {
      debugPrint('SmartAlertService: created alert for user=$userId');
    }
  }

  Future<void> toggleAlert(String alertId, bool isActive) async {
    await _client
        .from('smart_alerts')
        .update({'is_active': isActive})
        .eq('id', alertId);
  }

  Future<void> deleteAlert(String alertId) async {
    await _client.from('smart_alerts').delete().eq('id', alertId);
  }
}
