import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_governorates.dart';
import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../theme/app_form_fields.dart';
import '../../../../theme/app_text_styles.dart';
import '../../constants/listing_form_options.dart';
import '../../providers/edit_listing_form_mode.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import 'step2_title_description_fields.dart';

/// One selectable row in [showStep2PickerSheet].
class Step2PickerOption {
  const Step2PickerOption({required this.value, required this.label});

  final String value;
  final String label;
}

String step2PickerSheetTitle(String label) {
  final cleaned = label.replaceAll('*', '').trim();
  return 'اختر $cleaned';
}

/// iOS-style bottom sheet picker used across the post-listing flow.
Future<String?> showStep2PickerSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  String? selected,
  bool searchable = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _Step2PickerSheet(
      title: title,
      options: options,
      selected: selected,
      searchable: searchable,
    ),
  );
}

/// Value/label variant (e.g. governorate slug → Arabic name).
Future<String?> showStep2PickerSheetForOptions({
  required BuildContext context,
  required String title,
  required List<Step2PickerOption> options,
  String? selectedValue,
  bool searchable = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _Step2PickerSheet(
      title: title,
      options: options.map((o) => o.label).toList(),
      optionValues: options.map((o) => o.value).toList(),
      selected: _selectedLabelForValue(options, selectedValue),
      searchable: searchable,
      returnValue: true,
    ),
  );
}

String? _selectedLabelForValue(
  List<Step2PickerOption> options,
  String? selectedValue,
) {
  if (selectedValue == null) return null;
  for (final option in options) {
    if (option.value == selectedValue) return option.label;
  }
  return null;
}

class _Step2PickerSheet extends StatefulWidget {
  const _Step2PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
    this.optionValues,
    this.searchable = false,
    this.returnValue = false,
  });

  final String title;
  final List<String> options;
  final List<String>? optionValues;
  final String? selected;
  final bool searchable;
  final bool returnValue;

  @override
  State<_Step2PickerSheet> createState() => _Step2PickerSheetState();
}

class _Step2PickerSheetState extends State<_Step2PickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> get _visibleIndexes {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(widget.options.length, (index) => index);
    }
    return [
      for (var i = 0; i < widget.options.length; i++)
        if (widget.options[i].toLowerCase().contains(q)) i,
    ];
  }

  String _valueForIndex(int index) {
    final values = widget.optionValues;
    if (values != null && values.length == widget.options.length) {
      return values[index];
    }
    return widget.options[index];
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
    final indexes = _visibleIndexes;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: AppColors.fieldCarbon,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (widget.searchable) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.input,
                      decoration: InputDecoration(
                        hintText: 'بحث...',
                        hintStyle: AppTextStyles.hint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ],
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: bottomInset + 8),
                    itemCount: indexes.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFE5E5EA),
                    ),
                    itemBuilder: (context, listIndex) {
                      final index = indexes[listIndex];
                      final label = widget.options[index];
                      final isSelected = label == widget.selected;
                      return InkWell(
                        onTap: () {
                          final result = widget.returnValue
                              ? _valueForIndex(index)
                              : label;
                          Navigator.pop(context, result);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Step2PickerTriggerRow extends StatelessWidget {
  const Step2PickerTriggerRow({
    super.key,
    required this.label,
    required this.displayValue,
    required this.onTap,
  });

  final String label;
  final String displayValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  displayValue,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
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

class Step2FormShell extends ConsumerWidget {
  const Step2FormShell({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final isEdit = ref.watch(isEditListingFormProvider);

    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isEdit)
            Text(title, style: AppTextStyles.headline.copyWith(fontSize: 20)),
          if (state.categoryPath.isNotEmpty && !isEdit) ...[
            if (!isEdit) const SizedBox(height: 12),
            CategoryPathBreadcrumb(
              path: state.categoryPath,
              onTap: isEdit
                  ? null
                  : () {
                      notifier.resetCategoryDrill();
                      notifier.goToStep(1);
                    },
              onSegmentTap: isEdit ? null : null,
            ),
          ],
          if (!isEdit) const SizedBox(height: 16),
          const Step2TitleDescriptionFields(),
          ...children,
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );

    if (isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: content,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}

class Step2OtherTextField extends StatelessWidget {
  const Step2OtherTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = 'حدد القيمة',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: AppTextStyles.input,
        decoration: AppFormDecorations.underline(hintText: label),
        onChanged: onChanged,
      ),
    );
  }
}

class Step2PillChip extends StatelessWidget {
  const Step2PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.volt : AppColors.fieldCarbon,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.volt : AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.volt.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, color: AppColors.canvas, size: 13),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.subheading.copyWith(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.canvas : AppColors.pureWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Step2ChipSelector extends StatefulWidget {
  const Step2ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.includeOther = true,
    this.otherFieldLabel = 'حدد القيمة',
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool includeOther;
  final String otherFieldLabel;

  @override
  State<Step2ChipSelector> createState() => _Step2ChipSelectorState();
}

class _Step2ChipSelectorState extends State<Step2ChipSelector> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allOptions => widget.includeOther
      ? ListingFormOptions.withOther(widget.options)
      : widget.options;

  bool get _showOtherField =>
      widget.includeOther &&
      (_otherExpanded ||
          ListingFormOptions.isCustomValue(widget.selected, widget.options));

  String? get _chipSelection {
    if (_otherExpanded ||
        ListingFormOptions.isCustomValue(widget.selected, widget.options)) {
      return ListingFormOptions.other;
    }
    return widget.selected;
  }

  @override
  void initState() {
    super.initState();
    _otherExpanded = ListingFormOptions.isCustomValue(
      widget.selected,
      widget.options,
    );
    _otherController = TextEditingController(
      text: ListingFormOptions.isCustomValue(widget.selected, widget.options)
          ? widget.selected!.trim()
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant Step2ChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      final isCustom = ListingFormOptions.isCustomValue(
        widget.selected,
        widget.options,
      );
      if (isCustom) _otherExpanded = true;
      final text = isCustom ? widget.selected!.trim() : '';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allOptions.map((option) {
            return Step2PillChip(
              label: option,
              selected: _chipSelection == option,
              onTap: () {
                if (option == ListingFormOptions.other) {
                  setState(() => _otherExpanded = true);
                  _otherController.clear();
                  widget.onSelected(null);
                  return;
                }
                setState(() => _otherExpanded = false);
                widget.onSelected(option);
              },
            );
          }).toList(),
        ),
        if (_showOtherField)
          Step2OtherTextField(
            controller: _otherController,
            label: widget.otherFieldLabel,
            onChanged: (value) {
              final trimmed = value.trim();
              widget.onSelected(trimmed.isEmpty ? null : trimmed);
            },
          ),
      ],
    );
  }
}

class Step2MultiChipSelector extends StatefulWidget {
  const Step2MultiChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.onOtherChanged,
    this.includeOther = true,
    this.otherFieldLabel = 'حدد القيمة',
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<String?>? onOtherChanged;
  final bool includeOther;
  final String otherFieldLabel;

  @override
  State<Step2MultiChipSelector> createState() => _Step2MultiChipSelectorState();
}

class _Step2MultiChipSelectorState extends State<Step2MultiChipSelector> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allOptions => widget.includeOther
      ? ListingFormOptions.withOther(widget.options)
      : widget.options;

  bool get _otherSelected =>
      _otherExpanded ||
      ListingFormOptions.hasCustomInList(widget.selected, widget.options);

  @override
  void initState() {
    super.initState();
    final custom = ListingFormOptions.customValueInList(
      widget.selected,
      widget.options,
    );
    _otherExpanded = custom != null;
    _otherController = TextEditingController(text: custom ?? '');
  }

  @override
  void didUpdateWidget(covariant Step2MultiChipSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      final custom = ListingFormOptions.customValueInList(
        widget.selected,
        widget.options,
      );
      _otherExpanded = custom != null || _otherExpanded;
      final text = custom ?? '';
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

  void _toggleOther(bool selected) {
    setState(() => _otherExpanded = selected);
    if (!selected) {
      _otherController.clear();
      widget.onOtherChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allOptions.map((option) {
            if (option == ListingFormOptions.other) {
              return Step2PillChip(
                label: option,
                selected: _otherSelected,
                onTap: () => _toggleOther(!_otherSelected),
              );
            }
            final isSelected = widget.selected.contains(option);
            return Step2PillChip(
              label: option,
              selected: isSelected,
              onTap: () => widget.onToggle(option),
            );
          }).toList(),
        ),
        if (_otherSelected && widget.onOtherChanged != null)
          Step2OtherTextField(
            controller: _otherController,
            label: widget.otherFieldLabel,
            onChanged: (value) {
              final trimmed = value.trim();
              widget.onOtherChanged!(trimmed.isEmpty ? null : trimmed);
            },
          ),
      ],
    );
  }
}

class Step2LabeledDropdown extends StatefulWidget {
  const Step2LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.includeOther = true,
    this.otherFieldLabel = 'حدد القيمة',
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool includeOther;
  final String otherFieldLabel;

  @override
  State<Step2LabeledDropdown> createState() => _Step2LabeledDropdownState();
}

class _Step2LabeledDropdownState extends State<Step2LabeledDropdown> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allItems => widget.includeOther
      ? ListingFormOptions.withOther(widget.items)
      : widget.items;

  bool get _showOtherField =>
      widget.includeOther &&
      (_otherExpanded ||
          ListingFormOptions.isCustomValue(widget.value, widget.items));

  String get _displayValue {
    if (_showOtherField)
      return widget.value?.trim().isNotEmpty == true
          ? widget.value!.trim()
          : 'اختر';
    if (widget.value != null && widget.value!.isNotEmpty) {
      return widget.value!;
    }
    return 'اختر';
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
  void didUpdateWidget(covariant Step2LabeledDropdown oldWidget) {
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
    final picked = await showStep2PickerSheet(
      context: context,
      title: step2PickerSheetTitle(widget.label),
      options: _allItems,
      selected: _showOtherField ? ListingFormOptions.other : widget.value,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Step2PickerTriggerRow(
            label: widget.label,
            displayValue: _displayValue,
            onTap: _openPicker,
          ),
          if (_showOtherField)
            Step2OtherTextField(
              controller: _otherController,
              label: widget.otherFieldLabel,
              onChanged: (value) {
                final trimmed = value.trim();
                widget.onChanged(trimmed.isEmpty ? null : trimmed);
              },
            ),
        ],
      ),
    );
  }
}

class Step2SearchableDropdown extends StatefulWidget {
  const Step2SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.includeOther = true,
    this.otherFieldLabel = 'حدد القيمة',
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool includeOther;
  final String otherFieldLabel;

  @override
  State<Step2SearchableDropdown> createState() =>
      _Step2SearchableDropdownState();
}

class _Step2SearchableDropdownState extends State<Step2SearchableDropdown> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allItems => widget.includeOther
      ? ListingFormOptions.withOther(widget.items)
      : widget.items;

  bool get _showOtherField =>
      widget.includeOther &&
      (_otherExpanded ||
          ListingFormOptions.isCustomValue(widget.value, widget.items));

  String get _displayValue {
    if (widget.value == null || widget.value!.isEmpty) return 'اختر';
    return widget.value!;
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
  void didUpdateWidget(covariant Step2SearchableDropdown oldWidget) {
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
    final picked = await showStep2PickerSheet(
      context: context,
      title: step2PickerSheetTitle(widget.label),
      options: _allItems,
      selected: _showOtherField ? ListingFormOptions.other : widget.value,
      searchable: true,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Step2PickerTriggerRow(
            label: widget.label,
            displayValue: _displayValue,
            onTap: _openPicker,
          ),
          if (_showOtherField)
            Step2OtherTextField(
              controller: _otherController,
              label: widget.otherFieldLabel,
              onChanged: (value) {
                final trimmed = value.trim();
                widget.onChanged(trimmed.isEmpty ? null : trimmed);
              },
            ),
        ],
      ),
    );
  }
}

class Step2GovernoratePicker extends StatelessWidget {
  const Step2GovernoratePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  static final _options = iraqiGovernorates
      .map((g) => Step2PickerOption(value: g.slug, label: g.nameAr))
      .toList();

  String? get _displayLabel {
    if (value == null) return null;
    for (final option in _options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showStep2PickerSheetForOptions(
      context: context,
      title: step2PickerSheetTitle('المحافظة'),
      options: _options,
      selectedValue: value,
      searchable: true,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Step2PickerTriggerRow(
        label: 'المحافظة *',
        displayValue: _displayLabel ?? 'اختر',
        onTap: () => _openPicker(context),
      ),
    );
  }
}

class Step2IqdField extends StatelessWidget {
  const Step2IqdField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<double?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [appDigitsOnly()],
      textDirection: TextDirection.ltr,
      style: AppTextStyles.price.copyWith(fontSize: 15),
      decoration: AppFormDecorations.underline(
        hintText: label,
        suffixText: 'د.ع',
      ),
      onChanged: (v) {
        if (onChanged == null) return;
        onChanged!(double.tryParse(v.replaceAll(',', '')));
      },
    );
  }
}

class Step2IntDropdown extends StatelessWidget {
  const Step2IntDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.includeOther = false,
  });

  final String label;
  final int? value;
  final int min;
  final int max;
  final ValueChanged<int?> onChanged;
  final bool includeOther;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(max - min + 1, (i) => (min + i).toString());
    return Step2LabeledDropdown(
      label: label,
      value: value?.toString(),
      items: items,
      includeOther: includeOther,
      onChanged: (v) => onChanged(v == null ? null : int.tryParse(v)),
    );
  }
}

class Step2NegotiableSwitch extends ConsumerWidget {
  const Step2NegotiableSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('قابل للتفاوض'),
      value: state.isNegotiable,
      onChanged: (v) => notifier.updateField('isNegotiable', v),
    );
  }
}

/// Grid tile picker with optional custom value when [ListingFormOptions.other] is chosen.
class Step2GridWithOther extends StatefulWidget {
  const Step2GridWithOther({
    super.key,
    required this.label,
    required this.options,
    required this.icons,
    required this.value,
    required this.onChanged,
    this.otherFieldLabel = 'حدد النوع',
    this.crossAxisCount = 3,
  });

  final String label;
  final List<String> options;
  final Map<String, IconData> icons;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String otherFieldLabel;
  final int crossAxisCount;

  @override
  State<Step2GridWithOther> createState() => _Step2GridWithOtherState();
}

class _Step2GridWithOtherState extends State<Step2GridWithOther> {
  late final TextEditingController _otherController;
  bool _otherExpanded = false;

  List<String> get _allOptions => ListingFormOptions.withOther(widget.options);

  bool get _isCustom =>
      ListingFormOptions.isCustomValue(widget.value, widget.options);

  String? get _selectedTile {
    if (_otherExpanded || _isCustom) return ListingFormOptions.other;
    return widget.value;
  }

  bool get _showOtherField => _otherExpanded || _isCustom;

  @override
  void initState() {
    super.initState();
    _otherExpanded = _isCustom;
    _otherController = TextEditingController(
      text: _isCustom ? widget.value!.trim() : '',
    );
  }

  @override
  void didUpdateWidget(covariant Step2GridWithOther oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (_isCustom) _otherExpanded = true;
      final text = _isCustom ? widget.value!.trim() : '';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: widget.crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: _allOptions.map((type) {
            final selected = _selectedTile == type;
            final icon = widget.icons[type] ?? Icons.more_horiz;
            return Material(
              color: selected ? AppColors.volt : AppColors.fieldCarbon,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  if (type == ListingFormOptions.other) {
                    setState(() => _otherExpanded = true);
                    _otherController.clear();
                    widget.onChanged(null);
                    return;
                  }
                  setState(() => _otherExpanded = false);
                  widget.onChanged(type);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.volt : AppColors.glassBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: selected
                            ? AppColors.canvas
                            : AppColors.pureWhite,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected
                              ? AppColors.canvas
                              : AppColors.pureWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_showOtherField)
          Step2OtherTextField(
            controller: _otherController,
            label: widget.otherFieldLabel,
            onChanged: (value) {
              final trimmed = value.trim();
              widget.onChanged(trimmed.isEmpty ? null : trimmed);
            },
          ),
      ],
    );
  }
}
