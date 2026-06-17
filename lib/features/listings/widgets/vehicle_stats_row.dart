import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';

/// Four icon stat cards for vehicle listings (iqcars.net style).
class VehicleStatsRow extends StatelessWidget {
  const VehicleStatsRow({super.key, required this.vehicle});

  final VehicleListingMetadata vehicle;

  @override
  Widget build(BuildContext context) {
    final mileageUnit = vehicle.mileageUnit;
    final mileageValue = vehicle.mileage != null
        ? _formatMileageValue(vehicle.mileage!)
        : '—';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            value: vehicle.year != null ? vehicle.year.toString() : '—',
            subLabel: 'السنة',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_bulleted,
            value: vehicle.trim.isNotEmpty ? vehicle.trim : '—',
            subLabel: 'الفئة',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.speed,
            value: mileageValue,
            subLabel: mileageUnit.labelAr,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.settings,
            value: _formatEngineValue(vehicle.engine),
            subLabel: 'محرك',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.build_outlined,
            value: _formatCylindersValue(vehicle.cylinders),
            subLabel: 'أسطوانة',
          ),
        ),
      ],
    );
  }
}

String _formatMileageValue(int mileage) {
  return mileage.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

String _formatEngineValue(String engine) {
  if (engine.trim().isEmpty) return '—';
  return engine.trim();
}

String _formatCylindersValue(String? cylinders) {
  if (cylinders == null || cylinders.isEmpty) return '—';
  return cylinders;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.subLabel,
  });

  final IconData icon;
  final String value;
  final String subLabel;

  static const _borderColor = Color(0x15FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: AppColors.textMuted),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.pureWhite,
              height: 1.2,
            ),
          ),
          if (subLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
