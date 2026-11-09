import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/widgets/occurrence_image.dart';

void main() {
  testWidgets('arquivo inexistente mostra imagem quebrada sem lançar', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: OccurrenceImage(path: '/nao/existe.jpg', height: 100)),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
