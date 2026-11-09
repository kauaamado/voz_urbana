import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/widgets/occurrence_image.dart';

void main() {
  testWidgets('arquivo inexistente mostra imagem quebrada sem lançar', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OccurrenceImage(path: '/nao/existe.jpg', height: 100),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    expect(find.byIcon(Icons.broken_image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('decodifica na dimensão exibida (largura finita)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OccurrenceImage(path: '/x.jpg', width: 72, height: 72),
        ),
      ),
    );
    final provider = tester.widget<Image>(find.byType(Image)).image;
    expect(provider, isA<ResizeImage>());
    expect(
      (provider as ResizeImage).width,
      (72 * tester.view.devicePixelRatio).round(),
    );
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('largura infinita decodifica pela altura', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OccurrenceImage(
            path: '/x.jpg',
            width: double.infinity,
            height: 200,
          ),
        ),
      ),
    );
    final provider =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(provider.height, (200 * tester.view.devicePixelRatio).round());
    expect(provider.width, isNull);
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('tem rótulo para leitores de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OccurrenceImage(path: '/x.jpg', height: 100)),
      ),
    );
    expect(find.bySemanticsLabel('Foto da ocorrência'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    handle.dispose();
  });
}
