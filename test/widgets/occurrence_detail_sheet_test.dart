import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/widgets/occurrence_detail_sheet.dart';

Occurrence _occ({String description = 'Cano estourado', String? address}) =>
    Occurrence(
      title: 'Vazamento',
      description: description,
      category: OccurrenceCategory.saneamento,
      location: const LatLng(0, 0),
      address: address,
      dateTime: DateTime(2026, 3, 10, 14, 30),
    );

Future<void> _abrir(WidgetTester tester, Occurrence o) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showOccurrenceDetails(context, o),
          child: const Text('abrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra título, categoria, endereço e data', (tester) async {
    await _abrir(tester, _occ(address: 'Rua X, Centro'));
    expect(find.text('Vazamento'), findsOneWidget);
    expect(find.text('Saneamento'), findsOneWidget);
    expect(find.text('Rua X, Centro'), findsOneWidget);
    expect(find.textContaining('10/03/2026 14:30'), findsOneWidget);
  });

  testWidgets('sem endereço mostra "Endereço indisponível"', (tester) async {
    await _abrir(tester, _occ());
    expect(find.text('Endereço indisponível'), findsOneWidget);
  });

  testWidgets('descrição vazia não é exibida', (tester) async {
    await _abrir(tester, _occ(description: ''));
    expect(find.text('Cano estourado'), findsNothing);
    expect(find.text('Vazamento'), findsOneWidget);
  });
}
