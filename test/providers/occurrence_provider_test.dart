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
}
