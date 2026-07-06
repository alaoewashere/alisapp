import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../core/providers/locale_provider.dart';
import '../core/l10n/l10n_provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/arabic_number.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/listing_publication_date.dart';
import '../models/price_history.dart';
import '../services/price_history_service.dart';

class PriceHistoryWidget extends ConsumerWidget {
  const PriceHistoryWidget({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProvider(listingId));

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) {
        if (!data.hasChanges || data.timeline.isEmpty) {
          return const SizedBox.shrink();
        }
        return _PriceHistoryCard(data: data, strings: ref.watch(appLocalizationsProvider));
      },
    );
  }
}

class _PriceHistoryCard extends StatelessWidget {
  const _PriceHistoryCard({required this.data, required this.strings});

  final PriceHistoryData data;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final overallUp = !data.overallDropped;
    final trendColor = overallUp ? Colors.amber.shade700 : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.microShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, size: 20, color: trendColor),
              const SizedBox(width: 8),
              Text(
                strings.priceHistoryTitle,
                style: AppFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryBanner(data: data, strings: strings),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: _PriceSparkline(
              points: data.timeline,
              lineColor: trendColor,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(data.timeline.length, (index) {
            final point = data.timeline[index];
            final isLast = index == data.timeline.length - 1;
            return _TimelineRow(
              point: point,
              showConnector: !isLast,
              strings: strings,
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.data, required this.strings});

  final PriceHistoryData data;
  final AppLocalizations strings;

  String _formatDuration(DateTime from, DateTime to) {
    final weeks = (to.difference(from).inDays / 7).floor();
    if (weeks <= 0) return strings.lessThanOneWeek;
    if (weeks == 1) return strings.oneWeek;
    if (weeks == 2) return strings.twoWeeks;
    return strings.weeksCount('$weeks');
  }

  @override
  Widget build(BuildContext context) {
    final dropped = data.overallDropped;
    final bg = dropped
        ? AppColors.primary.withValues(alpha: 0.1)
        : Colors.amber.withValues(alpha: 0.12);
    final fg = dropped ? AppColors.primary : Colors.amber.shade800;
    final icon = dropped ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final from = formatIqdWithL10n(data.originalPrice, strings);
    final to = formatIqdWithL10n(data.currentPrice, strings);
    final duration = _formatDuration(data.listedAt, DateTime.now());
    final pct = data.totalPercentFromOriginal.abs().round();
    final pctLabel = '${dropped ? '↓' : '↑'} $pct%';

    final message = dropped
        ? strings.priceDroppedSummary(from, to, duration)
        : strings.priceIncreasedSummary(from, to);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pctLabel,
              style: AppFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSparkline extends StatelessWidget {
  const _PriceSparkline({
    required this.points,
    required this.lineColor,
  });

  final List<PriceHistoryPoint> points;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();

    final minPrice = points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = points.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice).clamp(1, 1 << 62);

    final spots = List.generate(points.length, (i) {
      final y = (points[i].price - minPrice) / range;
      return FlSpot(i.toDouble(), y);
    });

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: lineColor,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends ConsumerWidget {
  const _TimelineRow({
    required this.point,
    required this.showConnector,
    required this.strings,
  });

  final PriceHistoryPoint point;
  final bool showConnector;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final increased = (point.changeAmount ?? 0) > 0;
    final decreased = (point.changeAmount ?? 0) < 0;

    Color dotColor;
    if (point.isOriginal) {
      dotColor = Colors.grey.shade400;
    } else if (decreased) {
      dotColor = AppColors.primary;
    } else if (increased) {
      dotColor = Colors.amber.shade700;
    } else {
      dotColor = Colors.grey.shade500;
    }

    if (point.isCurrent) {
      dotColor = AppColors.primary;
    }

    final dotSize = point.isCurrent ? 12.0 : 10.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: point.isCurrent
                        ? Border.all(color: dotColor.withValues(alpha: 0.3), width: 3)
                        : null,
                  ),
                ),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (point.isOriginal)
                    Text(
                      strings.originalPriceLabel,
                      style: AppFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  if (point.isCurrent)
                    Text(
                      strings.currentPriceLabel,
                      style: AppFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        formatIqdWithL10n(point.price, strings),
                        style: AppFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (point.changeAmount != null &&
                          point.changeAmount != 0 &&
                          !point.isOriginal) ...[
                        const SizedBox(width: 8),
                        _ChangePill(amount: point.changeAmount!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatListingPublicationDate(point.at, locale),
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    final dropped = amount < 0;
    final color = dropped ? AppColors.primary : Colors.amber.shade800;
    final arrow = dropped ? '↓' : '↑';
    final label = '$arrow ${arabicNumber(amount.abs())}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
