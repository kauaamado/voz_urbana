import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/models/occurrence.dart';
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

  testWidgets('botão de filtro usa ícone de calendário, com e sem filtro', (tester) async {
    final p = OccurrenceProvider();
    await tester.pumpWidget(_app(p, const FilterBar()));
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt), findsNothing);

    p.setFilterDateRange(DateTime(2026, 3, 1), DateTime(2026, 3, 2));
    await tester.pump();
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt), findsNothing);
  });

  Occurrence em(DateTime quando) => Occurrence(
        title: 'x',
        description: '',
        category: OccurrenceCategory.lazer,
        location: const LatLng(0, 0),
        dateTime: quando,
      );

  testWidgets('mostra "1 ocorrência" no singular', (tester) async {
    final p = OccurrenceProvider()..addOccurrence(em(DateTime(2026, 3, 5, 12)));
    p.setFilterDateRange(DateTime(2026, 3, 5), DateTime(2026, 3, 5));
    await tester.pumpWidget(_app(p, const FilterBar()));
    expect(find.text('1 ocorrência'), findsOneWidget);
  });

  testWidgets('mostra "0 ocorrências" quando nada bate', (tester) async {
    final p = OccurrenceProvider()
      ..setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    await tester.pumpWidget(_app(p, const FilterBar()));
    expect(find.text('0 ocorrências'), findsOneWidget);
  });

  testWidgets('não mostra contagem sem filtro', (tester) async {
    await tester.pumpWidget(_app(OccurrenceProvider(), const FilterBar()));
    expect(find.textContaining('ocorrência'), findsNothing);
  });

  testWidgets('a contagem atualiza ao entrar uma ocorrência no período', (tester) async {
    final p = OccurrenceProvider()..addOccurrence(em(DateTime(2026, 3, 5, 9)));
    p.setFilterDateRange(DateTime(2026, 3, 5), DateTime(2026, 3, 5));
    await tester.pumpWidget(_app(p, const FilterBar()));
    expect(find.text('1 ocorrência'), findsOneWidget);

    p.addOccurrence(em(DateTime(2026, 3, 5, 18)));
    await tester.pump();
    expect(find.text('2 ocorrências'), findsOneWidget);
  });

  testWidgets('contagem é anunciada por leitores de tela (liveRegion)', (tester) async {
    final handle = tester.ensureSemantics();
    final p = OccurrenceProvider()
      ..setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    await tester.pumpWidget(_app(p, const FilterBar()));
    final node = tester.getSemantics(find.text('0 ocorrências'));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });
}
