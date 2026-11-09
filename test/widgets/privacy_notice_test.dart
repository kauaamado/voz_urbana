import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/widgets/privacy_notice.dart';

Widget _app({double scale = 1.0}) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const Scaffold(body: SingleChildScrollView(child: PrivacyNotice())),
    );

void main() {
  testWidgets('mostra o aviso e o botão "Saiba mais"', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.textContaining('Sua publicação é anônima'), findsOneWidget);
    expect(find.text('Saiba mais'), findsOneWidget);
  });

  testWidgets('"Saiba mais" abre o painel e "Entendi" o fecha', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Saiba mais'));
    await tester.pumpAndSettle();

    expect(find.text('Privacidade e LGPD'), findsOneWidget);
    expect(find.text('Evite fotografar rostos e placas de veículos.'), findsOneWidget);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('Privacidade e LGPD'), findsNothing);
  });

  testWidgets('painel rola em tela pequena com fonte a 200 %', (tester) async {
    tester.view.physicalSize = const Size(400, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(scale: 2.0));
    await tester.tap(find.text('Saiba mais'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Entendi'),
      100,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('Privacidade e LGPD'), findsNothing);
  });
}
