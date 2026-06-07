import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/maps_config.dart';
import '../../../core/utils/map_location_service.dart';

class MapPickerSheet extends StatefulWidget {
  const MapPickerSheet({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  final double? initialLat;
  final double? initialLng;

  @override
  State<MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends State<MapPickerSheet> {
  LatLng? _initialPosition;
  LatLng? _position;
  bool _mapReady = false;
  bool _mapUnavailable = false;
  String? _statusMessage;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _prepareMap();
  }

  Future<void> _prepareMap() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (!MapsConfig.isConfigured) {
        setState(() {
          _initialPosition = _defaultPosition();
          _position = _initialPosition;
          _mapUnavailable = true;
          _statusMessage =
              'الخريطة غير متاحة حالياً. يمكنك تأكيد موقع بغداد الافتراضي أو إغلاق النافذة.';
        });
        return;
      }

      setState(() {
        _initialPosition = _defaultPosition();
        _position = _initialPosition;
        _mapReady = true;
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('MapPickerSheet init failed: $e\n$stack');
      }
      if (!mounted) return;
      setState(() {
        _initialPosition = _defaultPosition();
        _position = _initialPosition;
        _mapUnavailable = true;
        _statusMessage = 'تعذّر تحميل الخريطة. تم استخدام موقع بغداد الافتراضي.';
      });
    }
  }

  LatLng _defaultPosition() {
    return LatLng(
      widget.initialLat ?? baghdadLatLng.latitude,
      widget.initialLng ?? baghdadLatLng.longitude,
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      final latLng = await resolveDeviceLocation();
      if (!mounted) return;

      if (latLng == baghdadLatLng &&
          widget.initialLat == null &&
          widget.initialLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذّر تحديد موقعك. تم استخدام موقع بغداد الافتراضي.',
            ),
          ),
        );
      }

      setState(() => _position = latLng);
      await _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      if (kDebugMode) debugPrint('Current location failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر الحصول على الموقع')),
      );
    }
  }

  void _confirm() {
    final pos = _position ?? _initialPosition ?? baghdadLatLng;
    Navigator.pop(context, (pos.latitude, pos.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.92,
      child: Column(
        children: [
          AppBar(
            title: const Text('تحديد الموقع'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(child: _buildMapArea()),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_statusMessage != null) ...[
                    Text(
                      _statusMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_position != null)
                    Text(
                      'الإحداثيات: ${_position!.latitude.toStringAsFixed(5)}, '
                      '${_position!.longitude.toStringAsFixed(5)}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('استخدام موقعي الحالي'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _confirm,
                    child: const Text('تأكيد الموقع'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    if (_initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mapUnavailable || !_mapReady) {
      return _MapFallback(
        position: _position ?? _initialPosition!,
        unavailable: _mapUnavailable,
      );
    }

    final position = _position ?? _initialPosition!;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition!,
        zoom: 12,
      ),
      onMapCreated: (controller) => _mapController = controller,
      cameraTargetBounds: CameraTargetBounds(iraqMapBounds),
      minMaxZoomPreference: const MinMaxZoomPreference(5, 18),
      markers: {
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          draggable: true,
          onDragEnd: (pos) => setState(() => _position = pos),
        ),
      },
      onTap: (pos) => setState(() => _position = pos),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({
    required this.position,
    required this.unavailable,
  });

  final LatLng position;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unavailable ? Icons.map_outlined : Icons.hourglass_top,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                unavailable
                    ? 'الخريطة غير متاحة'
                    : 'جاري تحميل الخريطة...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
                textDirection: TextDirection.ltr,
              ),
              if (!unavailable) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
