import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../features/listings/providers/post_listing_provider.dart';
import '../../../features/listings/widgets/steps/step2_form_common.dart';
import '../../../models/smart_alert_category.dart';
import '../../../shared/models/category_model.dart';

/// Cascading category pickers — root → subcategory → brand → model (same tree as listings).
class SmartAlertCategoryPickers extends ConsumerWidget {
  const SmartAlertCategoryPickers({
    super.key,
    required this.path,
    required this.onPathChanged,
  });

  final List<CategoryModel> path;
  final ValueChanged<List<CategoryModel>> onPathChanged;

  Future<void> _pick({
    required BuildContext context,
    required String title,
    required List<CategoryModel> options,
    required void Function(CategoryModel picked) onPicked,
    CategoryModel? selected,
    required String localeCode,
  }) async {
    if (options.isEmpty) return;

    final labels = options.map((c) => c.localizedName(localeCode)).toList();
    final pickedLabel = await showStep2PickerSheet(
      context: context,
      title: title,
      options: labels,
      selected: selected?.localizedName(localeCode),
      searchable: labels.length > 8,
    );
    if (pickedLabel == null) return;

    final index = labels.indexOf(pickedLabel);
    if (index < 0) return;
    onPicked(options[index]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final allAsync = ref.watch(allCategoriesProvider);

    return allAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('${strings.failedLoadCategories}: $e'),
      ),
      data: (all) {
        final rows = <Widget>[];

        final roots = childrenOf(all, null);
        rows.add(
          Step2PickerTriggerRow(
            label: smartAlertPickerLabelForParent(null, 0, strings),
            displayValue: path.isEmpty
                ? strings.allCategories
                : path.first.localizedName(localeCode),
            onTap: () => _pick(
              context: context,
              title: smartAlertPickerLabelForParent(null, 0, strings),
              options: roots,
              selected: path.isEmpty ? null : path.first,
              localeCode: localeCode,
              onPicked: (picked) => onPathChanged([picked]),
            ),
          ),
        );

        for (var depth = 0; depth < path.length; depth++) {
          final parent = path[depth];
          final children = childrenOf(all, parent.id);
          if (children.isEmpty) continue;

          final nextDepth = depth + 1;
          final hasChild = path.length > nextDepth;
          final label = smartAlertPickerLabelForParent(parent, nextDepth, strings);

          rows.add(const SizedBox(height: 8));
          rows.add(
            Step2PickerTriggerRow(
              label: label,
              displayValue: hasChild
                  ? path[nextDepth].localizedName(localeCode)
                  : strings.chooseOption,
              onTap: () => _pick(
                context: context,
                title: label,
                options: children,
                selected: hasChild ? path[nextDepth] : null,
                localeCode: localeCode,
                onPicked: (picked) {
                  onPathChanged([...path.sublist(0, nextDepth), picked]);
                },
              ),
            ),
          );

          if (!hasChild) break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
