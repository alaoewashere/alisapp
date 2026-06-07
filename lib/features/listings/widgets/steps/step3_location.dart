import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/maps_config.dart';
import '../../../../core/constants/app_governorates.dart';
import '../../providers/post_listing_provider.dart';
import '../map_picker_sheet.dart';

class Step3Location extends ConsumerStatefulWidget {
  const Step3Location({super.key});

  @override
  ConsumerState<Step3Location> createState() => _Step3LocationState();
}

class _Step3LocationState extends ConsumerState<Step3Location> {
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(
      text: ref.read(postListingProvider).city,
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final state = ref.read(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);

    try {
      if (!MapsConfig.isConfigured) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'الخريطة غير مهيّأة. أضف GOOGLE_MAPS_API_KEY أو استخدم المحافظة والمدينة.',
            ),
          ),
        );
        return;
      }

      final result = await showModalBottomSheet<(double, double)>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => MapPickerSheet(
          initialLat: state.latitude,
          initialLng: state.longitude,
        ),
      );

      if (result != null) {
        notifier.updateField('latitude', result.$1);
        notifier.updateField('longitude', result.$2);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذّر فتح الخريطة. يمكنك المتابعة باختيار المحافظة والمدينة فقط.',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
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
            DropdownButtonFormField<String>(
              initialValue: state.governorate,
              decoration: const InputDecoration(labelText: 'المحافظة *'),
              items: iraqiGovernorates
                  .map(
                    (g) => DropdownMenuItem(
                      value: g.slug,
                      child: Text(g.nameAr),
                    ),
                  )
                  .toList(),
              onChanged: (v) => notifier.updateField('governorate', v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(labelText: 'المدينة *'),
              onChanged: (v) => notifier.updateField('city', v),
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
              const SizedBox(height: 8),
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
      ),
    );
  }
}
