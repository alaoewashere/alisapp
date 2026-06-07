import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/filter_model.dart';
import '../../home/providers/home_provider.dart';
import '../providers/search_provider.dart';

void showFilterSheet(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onApplied,
}) {
  ref
      .read(filterDraftProvider.notifier)
      .updateDraft(ref.read(filterProvider));
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FilterSheet(onApplied: onApplied),
  );
}

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, this.onApplied});

  final VoidCallback? onApplied;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late FilterModel _draft;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  double _sliderMin = 0;
  double _sliderMax = 50000000;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(filterProvider);
    _minController = TextEditingController(
      text: _draft.minPrice?.round().toString() ?? '',
    );
    _maxController = TextEditingController(
      text: _draft.maxPrice?.round().toString() ?? '',
    );
    _sliderMin = _draft.minPrice ?? 0;
    _sliderMax = _draft.maxPrice ?? 50000000;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _updateDraft(FilterModel draft) {
    setState(() => _draft = draft);
    ref.read(filterDraftProvider.notifier).updateDraft(draft);
  }

  void _syncPriceFromFields() {
    final min = double.tryParse(_minController.text.replaceAll(',', ''));
    final max = double.tryParse(_maxController.text.replaceAll(',', ''));
    _updateDraft(_draft.copyWith(
      minPrice: min,
      maxPrice: max,
      clearMinPrice: min == null,
      clearMaxPrice: max == null,
    ));
    setState(() {
      _sliderMin = min ?? 0;
      _sliderMax = max ?? 50000000;
    });
  }

  void _apply() {
    ref.read(filterProvider.notifier).setFilter(_draft);
    ref.read(searchResultsProvider.notifier).search(_draft, log: false);
    Navigator.pop(context);
    widget.onApplied?.call();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final countAsync = ref.watch(filterPreviewCountProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'الفلاتر',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!_draft.isEmpty)
                    TextButton(
                      onPressed: () {
                        _minController.clear();
                        _maxController.clear();
                        _updateDraft(const FilterModel());
                        setState(() {
                          _sliderMin = 0;
                          _sliderMax = 50000000;
                        });
                      },
                      child: const Text('مسح الكل'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text('الفئة', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (all) {
                      final parents =
                          all.where((CategoryModel c) => c.isParent).toList();
                      final subs = _draft.categoryId == null
                          ? <CategoryModel>[]
                          : all
                              .where(
                                (CategoryModel c) =>
                                    c.parentId == _draft.categoryId,
                              )
                              .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: parents.map((c) {
                              final selected = _draft.categoryId == c.id;
                              return FilterChip(
                                label: Text(c.nameAr),
                                selected: selected,
                                onSelected: (_) {
                                  _updateDraft(_draft.copyWith(
                                    categoryId: selected ? null : c.id,
                                    clearSubcategory: true,
                                  ));
                                },
                              );
                            }).toList(),
                          ),
                          if (subs.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: subs.map((c) {
                                final selected = _draft.subcategoryId == c.id;
                                return FilterChip(
                                  label: Text(c.nameAr),
                                  selected: selected,
                                  onSelected: (_) {
                                    _updateDraft(_draft.copyWith(
                                      subcategoryId: selected ? null : c.id,
                                    ));
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('المحافظة', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _draft.governorate,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع المحافظات'),
                      ),
                      ...iraqiGovernorates.map(
                        (g) => DropdownMenuItem(
                          value: g.slug,
                          child: Text(g.nameAr),
                        ),
                      ),
                    ],
                    onChanged: (v) => _updateDraft(
                      _draft.copyWith(
                        governorate: v,
                        clearGovernorate: v == null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('نطاق السعر', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'من',
                            suffixText: 'د.ع',
                          ),
                          onChanged: (_) => _syncPriceFromFields(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            labelText: 'إلى',
                            suffixText: 'د.ع',
                          ),
                          onChanged: (_) => _syncPriceFromFields(),
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(
                      _sliderMin.clamp(0, 50000000),
                      _sliderMax.clamp(0, 50000000),
                    ),
                    min: 0,
                    max: 50000000,
                    divisions: 100,
                    onChanged: (range) {
                      _minController.text = range.start.round().toString();
                      _maxController.text = range.end.round().toString();
                      setState(() {
                        _sliderMin = range.start;
                        _sliderMax = range.end;
                      });
                      _updateDraft(_draft.copyWith(
                        minPrice: range.start,
                        maxPrice: range.end,
                      ));
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('الحالة', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FilterCondition.values.map((c) {
                      return ChoiceChip(
                        label: Text(c.labelAr),
                        selected: _draft.condition == c,
                        onSelected: (_) => _updateDraft(
                          _draft.copyWith(condition: c),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('خيارات إضافية', style: theme.textTheme.titleSmall),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('إعلانات مميزة فقط'),
                    value: _draft.isFeaturedOnly,
                    onChanged: (v) =>
                        _updateDraft(_draft.copyWith(isFeaturedOnly: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('قابل للتفاوض فقط'),
                    value: _draft.isNegotiableOnly,
                    onChanged: (v) =>
                        _updateDraft(_draft.copyWith(isNegotiableOnly: v)),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _apply,
                  child: countAsync.when(
                    data: (count) =>
                        Text('عرض ${arabicNumber(count)} نتيجة'),
                    loading: () => const Text('عرض النتائج...'),
                    error: (_, _) => const Text('عرض النتائج'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
