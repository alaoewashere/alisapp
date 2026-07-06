import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/car_paint_panels.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/car_paint/car_paint_summary_widget.dart';
import '../widgets/car_paint/car_paint_widget.dart';

/// Step 3.5 — vehicle body/paint condition (vehicles only).
class CarPaintConditionScreen extends ConsumerWidget {
  const CarPaintConditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final strings = ref.watch(appLocalizationsProvider);
    final theme = Theme.of(context);
    final panelConditions = state.vehicleDetails.panelConditions;
    final markedCount = state.configuredPaintPanels.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.bodyConditionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            strings.bodyPartSelected(markedCount, kCarPaintPanelCount),
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

class _AllOriginalTile extends ConsumerWidget {
  const _AllOriginalTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? AppColors.volt.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                activeColor: AppColors.volt,
                checkColor: AppColors.canvas,
                side: const BorderSide(color: AppColors.textMuted),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    strings.allCarPartsOriginalFull,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textDark,
                      height: 1.4,
                    ),
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
