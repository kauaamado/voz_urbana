import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/widgets/occurrence_marker.dart';

Occurrence _occ() => Occurrence(
      title: 'Poste sem luz',
      description: '',
      category: OccurrenceCategory.iluminacaoPublica,
      location: const LatLng(0, 0),
    );

void main() {
  testWidgets('sem foto mostra o ícone da categoria, com ≥44 px', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: OccurrenceMarker(occurrence: _occ(), onTap: () {}))),
    ));
    expect(find.byIcon(OccurrenceCategory.iluminacaoPublica.icon), findsOneWidget);
    final size = tester.getSize(find.byType(OccurrenceMarker));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('toque chama onTap', (tester) async {
    var tocou = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: OccurrenceMarker(occurrence: _occ(), onTap: () => tocou = true)),
      ),
    ));
    await tester.tap(find.byType(OccurrenceMarker));
    expect(tocou, isTrue);
  });

  testWidgets('semântica contém título e categoria', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: OccurrenceMarker(occurrence: _occ(), onTap: () {}))),
    ));
    expect(
      find.bySemanticsLabel('Poste sem luz, Iluminação Pública'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
