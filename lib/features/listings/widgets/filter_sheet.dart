import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_tree.dart';
import '../../../core/utils/digit_input_formatter.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/filter_model.dart';
import '../providers/post_listing_provider.dart' show allCategoriesProvider;
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

  // Full drill path (e.g. [Vehicles, Cars, Mercedes-Benz]) — kept visible as
  // a breadcrumb so the selection is never hidden, and rebuilt from the
  // saved filter whenever the sheet reopens so nothing is lost on "back".
  List<CategoryModel> _categoryPath = [];
  bool _categoryPathInitialized = false;

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

  void _initCategoryPathIfNeeded(List<CategoryModel> all) {
    if (_categoryPathInitialized) return;
    _categoryPathInitialized = true;
    final selectedId = _draft.effectiveCategoryId;
    if (selectedId != null) {
      _categoryPath = buildCategoryPath(selectedId, all);
    }
  }

  void _selectCategoryAtLevel(int level, CategoryModel category) {
    final alreadySelected =
        level < _categoryPath.length && _categoryPath[level].id == category.id;
    setState(() {
      if (alreadySelected) {
        // Tapping the selected chip again backs out one level — the level
        // above stays selected, it's never wiped entirely.
        _categoryPath = _categoryPath.sublist(0, level);
      } else {
        _categoryPath = [..._categoryPath.sublist(0, level), category];
      }
    });
    final newId = _categoryPath.isEmpty ? null : _categoryPath.last.id;
    _updateDraft(_draft.copyWith(
      categoryId: newId,
      clearCategory: newId == null,
      clearSubcategory: true,
    ));
  }

  void _clearCategoryPath() {
    setState(() => _categoryPath = []);
    _updateDraft(_draft.copyWith(clearCategory: true, clearSubcategory: true));
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
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final countAsync = ref.watch(filterPreviewCountProvider);
    final theme = Theme.of(context);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Grab handle.
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      strings.filtersTitle,
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
                          _categoryPath = [];
                        });
                      },
                      child: Text(strings.clearAll),
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
                  Text(strings.categorySection, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (all) {
                      _initCategoryPathIfNeeded(all);
                      return _CategoryDrillDown(
                        all: all,
                        path: _categoryPath,
                        localeCode: localeCode,
                        onSelect: _selectCategoryAtLevel,
                        onClear: _clearCategoryPath,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(strings.governorate, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _draft.governorate,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(strings.allGovernorates),
                      ),
                      ...iraqiGovernorates.map(
                        (g) => DropdownMenuItem(
                          value: g.slug,
                          child: Text(g.displayName(localeCode)),
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
                  Text(strings.priceRangeLabel, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [appDigitsOnly()],
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: strings.fromLabel,
                            suffixText: strings.currencyIqd,
                          ),
                          onChanged: (_) => _syncPriceFromFields(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [appDigitsOnly()],
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: strings.toLabel,
                            suffixText: strings.currencyIqd,
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
                  Text(strings.conditionLabel, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: FilterCondition.values.map((c) {
                      final label = switch (c) {
                        FilterCondition.all => strings.allCategories,
                        FilterCondition.newItem => strings.conditionNew,
                        FilterCondition.used => strings.conditionUsed,
                      };
                      return ChoiceChip(
                        label: Text(label),
                        selected: _draft.condition == c,
                        onSelected: (_) => _updateDraft(
                          _draft.copyWith(condition: c),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(strings.additionalOptions, style: theme.textTheme.titleSmall),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.featuredOnlyLabel),
                    value: _draft.isFeaturedOnly,
                    onChanged: (v) =>
                        _updateDraft(_draft.copyWith(isFeaturedOnly: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.negotiableOnlyLabel),
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
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.volt,
                      foregroundColor: AppColors.canvas,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: AppFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: countAsync.when(
                      data: (count) => Text(
                        strings.showResultsCount(arabicNumber(count)),
                      ),
                      loading: () => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.canvas,
                        ),
                      ),
                      error: (_, _) => Text(strings.showResults),
                    ),
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

/// Multi-level category picker using cascading dropdowns — one per tree level.
class _CategoryDrillDown extends StatelessWidget {
  const _CategoryDrillDown({
    required this.all,
    required this.path,
    required this.localeCode,
    required this.onSelect,
    required this.onClear,
  });

  final List<CategoryModel> all;
  final List<CategoryModel> path;
  final String localeCode;
  final void Function(int level, CategoryModel category) onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

    final levels = <List<CategoryModel>>[
      childrenOf(null, all),
      for (final node in path) childrenOf(node.id, all),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var level = 0; level < levels.length; level++)
          if (levels[level].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<int?>(
                key: ValueKey('cat_${level}_${level > 0 ? path[level - 1].id : 0}'),
                initialValue: level < path.length ? path[level].id : null,
                decoration: InputDecoration(
                  labelText: level == 0
                      ? strings.categorySection
                      : path[level - 1].localizedName(localeCode),
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('الكل'),
                  ),
                  ...levels[level].map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.localizedName(localeCode)),
                    ),
                  ),
                ],
                onChanged: (id) {
                  if (id == null) {
                    if (level == 0) {
                      onClear();
                    } else {
                      onSelect(level - 1, path[level - 1]);
                    }
                  } else {
                    final cat = levels[level].firstWhere((c) => c.id == id);
                    onSelect(level, cat);
                  }
                },
              ),
            ),
      ],
    );
  }
}
