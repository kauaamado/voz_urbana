import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/services/location_service.dart';

void main() {
  final casos = <LocationResult, String?>{
    const LocationServiceDisabled(): 'Ativar GPS',
    const LocationDenied(): 'Tentar novamente',
    const LocationDeniedForever(): 'Abrir configurações',
    LocationError(Exception('x')): 'Tentar novamente',
  };

  casos.forEach((resultado, acao) {
    test('${resultado.runtimeType} tem mensagem e ação "$acao"', () {
      expect(resultado.message, isNotEmpty);
      expect(resultado.actionLabel, acao);
    });
  });

  test('LocationOk não tem ação', () {
    const ok = LocationOk(LatLng(1, 2));
    expect(ok.actionLabel, isNull);
    expect(ok.position, const LatLng(1, 2));
  });
}
