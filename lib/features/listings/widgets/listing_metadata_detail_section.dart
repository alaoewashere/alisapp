import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/utils/listing_metadata_detail_rows.dart';

/// Label/value rows + optional chip groups (vehicle-style listing details).
class ListingMetadataDetailSection extends ConsumerWidget {
  const ListingMetadataDetailSection({
    super.key,
    required this.rows,
    this.chipGroups = const [],
  });

  final List<MapEntry<String, String>> rows;
  final List<MetadataChipGroup> chipGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appLocalizationsProvider);
    final visibleGroups =
        chipGroups.where((group) => group.chips.isNotEmpty).toList();

    if (rows.isEmpty && visibleGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rows.isNotEmpty) ...[
          Text(l10n.sectionDetails, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        for (final group in visibleGroups) ...[
          if (rows.isNotEmpty || group != visibleGroups.first)
            const SizedBox(height: 16),
          if (rows.isEmpty && group == visibleGroups.first) ...[
            Text(l10n.sectionDetails, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
          Text(group.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.chips
                .map(
                  (chip) => Chip(
                    label: Text(chip, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: Colors.grey.shade400),
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
