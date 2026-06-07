import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Baghdad center — default position for Iraq.
const baghdadLatLng = LatLng(33.3152, 44.3661);

/// Approximate bounds of Iraq.
final iraqMapBounds = LatLngBounds(
  southwest: const LatLng(29.0, 38.7),
  northeast: const LatLng(37.5, 48.8),
);

/// Resolves device location with simulator-friendly fallbacks.
Future<LatLng> resolveDeviceLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return baghdadLatLng;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return baghdadLatLng;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final latLng = LatLng(lastKnown.latitude, lastKnown.longitude);
      if (iraqMapBounds.contains(latLng)) return latLng;
    }

    final current = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 10),
      ),
    );
    final latLng = LatLng(current.latitude, current.longitude);
    if (iraqMapBounds.contains(latLng)) return latLng;

    return baghdadLatLng;
  } catch (_) {
    return baghdadLatLng;
  }
}
