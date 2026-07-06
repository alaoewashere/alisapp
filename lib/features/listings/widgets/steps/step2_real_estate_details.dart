import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../shared/models/real_estate_listing_metadata.dart';
import '../../constants/listing_form_options.dart';
import '../../constants/real_estate_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import 'step2_form_common.dart';
import 'step2_title_description_fields.dart';

class Step2RealEstateDetails extends ConsumerStatefulWidget {
  const Step2RealEstateDetails({super.key});

  @override
  ConsumerState<Step2RealEstateDetails> createState() =>
      _Step2RealEstateDetailsState();
}

class _Step2RealEstateDetailsState extends ConsumerState<Step2RealEstateDetails> {
  late final TextEditingController _areaController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final details = ref.read(postListingProvider).realEstateDetails;
    final price = ref.read(postListingProvider).price;
    _areaController = TextEditingController(
      text: details.areaSqm?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: price != null ? price.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _update(
    RealEstateListingMetadata Function(RealEstateListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).realEstateDetails;
    ref.read(postListingProvider.notifier).updateRealEstateDetails(
          update(current),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final details = state.realEstateDetails;
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.realEstateDetailsTitle,
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
            Step2LabeledDropdown(
              label: strings.propertyTypeRequiredLabel,
              value: details.propertyType,
              items: RealEstateListingOptions.propertyTypes,
              onChanged: (v) => _update((d) => d.copyWith(propertyType: v)),
            ),
            Text(strings.offerTypeRequiredLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Step2ChipSelector(
              options: RealEstateListingOptions.offerTypes,
              selected: details.offerType,
              onSelected: (v) => _update((d) => d.copyWith(offerType: v)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              inputFormatters: [appDigitsOnly()],
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: strings.areaSqmRequiredLabel,
                suffixText: strings.sqmUnit,
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                _update(
                  (d) => parsed == null
                      ? d.copyWith(clearAreaSqm: true)
                      : d.copyWith(areaSqm: parsed),
                );
              },
            ),
            const SizedBox(height: 12),
            Step2LabeledDropdown(
              label: strings.floorLabel,
              value: details.floor?.toString(),
              items: RealEstateListingOptions.floorOptions,
              onChanged: (v) {
                final parsed = int.tryParse(v ?? '');
                _update(
                  (d) => parsed == null
                      ? d.copyWith(clearFloor: true)
                      : d.copyWith(floor: parsed),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(strings.roomsCountLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Step2ChipSelector(
              options: RealEstateListingOptions.roomOptions,
              selected: details.rooms,
              onSelected: (v) => _update((d) => d.copyWith(rooms: v)),
            ),
            const SizedBox(height: 12),
            Text(strings.bathroomsCountLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Step2ChipSelector(
              options: RealEstateListingOptions.bathroomOptions,
              selected: details.bathrooms,
              onSelected: (v) => _update((d) => d.copyWith(bathrooms: v)),
            ),
            const SizedBox(height: 12),
            Step2LabeledDropdown(
              label: strings.buildingAgeYearsLabel,
              value: details.ageYears,
              items: RealEstateListingOptions.buildingAgeOptions,
              onChanged: (v) => _update((d) => d.copyWith(ageYears: v)),
            ),
            Step2LabeledDropdown(
              label: strings.finishingLabel,
              value: details.furnished,
              items: RealEstateListingOptions.furnishedOptions,
              onChanged: (v) => _update((d) => d.copyWith(furnished: v)),
            ),
            Step2LabeledDropdown(
              label: strings.deedTypeLabel,
              value: details.deedType,
              items: RealEstateListingOptions.deedTypeOptions,
              onChanged: (v) => _update((d) => d.copyWith(deedType: v)),
            ),
            const SizedBox(height: 8),
            Text(strings.featuresSectionTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Step2MultiChipSelector(
              options: RealEstateListingOptions.featureOptions,
              selected: details.features,
              onToggle: (feature) =>
                  notifier.toggleRealEstateFeature(feature),
              onOtherChanged: (custom) {
                _update(
                  (d) => d.copyWith(
                    features: ListingFormOptions.replaceCustomInList(
                      selected: d.features,
                      predefined: RealEstateListingOptions.featureOptions,
                      customValue: custom,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
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
