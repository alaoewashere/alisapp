import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../shared/models/tutoring_listing_metadata.dart';
import '../../constants/listing_form_options.dart';
import '../../constants/tutoring_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import 'step2_form_common.dart';

class Step2TutoringDetails extends ConsumerStatefulWidget {
  const Step2TutoringDetails({super.key});

  @override
  ConsumerState<Step2TutoringDetails> createState() =>
      _Step2TutoringDetailsState();
}

class _Step2TutoringDetailsState extends ConsumerState<Step2TutoringDetails> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final details = ref.read(postListingProvider).tutoringDetails;
    _priceController = TextEditingController(
      text: details.pricePerHour?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _update(
    TutoringListingMetadata Function(TutoringListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).tutoringDetails;
    ref.read(postListingProvider.notifier).updateTutoringDetails(
          update(current),
        );
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(postListingProvider).tutoringDetails;
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);

    return Step2FormShell(
      title: strings.tutoringDetailsTitle,
      children: [
        Step2SearchableDropdown(
          label: strings.subjectRequiredLabel,
          value: details.subject,
          items: TutoringListingOptions.subjects,
          onChanged: (v) => _update((d) => d.copyWith(subject: v)),
        ),
        Text(strings.studyStageRequiredLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2MultiChipSelector(
          options: TutoringListingOptions.stages,
          selected: details.stages,
          onToggle: (stage) =>
              ref.read(postListingProvider.notifier).toggleTutoringStage(stage),
          onOtherChanged: (custom) {
            _update(
              (d) => d.copyWith(
                stages: ListingFormOptions.replaceCustomInList(
                  selected: d.stages,
                  predefined: TutoringListingOptions.stages,
                  customValue: custom,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(strings.curriculumLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: TutoringListingOptions.curricula,
          selected: details.curriculum,
          onSelected: (v) => _update((d) => d.copyWith(curriculum: v)),
        ),
        const SizedBox(height: 12),
        Text(strings.teachingMethodRequiredLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: TutoringListingOptions.sessionTypes,
          selected: details.sessionType,
          onSelected: (v) => _update((d) => d.copyWith(sessionType: v)),
        ),
        const SizedBox(height: 12),
        Text(strings.acceptedGenderLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: TutoringListingOptions.genders,
          selected: details.gender,
          onSelected: (v) => _update((d) => d.copyWith(gender: v)),
        ),
        const SizedBox(height: 12),
        Step2IqdField(
          label: strings.pricePerHourRequiredLabel,
          controller: _priceController,
          onChanged: (v) {
            _update(
              (d) => v == null
                  ? d.copyWith(clearPricePerHour: true)
                  : d.copyWith(pricePerHour: v.round()),
            );
          },
        ),
        const SizedBox(height: 12),
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
        Step2LabeledDropdown(
          label: strings.educationQualificationLabel,
          value: details.qualifications,
          items: TutoringListingOptions.qualifications,
          onChanged: (v) => _update((d) => d.copyWith(qualifications: v)),
        ),
        const Step2NegotiableSwitch(),
      ],
    );
  }
}
