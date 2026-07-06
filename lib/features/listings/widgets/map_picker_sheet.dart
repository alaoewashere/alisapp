import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/maps_config.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/map_geocoding_service.dart';
import '../../../core/utils/map_location_service.dart';

class MapPickerSheet extends ConsumerStatefulWidget {
  const MapPickerSheet({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  final double? initialLat;
  final double? initialLng;

  @override
  ConsumerState<MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends ConsumerState<MapPickerSheet> {
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

      final strings = ref.read(appLocalizationsProvider);

      if (!MapsConfig.isConfigured) {
        setState(() {
          _initialPosition = _defaultPosition();
          _position = _initialPosition;
          _mapUnavailable = true;
          _statusMessage = strings.locationMapUnavailableStatus;
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
      final strings = ref.read(appLocalizationsProvider);
      setState(() {
        _initialPosition = _defaultPosition();
        _position = _initialPosition;
        _mapUnavailable = true;
        _statusMessage = strings.locationMapLoadFailedStatus;
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
    final strings = ref.read(appLocalizationsProvider);
    try {
      final latLng = await resolveDeviceLocation();
      if (!mounted) return;

      if (latLng == baghdadLatLng &&
          widget.initialLat == null &&
          widget.initialLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.locationGpsFailedSnack)),
        );
      }

      setState(() => _position = latLng);
      await _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      if (kDebugMode) debugPrint('Current location failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.locationFetchFailedSnack)),
      );
    }
  }

  bool _confirming = false;

  Future<void> _confirm() async {
    if (_confirming) return;
    setState(() => _confirming = true);

    final pos = _position ?? _initialPosition ?? baghdadLatLng;
    String? address;
    try {
      address = await reverseGeocodeLatLng(pos);
    } catch (e) {
      if (kDebugMode) debugPrint('Reverse geocode failed: $e');
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      MapPickerResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.92,
      child: Column(
        children: [
          AppBar(
            title: Text(strings.locationPickerTitle),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(child: _buildMapArea(strings)),
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
                      '${strings.locationCoordinates}: '
                      '${_position!.latitude.toStringAsFixed(5)}, '
                      '${_position!.longitude.toStringAsFixed(5)}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(strings.locationUseCurrentLocation),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _confirming ? null : _confirm,
                    child: _confirming
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.locationConfirm),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea(AppLocalizations strings) {
    if (_initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mapUnavailable || !_mapReady) {
      return _MapFallback(
        position: _position ?? _initialPosition!,
        unavailable: _mapUnavailable,
        unavailableLabel: strings.locationMapUnavailable,
        loadingLabel: strings.locationLoadingMap,
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
    required this.unavailableLabel,
    required this.loadingLabel,
  });

  final LatLng position;
  final bool unavailable;
  final String unavailableLabel;
  final String loadingLabel;

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
                unavailable ? unavailableLabel : loadingLabel,
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
