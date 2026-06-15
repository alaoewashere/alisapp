import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../constants/vehicle_listing_options.dart';

const _dividerColor = Color(0xFFE5E5EA);

/// Sahibinden-style accordion checklist for vehicle specs (one group open at a time).
class VehicleSpecsChecklist extends StatefulWidget {
  const VehicleSpecsChecklist({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<VehicleSpecsChecklist> createState() => _VehicleSpecsChecklistState();
}

class _VehicleSpecsChecklistState extends State<VehicleSpecsChecklist> {
  int? _expandedGroupIndex;

  int get _selectedCount => widget.selected.length;

  int _groupSelectedCount(VehicleSpecGroup group) {
    return group.specs.where(widget.selected.contains).length;
  }

  void _toggleGroup(int index) {
    setState(() {
      _expandedGroupIndex = _expandedGroupIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = VehicleListingOptions.vehicleSpecGroups;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            _SpecAccordionGroup(
              group: groups[i],
              isExpanded: _expandedGroupIndex == i,
              selectedCount: _groupSelectedCount(groups[i]),
              selected: widget.selected,
              onHeaderTap: () => _toggleGroup(i),
              onToggle: widget.onToggle,
            ),
            if (i < groups.length - 1) const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'تم اختيار $_selectedCount مواصفة',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecAccordionGroup extends StatelessWidget {
  const _SpecAccordionGroup({
    required this.group,
    required this.isExpanded,
    required this.selectedCount,
    required this.selected,
    required this.onHeaderTap,
    required this.onToggle,
  });

  final VehicleSpecGroup group;
  final bool isExpanded;
  final int selectedCount;
  final List<String> selected;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onHeaderTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 8),
                    _SelectedCountBadge(count: selectedCount),
                  ],
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1, thickness: 1, color: _dividerColor),
                      for (var i = 0; i < group.specs.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: _dividerColor,
                          ),
                        _SpecCheckRow(
                          label: group.specs[i],
                          isSelected: selected.contains(group.specs[i]),
                          onTap: () => onToggle(group.specs[i]),
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SelectedCountBadge extends StatelessWidget {
  const _SelectedCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SpecCheckRow extends StatelessWidget {
  const _SpecCheckRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            _CircleCheckbox(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _CircleCheckbox extends StatelessWidget {
  const _CircleCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFC7C7CC),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
