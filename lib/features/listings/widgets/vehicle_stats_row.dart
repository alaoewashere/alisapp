import 'package:flutter/material.dart';

import '../../../core/utils/vehicle_listing_utils.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';

/// Four icon stat cards for vehicle listings (iqcars.net style).
class VehicleStatsRow extends StatelessWidget {
  const VehicleStatsRow({super.key, required this.vehicle});

  final VehicleListingMetadata vehicle;

  @override
  Widget build(BuildContext context) {
    final mileageUnit = vehicle.mileageUnit;
    final mileageValue = vehicle.mileage != null
        ? formatVehicleMileageDisplay(vehicle.mileage!, mileageUnit)
        : '—';

    return Row(
      children: [
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
            value: formatVehicleEngineDisplay(vehicle.engine),
            subLabel: 'محرك',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.build_outlined,
            value: formatVehicleCylindersDisplay(vehicle.cylinders),
            subLabel: 'أسطوانة',
          ),
        ),
      ],
    );
  }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
              height: 1.2,
            ),
          ),
          if (subLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
