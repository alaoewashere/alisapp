import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../theme/app_form_fields.dart';
import '../../../../theme/app_text_styles.dart';
import '../../providers/post_listing_provider.dart';

/// Title + description fields at the top of every Step 2 details form.
class Step2TitleDescriptionFields extends ConsumerStatefulWidget {
  const Step2TitleDescriptionFields({super.key});

  @override
  ConsumerState<Step2TitleDescriptionFields> createState() =>
      _Step2TitleDescriptionFieldsState();
}

class _Step2TitleDescriptionFieldsState
    extends ConsumerState<Step2TitleDescriptionFields> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(postListingProvider);
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final strings = ref.watch(appLocalizationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldGroupLabel(label: strings.listingTitleLabel, required: true),
        AppFormFieldGroup(
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              minLines: 1,
              maxLines: 2,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.input,
              decoration: AppFormDecorations.underline(
                hintText: strings.listingTitleHint,
              ).copyWith(counterText: ''),
              onChanged: (v) => notifier.updateField('title', v),
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
        AppFieldCharCounter(current: state.title.length, max: 100),
        const SizedBox(height: 24),
        AppFieldGroupLabel(
          label: strings.listingDescriptionLabel,
          optional: true,
          optionalLabel: strings.optionalLabel,
        ),
        AppFormFieldGroup(
          children: [
            TextFormField(
              controller: _descriptionController,
              maxLength: 2000,
              minLines: 5,
              maxLines: 10,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.body.copyWith(fontSize: 15),
              decoration: AppFormDecorations.underline(
                hintText: strings.listingDescriptionHint,
                alignLabelWithHint: true,
              ).copyWith(counterText: ''),
              onChanged: (v) => notifier.updateField('description', v),
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
        AppFieldCharCounter(current: state.description.length, max: 2000),
        AppListingFormSectionDivider(label: strings.listingDetailsTitle),
      ],
    );
  }
}
