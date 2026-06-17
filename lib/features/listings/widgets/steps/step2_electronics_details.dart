import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../core/utils/electronics_listing_utils.dart';
import '../../../../shared/models/electronics_listing_metadata.dart';
import '../../constants/electronics_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import 'step2_form_common.dart';
import 'step2_title_description_fields.dart';

class Step2ElectronicsDetails extends ConsumerStatefulWidget {
  const Step2ElectronicsDetails({super.key});

  @override
  ConsumerState<Step2ElectronicsDetails> createState() =>
      _Step2ElectronicsDetailsState();
}

class _Step2ElectronicsDetailsState
    extends ConsumerState<Step2ElectronicsDetails> {
  late final TextEditingController _modelController;
  late final TextEditingController _batteryController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(postListingProvider);
    final details = state.electronicsDetails;
    _modelController = TextEditingController(text: details.model ?? '');
    _batteryController =
        TextEditingController(text: details.batteryHealth ?? '');
    _priceController = TextEditingController(
      text: state.price != null ? state.price!.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _modelController.dispose();
    _batteryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _update(
    ElectronicsListingMetadata Function(ElectronicsListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).electronicsDetails;
    ref.read(postListingProvider.notifier).updateElectronicsDetails(
          update(current),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final kind = electronicsFormKind(state.categoryPath);
    final details = state.electronicsDetails;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              electronicsFormTitle(kind),
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
            ...switch (kind) {
              ElectronicsFormKind.phone => _phoneFields(details, theme),
              ElectronicsFormKind.laptop => _laptopFields(details, theme),
              ElectronicsFormKind.tv => _tvFields(details, theme),
              ElectronicsFormKind.none => const <Widget>[],
            },
            const SizedBox(height: 24),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [appDigitsOnly()],
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

  List<Widget> _brandModelFields(
    ElectronicsListingMetadata details,
    List<String> brandOptions,
  ) {
    final brands = {
      ...brandOptions,
      if (details.brand != null && details.brand!.isNotEmpty) details.brand!,
    }.toList();

    return [
      Step2LabeledDropdown(
        label: 'الماركة',
        value: details.brand,
        items: brands,
        onChanged: (v) => _update((d) => d.copyWith(brand: v)),
      ),
      TextField(
        controller: _modelController,
        decoration: const InputDecoration(labelText: 'الموديل'),
        onChanged: (v) => _update((d) => d.copyWith(model: v)),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _phoneFields(
    ElectronicsListingMetadata details,
    ThemeData theme,
  ) {
    return [
      ..._brandModelFields(details, ElectronicsListingOptions.phoneBrands),
      Step2LabeledDropdown(
        label: 'التخزين',
        value: details.storage,
        items: ElectronicsListingOptions.storageOptions,
        onChanged: (v) => _update((d) => d.copyWith(storage: v)),
      ),
      Step2LabeledDropdown(
        label: 'الرام',
        value: details.ram,
        items: ElectronicsListingOptions.phoneRamOptions,
        onChanged: (v) => _update((d) => d.copyWith(ram: v)),
      ),
      Step2LabeledDropdown(
        label: 'اللون',
        value: details.color,
        items: ElectronicsListingOptions.phoneColors,
        onChanged: (v) => _update((d) => d.copyWith(color: v)),
      ),
      Text('الحالة *', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Step2ChipSelector(
        options: ElectronicsListingOptions.phoneConditions,
        selected: details.condition,
        onSelected: (v) => _update((d) => d.copyWith(condition: v)),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _batteryController,
        keyboardType: TextInputType.number,
        inputFormatters: [appDigitsOnly()],
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          labelText: 'صحة البطارية',
          suffixText: '%',
        ),
        onChanged: (v) {
          if (v.trim().isEmpty) {
            _update((d) => d.copyWith(clearBatteryHealth: true));
          } else {
            _update((d) => d.copyWith(batteryHealth: '$v%'));
          }
        },
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('مع العلبة'),
        value: details.hasBox ?? false,
        onChanged: (v) => _update((d) => d.copyWith(hasBox: v)),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('مع الشاحن'),
        value: details.hasCharger ?? false,
        onChanged: (v) => _update((d) => d.copyWith(hasCharger: v)),
      ),
      Step2LabeledDropdown(
        label: 'الضمان',
        value: details.warranty,
        items: ElectronicsListingOptions.warrantyOptions,
        onChanged: (v) => _update((d) => d.copyWith(warranty: v)),
      ),
    ];
  }

  List<Widget> _laptopFields(
    ElectronicsListingMetadata details,
    ThemeData theme,
  ) {
    return [
      ..._brandModelFields(details, ElectronicsListingOptions.laptopBrands),
      Step2LabeledDropdown(
        label: 'المعالج',
        value: details.processor,
        items: ElectronicsListingOptions.processorOptions,
        onChanged: (v) => _update((d) => d.copyWith(processor: v)),
      ),
      Step2LabeledDropdown(
        label: 'الرام',
        value: details.ram,
        items: ElectronicsListingOptions.laptopRamOptions,
        onChanged: (v) => _update((d) => d.copyWith(ram: v)),
      ),
      Step2LabeledDropdown(
        label: 'التخزين',
        value: details.storage,
        items: ElectronicsListingOptions.laptopStorageOptions,
        onChanged: (v) => _update((d) => d.copyWith(storage: v)),
      ),
      Step2LabeledDropdown(
        label: 'حجم الشاشة (بوصة)',
        value: details.screenSize,
        items: ElectronicsListingOptions.laptopScreenSizes,
        onChanged: (v) => _update((d) => d.copyWith(screenSize: v)),
      ),
      Text('الحالة *', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Step2ChipSelector(
        options: ElectronicsListingOptions.laptopConditions,
        selected: details.condition,
        onSelected: (v) => _update((d) => d.copyWith(condition: v)),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('مع العلبة'),
        value: details.hasBox ?? false,
        onChanged: (v) => _update((d) => d.copyWith(hasBox: v)),
      ),
    ];
  }

  List<Widget> _tvFields(
    ElectronicsListingMetadata details,
    ThemeData theme,
  ) {
    return [
      ..._brandModelFields(details, ElectronicsListingOptions.tvBrands),
      Step2LabeledDropdown(
        label: 'حجم الشاشة (بوصة)',
        value: details.screenSize,
        items: ElectronicsListingOptions.tvScreenSizes,
        onChanged: (v) => _update((d) => d.copyWith(screenSize: v)),
      ),
      Step2LabeledDropdown(
        label: 'الدقة',
        value: details.resolution,
        items: ElectronicsListingOptions.resolutionOptions,
        onChanged: (v) => _update((d) => d.copyWith(resolution: v)),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('سمارت TV'),
        value: details.smart ?? false,
        onChanged: (v) => _update((d) => d.copyWith(smart: v)),
      ),
      Text('الحالة *', style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Step2ChipSelector(
        options: ElectronicsListingOptions.tvConditions,
        selected: details.condition,
        onSelected: (v) => _update((d) => d.copyWith(condition: v)),
      ),
      const SizedBox(height: 12),
    ];
  }
}
