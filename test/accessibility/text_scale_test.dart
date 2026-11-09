import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/screens/new_occurrence_screen.dart';
import 'package:voz_urbana/screens/timeline_screen.dart';
import 'package:voz_urbana/services/location_service.dart';
import 'package:voz_urbana/widgets/filter_bar.dart';
import 'package:voz_urbana/widgets/occurrence_detail_sheet.dart';

import '../helpers/fakes.dart';

/// Monta [child] com a fonte do sistema a 200 % em uma tela de 400×800.
Future<void> _pump(
  WidgetTester tester,
  OccurrenceProvider provider,
  Widget child,
) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
        child: c!,
      ),
      home: Scaffold(body: child),
    ),
  ));
  await tester.pumpAndSettle();
}

Occurrence _longa() => Occurrence(
      title: 'Vazamento de água na calçada em frente à escola',
      description: 'Cano estourado desperdiçando água potável há vários dias.',
      category: OccurrenceCategory.iluminacaoPublica,
      location: const LatLng(0, 0),
      address: 'Rua do Imperador, Centro, Petrópolis',
      imagePath: '/nao/existe.jpg',
    );

void main() {
  testWidgets('Linha do Tempo a 200 % não estoura', (tester) async {
    final p = OccurrenceProvider()..addOccurrence(_longa());
    await _pump(tester, p, const TimelineScreen());
    expect(tester.takeException(), isNull);
  });

  testWidgets('FilterBar com filtro ativo a 200 % não estoura', (tester) async {
    final p = OccurrenceProvider()
      ..setFilterDateRange(DateTime(2026, 3, 1), DateTime(2026, 3, 31));
    await _pump(tester, p, const FilterBar());
    expect(tester.takeException(), isNull);
  });

  testWidgets('registro a 200 % não estoura', (tester) async {
    await _pump(
      tester,
      OccurrenceProvider(),
      NewOccurrenceScreen(
        locationService: FakeLocation(const LocationOk(LatLng(0, 0))),
        addressService: FakeAddress('Rua do Imperador, Centro, Petrópolis'),
        pickImagePath: (ImageSource _) async => '/fake/foto.jpg',
      ),
    );
    await tester.tap(find.text('Câmera'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iluminação Pública'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('detalhe da ocorrência a 200 % não estoura', (tester) async {
    await _pump(
      tester,
      OccurrenceProvider(),
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showOccurrenceDetails(context, _longa()),
          child: const Text('abrir'),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
