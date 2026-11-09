# Ajustes de Usabilidade — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deixar o protótipo Voz Urbana aderente aos requisitos RF1–RF5, RU1–RU5 e RNF2 do documento do aluno, com publicação em até 4 toques.

**Architecture:** Mantém `OccurrenceProvider` como fonte única (lista + filtro). Lógica de plataforma (GPS, endereço) sai da tela para serviços com interface abstrata, injetáveis por construtor (testáveis com fakes). Elementos repetidos entre Mapa e Linha do Tempo viram widgets em `lib/widgets/`.

**Tech Stack:** Flutter, Dart ^3.12.2, provider, geolocator, flutter_map, image_picker, intl, uuid. **Nenhuma dependência nova.**

**Spec:** `docs/superpowers/specs/2026-11-08-ajustes-usabilidade-design.md`

## Global Constraints

- Nenhuma dependência nova em `pubspec.yaml` (endereço via `dart:io` `HttpClient`).
- Todo texto visível ao usuário em português do Brasil, com acentuação correta.
- Alvos de toque ≥ 44 px (`DesignSystem.minTouchTarget`); texto de conteúdo ≥ 14 px, metadados ≥ 12 px.
- `DesignSystem.success` passa a `Color(0xFF15803D)`.
- Foto, categoria e localização obrigatórias para publicar; título e descrição opcionais; título vazio vira o `label` da categoria.
- Sem diálogo de confirmação de publicação (a tela de registro é a revisão).
- Fora do escopo: login, editar/excluir, backend, persistência, relatório/slides, mexer em `DESIGN.md`.
- Commits em conventional commits, em português (ex.: `feat(registro): ...`), um por tarefa. Só commitar quando o aluno autorizar a execução do plano.
- Antes de cada commit: `flutter analyze` sem avisos e `flutter test` verde.
- Contrato de textos (usado nos testes): `'Publicar'`, `'Falta: foto, categoria'` (itens na ordem foto, categoria, localização, separados por `', '`), `'Filtrar período'`, `'Limpar filtro'`, `'Nenhuma ocorrência registrada.'`, `'Nenhuma ocorrência neste período'`, `'Endereço indisponível'`, `'Descartar registro?'`.

## Review Focus

1. Permissão de GPS negada para sempre → mensagem com ação "Abrir configurações", sem travar o formulário. (Task 7)
2. Usuário cancela a câmera/galeria (retorno nulo) → nada muda, sem erro. (Task 7)
3. Título só com espaços → vira o nome da categoria; descrição vazia aceita. (Tasks 2 e 7)
4. Nominatim lento, sem internet ou JSON malformado/vazio → `null`, publica mesmo assim. (Task 4)
5. Foto cujo arquivo sumiu ou URL inválida → ícone de imagem quebrada, sem exceção. (Task 5)

---

### Task 1: Modelo e tema

**Files:**
- Modify: `lib/models/occurrence.dart`
- Modify: `lib/theme/design_system.dart` (`success`, comentários "FeedLoop")
- Delete/Replace: `test/widget_test.dart` (template do contador, quebrado) → `test/models/occurrence_test.dart`

**Interfaces:**
- Produces: `OccurrenceCategory.icon` (`IconData`), `OccurrenceCategory.color` (`Color`); `Occurrence.address` (`String?`, parâmetro nomeado opcional); `static String Occurrence.titleFor(String typed, OccurrenceCategory category)` → `typed.trim()` se não vazio, senão `category.label`.

- [ ] **Step 1: Escrever os testes** em `test/models/occurrence_test.dart`: `titleFor('  ', OccurrenceCategory.saneamento)` retorna `'Saneamento'`; `titleFor(' Buraco ', ...)` retorna `'Buraco'`; toda categoria tem `icon` e `color` não nulos e `values.length == 6`; `Occurrence(...).address` é `null` por padrão e aceita valor.
- [ ] **Step 2: Rodar** `flutter test test/models/occurrence_test.dart` → FALHA (membros não existem).
- [ ] **Step 3: Implementar** o enum com `(label, icon, color)` (ícones Material coerentes: lâmpada, estrada/construção, água, escudo, museu/monumento, parque; cores com contraste ≥3:1 sobre branco), `address` e `titleFor`. Trocar `success` no tema e remover os comentários "FeedLoop". Remover `test/widget_test.dart`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Commit** `feat(modelo): adiciona ícone, cor e endereço às ocorrências`

---

### Task 2: Provider — estado do filtro

**Files:**
- Modify: `lib/providers/occurrence_provider.dart`
- Test: `test/providers/occurrence_provider_test.dart`

**Interfaces:**
- Consumes: `Occurrence`, `OccurrenceCategory` (Task 1).
- Produces: `bool get hasActiveFilter` no `OccurrenceProvider`.

- [ ] **Step 1: Escrever os testes:** provider novo tem 4 ocorrências de exemplo e `hasActiveFilter == false`; `setFilterDateRange` com intervalo que exclui todas deixa `occurrences` vazio e `hasActiveFilter == true`; `clearFilter` restaura as 4; `addOccurrence` coloca o novo item primeiro (mais recente).
- [ ] **Step 2: Rodar** → FALHA (`hasActiveFilter` indefinido).
- [ ] **Step 3: Implementar** `hasActiveFilter` (`_filterStartDate != null && _filterEndDate != null`). Sem outras mudanças de API.
- [ ] **Step 4: Rodar** `flutter test test/providers` → PASSA.
- [ ] **Step 5: Commit** `feat(filtro): expõe hasActiveFilter no provider`

---

### Task 3: Serviço de localização

**Files:**
- Create: `lib/services/location_service.dart`
- Test: `test/services/location_service_test.dart` (só o contrato dos tipos; a chamada ao `Geolocator` é de plataforma)

**Interfaces:**
- Produces:
  - `sealed class LocationResult` com `LocationOk(LatLng position)`, `LocationServiceDisabled`, `LocationDenied`, `LocationDeniedForever`, `LocationError(Object error)`.
  - `abstract class LocationService { Future<LocationResult> current(); Future<void> openLocationSettings(); Future<void> openAppSettings(); }`
  - `class GeolocatorLocationService implements LocationService`.
  - Extensão `String LocationResult.message` (texto pt-BR por caso) e `String? actionLabel` (`'Ativar GPS'` para serviço desligado, `'Abrir configurações'` para negado para sempre, `'Tentar novamente'` para os demais).

- [ ] **Step 1: Escrever o teste:** para cada um dos cinco resultados, `message` é não vazio e `actionLabel` é o esperado acima; `LocationOk` não tem `actionLabel`.
- [ ] **Step 2: Rodar** → FALHA.
- [ ] **Step 3: Implementar** movendo a sequência hoje em `NewOccurrenceScreen._getLocation` (serviço ligado → permissão → `getCurrentPosition` com `LocationAccuracy.high`) para `GeolocatorLocationService.current()`, devolvendo o tipo selado; `openLocationSettings`/`openAppSettings` delegam ao `Geolocator`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Commit** `refactor(localizacao): extrai LocationService com resultados tipados`

---

### Task 4: Serviço de endereço (Nominatim)

**Files:**
- Create: `lib/services/address_service.dart`
- Test: `test/services/address_service_test.dart`

**Interfaces:**
- Consumes: `LatLng` (latlong2).
- Produces: `abstract class AddressService { Future<String?> reverse(LatLng position); }`; `class NominatimAddressService implements AddressService` com `static String? parse(String body)`.

- [ ] **Step 1: Confirmar a política de uso do Nominatim** (WebFetch em `operations.osmfoundation.org/policies/nominatim/`): exige `User-Agent` identificável e ≤1 req/s. Se mudou, ajustar a implementação e avisar o aluno.
- [ ] **Step 2: Escrever os testes de `parse`:** JSON com `display_name` retorna a string; JSON com `address` (`road`, `suburb`/`neighbourhood`, `city`) é preferido e montado como `"Rua X, Bairro, Cidade"`; corpo vazio, JSON inválido e JSON sem os campos retornam `null` (sem lançar).
- [ ] **Step 3: Rodar** → FALHA.
- [ ] **Step 4: Implementar** `reverse` com `dart:io` `HttpClient`: GET `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=..&lon=..&accept-language=pt-BR`, header `User-Agent: voz_urbana/1.0 (projeto academico CEFET/RJ)`, `connectionTimeout` e timeout total de 5 s; qualquer exceção ou status ≠ 200 → `null`.
- [ ] **Step 5: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 6: Commit** `feat(endereco): busca endereço via Nominatim sem dependências`

---

### Task 5: Widgets compartilhados

**Files:**
- Create: `lib/widgets/occurrence_image.dart`, `lib/widgets/category_chips.dart`, `lib/widgets/filter_bar.dart`, `lib/widgets/empty_occurrences.dart`
- Test: `test/widgets/category_chips_test.dart`, `test/widgets/filter_bar_test.dart`, `test/widgets/occurrence_image_test.dart`

**Interfaces:**
- Consumes: `OccurrenceCategory` (Task 1), `OccurrenceProvider.hasActiveFilter/setFilterDateRange/clearFilter` (Task 2).
- Produces:
  - `OccurrenceImage({required String path, double? height, double? width, BoxFit fit = BoxFit.cover})` — `http(s)` → `Image.network`, senão `Image.file`; `errorBuilder` mostra `Icons.broken_image`.
  - `CategoryChips({required OccurrenceCategory? selected, required ValueChanged<OccurrenceCategory> onSelected})` — seleção única, ícone + rótulo, altura ≥44, `Semantics(selected: ...)`.
  - `FilterBar()` — lê o provider; botão `'Filtrar período'` (abre `showDateRangePicker`); com filtro ativo mostra `Chip` `"dd/MM – dd/MM"` com ação de remover (`Semantics(label: 'Limpar filtro')`).
  - `EmptyOccurrences({required bool filtered})` — `'Nenhuma ocorrência registrada.'` ou `'Nenhuma ocorrência neste período'` + `TextButton('Limpar filtro')` (chama `clearFilter`) quando `filtered`.

- [ ] **Step 1: Escrever os testes:** `CategoryChips` mostra 6 chips e toque chama `onSelected` com a categoria certa; `FilterBar` sem filtro mostra `'Filtrar período'` e nenhum chip; após `setFilterDateRange(...)` mostra o chip e tocar em remover chama `clearFilter` (provider volta a `hasActiveFilter == false`); `OccurrenceImage` com caminho inexistente renderiza `Icons.broken_image` sem lançar (cobre Review Focus 5); `EmptyOccurrences(filtered: true)` mostra `'Limpar filtro'`.
- [ ] **Step 2: Rodar** `flutter test test/widgets` → FALHA.
- [ ] **Step 3: Implementar** os quatro widgets conforme as interfaces. `FilterBar` mantém o tema do date picker (`primary: DesignSystem.primary`) já usado hoje em `timeline_screen.dart`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Commit** `feat(ui): adiciona widgets compartilhados de filtro, categoria e imagem`

---

### Task 6: Detalhe e marcador

**Files:**
- Create: `lib/widgets/occurrence_detail_sheet.dart`, `lib/widgets/occurrence_marker.dart`
- Test: `test/widgets/occurrence_detail_sheet_test.dart`, `test/widgets/occurrence_marker_test.dart`

**Interfaces:**
- Consumes: `Occurrence`, `OccurrenceImage` (Task 5).
- Produces:
  - `void showOccurrenceDetails(BuildContext context, Occurrence occurrence)` — bottom sheet com título, chip de categoria (ícone), descrição (omitida se vazia), endereço (`address ?? 'Endereço indisponível'`), data `dd/MM/yyyy HH:mm` e foto.
  - `OccurrenceMarker({required Occurrence occurrence, required VoidCallback onTap})` — círculo de 44 px, borda na cor da categoria; miniatura (`ClipOval` + `OccurrenceImage`) quando houver `imagePath`, senão o ícone da categoria; `Semantics(button: true, label: '<título>, <categoria>')`.

- [ ] **Step 1: Escrever os testes:** o sheet mostra título, categoria, endereço e `'Endereço indisponível'` quando `address == null`; não mostra descrição vazia; marcador sem foto exibe o ícone da categoria e tem tamanho ≥44; marcador chama `onTap`; semantics contém título e categoria.
- [ ] **Step 2: Rodar** → FALHA.
- [ ] **Step 3: Implementar** movendo o conteúdo de `MapScreen._showOccurrenceDetails` (hoje com `dynamic`) para o novo arquivo, tipado.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Commit** `feat(ui): extrai detalhe da ocorrência e marcador com semântica`

---

### Task 7: Tela de registro (foto primeiro)

**Files:**
- Modify (reescrever): `lib/screens/new_occurrence_screen.dart`
- Test: `test/screens/new_occurrence_screen_test.dart`

**Interfaces:**
- Consumes: `LocationService`/`LocationResult` (Task 3), `AddressService` (Task 4), `CategoryChips`/`OccurrenceImage` (Task 5), `Occurrence.titleFor` (Task 1), `OccurrenceProvider.addOccurrence`.
- Produces: `NewOccurrenceScreen({super.key, LocationService? locationService, AddressService? addressService, Future<String?> Function(ImageSource source)? pickImagePath})` — padrões: `GeolocatorLocationService()`, `NominatimAddressService()`, e picker real do `image_picker` (devolve `XFile.path` ou `null`).

Layout, de cima para baixo: foto (Câmera/Galeria; prévia + "Remover foto") → `CategoryChips` → cartão de localização (carregando / capturada com endereço ou `'Endereço indisponível'` / falha com `message` + botão `actionLabel`) → `ExpansionTile('Detalhes (opcional)')` com título e descrição → aviso de privacidade de uma linha → botão `'Publicar'`.

- [ ] **Step 1: Escrever os testes de widget** (fakes de `LocationService`, `AddressService` e picker; provider real):
  - botão desabilitado e texto auxiliar `'Falta: foto, categoria'` ao abrir; após escolher foto e categoria, com localização `LocationOk`, o botão habilita e o auxiliar some;
  - picker devolvendo `null` (cancelou) não altera nada nem lança (Review Focus 2);
  - `LocationDeniedForever` mostra `'Abrir configurações'` e tocar chama `openAppSettings` do fake; `LocationServiceDisabled` mostra `'Ativar GPS'` e chama `openLocationSettings` (Review Focus 1);
  - publicar sem título (`'   '`) cria ocorrência com título igual ao `label` da categoria e descrição vazia (Review Focus 3);
  - publicar passa o endereço do fake para `Occurrence.address`; endereço `null` publica mesmo assim;
  - voltar com foto escolhida abre `'Descartar registro?'`; sem dados, sai direto.
- [ ] **Step 2: Rodar** `flutter test test/screens/new_occurrence_screen_test.dart` → FALHA.
- [ ] **Step 3: Implementar** a tela. Regras: foto obrigatória; `PopScope(canPop: !dirty)` com diálogo de descarte, em que `dirty` = há foto, categoria ou texto; ao capturar a localização com sucesso, buscar endereço sem bloquear o botão; publicar chama `addOccurrence`, faz `Navigator.pop` e mostra SnackBar de sucesso (`DesignSystem.success`). Remover o `AlertDialog` de confirmação, o SnackBar efêmero de erro de GPS e o `CircularProgressIndicator` de tela inteira (não há upload real).
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Verificar o fluxo de toques** no aparelho/emulador: Registrar → foto → categoria → Publicar = 4 toques.
- [ ] **Step 6: Commit** `feat(registro): fluxo foto-primeiro em até 4 toques com endereço e alertas de GPS`

---

### Task 8: Mapa

**Files:**
- Modify: `lib/screens/map_screen.dart`

**Interfaces:**
- Consumes: `OccurrenceMarker`, `showOccurrenceDetails` (Task 6), `FilterBar`, `EmptyOccurrences` (Task 5), `LocationService` (Task 3), `OccurrenceProvider`.
- Produces: `MapScreen({super.key, LocationService? locationService})`.

- [ ] **Step 1: Implementar** `MapScreen` como `StatefulWidget` com `MapController`: `Stack` com `FlutterMap` (mesmos tiles OSM e centro atuais), marcadores `OccurrenceMarker` (44 px) que abrem `showOccurrenceDetails`, `FilterBar` sobreposta no topo, `EmptyOccurrences(filtered: true)` centralizado quando houver filtro sem resultados, e botão pequeno "minha localização" (canto inferior direito, acima do FAB de registro, `Semantics(label: 'Minha localização')`): spinner enquanto busca, move o mapa em `LocationOk`, SnackBar com `message` e ação (`actionLabel`) nos demais casos.
- [ ] **Step 2: Rodar** `flutter analyze && flutter test` → verde. (Sem teste de widget para o mapa: `flutter_map` carrega tiles pela rede; a verificação é manual.)
- [ ] **Step 3: Verificar no aparelho/emulador:** pinos por categoria; foto aparece no marcador de uma ocorrência com foto; filtro mostra chip e some pinos fora do período; filtro vazio mostra aviso com "Limpar filtro"; "minha localização" com GPS ligado e desligado.
- [ ] **Step 4: Commit** `feat(mapa): marcadores por categoria, filtro de período e minha localização`

---

### Task 9: Linha do Tempo

**Files:**
- Modify: `lib/screens/timeline_screen.dart`
- Test: `test/screens/timeline_screen_test.dart`

**Interfaces:**
- Consumes: `FilterBar`, `EmptyOccurrences`, `OccurrenceImage` (Task 5), `showOccurrenceDetails` (Task 6).

- [ ] **Step 1: Escrever os testes** (provider real): lista mostra os 4 títulos de exemplo; com filtro sem resultados aparece `'Nenhuma ocorrência neste período'` e `'Limpar filtro'` restaura a lista; tocar em um cartão abre o detalhe (aparece o endereço/`'Endereço indisponível'`).
- [ ] **Step 2: Rodar** → FALHA.
- [ ] **Step 3: Implementar:** trocar `_buildFilterHeader` por `FilterBar`; cartão com ícone/cor da categoria, miniatura (`OccurrenceImage`, ≤ 72 px) quando houver foto, `InkWell` que abre `showOccurrenceDetails`; estado vazio via `EmptyOccurrences(filtered: provider.hasActiveFilter)`; texto de conteúdo ≥14 px, chip de categoria com 14 px.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → verde.
- [ ] **Step 5: Commit** `feat(linha-do-tempo): miniaturas, detalhe ao tocar e filtro compartilhado`

---

### Task 10: Acessibilidade, verificação final e memória

**Files:**
- Modify: `lib/screens/home_screen.dart` (`Semantics`/`tooltip` do FAB "Registrar" e das abas, se faltarem)
- Modify: `MEMORY.md` (hoje vazio; `AGENTS.md` o define como fonte de contexto)

- [ ] **Step 1: Revisar** rótulos de acessibilidade dos controles principais (FAB, abas, botões de foto, chips, filtro, minha localização) e corrigir os que faltarem.
- [ ] **Step 2: Escrever `MEMORY.md`:** o que o app é, estrutura de `lib/`, decisões (RU4 = até 4 toques com categoria obrigatória; foto obrigatória; endereço via Nominatim sem chave; sem backend/persistência), como testar e rodar.
- [ ] **Step 3: Rodar** `flutter analyze && flutter test` → sem avisos, tudo verde. Conferir `git diff pubspec.yaml pubspec.lock` → sem mudanças.
- [ ] **Step 4: Verificação manual completa** (checklist do aluno): 4 toques; GPS desligado; permissão negada; negada para sempre; sem internet (endereço indisponível, publica); filtro vazio; sair do formulário com dados; TalkBack nos controles principais.
- [ ] **Step 5: Commit** `docs: atualiza MEMORY.md com decisões e estrutura do app`
