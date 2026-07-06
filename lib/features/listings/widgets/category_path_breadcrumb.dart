import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/category_locale.dart';
import '../../../shared/models/category_model.dart';

/// Horizontal scrollable breadcrumb for category drill-down paths.
class CategoryPathBreadcrumb extends ConsumerWidget {
  const CategoryPathBreadcrumb({
    super.key,
    required this.path,
    this.onSegmentTap,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<CategoryModel> path;
  final void Function(int index)? onSegmentTap;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (path.isEmpty) return const SizedBox.shrink();

    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < path.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            _BreadcrumbChip(
              label: path[i].localizedName(localeCode),
              isLast: i == path.length - 1,
              onTap: onSegmentTap != null ? () => onSegmentTap!(i) : null,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Padding(padding: padding, child: content);
    }

    return Padding(
      padding: padding,
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.label,
    required this.isLast,
    this.onTap,
  });

  final String label;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final child = Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
        color: isLast ? colorScheme.primary : colorScheme.onSurface,
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      ),
    );
  }
}
