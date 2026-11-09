import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/models/occurrence.dart';

void main() {
  group('Occurrence.titleFor', () {
    test('usa o rótulo da categoria quando o título está em branco', () {
      expect(
        Occurrence.titleFor('  ', OccurrenceCategory.saneamento),
        'Saneamento',
      );
    });

    test('remove espaços do título digitado', () {
      expect(
        Occurrence.titleFor(' Buraco ', OccurrenceCategory.pavimentacao),
        'Buraco',
      );
    });
  });

  group('OccurrenceCategory', () {
    test('tem 6 categorias, todas com ícone e cor', () {
      expect(OccurrenceCategory.values.length, 6);
      for (final c in OccurrenceCategory.values) {
        expect(c.icon, isNotNull);
        expect(c.color, isNotNull);
      }
    });
  });

  group('Occurrence.address', () {
    test('é nulo por padrão e aceita valor', () {
      final semEndereco = Occurrence(
        title: 'a',
        description: '',
        category: OccurrenceCategory.lazer,
        location: const LatLng(0, 0),
      );
      final comEndereco = Occurrence(
        title: 'a',
        description: '',
        category: OccurrenceCategory.lazer,
        location: const LatLng(0, 0),
        address: 'Rua X',
      );
      expect(semEndereco.address, isNull);
      expect(comEndereco.address, 'Rua X');
    });
  });
}
