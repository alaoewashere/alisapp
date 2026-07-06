import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/enum_localizations.dart';
import '../../../../core/l10n/l10n_provider.dart';
import '../../../../core/utils/category_tree.dart';
import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/models/vehicle_listing_metadata.dart';
import '../../constants/vehicle_listing_options.dart';
import '../../constants/listing_form_options.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import '../vehicle_color_picker.dart';
import '../vehicle_form_field_card.dart';
import '../vehicle_specs_checklist.dart';
import '../vehicle_price_estimator_section.dart';
import 'step2_form_common.dart';
import 'step2_title_description_fields.dart';

class Step2VehicleDetails extends ConsumerStatefulWidget {
  const Step2VehicleDetails({super.key});

  @override
  ConsumerState<Step2VehicleDetails> createState() =>
      _Step2VehicleDetailsState();
}

class _Step2VehicleDetailsState extends ConsumerState<Step2VehicleDetails> {
  late final TextEditingController _mileageController;
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
    _mileageController = TextEditingController(
      text: vehicle.mileage?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: price != null ? price.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// The brand node within the selected category drill-down (e.g. "Toyota"),
  /// used to look up real trim/engine options for that brand.
  CategoryModel? _selectedBrand(List<CategoryModel> path) {
    for (final c in path) {
      if (isVehicleBrand(c)) return c;
    }
    return null;
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
    final strings = ref.watch(appLocalizationsProvider);

    final brandSlug = _selectedBrand(state.categoryPath)?.slug;
    final curatedTrims = brandSlug == null
        ? const <String>[]
        : ref
            .watch(vehicleTrimOptionsProvider(brandSlug))
            .maybeWhen(data: (v) => v, orElse: () => const <String>[]);
    final trimOptions = curatedTrims.isNotEmpty
        ? curatedTrims
        : VehicleListingOptions.genericTrimOptions;
    final curatedEngines = brandSlug == null
        ? const <String>[]
        : ref
            .watch(vehicleEngineOptionsProvider(brandSlug))
            .maybeWhen(data: (v) => v, orElse: () => const <String>[]);
    final engineOptions = curatedEngines.isNotEmpty
        ? curatedEngines
        : VehicleListingOptions.genericEngineOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.vehicleDetailsTitle,
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
              strings.basicInfoTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _VehiclePickerField(
              label: strings.vehicleTrimLabel,
              value: vehicle.trim,
              items: trimOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(trim: v)),
            ),
            const SizedBox(height: 12),
            _VehicleTextFieldCard(
              label: strings.mileageLabel,
              controller: _mileageController,
              hint: '0',
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.number,
              inputFormatters: [appDigitsOnly()],
              unitLabel: vehicle.mileageUnit.localizedLabel(strings),
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
            ),
            const SizedBox(height: 12),
            _VehicleYearPickerField(
              year: vehicle.year,
              onChanged: (year) =>
                  _updateVehicle((d) => d.copyWith(year: year)),
            ),
            const SizedBox(height: 12),
            _VehiclePickerField(
              label: strings.engineLabel,
              value: vehicle.engine,
              items: engineOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(engine: v)),
            ),
            const SizedBox(height: 12),
            _VehiclePickerField(
              label: strings.cylindersLabel,
              value: vehicle.cylinders,
              items: VehicleListingOptions.cylinderOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(cylinders: v)),
            ),
            const SizedBox(height: 24),
            Text(strings.detailsSection, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Step2LabeledDropdown(
              label: strings.conditionRequiredLabel,
              value: switch (state.condition) {
                ListingCondition.newItem => strings.conditionNew,
                ListingCondition.used => strings.conditionUsed,
                null => null,
              },
              items: [strings.conditionNew, strings.conditionUsed],
              onChanged: (v) {
                notifier.updateField(
                  'condition',
                  switch (v) {
                    final n when n == strings.conditionNew =>
                      ListingCondition.newItem,
                    final u when u == strings.conditionUsed =>
                      ListingCondition.used,
                    _ => null,
                  },
                );
              },
            ),
            Step2LabeledDropdown(
              label: strings.paintStatusLabel,
              value: vehicle.paintParts,
              items: VehicleListingOptions.paintPartOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(paintParts: v)),
            ),
            Step2LabeledDropdown(
              label: strings.fuelRequiredLabel,
              value: vehicle.fuel,
              items: VehicleListingOptions.fuelOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(fuel: v)),
            ),
            Step2LabeledDropdown(
              label: strings.importCountryLabel,
              value: vehicle.importCountry,
              items: VehicleListingOptions.importCountryOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(importCountry: v)),
            ),
            Step2LabeledDropdown(
              label: strings.plateLabel,
              value: vehicle.plate,
              items: VehicleListingOptions.plateOptions,
              onChanged: (v) => _updateVehicle((d) => d.copyWith(plate: v)),
            ),
            Step2LabeledDropdown(
              label: strings.transmissionRequiredLabel,
              value: vehicle.transmission,
              items: VehicleListingOptions.transmissionOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(transmission: v)),
            ),
            Step2LabeledDropdown(
              label: strings.seatCountLabel,
              value: vehicle.seatNumber,
              items: VehicleListingOptions.seatNumberOptions,
              onChanged: (v) =>
                  _updateVehicle((d) => d.copyWith(seatNumber: v)),
            ),
            Step2LabeledDropdown(
              label: strings.seatMaterialLabel,
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
            Text(strings.specsSectionTitle, style: theme.textTheme.titleSmall),
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
              inputFormatters: [appThousands()],
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: strings.priceRequiredLabel,
                suffixText: strings.currencyIqd,
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', ''));
                notifier.updateField('price', parsed);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.negotiable),
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

class _VehicleFieldCard extends StatelessWidget {
  const _VehicleFieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => VehicleFormFieldCard(child: child);
}

class _VehicleFieldLabel extends StatelessWidget {
  const _VehicleFieldLabel({required this.label});

  final String label;

  static const _style = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return Text(label, style: _style);
  }
}

class _VehicleTextFieldCard extends StatelessWidget {
  const _VehicleTextFieldCard({
    required this.label,
    required this.controller,
    required this.hint,
    required this.textDirection,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.unitLabel,
    this.onUnitTap,
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

  static const _valueStyle = TextStyle(
    fontSize: 15,
    color: AppColors.pureWhite,
  );

  static const _hintStyle = TextStyle(
    fontSize: 15,
    color: AppColors.textMuted,
  );

  @override
  Widget build(BuildContext context) {
    return _VehicleFieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VehicleFieldLabel(label: label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  textDirection: textDirection,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: _valueStyle,
                  cursorColor: AppColors.volt,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: AppColors.fieldCarbon,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
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
      ),
    );
  }
}

class _VehicleYearPickerField extends StatelessWidget {
  const _VehicleYearPickerField({
    required this.year,
    required this.onChanged,
  });

  final int? year;
  final ValueChanged<int?> onChanged;

  static List<int> _yearOptions() {
    final currentYear = DateTime.now().year;
    return List.generate(
      currentYear - 1970 + 1,
      (index) => currentYear - index,
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final options = _yearOptions();
    final labels = options.map((y) => y.toString()).toList();
    final picked = await showStep2PickerSheet(
      context: context,
      title: step2PickerSheetTitle(context.l10n, context.l10n.yearLabel),
      options: labels,
      selected: year?.toString(),
    );
    if (picked == null) return;
    onChanged(int.tryParse(picked));
  }

  @override
  Widget build(BuildContext context) {
    final displayValue =
        year != null ? year.toString() : context.l10n.chooseOption;

    return _VehicleFieldCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPicker(context),
          child: Row(
            children: [
              _VehicleFieldLabel(label: context.l10n.yearLabel),
              const Spacer(),
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehiclePickerField extends StatefulWidget {
  const _VehiclePickerField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<_VehiclePickerField> createState() => _VehiclePickerFieldState();
}

class _VehiclePickerFieldState extends State<_VehiclePickerField> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allItems => ListingFormOptions.withOther(widget.items);

  bool get _showOtherField =>
      _otherExpanded ||
      ListingFormOptions.isCustomValue(widget.value, widget.items);

  String get _displayValue {
    final choose = context.l10n.chooseOption;
    if (_showOtherField) {
      return widget.value?.trim().isNotEmpty == true
          ? widget.value!.trim()
          : choose;
    }
    if (widget.value != null && widget.value!.isNotEmpty) {
      return step2AttributeLabel(widget.value!, context.l10n);
    }
    return choose;
  }

  @override
  void initState() {
    super.initState();
    _otherExpanded = ListingFormOptions.isCustomValue(
      widget.value,
      widget.items,
    );
    _otherController = TextEditingController(
      text: ListingFormOptions.isCustomValue(widget.value, widget.items)
          ? widget.value!.trim()
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant _VehiclePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final isCustom = ListingFormOptions.isCustomValue(
        widget.value,
        widget.items,
      );
      if (isCustom) _otherExpanded = true;
      final text = isCustom ? widget.value!.trim() : '';
      if (_otherController.text != text) {
        _otherController.text = text;
      }
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    final l10n = context.l10n;
    final picked = await showStep2PickerSheetForOptions(
      context: context,
      title: step2PickerSheetTitle(l10n, widget.label),
      options: step2AttributePickerOptions(_allItems, l10n),
      selectedValue: _showOtherField ? ListingFormOptions.other : widget.value,
    );
    if (!mounted || picked == null) return;

    if (picked == ListingFormOptions.other) {
      setState(() => _otherExpanded = true);
      _otherController.clear();
      widget.onChanged(null);
      return;
    }

    setState(() => _otherExpanded = false);
    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return _VehicleFieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openPicker,
              child: Row(
                children: [
                  _VehicleFieldLabel(label: widget.label),
                  const Spacer(),
                  Text(
                    _displayValue,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_showOtherField) ...[
            const SizedBox(height: 12),
            Step2OtherTextField(
              controller: _otherController,
              label: context.l10n.specifyValue,
              onChanged: (value) {
                final trimmed = value.trim();
                widget.onChanged(trimmed.isEmpty ? null : trimmed);
              },
            ),
          ],
        ],
      ),
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
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
            ),
          ),
        ),
      ),
    );
  }
}
