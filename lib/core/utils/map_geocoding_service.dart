import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../config/maps_config.dart';

/// Result from the map picker sheet.
class MapPickerResult {
  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

/// Reverse-geocodes coordinates to a human-readable address (Arabic when available).
Future<String?> reverseGeocodeLatLng(LatLng latLng) async {
  if (!MapsConfig.isConfigured) return null;

  final uri = Uri.https(
    'maps.googleapis.com',
    '/maps/api/geocode/json',
    {
      'latlng': '${latLng.latitude},${latLng.longitude}',
      'key': MapsConfig.apiKey,
      'language': 'ar',
    },
  );

  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') return null;

    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    final formatted = first['formatted_address'] as String?;
    if (formatted == null || formatted.trim().isEmpty) return null;
    return formatted.trim();
  } catch (_) {
    return null;
  }
}
