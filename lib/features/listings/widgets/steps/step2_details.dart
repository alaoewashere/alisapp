import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/listing_model.dart';
import '../../providers/post_listing_provider.dart';

class Step2Details extends ConsumerStatefulWidget {
  const Step2Details({super.key});

  @override
  ConsumerState<Step2Details> createState() => _Step2DetailsState();
}

class _Step2DetailsState extends ConsumerState<Step2Details> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(postListingProvider);
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
    _priceController = TextEditingController(
      text: state.price != null ? state.price!.round().toString() : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
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
              'تفاصيل الإعلان',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('نوع الإعلان *', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ListingType>(
              segments: ListingType.values
                  .map(
                    (type) => ButtonSegment(
                      value: type,
                      label: Text(type.labelAr),
                    ),
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
            TextField(
              controller: _titleController,
              maxLength: 100,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'عنوان الإعلان *',
                counterText: '',
              ),
              onChanged: (v) => notifier.updateField('title', v),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${state.title.length}/100',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLength: 2000,
              maxLines: 5,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'الوصف *',
                counterText: '',
                alignLabelWithHint: true,
              ),
              onChanged: (v) => notifier.updateField('description', v),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${state.description.length}/2000',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'السعر *',
                suffixText: 'د.ع',
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', ''));
                notifier.updateField('price', parsed);
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('قابل للتفاوض'),
              value: state.isNegotiable,
              onChanged: (v) => notifier.updateField('isNegotiable', v),
            ),
            const SizedBox(height: 8),
            Text('الحالة *', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ConditionToggle(
                    label: 'جديد',
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
                    label: 'مستعمل',
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
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor:
            selected ? colorScheme.primaryContainer : Colors.transparent,
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outline,
          width: selected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
    );
  }
}
