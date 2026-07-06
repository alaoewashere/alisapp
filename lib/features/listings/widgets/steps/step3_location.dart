import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/maps_config.dart';
import '../../../../core/l10n/l10n_provider.dart';
import '../../../../core/utils/map_geocoding_service.dart';
import '../../providers/edit_listing_form_mode.dart';
import '../../providers/post_listing_provider.dart';
import '../map_picker_sheet.dart';
import 'step2_form_common.dart';

class Step3Location extends ConsumerStatefulWidget {
  const Step3Location({super.key});

  @override
  ConsumerState<Step3Location> createState() => _Step3LocationState();
}

class _Step3LocationState extends ConsumerState<Step3Location> {
  Future<void> _openMapPicker() async {
    final state = ref.read(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final strings = ref.read(appLocalizationsProvider);

    try {
      if (!MapsConfig.isConfigured) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.mapNotConfigured)),
        );
        return;
      }

      final result = await showModalBottomSheet<MapPickerResult>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => MapPickerSheet(
          initialLat: state.latitude,
          initialLng: state.longitude,
        ),
      );

      if (result != null) {
        notifier.applyMapPickerResult(
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.address,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.mapOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final strings = ref.watch(appLocalizationsProvider);

    final isEdit = ref.watch(isEditListingFormProvider);

    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.locationLabel,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Step2GovernoratePicker(
            value: state.governorate,
            onChanged: (v) => notifier.updateField('governorate', v),
          ),
          Step2NeighborhoodPicker(
            governorateSlug: state.governorate,
            selectedSlug: notifier.selectedAreaSlug,
            onChanged: notifier.setAreaNameFromSlug,
          ),
          if (state.areaName != null && state.areaName!.trim().isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => notifier.setAreaNameFromSlug(null),
                child: Text(strings.removeArea),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openMapPicker,
            icon: const Icon(Icons.map_outlined),
            label: Text(strings.pickLocationOnMap),
          ),
          if (state.latitude != null && state.longitude != null) ...[
            const SizedBox(height: 12),
            if (state.locationAddress != null &&
                state.locationAddress!.trim().isNotEmpty)
              Text(
                state.locationAddress!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
              )
            else
              Text(
                strings.coordinatesLabel(
                  '${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                ),
                style: theme.textTheme.bodySmall,
                textDirection: TextDirection.ltr,
              ),
            if (state.areaName != null && state.areaName!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.areaNameLocked
                      ? strings.selectedAreaLabel(state.areaName!)
                      : strings.suggestedAreaLabel(state.areaName!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: state.areaNameLocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            TextButton(
              onPressed: notifier.clearLocation,
              child: Text(strings.removeLocation),
            ),
          ],
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
