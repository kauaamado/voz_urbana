import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/occurrence_provider.dart';
import '../services/location_service.dart';
import '../theme/design_system.dart';
import '../widgets/empty_occurrences.dart';
import '../widgets/filter_bar.dart';
import '../widgets/occurrence_detail_sheet.dart';
import '../widgets/occurrence_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.locationService});

  final LocationService? locationService;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCenter = LatLng(-22.5112, -43.1779); // CEFET-RJ Petrópolis

  final _mapController = MapController();
  late final LocationService _locationService =
      widget.locationService ?? GeolocatorLocationService();

  LatLng? _myPosition;
  bool _locating = false;

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    final result = await _locationService.current();
    if (!mounted) return;
    setState(() => _locating = false);

    if (result is LocationOk) {
      setState(() => _myPosition = result.position);
      _mapController.move(result.position, 16);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: DesignSystem.error,
        action: result.actionLabel == null
            ? null
            : SnackBarAction(
                label: result.actionLabel!,
                textColor: Colors.white,
                onPressed: () => switch (result) {
                  LocationServiceDisabled() =>
                    _locationService.openLocationSettings(),
                  LocationDeniedForever() => _locationService.openAppSettings(),
                  _ => _goToMyLocation(),
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OccurrenceProvider>();
    final occurrences = provider.occurrences;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.voz_urbana',
            ),
            MarkerLayer(
              markers: [
                for (final o in occurrences)
                  Marker(
                    point: o.location,
                    width: OccurrenceMarker.size,
                    height: OccurrenceMarker.size,
                    child: OccurrenceMarker(
                      occurrence: o,
                      onTap: () => showOccurrenceDetails(context, o),
                    ),
                  ),
                if (_myPosition != null)
                  Marker(
                    point: _myPosition!,
                    width: 28,
                    height: 28,
                    child: Semantics(
                      label: 'Você está aqui',
                      child: const Icon(Icons.my_location,
                          color: DesignSystem.primary, size: 28),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const Positioned(top: 0, left: 0, right: 0, child: FilterBar()),
        if (provider.hasActiveFilter && occurrences.isEmpty)
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: EmptyOccurrences(filtered: true),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 88, // acima do botão "Registrar"
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: 'Minha localização',
            backgroundColor: DesignSystem.surface,
            foregroundColor: DesignSystem.primary,
            onPressed: _locating ? null : _goToMyLocation,
            child: _locating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
