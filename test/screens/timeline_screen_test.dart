import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/screens/timeline_screen.dart';
import 'package:voz_urbana/widgets/filter_bar.dart';

Future<OccurrenceProvider> _abrir(WidgetTester tester) async {
  final provider = OccurrenceProvider();
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: Scaffold(body: TimelineScreen())),
  ));
  return provider;
}

void main() {
  testWidgets('lista as ocorrências e usa o filtro compartilhado', (tester) async {
    await _abrir(tester);
    expect(find.byType(FilterBar), findsOneWidget);
    expect(find.text('Buraco na via'), findsOneWidget);
    expect(find.text('Poste sem luz'), findsOneWidget);
  });

  testWidgets('filtro sem resultados mostra aviso e limpar restaura a lista', (tester) async {
    final p = await _abrir(tester);
    p.setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    await tester.pump();

    expect(find.text('Nenhuma ocorrência neste período'), findsOneWidget);
    await tester.tap(find.text('Limpar filtro'));
    await tester.pump();
    expect(find.text('Buraco na via'), findsOneWidget);
  });

  testWidgets('tocar em um cartão abre o detalhe', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Buraco na via'));
    await tester.pumpAndSettle();
    expect(find.text('Endereço indisponível'), findsOneWidget);
    expect(find.textContaining('Registrado em:'), findsOneWidget);
  });

  testWidgets('a barra do filtro ocupa toda a largura da tela', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _abrir(tester);
    expect(tester.getSize(find.byType(FilterBar)).width, 400);
    expect(tester.getTopLeft(find.byType(FilterBar)).dx, 0);
  });
}
