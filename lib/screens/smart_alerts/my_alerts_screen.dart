import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/utils/arabic_number.dart';
import '../../models/smart_alert.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../services/smart_alert_service.dart';

class MyAlertsScreen extends ConsumerWidget {
  const MyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final alertsAsync = ref.watch(userSmartAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          'تنبيهاتي الذكية',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        leading: AppBackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'تنبيه جديد',
            onPressed: () => context.push(AppRoutes.createSmartAlert),
          ),
        ],
      ),
      floatingActionButton: userId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.createSmartAlert),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text('تنبيه جديد', style: AppFonts.cairo()),
            ),
      body: userId == null
          ? Center(
              child: Text(
                'سجّل الدخول لإدارة التنبيهات',
                style: AppFonts.cairo(color: AppColors.textMuted),
              ),
            )
          : alertsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (alerts) {
                if (alerts.isEmpty) {
                  return _EmptyAlerts(
                    onCreate: () => context.push(AppRoutes.createSmartAlert),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userSmartAlertsProvider);
                    await ref.read(userSmartAlertsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: alerts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return _AlertCard(
                        alert: alert,
                        onToggle: (active) async {
                          await ref
                              .read(smartAlertServiceProvider)
                              .toggleAlert(alert.id, active);
                          ref.invalidate(userSmartAlertsProvider);
                        },
                        onDelete: () async {
                          await ref
                              .read(smartAlertServiceProvider)
                              .deleteAlert(alert.id);
                          ref.invalidate(userSmartAlertsProvider);
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد تنبيهات بعد',
              style: AppFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'أنشئ تنبيهاً الآن',
                style: AppFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onDelete,
  });

  final SmartAlert alert;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return true;
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.fieldCarbon,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.microShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (alert.category != null &&
                          alert.category!.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            alert.category!,
                            style: AppFonts.cairo(
                              fontSize: 11,
                              color: AppColors.badgeText,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.summaryLine,
                    style: AppFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.lastTriggeredLabel,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.85),
                    ),
                  ),
                  if (alert.triggerCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${arabicNumber(alert.triggerCount)} إعلان مطابق',
                        style: AppFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: alert.isActive,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return null;
              }),
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner shown on search results to save current filters as a smart alert.
class SmartAlertSaveBanner extends ConsumerWidget {
  const SmartAlertSaveBanner({super.key, required this.draft});

  final SmartAlertDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {
          final userId = ref.read(currentUserIdProvider);
          if (userId == null) {
            context.push(AppRoutes.login);
            return;
          }
          context.push(AppRoutes.createSmartAlert, extra: draft);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'احفظ هذا البحث كتنبيه ذكي 🔔',
                  style: AppFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
