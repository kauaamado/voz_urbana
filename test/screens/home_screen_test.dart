import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/screens/home_screen.dart';

void main() {
  testWidgets('botão de registrar tem rótulo acessível e abas têm nome', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => OccurrenceProvider(),
      child: const MaterialApp(home: HomeScreen()),
    ));
    expect(find.byTooltip('Registrar nova ocorrência'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Linha do Tempo'), findsOneWidget);
    handle.dispose();
  });
}
