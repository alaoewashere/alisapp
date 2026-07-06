import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/car_paint_panels.dart';
import '../../../../core/l10n/car_paint_locale.dart';
import '../../../../core/l10n/l10n_provider.dart';
import 'car_paint_calibrator.dart';
import 'car_paint_panel_overlay.dart';
import 'car_paint_panel_layout.dart';

/// Image-based Sahibinden-style car paint diagram with overlays and + buttons.
class CarPaintWidget extends StatelessWidget {
  const CarPaintWidget({
    super.key,
    required this.panelConditions,
    this.onPanelConditionChanged,
    this.showPlusButtons = true,
    this.horizontalPadding = 32,
  });

  final Map<String, String> panelConditions;
  final void Function(String panelId, String condition)? onPanelConditionChanged;
  final bool showPlusButtons;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final imgWidth = MediaQuery.sizeOf(context).width - horizontalPadding;
    final imgHeight = imgWidth * kCarPaintImageAspectRatio;

    return Center(
      child: SizedBox(
        width: imgWidth,
        height: imgHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildBaseImage(imgWidth, imgHeight),
            ...buildCarPaintPanelOverlays(
              panelConditions: panelConditions,
              width: imgWidth,
              height: imgHeight,
            ),
            if (showPlusButtons) ..._buildPlusButtons(context, imgWidth, imgHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseImage(double imgWidth, double imgHeight) {
    final image = Image.asset(
      kCarPaintBaseImageAsset,
      width: imgWidth,
      height: imgHeight,
      fit: BoxFit.fill,
    );

    if (carPaintCalibrationEnabled) {
      return CarPaintCalibrator(
        imgWidth: imgWidth,
        imgHeight: imgHeight,
        child: image,
      );
    }

    return image;
  }

  List<Widget> _buildPlusButtons(
    BuildContext context,
    double width,
    double height,
  ) {
    return kCarPaintPanelLayouts.map((panel) {
      final rect = panel.rectForSize(width, height);
      final center = rect.center;
      final condition = panelConditions[panel.id];
      final hasCondition =
          condition != null && condition != CarPaintCondition.original;
      final accentColor = hasCondition
          ? carPaintOverlayColor(condition)
          : CarPaintColors.addIcon;

      return Positioned(
        left: center.dx - 14,
        top: center.dy - 14,
        child: GestureDetector(
          onTap: () => _showPicker(context, panel),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Icon(
              Icons.add,
              size: 16,
              color: accentColor,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showPicker(BuildContext context, CarPaintPanelLayout panel) {
    final strings = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.fieldCarbon,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  carPaintPanelLabel(strings, panel.id),
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureWhite,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              _conditionTile(
                sheetContext,
                panel,
                CarPaintCondition.original,
                strings.bodyPartOriginal,
                CarPaintColors.original,
              ),
              _conditionTile(
                sheetContext,
                panel,
                CarPaintCondition.localPaint,
                strings.bodyPartLocalPaint,
                CarPaintColors.localPaint,
              ),
              _conditionTile(
                sheetContext,
                panel,
                CarPaintCondition.painted,
                strings.bodyPartPainted,
                CarPaintColors.painted,
              ),
              _conditionTile(
                sheetContext,
                panel,
                CarPaintCondition.replaced,
                strings.bodyPartReplaced,
                CarPaintColors.replaced,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _conditionTile(
    BuildContext context,
    CarPaintPanelLayout panel,
    String value,
    String label,
    Color color,
  ) {
    final current = panelConditions[panel.id];
    final isSelected =
        (current ?? CarPaintCondition.original) == value;

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.volt : const Color(0x20FFFFFF),
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.pureWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.volt)
          : null,
      onTap: () {
        onPanelConditionChanged?.call(panel.id, value);
        Navigator.pop(context);
      },
    );
  }
}
