import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

sealed class LocationResult {
  const LocationResult();
}

class LocationOk extends LocationResult {
  final LatLng position;
  const LocationOk(this.position);
}

class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}

class LocationDenied extends LocationResult {
  const LocationDenied();
}

class LocationDeniedForever extends LocationResult {
  const LocationDeniedForever();
}

class LocationError extends LocationResult {
  final Object error;
  const LocationError(this.error);
}

extension LocationResultText on LocationResult {
  String get message => switch (this) {
    LocationOk() => 'Localização capturada',
    LocationServiceDisabled() =>
      'O GPS está desativado. Ative-o para registrar a ocorrência.',
    LocationDenied() => 'Permissão de localização negada.',
    LocationDeniedForever() =>
      'Permissão de localização bloqueada. Libere-a nas configurações do aplicativo.',
    LocationError() => 'Não foi possível obter a localização.',
  };

  String? get actionLabel => switch (this) {
    LocationOk() => null,
    LocationServiceDisabled() => 'Ativar GPS',
    LocationDeniedForever() => 'Abrir configurações',
    LocationDenied() || LocationError() => 'Tentar novamente',
  };
}

abstract class LocationService {
  Future<LocationResult> current();
  Future<void> openLocationSettings();
  Future<void> openAppSettings();
}

class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService({
    this.positionTimeout = const Duration(seconds: 15),
  });

  /// Tempo máximo esperando o fix do GPS (ex.: ambiente fechado).
  final Duration positionTimeout;

  @override
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationServiceDisabled();
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationDeniedForever();
      }
      if (permission == LocationPermission.denied) {
        return const LocationDenied();
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: positionTimeout,
        ),
      ).timeout(positionTimeout);
      return LocationOk(LatLng(position.latitude, position.longitude));
    } catch (e) {
      return LocationError(e);
    }
  }

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
