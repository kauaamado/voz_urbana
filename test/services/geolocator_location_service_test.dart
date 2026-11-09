// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:voz_urbana/services/location_service.dart';

/// Plataforma que nunca devolve a posição (GPS sem fix em ambiente fechado).
class _HangingPlatform extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      Completer<Position>().future;
}

void main() {
  test(
    'GPS sem fix vira LocationError em vez de ficar carregando para sempre',
    () async {
      GeolocatorPlatform.instance = _HangingPlatform();
      final service = GeolocatorLocationService(
        positionTimeout: const Duration(milliseconds: 50),
      );

      final result = await service.current().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw StateError('current() não respeitou o timeout'),
      );

      expect(result, isA<LocationError>());
      expect(result.actionLabel, 'Tentar novamente');
    },
  );
}
