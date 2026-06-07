import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_governorates.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/listing_model.dart';
import '../../providers/post_listing_provider.dart';

class Step5Review extends ConsumerStatefulWidget {
  const Step5Review({
    super.key,
    required this.onPublish,
    required this.onSaveDraft,
  });

  final VoidCallback onPublish;
  final VoidCallback onSaveDraft;

  @override
  ConsumerState<Step5Review> createState() => _Step5ReviewState();
}

class _Step5ReviewState extends ConsumerState<Step5Review> {
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);
    final parent = state.selectedCategory;
    final sub = state.selectedSubcategory;
    final categoryLabel = sub != null && parent != null
        ? '${parent.nameAr} > ${sub.nameAr}'
        : (state.effectiveCategory?.nameAr ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'مراجعة الإعلان',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _ReviewSection(
                title: 'الصور',
                step: 4,
                onEdit: notifier.goToStep,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            state.images.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (state.images.length > 1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.images.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              state.images[i],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _ReviewSection(
                title: 'التفاصيل',
                step: 2,
                onEdit: notifier.goToStep,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.price != null ? formatIQD(state.price!) : '—',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (state.condition != null) ...[
                      const SizedBox(height: 8),
                      _Badge(
                        label: state.condition == ListingCondition.newItem
                            ? 'جديد'
                            : 'مستعمل',
                      ),
                    ],
                  ],
                ),
              ),
              _ReviewSection(
                title: 'الفئة',
                step: 1,
                onEdit: notifier.goToStep,
                child: Text(categoryLabel),
              ),
              _ReviewSection(
                title: 'الموقع',
                step: 3,
                onEdit: notifier.goToStep,
                child: Text(
                  '${governorateNameAr(state.governorate ?? '')} — ${state.city}',
                ),
              ),
              _ReviewSection(
                title: 'الوصف',
                step: 2,
                onEdit: notifier.goToStep,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      state.description,
                      maxLines: _descriptionExpanded ? null : 3,
                      overflow: _descriptionExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (state.description.length > 120)
                      TextButton(
                        onPressed: () => setState(
                          () => _descriptionExpanded = !_descriptionExpanded,
                        ),
                        child: Text(
                          _descriptionExpanded ? 'عرض أقل' : 'عرض المزيد',
                        ),
                      ),
                  ],
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                TextButton(
                  onPressed: widget.onPublish,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.step,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final int step;
  final void Function(int) onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => onEdit(step),
                  child: const Text('تعديل'),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
