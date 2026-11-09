import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/widgets/category_chips.dart';

void main() {
  testWidgets('mostra 6 categorias e toque chama onSelected', (tester) async {
    OccurrenceCategory? escolhida;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CategoryChips(selected: null, onSelected: (c) => escolhida = c),
      ),
    ));

    expect(find.byType(ChoiceChip), findsNWidgets(6));
    await tester.tap(find.text('Saneamento'));
    expect(escolhida, OccurrenceCategory.saneamento);
  });

  testWidgets('alvo de toque tem ao menos 44 px de altura', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CategoryChips(selected: null, onSelected: (_) {})),
    ));
    final size = tester.getSize(find.byType(ChoiceChip).first);
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('categoria selecionada aparece marcada', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CategoryChips(
          selected: OccurrenceCategory.lazer,
          onSelected: (_) {},
        ),
      ),
    ));
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Lazer'),
    );
    expect(chip.selected, isTrue);
  });
}
