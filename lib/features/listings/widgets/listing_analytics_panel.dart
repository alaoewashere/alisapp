import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../data/listings_repository.dart';
import '../models/listing_analytics.dart';

final _listingAnalyticsProvider =
    FutureProvider.family<ListingAnalytics?, String>((ref, listingId) async {
  return ref.read(listingsRepositoryProvider).fetchAnalytics(listingId);
});

/// Advanced analytics panel — shown to the owner of a Premium listing.
class ListingAnalyticsPanel extends ConsumerWidget {
  const ListingAnalyticsPanel({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_listingAnalyticsProvider(listingId));

    return async.when(
      loading: () => const _PanelShell(child: _LoadingPlaceholder()),
      error: (_, _) => const SizedBox.shrink(),
      data: (analytics) {
        if (analytics == null) return const SizedBox.shrink();
        return _PanelShell(child: _AnalyticsContent(analytics: analytics));
      },
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.premiumGold.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.premiumGold,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'تحميل الإحصائيات...',
          style: AppFonts.cairo(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({required this.analytics});

  final ListingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.premiumGold),
            const SizedBox(width: 8),
            Text(
              'إحصائيات متقدمة',
              style: AppFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.premiumGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Stats grid
        Row(
          children: [
            _StatTile(
              icon: Icons.visibility_outlined,
              label: 'إجمالي المشاهدات',
              value: '${analytics.totalViews}',
            ),
            const SizedBox(width: 10),
            _StatTile(
              icon: Icons.chat_bubble_outline,
              label: 'إجمالي التواصل',
              value: '${analytics.totalContacts}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatTile(
              icon: Icons.trending_up_rounded,
              label: 'مشاهدات آخر 7 أيام',
              value: '${analytics.views7d}',
              highlight: analytics.views7d > 0,
            ),
            const SizedBox(width: 10),
            _StatTile(
              icon: Icons.percent_rounded,
              label: 'معدل التواصل',
              value: '${(analytics.contactRate * 100).toStringAsFixed(1)}٪',
              highlight: analytics.contactRate > 0.05,
            ),
          ],
        ),
        if (analytics.peakHour != null) ...[
          const SizedBox(height: 10),
          _PeakHourRow(hour: analytics.peakHour!),
        ],
        if (analytics.hourlyViews.isNotEmpty) ...[
          const SizedBox(height: 14),
          _MiniBarChart(data: analytics.hourlyViews),
        ],
        const SizedBox(height: 4),
        Text(
          'البيانات تغطي آخر 30 يوماً',
          textAlign: TextAlign.center,
          style: AppFonts.cairo(
            fontSize: 10,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final accent = highlight ? AppColors.volt : AppColors.textMuted;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppFonts.cairo(
                fontSize: 10,
                color: AppColors.textMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeakHourRow extends StatelessWidget {
  const _PeakHourRow({required this.hour});

  final int hour;

  String get _label {
    final h = hour.toString().padLeft(2, '0');
    return '$h:00 – ${(hour + 1) % 24}:00';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.volt.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.volt.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 14, color: AppColors.volt),
          const SizedBox(width: 8),
          Text(
            'ساعة الذروة: $_label',
            style: AppFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.data});

  final List<HourlyViewCount> data;

  @override
  Widget build(BuildContext context) {
    final maxViews = data.map((e) => e.views).reduce((a, b) => a > b ? a : b);
    if (maxViews == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'توزيع المشاهدات (7 أيام)',
          style: AppFonts.cairo(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((e) {
              final frac = e.views / maxViews;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Tooltip(
                    message: '${e.label}: ${e.views}',
                    child: Container(
                      height: 8 + frac * 40,
                      decoration: BoxDecoration(
                        color: frac > 0.8
                            ? AppColors.premiumGold
                            : AppColors.premiumGold.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
