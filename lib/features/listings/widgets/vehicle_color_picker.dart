import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../core/constants/app_colors.dart';
import '../constants/vehicle_listing_options.dart';

/// Card-style vehicle color picker with preset swatches and custom spectrum sheet.
class VehicleColorPicker extends StatelessWidget {
  const VehicleColorPicker({
    super.key,
    required this.selectedColor,
    required this.customColor,
    required this.onColorSelected,
    required this.onCustomColorSelected,
  });

  final String? selectedColor;
  final String customColor;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onCustomColorSelected;

  static const _circleSize = 44.0;
  static const _rainbowGradient = SweepGradient(
    colors: [
      Color(0xFFFF0000),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF00FFFF),
      Color(0xFF0000FF),
      Color(0xFFFF00FF),
      Color(0xFFFF0000),
    ],
  );

  String? get _displayLabel {
    if (selectedColor == null || selectedColor!.isEmpty) return null;
    if (VehicleCarColors.isOtherLabel(selectedColor)) {
      return VehicleCarColors.otherLabel;
    }
    return selectedColor;
  }

  Color? _parseCustomHex() {
    final raw = customColor.trim();
    if (raw.isEmpty) return null;
    final hex = raw.startsWith('#') ? raw.substring(1) : raw;
    if (hex.length != 6 && hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    if (hex.length == 6) return Color(0xFF000000 | value);
    return Color(value);
  }

  bool _isSelected(CarColorOption option) {
    if (option.isOther) {
      return VehicleCarColors.isOtherLabel(selectedColor);
    }
    return selectedColor == option.labelAr;
  }

  Future<void> _openCustomPicker(BuildContext context) async {
    var pickerColor = _parseCustomHex() ?? Colors.deepOrange;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.paddingOf(sheetContext).bottom + 16,
                ),
                child: StatefulBuilder(
                  builder: (context, setSheetState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D1D6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'اختر لوناً مخصصاً',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (color) {
                            setSheetState(() => pickerColor = color);
                          },
                          enableAlpha: false,
                          displayThumbColor: true,
                          pickerAreaHeightPercent: 0.65,
                          labelTypes: const [],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.pop(sheetContext, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('تأكيد'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    final hex =
        '#${pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    onColorSelected(VehicleCarColors.otherLabel);
    onCustomColorSelected(hex);
  }

  void _onTapSwatch(BuildContext context, CarColorOption option) {
    if (option.isOther) {
      _openCustomPicker(context);
      return;
    }
    onColorSelected(option.labelAr);
    onCustomColorSelected('');
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = _displayLabel;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'اللون',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    displayLabel ?? 'اختر اللون',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: displayLabel != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: displayLabel != null
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: _circleSize + 4,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: VehicleCarColors.options.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final option = VehicleCarColors.options[index];
                    return _ColorSwatch(
                      option: option,
                      selected: _isSelected(option),
                      customPreviewColor: option.isOther
                          ? _parseCustomHex()
                          : null,
                      onTap: () => _onTapSwatch(context, option),
                    );
                  },
                ),
              ),
              if (displayLabel != null) ...[
                const SizedBox(height: 14),
                Text(
                  displayLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
    this.customPreviewColor,
  });

  final CarColorOption option;
  final bool selected;
  final VoidCallback onTap;
  final Color? customPreviewColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = _borderColorFor(option, customPreviewColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          width: VehicleColorPicker._circleSize,
          height: VehicleColorPicker._circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _fillColor(customPreviewColor),
            gradient: _useRainbow(customPreviewColor)
                ? VehicleColorPicker._rainbowGradient
                : null,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  color: _checkColorFor(option, customPreviewColor),
                  size: 22,
                )
              : null,
        ),
      ),
    );
  }

  Color _borderColorFor(CarColorOption option, Color? customPreview) {
    if (option.isOther) {
      return customPreview != null && selected
          ? _darkerShade(customPreview)
          : const Color(0xFFBDBDBD);
    }
    return _darkerShade(option.color);
  }

  Color? _fillColor(Color? customPreviewColor) {
    if (option.isOther) {
      return customPreviewColor != null && selected ? customPreviewColor : null;
    }
    return option.color;
  }

  bool _useRainbow(Color? customPreviewColor) {
    return option.isOther && !(customPreviewColor != null && selected);
  }

  Color _checkColorFor(CarColorOption option, Color? customPreview) {
    if (option.isOther && customPreview != null && selected) {
      return customPreview.computeLuminance() > 0.55
          ? AppColors.textDark
          : Colors.white;
    }
    if (option.labelAr == 'أبيض' || option.labelAr == 'ذهبي') {
      return AppColors.textDark;
    }
    return Colors.white;
  }

  Color _darkerShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0))
        .toColor();
  }
}
