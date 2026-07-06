import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_provider.dart';
import '../../../../core/utils/digit_input_formatter.dart';
import '../../../../shared/models/general_listing_metadata.dart';
import '../../constants/general_listing_options.dart';
import '../../providers/post_listing_provider.dart';
import '../category_path_breadcrumb.dart';
import 'step2_form_common.dart';
import 'step2_title_description_fields.dart';

class Step2GeneralMarketplaceDetails extends ConsumerStatefulWidget {
  const Step2GeneralMarketplaceDetails({super.key});

  @override
  ConsumerState<Step2GeneralMarketplaceDetails> createState() =>
      _Step2GeneralMarketplaceDetailsState();
}

class _Step2GeneralMarketplaceDetailsState
    extends ConsumerState<Step2GeneralMarketplaceDetails> {
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(postListingProvider);
    _brandController = TextEditingController(
      text: state.generalDetails.brand ?? '',
    );
    _priceController = TextEditingController(
      text: state.price != null ? state.price!.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _update(
    GeneralListingMetadata Function(GeneralListingMetadata) update,
  ) {
    final current = ref.read(postListingProvider).generalDetails;
    ref.read(postListingProvider.notifier).updateGeneralDetails(
          update(current),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final details = state.generalDetails;
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
            Text(strings.conditionRequiredLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Step2ChipSelector(
              options: GeneralListingOptions.itemConditions,
              selected: details.itemCondition,
              onSelected: (v) => _update((d) => d.copyWith(itemCondition: v)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _brandController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: strings.brandOptionalLabel,
              ),
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  _update((d) => d.copyWith(clearBrand: true));
                } else {
                  _update((d) => d.copyWith(brand: v));
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.exchangePossibleQuestion),
              value: details.exchangePossible ?? false,
              onChanged: (v) => _update((d) => d.copyWith(exchangePossible: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.deliveryAvailableQuestion),
              value: details.deliveryAvailable ?? false,
              onChanged: (v) {
                _update(
                  (d) => v
                      ? d.copyWith(deliveryAvailable: true)
                      : d.copyWith(
                          deliveryAvailable: false,
                          clearDeliveryCost: true,
                        ),
                );
              },
            ),
            if (details.deliveryAvailable == true) ...[
              Text(strings.deliveryCostRequiredLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Step2ChipSelector(
                options: GeneralListingOptions.deliveryCostOptions,
                selected: details.deliveryCost,
                onSelected: (v) => _update((d) => d.copyWith(deliveryCost: v)),
              ),
              const SizedBox(height: 12),
            ],
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
