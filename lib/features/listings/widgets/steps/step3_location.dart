import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/maps_config.dart';
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

    try {
      if (!MapsConfig.isConfigured) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'الخريطة غير مهيّأة. أضف GOOGLE_MAPS_API_KEY أو اختر المحافظة فقط.',
            ),
          ),
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
        notifier.updateField('latitude', result.latitude);
        notifier.updateField('longitude', result.longitude);
        notifier.updateField('locationAddress', result.address);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذّر فتح الخريطة. يمكنك المتابعة باختيار المحافظة فقط.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);

    final isEdit = ref.watch(isEditListingFormProvider);

    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الموقع',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Step2GovernoratePicker(
            value: state.governorate,
            onChanged: (v) => notifier.updateField('governorate', v),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openMapPicker,
            icon: const Icon(Icons.map_outlined),
            label: const Text('تحديد الموقع على الخريطة'),
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
                'الإحداثيات: ${state.latitude!.toStringAsFixed(5)}, ${state.longitude!.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall,
                textDirection: TextDirection.ltr,
              ),
            TextButton(
              onPressed: notifier.clearLocation,
              child: const Text('إزالة الموقع'),
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
