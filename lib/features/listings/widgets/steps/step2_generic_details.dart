import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/l10n_provider.dart';
import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../theme/app_form_fields.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../shared/models/listing_model.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import 'step2_title_description_fields.dart';

class Step2GenericDetails extends ConsumerStatefulWidget {
  const Step2GenericDetails({super.key});

  @override
  ConsumerState<Step2GenericDetails> createState() =>
      _Step2GenericDetailsState();
}

class _Step2GenericDetailsState extends ConsumerState<Step2GenericDetails> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(postListingProvider);
    _priceController = TextEditingController(
      text: state.price != null ? state.price!.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
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
              strings.listingDetailsTitle,
              style: AppTextStyles.headline.copyWith(fontSize: 20),
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
            Text(strings.listingTypeLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ListingType>(
              segments: ListingType.values
                  .map(
                    (type) =>
                        ButtonSegment(value: type, label: Text(type.labelAr)),
                  )
                  .toList(),
              selected: {state.listingType},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  notifier.updateField('listingType', selected.first);
                }
              },
            ),
            const SizedBox(height: 16),
            AppFieldGroupLabel(label: strings.priceLabel, required: true),
            AppFormFieldGroup(
              children: [
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [appThousands()],
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                  decoration: AppFormDecorations.underline(
                    hintText: '0',
                    suffixText: strings.currencyIqd,
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.replaceAll(',', ''));
                    notifier.updateField('price', parsed);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.negotiable),
              value: state.isNegotiable,
              onChanged: (v) => notifier.updateField('isNegotiable', v),
            ),
            const SizedBox(height: 8),
            Text(strings.conditionLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ConditionToggle(
                    label: strings.conditionNew,
                    selected: state.condition == ListingCondition.newItem,
                    onTap: () => notifier.updateField(
                      'condition',
                      ListingCondition.newItem,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ConditionToggle(
                    label: strings.conditionUsed,
                    selected: state.condition == ListingCondition.used,
                    onTap: () => notifier.updateField(
                      'condition',
                      ListingCondition.used,
                    ),
                  ),
                ),
              ],
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

class _ConditionToggle extends StatelessWidget {
  const _ConditionToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.volt : AppColors.fieldCarbon,
        side: BorderSide(
          color: selected ? AppColors.volt : AppColors.glassBorder,
          width: selected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? AppColors.canvas : AppColors.pureWhite,
        ),
      ),
    );
  }
}
