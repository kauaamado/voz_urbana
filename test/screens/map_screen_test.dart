import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/screens/map_screen.dart';
import 'package:voz_urbana/services/location_service.dart';
import 'package:voz_urbana/widgets/filter_bar.dart';
import 'package:voz_urbana/widgets/occurrence_marker.dart';

import '../helpers/fakes.dart';

Future<OccurrenceProvider> _abrir(WidgetTester tester, FakeLocation loc) async {
  final provider = OccurrenceProvider();
  await tester.pumpWidget(ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      home: Scaffold(body: MapScreen(locationService: loc)),
    ),
  ));
  await tester.pump();
  return provider;
}

void main() {
  testWidgets('mostra o filtro e um marcador por ocorrência', (tester) async {
    await _abrir(tester, FakeLocation(const LocationOk(LatLng(-22.51, -43.17))));
    expect(find.byType(FilterBar), findsOneWidget);
    expect(find.byType(OccurrenceMarker), findsNWidgets(4));
  });

  testWidgets('filtro sem resultados mostra aviso e some com os marcadores', (tester) async {
    final p = await _abrir(tester, FakeLocation(const LocationOk(LatLng(0, 0))));
    p.setFilterDateRange(DateTime(2020, 1, 1), DateTime(2020, 1, 2));
    await tester.pump();
    expect(find.byType(OccurrenceMarker), findsNothing);
    expect(find.text('Nenhuma ocorrência neste período'), findsOneWidget);
  });

  testWidgets('"minha localização" consulta o serviço e mostra a posição', (tester) async {
    final loc = FakeLocation(const LocationOk(LatLng(-22.5112, -43.1779)));
    await _abrir(tester, loc);
    await tester.tap(find.byTooltip('Minha localização'));
    await tester.pump();
    await tester.pump();
    expect(loc.calls, 1);
    expect(find.byIcon(Icons.my_location), findsWidgets);
  });

  testWidgets('falha de GPS mostra mensagem com ação', (tester) async {
    final loc = FakeLocation(const LocationServiceDisabled());
    await _abrir(tester, loc);
    await tester.tap(find.byTooltip('Minha localização'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // fim da animação do SnackBar
    expect(find.textContaining('GPS está desativado'), findsOneWidget);
    await tester.tap(find.text('Ativar GPS'));
    expect(loc.locationSettings, 1);
  });
}
