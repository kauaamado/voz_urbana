import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/services/address_service.dart';

void main() {
  group('NominatimAddressService.parse', () {
    test('monta "Rua, Bairro, Cidade" a partir de address', () {
      const body =
          '{"display_name":"longo demais","address":{"road":"Rua X","suburb":"Centro","city":"Petrópolis"}}';
      expect(NominatimAddressService.parse(body), 'Rua X, Centro, Petrópolis');
    });

    test('usa display_name quando não há address utilizável', () {
      expect(
        NominatimAddressService.parse('{"display_name":"Algum lugar, RJ"}'),
        'Algum lugar, RJ',
      );
    });

    test('corpo vazio, JSON inválido ou sem campos retornam null', () {
      expect(NominatimAddressService.parse(''), isNull);
      expect(NominatimAddressService.parse('<html>'), isNull);
      expect(NominatimAddressService.parse('{"error":"Unable to geocode"}'), isNull);
      expect(NominatimAddressService.parse('[]'), isNull);
    });
  });

  group('NominatimAddressService.reverse', () {
    test('mesma posição não repete a requisição (cache)', () async {
      var chamadas = 0;
      final service = NominatimAddressService(
        fetch: (lat, lon) async {
          chamadas++;
          return '{"display_name":"Rua Y"}';
        },
      );
      const p = LatLng(-22.5112, -43.1779);
      expect(await service.reverse(p), 'Rua Y');
      expect(await service.reverse(p), 'Rua Y');
      expect(chamadas, 1);
    });

    test('falha de rede retorna null sem lançar', () async {
      final service = NominatimAddressService(
        fetch: (lat, lon) async => throw Exception('sem internet'),
      );
      expect(await service.reverse(const LatLng(0, 0)), isNull);
    });
  });
}
