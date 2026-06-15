import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/models/vehicle_listing_metadata.dart';
import '../../constants/vehicle_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import '../vehicle_color_picker.dart';
import '../vehicle_specs_checklist.dart';
import '../vehicle_price_estimator_section.dart';
import 'step2_form_common.dart';
import 'step2_title_description_fields.dart';

const _vehicleFormCardFill = Color(0xFFF8F8F8);
const _vehicleFormDivider = Color(0xFFE5E5EA);

class Step2VehicleDetails extends ConsumerStatefulWidget {
  const Step2VehicleDetails({super.key});

  @override
  ConsumerState<Step2VehicleDetails> createState() =>
      _Step2VehicleDetailsState();
}

class _Step2VehicleDetailsState extends ConsumerState<Step2VehicleDetails> {
  late final TextEditingController _trimController;
  late final TextEditingController _mileageController;
  late final TextEditingController _engineController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(postListingProvider.notifier)
          .updateField('listingType', ListingType.sale);
    });
    final vehicle = ref.read(postListingProvider).vehicleDetails;
    final price = ref.read(postListingProvider).price;
    _trimController = TextEditingController(text: vehicle.trim);
    _mileageController = TextEditingController(
      text: vehicle.mileage?.toString() ?? '',
    );
    _engineController = TextEditingController(text: vehicle.engine);
    _priceController = TextEditingController(
      text: price != null ? price.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _trimController.dispose();
    _mileageController.dispose();
    _engineController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateVehicle(
    VehicleListingMetadata Function(VehicleListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).vehicleDetails;
    ref.read(postListingProvider.notifier).updateVehicleDetails(update(current));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final vehicle = state.vehicleDetails;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تفاصيل المركبة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.categoryPath.isNotEmpty) ...[
              const SizedBox(height: 12),
              CategoryPathBreadcrumb(
                path: state.categoryPath,
                onTap: () {
                  notifier.resetCategoryDrill();
                  notifier.goToStep(1);
                },
              ),
            ],
            const SizedBox(height: 16),
            const Step2TitleDescriptionFields(),
            Text(
              'المعلومات الأساسية',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _VehicleSettingsCard(
              children: [
                _VehicleTextRow(
                  label: 'الفئة',
                  controller: _trimController,
                  hint: 'مثال: SE',
                  textDirection: TextDirection.rtl,
                  onChanged: (v) => _updateVehicle((d) => d.copyWith(trim: v)),
                ),
                _VehicleTextRow(
                  label: 'المسافة',
                  controller: _mileageController,
                  hint: '0',
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  unitLabel: vehicle.mileageUnit.labelAr,
                  onUnitTap: () {
                    final next = vehicle.mileageUnit == MileageUnit.km
                        ? MileageUnit.mile
                        : MileageUnit.km;
                    _updateVehicle((d) => d.copyWith(mileageUnit: next));
                  },
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    _updateVehicle(
                      (d) => parsed == null
                          ? d.copyWith(clearMileage: true)
                          : d.copyWith(mileage: parsed),
                    );
                  },
                  showDivider: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _VehicleSettingsCard(
              children: [
                _VehicleTextRow(
                  label: 'المحرك',
                  controller: _engineController,
                  hint: '2.0T',
                  textDirection: TextDirection.ltr,
                  onChanged: (v) => _updateVehicle((d) => d.copyWith(engine: v)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _vehicleFormDivider,
                      ),
                      Step2LabeledDropdown(
                        label: 'الأسطوانات',
                        value: vehicle.cylinders,
                        items: VehicleListingOptions.cylinderOptions,
                        onChanged: (v) =>
                            _updateVehicle((d) => d.copyWith(cylinders: v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('التفاصيل', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Step2LabeledDropdown(
              label: 'الحالة *',
              value: switch (state.condition) {
                ListingCondition.newItem => 'جديد',
                ListingCondition.used => 'مستعمل',
                null => null,
              },
              items: const ['جديد', 'مستعمل'],
              onChanged: (v) {
                notifier.updateField(
                  'condition',
                  switch (v) {
                    'جديد' => ListingCondition.newItem,
                    'مستعمل' => ListingCondition.used,
                    _ => null,
                  },
                );
              },
            ),
            Step2LabeledDropdown(
              label: 'وضع الطلاء',
              value: vehicle.paintParts,
              items: VehicleListingOptions.paintPartOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(paintParts: v)),
            ),
            Step2LabeledDropdown(
              label: 'الوقود *',
              value: vehicle.fuel,
              items: VehicleListingOptions.fuelOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(fuel: v)),
            ),
            Step2LabeledDropdown(
              label: 'بلد الاستيراد',
              value: vehicle.importCountry,
              items: VehicleListingOptions.importCountryOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(importCountry: v)),
            ),
            Step2LabeledDropdown(
              label: 'اللوحة',
              value: vehicle.plate,
              items: VehicleListingOptions.plateOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(plate: v)),
            ),
            Step2LabeledDropdown(
              label: 'ناقل الحركة *',
              value: vehicle.transmission,
              items: VehicleListingOptions.transmissionOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(transmission: v)),
            ),
            Step2LabeledDropdown(
              label: 'عدد المقاعد',
              value: vehicle.seatNumber,
              items: VehicleListingOptions.seatNumberOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(seatNumber: v)),
            ),
            Step2LabeledDropdown(
              label: 'مادة المقاعد',
              value: vehicle.seatMaterial,
              items: VehicleListingOptions.seatMaterialOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(seatMaterial: v)),
            ),
            const SizedBox(height: 12),
            VehicleColorPicker(
              selectedColor: vehicle.color,
              customColor: vehicle.customColor,
              onColorSelected: (label) =>
                  _updateVehicle((d) => d.copyWith(color: label)),
              onCustomColorSelected: (hex) =>
                  _updateVehicle((d) => d.copyWith(customColor: hex)),
            ),
            const SizedBox(height: 24),
            Text('المواصفات', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            VehicleSpecsChecklist(
              selected: vehicle.selectedSpecs,
              onToggle: notifier.toggleVehicleSpec,
            ),
            VehiclePriceEstimatorSection(
              categoryPath: state.categoryPath,
              vehicle: vehicle,
              condition: state.condition,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'السعر *',
                suffixText: 'د.ع',
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', ''));
                notifier.updateField('price', parsed);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('قابل للتفاوض'),
              value: state.isNegotiable,
              onChanged: (v) => notifier.updateField('isNegotiable', v),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VehicleSettingsCard extends StatelessWidget {
  const _VehicleSettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _vehicleFormCardFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _VehicleTextRow extends StatelessWidget {
  const _VehicleTextRow({
    required this.label,
    required this.controller,
    required this.hint,
    required this.textDirection,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.unitLabel,
    this.onUnitTap,
    this.showDivider = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextDirection textDirection;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? unitLabel;
  final VoidCallback? onUnitTap;
  final bool showDivider;

  static const _labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const _fieldStyle = TextStyle(
    fontSize: 15,
    color: AppColors.textDark,
  );

  static const _hintStyle = TextStyle(
    fontSize: 15,
    color: AppColors.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: _vehicleFormDivider),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: _labelStyle),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                textDirection: textDirection,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: _fieldStyle,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: _hintStyle,
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
            if (unitLabel != null && onUnitTap != null) ...[
              const SizedBox(width: 8),
              _VehicleUnitPill(label: unitLabel!, onTap: onUnitTap!),
            ],
          ],
        ),
      ],
    );
  }
}

class _VehicleUnitPill extends StatelessWidget {
  const _VehicleUnitPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _vehicleFormDivider),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
