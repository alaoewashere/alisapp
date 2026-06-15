import 'package:flutter/material.dart';

import '../../../core/utils/listing_metadata_detail_rows.dart';
import '../../../core/utils/vehicle_listing_utils.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';
import 'listing_metadata_detail_section.dart';

/// Vehicle listing details — uses shared [ListingMetadataDetailSection] styling.
class VehicleListingDetailSection extends StatelessWidget {
  const VehicleListingDetailSection({
    super.key,
    required this.vehicle,
    required this.condition,
  });

  final VehicleListingMetadata vehicle;
  final ListingCondition? condition;

  @override
  Widget build(BuildContext context) {
    return ListingMetadataDetailSection(
      rows: vehicleDetailRows(vehicle, condition),
      chipGroups: vehicle.selectedSpecs.isEmpty
          ? const []
          : [
              MetadataChipGroup(
                title: 'المواصفات',
                chips: vehicle.selectedSpecs,
              ),
            ],
    );
  }
}
