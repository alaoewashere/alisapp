import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/maps_config.dart';
import '../widgets/map_picker_sheet.dart';

class ListingMapPreview extends StatelessWidget {
  const ListingMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    if (!MapsConfig.isConfigured) return const SizedBox.shrink();

    final position = LatLng(latitude, longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 14),
              markers: {
                Marker(markerId: const MarkerId('listing'), position: position),
              },
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
              onTap: (_) => _openFullMap(context),
            ),
          ),
        ),
        TextButton(
          onPressed: () => _openFullMap(context),
          child: const Text('عرض على الخريطة'),
        ),
      ],
    );
  }

  void _openFullMap(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MapPickerSheet(
        initialLat: latitude,
        initialLng: longitude,
      ),
    );
  }
}
