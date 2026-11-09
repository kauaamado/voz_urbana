import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/widgets/empty_occurrences.dart';
import 'package:voz_urbana/widgets/filter_bar.dart';

Widget _app(OccurrenceProvider p, Widget child) => ChangeNotifierProvider.value(
      value: p,
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  testWidgets('sem filtro mostra o botão e nenhum chip', (tester) async {
    await tester.pumpWidget(_app(OccurrenceProvider(), const FilterBar()));
    expect(find.text('Filtrar período'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('com filtro mostra o período e remover limpa o filtro', (tester) async {
    final p = OccurrenceProvider()
      ..setFilterDateRange(DateTime(2026, 3, 1), DateTime(2026, 3, 15));
    await tester.pumpWidget(_app(p, const FilterBar()));

    expect(find.text('01/03 – 15/03'), findsOneWidget);
    await tester.tap(find.byTooltip('Limpar filtro'));
    await tester.pump();
    expect(p.hasActiveFilter, isFalse);
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('estado vazio filtrado oferece limpar o filtro', (tester) async {
    final p = OccurrenceProvider()
      ..setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    await tester.pumpWidget(_app(p, const EmptyOccurrences(filtered: true)));

    expect(find.text('Nenhuma ocorrência neste período'), findsOneWidget);
    await tester.tap(find.text('Limpar filtro'));
    expect(p.hasActiveFilter, isFalse);
  });

  testWidgets('estado vazio sem filtro não oferece limpar', (tester) async {
    await tester.pumpWidget(
      _app(OccurrenceProvider(), const EmptyOccurrences(filtered: false)),
    );
    expect(find.text('Nenhuma ocorrência registrada.'), findsOneWidget);
    expect(find.text('Limpar filtro'), findsNothing);
  });
}
