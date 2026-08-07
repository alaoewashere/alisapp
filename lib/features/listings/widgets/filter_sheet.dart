import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/iraq_neighborhoods.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_tree.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/digit_input_formatter.dart';
import '../../../core/utils/vehicle_listing_utils.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/filter_model.dart';
import '../constants/vehicle_listing_options.dart';
import '../providers/post_listing_provider.dart' show allCategoriesProvider;
import '../providers/search_provider.dart';
import 'steps/step2_form_common.dart' show Step2GovernoratePicker, Step2NeighborhoodPicker;

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
  bool _priceInUsd = false;

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

  /// RangeSlider requires start <= end. _sliderMin/_sliderMax can drift out
  /// of order (typed input, currency conversion, a stale reopened draft) —
  /// order them here so the widget itself can never assert on it, no
  /// matter how the state upstream got there.
  RangeValues _safeSliderValues() {
    final a = _sliderMin.clamp(0.0, 50000000.0);
    final b = _sliderMax.clamp(0.0, 50000000.0);
    return a <= b ? RangeValues(a, b) : RangeValues(b, a);
  }

  void _syncPriceFromFields() {
    final rawMin = double.tryParse(_minController.text.replaceAll(',', ''));
    final rawMax = double.tryParse(_maxController.text.replaceAll(',', ''));
    // Fields show whatever currency is toggled; draft.minPrice/maxPrice and
    // the backend `price` column are always IQD — convert on the way in.
    final min = rawMin == null
        ? null
        : (_priceInUsd ? rawMin * kApproxIqdPerUsd : rawMin);
    final max = rawMax == null
        ? null
        : (_priceInUsd ? rawMax * kApproxIqdPerUsd : rawMax);
    // Don't reorder/rewrite the fields while the user is mid-keystroke —
    // that fights their typing (e.g. min temporarily > a stale max while
    // they're still entering digits). The RangeSlider below defensively
    // orders start/end itself, and _apply() normalizes once on submit.
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

  /// Swap any min/max pair that ended up inverted so the query sent to the
  /// backend (and the reopened sheet's fields) is always sane, regardless
  /// of the order the user filled the two sides in.
  FilterModel _normalizeRanges(FilterModel f) {
    T? lo<T extends num>(T? a, T? b) => (a != null && b != null && a > b) ? b : a;
    T? hi<T extends num>(T? a, T? b) => (a != null && b != null && a > b) ? a : b;
    return f.copyWith(
      minPrice: lo(f.minPrice, f.maxPrice),
      maxPrice: hi(f.minPrice, f.maxPrice),
      minYear: lo(f.minYear, f.maxYear),
      maxYear: hi(f.minYear, f.maxYear),
      minMileage: lo(f.minMileage, f.maxMileage),
      maxMileage: hi(f.minMileage, f.maxMileage),
      minEnginePowerHp: lo(f.minEnginePowerHp, f.maxEnginePowerHp),
      maxEnginePowerHp: hi(f.minEnginePowerHp, f.maxEnginePowerHp),
      minEngineCapacityCc: lo(f.minEngineCapacityCc, f.maxEngineCapacityCc),
      maxEngineCapacityCc: hi(f.minEngineCapacityCc, f.maxEngineCapacityCc),
    );
  }

  void _apply() {
    _draft = _normalizeRanges(_draft);
    ref.read(filterProvider.notifier).setFilter(_draft);
    ref.read(searchResultsProvider.notifier).search(_draft, log: false);
    Navigator.pop(context);
    // onApplied (search_screen.dart) pushes AppRoutes.searchResults on this
    // same Navigator. Firing it synchronously right after pop() races the
    // sheet's removal — the pushed Page can land before the popped one is
    // out of the page list, both keyed by the same route → GoRouter's
    // "!keyReservation.contains(key)" duplicate-key assertion. Deferring to
    // the next frame lets the pop settle first.
    final onApplied = widget.onApplied;
    if (onApplied != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onApplied());
    }
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
                          _priceInUsd = false;
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
                  Text('الموقع', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Step2GovernoratePicker(
                    value: _draft.governorate,
                    onChanged: (v) => _updateDraft(
                      _draft.copyWith(
                        governorate: v,
                        clearGovernorate: v == null,
                        clearAreaName: true,
                      ),
                    ),
                  ),
                  Step2NeighborhoodPicker(
                    governorateSlug: _draft.governorate,
                    selectedSlug: _draft.areaName == null
                        ? null
                        : neighborhoodByNameAr(_draft.areaName!)?.slug,
                    onChanged: (slug) {
                      final area = slug == null ? null : neighborhoodBySlug(slug);
                      _updateDraft(_draft.copyWith(
                        areaName: area?.nameAr,
                        clearAreaName: area == null,
                      ));
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(strings.priceRangeLabel, style: theme.textTheme.titleSmall),
                      const Spacer(),
                      _CurrencyToggle(
                        isUsd: _priceInUsd,
                        onChanged: (usd) {
                          // Re-render the already-typed numbers in the new
                          // currency — draft.minPrice/maxPrice (IQD) don't
                          // change, only how the fields display them.
                          setState(() {
                            _priceInUsd = usd;
                            if (_draft.minPrice != null) {
                              final v = usd
                                  ? _draft.minPrice! / kApproxIqdPerUsd
                                  : _draft.minPrice!;
                              _minController.text = v.round().toString();
                            }
                            if (_draft.maxPrice != null) {
                              final v = usd
                                  ? _draft.maxPrice! / kApproxIqdPerUsd
                                  : _draft.maxPrice!;
                              _maxController.text = v.round().toString();
                            }
                          });
                        },
                      ),
                    ],
                  ),
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
                            suffixText: _priceInUsd ? 'USD' : strings.currencyIqd,
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
                            suffixText: _priceInUsd ? 'USD' : strings.currencyIqd,
                          ),
                          onChanged: (_) => _syncPriceFromFields(),
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _safeSliderValues(),
                    min: 0,
                    max: 50000000,
                    divisions: 100,
                    onChanged: (range) {
                      // Slider always drags in IQD; fields show the toggled
                      // currency.
                      final displayStart =
                          _priceInUsd ? range.start / kApproxIqdPerUsd : range.start;
                      final displayEnd =
                          _priceInUsd ? range.end / kApproxIqdPerUsd : range.end;
                      _minController.text = displayStart.round().toString();
                      _maxController.text = displayEnd.round().toString();
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
                  if (isAutomobileCarListingPath(_categoryPath)) ...[
                    const SizedBox(height: 20),
                    _CarFilters(draft: _draft, onChanged: _updateDraft),
                  ],
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

/// IQD/USD toggle for the price fields. Conversion uses [kApproxIqdPerUsd] —
/// there's no per-listing USD price column, IQD stays the source of truth.
class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.isUsd, required this.onChanged});

  final bool isUsd;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, label: Text('د.ع')),
        ButtonSegment(value: true, label: Text('USD')),
      ],
      selected: {isUsd},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

/// سيارات-only filters — hidden entirely outside that category path.
/// Reuses [VehicleListingOptions] / [VehicleCarColors] so the labels match
/// what post-listing already collects; ranges reuse the same digit-only
/// TextField pattern as the price section above.
class _CarFilters extends StatelessWidget {
  const _CarFilters({required this.draft, required this.onChanged});

  final FilterModel draft;
  final ValueChanged<FilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionLabel(String text) =>
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(text, style: theme.textTheme.titleSmall),
        );

    Widget chipGroup<T>({
      required List<T> options,
      required T? selected,
      required String Function(T) labelOf,
      required ValueChanged<T?> onSelect,
    }) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options.map((o) {
          final isSelected = selected == o;
          return ChoiceChip(
            label: Text(labelOf(o)),
            selected: isSelected,
            onSelected: (_) => onSelect(isSelected ? null : o),
          );
        }).toList(),
      );
    }

    Widget rangeRow({
      required Key minKey,
      required Key maxKey,
      required String? minValue,
      required String? maxValue,
      required String unit,
      required void Function(int?) onMinChanged,
      required void Function(int?) onMaxChanged,
    }) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              key: minKey,
              initialValue: minValue,
              keyboardType: TextInputType.number,
              inputFormatters: [appDigitsOnly()],
              decoration: InputDecoration(
                labelText: 'الحد الأدنى',
                suffixText: unit,
              ),
              onChanged: (v) => onMinChanged(int.tryParse(v)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              key: maxKey,
              initialValue: maxValue,
              keyboardType: TextInputType.number,
              inputFormatters: [appDigitsOnly()],
              decoration: InputDecoration(
                labelText: 'الحد الأعلى',
                suffixText: unit,
              ),
              onChanged: (v) => onMaxChanged(int.tryParse(v)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        sectionLabel('سنة الصنع'),
        rangeRow(
          minKey: const ValueKey('car_year_min'),
          maxKey: const ValueKey('car_year_max'),
          minValue: draft.minYear?.toString(),
          maxValue: draft.maxYear?.toString(),
          unit: '',
          onMinChanged: (v) => onChanged(
            draft.copyWith(minYear: v, clearMinYear: v == null),
          ),
          onMaxChanged: (v) => onChanged(
            draft.copyWith(maxYear: v, clearMaxYear: v == null),
          ),
        ),
        sectionLabel('نوع الوقود'),
        chipGroup<String>(
          options: VehicleListingOptions.fuelOptions,
          selected: draft.fuel,
          labelOf: (o) => o,
          onSelect: (v) => onChanged(draft.copyWith(fuel: v, clearFuel: v == null)),
        ),
        sectionLabel('ناقل الحركة'),
        chipGroup<String>(
          options: VehicleListingOptions.transmissionOptions,
          selected: draft.transmission,
          labelOf: (o) => o,
          onSelect: (v) => onChanged(
            draft.copyWith(transmission: v, clearTransmission: v == null),
          ),
        ),
        sectionLabel('الممشى'),
        rangeRow(
          minKey: const ValueKey('car_mileage_min'),
          maxKey: const ValueKey('car_mileage_max'),
          minValue: draft.minMileage?.toString(),
          maxValue: draft.maxMileage?.toString(),
          unit: 'كم',
          onMinChanged: (v) => onChanged(
            draft.copyWith(minMileage: v, clearMinMileage: v == null),
          ),
          onMaxChanged: (v) => onChanged(
            draft.copyWith(maxMileage: v, clearMaxMileage: v == null),
          ),
        ),
        sectionLabel('نوع الهيكل'),
        chipGroup<String>(
          options: const [
            'سيدان', 'SUV', 'كروس أوفر', 'هاتشباك', 'كوبيه', 'بيك أب', 'فان',
            'ستيشن', 'مكشوفة',
          ],
          selected: draft.bodyType,
          labelOf: (o) => o,
          onSelect: (v) =>
              onChanged(draft.copyWith(bodyType: v, clearBodyType: v == null)),
        ),
        sectionLabel('قوة المحرك'),
        rangeRow(
          minKey: const ValueKey('car_power_min'),
          maxKey: const ValueKey('car_power_max'),
          minValue: draft.minEnginePowerHp?.toString(),
          maxValue: draft.maxEnginePowerHp?.toString(),
          unit: 'HP',
          onMinChanged: (v) => onChanged(
            draft.copyWith(minEnginePowerHp: v, clearMinEnginePowerHp: v == null),
          ),
          onMaxChanged: (v) => onChanged(
            draft.copyWith(maxEnginePowerHp: v, clearMaxEnginePowerHp: v == null),
          ),
        ),
        sectionLabel('سعة المحرك'),
        rangeRow(
          minKey: const ValueKey('car_cc_min'),
          maxKey: const ValueKey('car_cc_max'),
          minValue: draft.minEngineCapacityCc?.toString(),
          maxValue: draft.maxEngineCapacityCc?.toString(),
          unit: 'CC',
          onMinChanged: (v) => onChanged(
            draft.copyWith(
              minEngineCapacityCc: v,
              clearMinEngineCapacityCc: v == null,
            ),
          ),
          onMaxChanged: (v) => onChanged(
            draft.copyWith(
              maxEngineCapacityCc: v,
              clearMaxEngineCapacityCc: v == null,
            ),
          ),
        ),
        sectionLabel('نظام الدفع'),
        chipGroup<String>(
          options: const ['دفع أمامي', 'دفع خلفي', 'دفع رباعي'],
          selected: draft.driveType,
          labelOf: (o) => o,
          onSelect: (v) =>
              onChanged(draft.copyWith(driveType: v, clearDriveType: v == null)),
        ),
        sectionLabel('عدد الأبواب'),
        chipGroup<String>(
          options: const ['2', '3', '4', '5'],
          selected: draft.doors,
          labelOf: (o) => o,
          onSelect: (v) => onChanged(draft.copyWith(doors: v, clearDoors: v == null)),
        ),
        sectionLabel('اللون الخارجي'),
        chipGroup<String>(
          options: VehicleCarColors.options.map((c) => c.labelAr).toList(),
          selected: draft.vehicleColor,
          labelOf: (o) => o,
          onSelect: (v) => onChanged(
            draft.copyWith(vehicleColor: v, clearVehicleColor: v == null),
          ),
        ),
        sectionLabel('يوجد ضمان'),
        chipGroup<bool>(
          options: const [true, false],
          selected: draft.hasWarranty,
          labelOf: (o) => o ? 'نعم' : 'لا',
          onSelect: (v) => onChanged(
            draft.copyWith(hasWarranty: v, clearHasWarranty: v == null),
          ),
        ),
        sectionLabel('حادث سابق'),
        chipGroup<bool>(
          options: const [true, false],
          selected: draft.hasAccidentHistory,
          labelOf: (o) => o ? 'نعم' : 'لا',
          onSelect: (v) => onChanged(
            draft.copyWith(hasAccidentHistory: v, clearHasAccidentHistory: v == null),
          ),
        ),
        sectionLabel('سجل ضرر جسيم'),
        chipGroup<bool>(
          options: const [true, false],
          selected: draft.hasHeavyDamage,
          labelOf: (o) => o ? 'نعم' : 'لا',
          onSelect: (v) => onChanged(
            draft.copyWith(hasHeavyDamage: v, clearHasHeavyDamage: v == null),
          ),
        ),
        sectionLabel('نوع اللوحة'),
        chipGroup<String>(
          options: const ['عراقية', 'إقليم كردستان', 'مؤقتة', 'دبلوماسية'],
          selected: draft.plateType,
          labelOf: (o) => o,
          onSelect: (v) =>
              onChanged(draft.copyWith(plateType: v, clearPlateType: v == null)),
        ),
        sectionLabel('نوع البائع'),
        chipGroup<String>(
          options: const ['المالك', 'معرض سيارات', 'وكيل معتمد'],
          selected: draft.sellerType,
          labelOf: (o) => o,
          onSelect: (v) =>
              onChanged(draft.copyWith(sellerType: v, clearSellerType: v == null)),
        ),
      ],
    );
  }
}
