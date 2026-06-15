import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/job_listing_metadata.dart';
import '../../constants/job_listing_options.dart';
import '../../constants/listing_form_options.dart';
import '../../providers/post_listing_provider.dart';
import 'step2_form_common.dart';

class Step2JobDetails extends ConsumerStatefulWidget {
  const Step2JobDetails({super.key});

  @override
  ConsumerState<Step2JobDetails> createState() => _Step2JobDetailsState();
}

class _Step2JobDetailsState extends ConsumerState<Step2JobDetails> {
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;

  @override
  void initState() {
    super.initState();
    final details = ref.read(postListingProvider).jobDetails;
    _salaryMinController =
        TextEditingController(text: details.salaryMin?.toString() ?? '');
    _salaryMaxController =
        TextEditingController(text: details.salaryMax?.toString() ?? '');
  }

  @override
  void dispose() {
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  void _update(JobListingMetadata Function(JobListingMetadata) update) {
    final current = ref.read(postListingProvider).jobDetails;
    ref.read(postListingProvider.notifier).updateJobDetails(update(current));
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(postListingProvider).jobDetails;
    final theme = Theme.of(context);

    return Step2FormShell(
      title: 'تفاصيل الوظيفة',
      children: [
        Text('نوع الدوام *', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: JobListingOptions.jobTypes,
          selected: details.jobType,
          onSelected: (v) => _update((d) => d.copyWith(jobType: v)),
        ),
        const SizedBox(height: 12),
        Step2LabeledDropdown(
          label: 'القطاع *',
          value: details.sector,
          items: JobListingOptions.sectors,
          onChanged: (v) => _update((d) => d.copyWith(sector: v)),
        ),
        Text('الخبرة المطلوبة', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: JobListingOptions.experienceLevels,
          selected: details.experienceRequired,
          onSelected: (v) => _update((d) => d.copyWith(experienceRequired: v)),
        ),
        const SizedBox(height: 12),
        Text('المؤهل المطلوب', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: JobListingOptions.educationLevels,
          selected: details.educationRequired,
          onSelected: (v) => _update((d) => d.copyWith(educationRequired: v)),
        ),
        const SizedBox(height: 12),
        Text('تفضيل الجنس', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: JobListingOptions.genderPreferences,
          selected: details.genderPreference,
          onSelected: (v) => _update((d) => d.copyWith(genderPreference: v)),
        ),
        const SizedBox(height: 12),
        Text('نوع الراتب', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2ChipSelector(
          options: JobListingOptions.salaryTypes,
          selected: details.salaryType,
          onSelected: (v) => _update((d) => d.copyWith(salaryType: v)),
        ),
        const SizedBox(height: 12),
        Step2IqdField(
          label: 'الراتب الأدنى *',
          controller: _salaryMinController,
          onChanged: (v) {
            _update(
              (d) => v == null
                  ? d.copyWith(clearSalaryMin: true)
                  : d.copyWith(salaryMin: v.round()),
            );
          },
        ),
        const SizedBox(height: 12),
        Step2IqdField(
          label: 'الراتب الأعلى',
          controller: _salaryMaxController,
          onChanged: (v) {
            _update(
              (d) => v == null
                  ? d.copyWith(clearSalaryMax: true)
                  : d.copyWith(salaryMax: v.round()),
            );
          },
        ),
        const SizedBox(height: 12),
        Text('المزايا', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Step2MultiChipSelector(
          options: JobListingOptions.benefits,
          selected: details.benefits,
          onToggle: (benefit) =>
              ref.read(postListingProvider.notifier).toggleJobBenefit(benefit),
          onOtherChanged: (custom) {
            _update(
              (d) => d.copyWith(
                benefits: ListingFormOptions.replaceCustomInList(
                  selected: d.benefits,
                  predefined: JobListingOptions.benefits,
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
