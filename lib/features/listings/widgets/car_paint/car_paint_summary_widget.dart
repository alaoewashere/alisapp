import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/car_paint_panels.dart';
import '../../../../core/utils/car_paint_utils.dart';
import 'car_paint_widget.dart';

/// Read-only Sahibinden-style paint summary for listing detail and review.
class CarPaintSummaryWidget extends StatelessWidget {
  const CarPaintSummaryWidget({
    super.key,
    required this.panelConditions,
    this.showDiagram = true,
    this.diagramHeight = 160,
    this.showWhenAllOriginal = true,
    this.requireMarkedPanels = false,
    this.markedPanelCount = 0,
    this.allOriginalLabelAr = 'جميع أجزاء السيارة أصلية',
  });

  final Map<String, String> panelConditions;
  final bool showDiagram;
  final double diagramHeight;
  final bool showWhenAllOriginal;
  final bool requireMarkedPanels;
  final int markedPanelCount;
  final String allOriginalLabelAr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = buildCarPaintSummaryGroups(panelConditions);
    final allOriginal = carPaintAllOriginal(panelConditions);

    if (requireMarkedPanels && markedPanelCount == 0) {
      return const SizedBox.shrink();
    }

    if (allOriginal && !showWhenAllOriginal) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDiagram) ...[
          CarPaintWidget(
            panelConditions: panelConditions,
            showPlusButtons: false,
            horizontalPadding: 64,
          ),
          const SizedBox(height: 12),
        ],
        if (allOriginal)
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                allOriginalLabelAr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else
          ...groups.map((group) => _SummaryGroup(group: group)),
      ],
    );
  }
}

class CarPaintLegendRow extends StatelessWidget {
  const CarPaintLegendRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      (CarPaintColors.original, 'أصلي'),
      (CarPaintColors.localPaint, 'صبغ محلي'),
      (CarPaintColors.painted, 'مصبوغه'),
      (CarPaintColors.replaced, 'مستبدلة'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.$1,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0x20FFFFFF)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SummaryGroup extends StatelessWidget {
  const _SummaryGroup({required this.group});

  final CarPaintSummaryGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: group.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                group.labelAr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...group.panelNamesAr.map(
            (name) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 18, bottom: 2),
              child: Text('• $name', style: theme.textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}
