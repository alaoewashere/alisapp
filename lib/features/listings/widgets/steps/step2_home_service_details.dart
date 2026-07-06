import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../shared/models/home_service_listing_metadata.dart';
import '../../constants/home_service_listing_options.dart';
import '../../constants/listing_form_options.dart';
import '../../providers/post_listing_provider.dart';
import 'step2_form_common.dart';

class Step2HomeServiceDetails extends ConsumerStatefulWidget {
  const Step2HomeServiceDetails({super.key});

  @override
  ConsumerState<Step2HomeServiceDetails> createState() =>
      _Step2HomeServiceDetailsState();
}

class _Step2HomeServiceDetailsState
    extends ConsumerState<Step2HomeServiceDetails> {
  late final TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    final details = ref.read(postListingProvider).homeServiceDetails;
    _salaryController = TextEditingController(
      text: details.salaryExpected?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  void _update(
    HomeServiceListingMetadata Function(HomeServiceListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).homeServiceDetails;
    ref.read(postListingProvider.notifier).updateHomeServiceDetails(
          update(current),
        );
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(postListingProvider).homeServiceDetails;
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);

    return Step2FormShell(
      title: strings.serviceDetailsTitle,
      children: [
        Text(strings.genderLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: HomeServiceListingOptions.genders,
          selected: details.gender,
          onSelected: (v) => _update((d) => d.copyWith(gender: v)),
        ),
        const SizedBox(height: 12),
        Text(strings.nationalityLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: HomeServiceListingOptions.nationalities,
          selected: details.nationality,
          onSelected: (v) => _update((d) => d.copyWith(nationality: v)),
        ),
        const SizedBox(height: 12),
        Text(strings.workHoursRequiredLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: HomeServiceListingOptions.availabilityOptions,
          selected: details.availability,
          onSelected: (v) => _update((d) => d.copyWith(availability: v)),
        ),
        const SizedBox(height: 12),
        Step2IntDropdown(
          label: strings.weekDaysLabel,
          value: details.daysPerWeek,
          min: 1,
          max: 7,
          onChanged: (v) => _update(
            (d) => v == null
                ? d.copyWith(clearDaysPerWeek: true)
                : d.copyWith(daysPerWeek: v),
          ),
        ),
        Step2IntDropdown(
          label: strings.yearsExperienceLabel,
          value: details.experienceYears,
          min: 0,
          max: 40,
          onChanged: (v) => _update(
            (d) => v == null
                ? d.copyWith(clearExperienceYears: true)
                : d.copyWith(experienceYears: v),
          ),
        ),
        Step2IqdField(
          label: strings.expectedSalaryRequiredLabel,
          controller: _salaryController,
          onChanged: (v) {
            _update(
              (d) => v == null
                  ? d.copyWith(clearSalaryExpected: true)
                  : d.copyWith(salaryExpected: v.round()),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(strings.languagesSectionTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2MultiChipSelector(
          options: HomeServiceListingOptions.languages,
          selected: details.languages,
          onToggle: (lang) => ref
              .read(postListingProvider.notifier)
              .toggleHomeServiceLanguage(lang),
          onOtherChanged: (custom) {
            _update(
              (d) => d.copyWith(
                languages: ListingFormOptions.replaceCustomInList(
                  selected: d.languages,
                  predefined: HomeServiceListingOptions.languages,
                  customValue: custom,
                ),
              ),
            );
          },
        ),
        const Step2NegotiableSwitch(),
      ],
    );
  }
}
