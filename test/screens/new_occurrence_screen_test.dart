import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/providers/occurrence_provider.dart';
import 'package:voz_urbana/screens/new_occurrence_screen.dart';
import 'package:voz_urbana/services/address_service.dart';
import 'package:voz_urbana/services/location_service.dart';

import '../helpers/fakes.dart';

const _ok = LocationOk(LatLng(-22.5, -43.1));

Future<OccurrenceProvider> _abrir(
  WidgetTester tester, {
  LocationService? location,
  AddressService? address,
  Future<String?> Function(ImageSource)? picker,
}) async {
  await tester.binding.setSurfaceSize(const Size(500, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final provider = OccurrenceProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewOccurrenceScreen(
                      locationService: location ?? FakeLocation(_ok),
                      addressService: address ?? FakeAddress(null),
                      pickImagePath: picker ?? (_) async => '/fake/foto.jpg',
                    ),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return provider;
}

Finder get _publicar => find.widgetWithText(ElevatedButton, 'Publicar');
bool _habilitado(WidgetTester t) =>
    t.widget<ElevatedButton>(_publicar).onPressed != null;

Future<void> _fotoECategoria(WidgetTester tester) async {
  await tester.tap(find.text('Câmera'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Lazer'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'abre desabilitado dizendo o que falta; habilita com foto e categoria',
    (tester) async {
      await _abrir(tester);
      expect(_habilitado(tester), isFalse);
      expect(find.text('Falta: foto, categoria'), findsOneWidget);

      await _fotoECategoria(tester);
      expect(_habilitado(tester), isTrue);
      expect(find.textContaining('Falta:'), findsNothing);
    },
  );

  testWidgets('cancelar a câmera (null) não altera nada nem lança', (
    tester,
  ) async {
    await _abrir(tester, picker: (_) async => null);
    await tester.tap(find.text('Câmera'));
    await tester.pumpAndSettle();
    expect(find.text('Falta: foto, categoria'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permissão negada para sempre oferece abrir configurações', (
    tester,
  ) async {
    final loc = FakeLocation(const LocationDeniedForever());
    await _abrir(tester, location: loc);
    expect(find.text('Abrir configurações'), findsOneWidget);
    await tester.tap(find.text('Abrir configurações'));
    expect(loc.appSettings, 1);
    expect(
      find.textContaining('localização'),
      findsWidgets,
    ); // formulário segue utilizável
  });

  testWidgets('GPS desligado oferece ativar o GPS', (tester) async {
    final loc = FakeLocation(const LocationServiceDisabled());
    await _abrir(tester, location: loc);
    await tester.tap(find.text('Ativar GPS'));
    expect(loc.locationSettings, 1);
  });

  testWidgets(
    'título em branco vira o nome da categoria e descrição fica vazia',
    (tester) async {
      final provider = await _abrir(tester);
      await _fotoECategoria(tester);
      await tester.tap(find.text('Detalhes (opcional)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.tap(_publicar);
      await tester.pumpAndSettle();

      final nova = provider.occurrences.first;
      expect(nova.title, 'Lazer');
      expect(nova.description, '');
      expect(nova.category, OccurrenceCategory.lazer);
      expect(nova.imagePath, '/fake/foto.jpg');
      expect(find.text('Ocorrência registrada com sucesso!'), findsOneWidget);
    },
  );

  testWidgets('publica com o endereço encontrado', (tester) async {
    final provider = await _abrir(
      tester,
      address: FakeAddress('Rua Z, Centro'),
    );
    await _fotoECategoria(tester);
    await tester.tap(_publicar);
    await tester.pumpAndSettle();
    expect(provider.occurrences.first.address, 'Rua Z, Centro');
  });

  testWidgets('endereço indisponível não impede a publicação', (tester) async {
    final provider = await _abrir(tester, address: FakeAddress(null));
    expect(find.text('Endereço indisponível'), findsOneWidget);
    await _fotoECategoria(tester);
    await tester.tap(_publicar);
    await tester.pumpAndSettle();
    expect(provider.occurrences.first.address, isNull);
    expect(provider.occurrences.length, 5);
  });

  testWidgets('voltar com dados pergunta se deve descartar', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Câmera'));
    await tester.pumpAndSettle();

    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Descartar ocorrência?'), findsOneWidget);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Registrar ocorrência'), findsNothing);
  });

  testWidgets('voltar sem dados sai direto', (tester) async {
    await _abrir(tester);
    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Descartar ocorrência?'), findsNothing);
    expect(find.text('Registrar ocorrência'), findsNothing);
  });

  Future<void> idaEVoltaDoApp(WidgetTester tester) async {
    final b = tester.binding;
    for (final st in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      b.handleAppLifecycleStateChanged(st);
    }
    await tester.pumpAndSettle();
  }

  testWidgets('voltar da câmera não refaz o pedido de permissão', (
    tester,
  ) async {
    final loc = FakeLocation(const LocationDenied());
    await _abrir(tester, location: loc);
    expect(loc.calls, 1);

    await idaEVoltaDoApp(tester);
    expect(loc.calls, 1);
  });

  testWidgets('voltar das configurações do GPS tenta a localização de novo', (
    tester,
  ) async {
    final loc = FakeLocation(const LocationServiceDisabled());
    await _abrir(tester, location: loc);
    await tester.tap(find.text('Ativar GPS'));
    await tester.pump();

    await idaEVoltaDoApp(tester);
    expect(loc.calls, 2);
  });

  testWidgets('cartão de localização anuncia mudanças aos leitores de tela', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _abrir(tester);
    final node = tester.getSemantics(find.byKey(const Key('location-card')));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('título da tela é "Registrar ocorrência"', (tester) async {
    await _abrir(tester);
    expect(find.text('Registrar ocorrência'), findsOneWidget);
  });
}
