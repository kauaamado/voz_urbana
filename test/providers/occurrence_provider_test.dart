import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';

void main() {
  test('começa com 4 ocorrências de exemplo e sem filtro ativo', () {
    final p = OccurrenceProvider();
    expect(p.occurrences.length, 4);
    expect(p.hasActiveFilter, isFalse);
  });

  test('filtro que exclui tudo deixa a lista vazia e fica ativo', () {
    final p = OccurrenceProvider();
    p.setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    expect(p.occurrences, isEmpty);
    expect(p.hasActiveFilter, isTrue);
  });

  test('clearFilter restaura as ocorrências', () {
    final p = OccurrenceProvider();
    p.setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    p.clearFilter();
    expect(p.occurrences.length, 4);
    expect(p.hasActiveFilter, isFalse);
  });

  test('addOccurrence coloca o novo registro em primeiro', () {
    final p = OccurrenceProvider();
    p.addOccurrence(Occurrence(
      title: 'Novo',
      description: '',
      category: OccurrenceCategory.lazer,
      location: const LatLng(0, 0),
    ));
    expect(p.occurrences.first.title, 'Novo');
    expect(p.occurrences.length, 5);
  });

  test('filtro de um único dia inclui só esse dia, do início ao fim', () {
    final p = OccurrenceProvider();
    Occurrence em(String titulo, DateTime quando) => Occurrence(
          title: titulo,
          description: '',
          category: OccurrenceCategory.lazer,
          location: const LatLng(0, 0),
          dateTime: quando,
        );
    p.addOccurrence(em('dia anterior', DateTime(2026, 3, 4, 23, 59)));
    p.addOccurrence(em('início do dia', DateTime(2026, 3, 5, 0, 0)));
    p.addOccurrence(em('fim do dia', DateTime(2026, 3, 5, 23, 59)));
    p.addOccurrence(em('dia seguinte', DateTime(2026, 3, 6, 0, 0)));

    // O seletor de datas devolve as duas pontas à meia-noite.
    p.setFilterDateRange(DateTime(2026, 3, 5), DateTime(2026, 3, 5));

    final titulos = p.occurrences.map((o) => o.title).toSet();
    expect(titulos, {'início do dia', 'fim do dia'});
  });

  test('filtro de vários dias inclui o último dia inteiro', () {
    final p = OccurrenceProvider();
    p.addOccurrence(Occurrence(
      title: 'último dia à noite',
      description: '',
      category: OccurrenceCategory.lazer,
      location: const LatLng(0, 0),
      dateTime: DateTime(2026, 3, 10, 22, 0),
    ));
    p.setFilterDateRange(DateTime(2026, 3, 8), DateTime(2026, 3, 10));
    expect(p.occurrences.map((o) => o.title), contains('último dia à noite'));
  });
}
