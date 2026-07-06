import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../shared/models/animal_listing_metadata.dart';
import '../../../../core/utils/animal_listing_utils.dart';
import '../../constants/animal_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import 'step2_form_common.dart';

class Step2AnimalDetails extends ConsumerStatefulWidget {
  const Step2AnimalDetails({super.key});

  @override
  ConsumerState<Step2AnimalDetails> createState() => _Step2AnimalDetailsState();
}

class _Step2AnimalDetailsState extends ConsumerState<Step2AnimalDetails> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final price = ref.read(postListingProvider).price;
    _priceController = TextEditingController(
      text: price != null ? price.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _update(AnimalListingMetadata Function(AnimalListingMetadata) update) {
    final current = ref.read(postListingProvider).animalDetails;
    ref.read(postListingProvider.notifier).updateAnimalDetails(update(current));
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(postListingProvider).animalDetails;
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);
    final animalType =
        deriveAnimalDetailsFromPath(ref.watch(postListingProvider).categoryPath)
            .animalType ??
        details.animalType;

    return Step2FormShell(
      title: strings.animalDetailsTitle,
      children: [
        Step2IntDropdown(
          label: strings.ageMonthsLabel,
          value: details.ageMonths,
          min: 1,
          max: 240,
          onChanged: (v) => _update(
            (d) => v == null
                ? d.copyWith(clearAgeMonths: true)
                : d.copyWith(ageMonths: v),
          ),
        ),
        Text(strings.genderLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: AnimalListingOptions.genders,
          selected: details.gender,
          onSelected: (v) => _update((d) => d.copyWith(gender: v)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.vaccinatedQuestion),
          value: details.vaccinated ?? false,
          onChanged: (v) => _update((d) => d.copyWith(vaccinated: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.hasDocumentsQuestion),
          value: details.hasPapers ?? false,
          onChanged: (v) => _update((d) => d.copyWith(hasPapers: v)),
        ),
        if (AnimalListingOptions.showTrainedToggle(animalType))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(strings.trainedQuestion),
            value: details.trained ?? false,
            onChanged: (v) => _update((d) => d.copyWith(trained: v)),
          ),
        Text(strings.colorLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: AnimalListingOptions.colors,
          selected: details.color,
          onSelected: (v) => _update((d) => d.copyWith(color: v)),
        ),
        const SizedBox(height: 12),
        Step2IqdField(
          label: strings.priceRequiredLabel,
          controller: _priceController,
          onChanged: (v) => notifier.updateField('price', v),
        ),
        const Step2NegotiableSwitch(),
      ],
    );
  }
}
