import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/car_paint_panels.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/car_paint/car_paint_summary_widget.dart';
import '../widgets/car_paint/car_paint_widget.dart';

/// Step 3.5 — vehicle body/paint condition (المركبات only).
class CarPaintConditionScreen extends ConsumerWidget {
  const CarPaintConditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final panelConditions = state.vehicleDetails.panelConditions;
    final markedCount = state.configuredPaintPanels.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'حالة الهيكل والطلاء',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'تم الاختيار لـ $markedCount/$kCarPaintPanelCount قطعة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const CarPaintLegendRow(),
          const SizedBox(height: 12),
          CarPaintWidget(
            panelConditions: panelConditions,
            showPlusButtons: !state.allPartsOriginalDeclared,
            onPanelConditionChanged: notifier.setVehiclePanelCondition,
          ),
          const SizedBox(height: 16),
          _AllOriginalTile(
            value: state.allPartsOriginalDeclared,
            onChanged: notifier.setAllPartsOriginalDeclared,
          ),
          if (markedCount > 0 && !state.allPartsOriginalDeclared) ...[
            const SizedBox(height: 16),
            CarPaintSummaryWidget(
              panelConditions: panelConditions,
              showDiagram: false,
              requireMarkedPanels: true,
              markedPanelCount: markedCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _AllOriginalTile extends StatelessWidget {
  const _AllOriginalTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: CarPaintColors.panelStroke),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    'جميع أجزاء السيارة أصلية. لا توجد قطع مصبوغة أو مستبدلة.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
