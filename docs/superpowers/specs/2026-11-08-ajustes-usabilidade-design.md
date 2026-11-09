# Voz Urbana — Ajustes de usabilidade para o protótipo (spec)

Data: 2026-11-08 · Projeto: `voz_urbana` (Flutter, Dart ^3.12.2, Provider)

## 1. Entendimento (para correção)

**Objetivo.** Deixar o protótipo aderente aos requisitos do documento
`KauaWilliansLopesAmado-VozUrbana-Resumo-e-Requisitos.md` e às heurísticas de
Nielsen, para ser avaliado por colegas (avaliação heurística) e apresentado em
aula (disciplina Projeto de Interação, CEFET/RJ UnED Petrópolis), em 7 dias.

**Fora do escopo desta spec:** relatório, slides e a planilha de avaliação
(feitos pelo aluno e colegas). Também fora: login, editar/excluir registros,
backend, persistência em disco. Endereço (RF2): ver seção 3.8, sujeito à
aprovação do aluno.

**Decisão já tomada.** RU4 passa a ser "até **4 toques**" para publicar
(Registrar → foto → categoria → Publicar). O texto do requisito será ajustado
pelo aluno no relatório, com a justificativa: categoria obrigatória preserva a
qualidade dos dados.

**Critérios de sucesso.**
1. Publicar uma ocorrência em ≤4 toques.
2. Cada requisito de usabilidade (RU1–RU5) e funcional (RF1, RF3–RF5) tem um
   ponto demonstrável no app.
3. `flutter analyze` sem avisos e `flutter test` verde.
4. Nenhuma dependência nova.

## 2. Mapa de requisitos → mudanças

| Requisito | Mudança |
|---|---|
| RU4 (toques) | Tela de registro foto-primeiro; categoria em chips; título/descrição opcionais |
| RU3 (prevenção de erros) | Alerta de GPS persistente com ação; confirmação ao descartar; a própria tela de registro é a revisão (resumo + aviso de publicidade) |
| RU1 (status) | Indicador de filtro ativo; estado vazio com ação; spinner de localização no mapa; botão desabilitado com motivo |
| RF4 (filtro) | Filtro de período no mapa **e** na linha do tempo, mesmo estado |
| RF5 (mapa) | Pinos com ícone/cor por categoria; miniatura da foto quando houver; botão "minha localização" |
| RU2 (mundo real) | Ícones por categoria; rótulos claros |
| RU5 (acessibilidade) | `Semantics`, texto ≥14 px no conteúdo, contraste AA |
| RNF2 (privacidade) | Aviso curto de anonimato/localização pública |

## 3. Design

### 3.1 Modelo — `lib/models/occurrence.dart`
`OccurrenceCategory` ganha `icon` (`IconData`) e `color` (`Color`, todas com
contraste ≥3:1 contra o fundo do pino). `Occurrence.title` continua obrigatório
no modelo; a tela gera o título a partir da categoria quando o usuário não digita.
`description` continua `String` (pode ser vazia).

### 3.2 Serviço de localização — `lib/services/location_service.dart` (novo)
Extrai a lógica hoje embutida em `NewOccurrenceScreen._getLocation`.
`Future<LocationResult> current()` devolve um tipo selado:
`LocationOk(LatLng)`, `LocationServiceDisabled`, `LocationDenied`,
`LocationDeniedForever`, `LocationError`. Também expõe `openLocationSettings()` e
`openAppSettings()` (ambos já existem em `geolocator`). Usado pelo registro e
pelo botão "minha localização" do mapa. Injetável para testes.

### 3.3 Componentes compartilhados — `lib/widgets/` (novos)
- `filter_bar.dart`: cabeçalho com botão "Filtrar período" e, se ativo, um chip
  "dd/MM – dd/MM ✕". Lê/escreve o filtro no `OccurrenceProvider` (já global).
  Usado por Mapa e Linha do Tempo (hoje só a Linha do Tempo tem interface).
- `occurrence_image.dart`: imagem de `http(s)` ou `File`, com `errorBuilder`.
  Remove a duplicação atual em `map_screen.dart`.
- `occurrence_detail_sheet.dart`: bottom sheet de detalhe, tipado com
  `Occurrence` (hoje `dynamic`), aberto do mapa e da linha do tempo.
- `category_chips.dart`: seleção única, ícone + rótulo, alvo ≥44 px.

### 3.4 Registro — `lib/screens/new_occurrence_screen.dart`
Ordem de cima para baixo: (1) foto (botões Câmera/Galeria; prévia com
"Remover"); (2) categoria em chips; (3) cartão de localização com estado
(carregando / capturada / falha); (4) título e descrição, ambos **opcionais**,
recolhidos sob "Detalhes (opcional)"; (5) aviso de privacidade em uma linha;
(6) botão **Publicar**.

- Foto passa a ser **obrigatória** (RF1: o registro é fotográfico). Confirmado
  pelo aluno em 2026-11-08, junto com título/descrição opcionais e a remoção do
  diálogo de confirmação.
- O botão fica desabilitado com texto auxiliar do que falta ("Falta: foto,
  categoria") — o usuário vê o motivo em vez de um erro posterior.
- O `AlertDialog` de confirmação é removido: a tela já mostra o resumo e o aviso
  de que a publicação é pública, o que mantém o fluxo em 4 toques.
- Falha de GPS: banner persistente no cartão de localização com ação contextual
  ("Ativar GPS" → `openLocationSettings`; "Abrir configurações" →
  `openAppSettings`; "Tentar novamente"). Some o SnackBar efêmero.
- Sair com foto/categoria/texto preenchidos: `PopScope` + diálogo "Descartar
  registro?".
- Sem upload real (não há backend): não haverá spinner artificial. O feedback
  de publicação é o SnackBar de sucesso e o novo item visível no topo da lista.
  Essa limitação deve constar no relatório.

### 3.5 Mapa — `lib/screens/map_screen.dart`
- `MapController` para recentrar. Botão pequeno "minha localização" (usa o
  `LocationService`; mostra spinner enquanto busca; erro via SnackBar com ação).
- Marcador: círculo de 44 px com borda na cor da categoria; miniatura da foto
  quando houver, senão o ícone da categoria. `Semantics(label: título + categoria)`.
- `FilterBar` no topo, sobreposto ao mapa.
- Filtro sem resultados: aviso "Nenhuma ocorrência neste período" com "Limpar filtro".
- Toque no marcador abre `OccurrenceDetailSheet`.

### 3.6 Linha do Tempo — `lib/screens/timeline_screen.dart`
Usa `FilterBar`; cartão com miniatura (quando houver), ícone da categoria e
toque que abre `OccurrenceDetailSheet`; estado vazio diferencia "sem registros"
de "sem registros neste período" (com "Limpar filtro").

### 3.7 Tema — `lib/theme/design_system.dart`
- `success` escurecido para `#15803D` (contraste com texto branco ≥4,5:1; o
  `#16A34A` atual dá ~3,3:1).
- Texto de conteúdo ≥14 px; metadados ≥12 px. Alvos de toque ≥44 px (já é
  `minTouchTarget`).
- Corrigir comentários "FeedLoop" que não descrevem este produto
  (`DESIGN.md` é um template de outro produto — fora do escopo, apenas sinalizar).

### 3.8 Endereço (RF2) — aprovado pelo aluno em 2026-11-08 (Nominatim)
`lib/services/address_service.dart` (novo): geocodificação reversa via Nominatim
(OpenStreetMap), usando `dart:io` `HttpClient` (sem dependência nova, sem chave,
gratuito). `User-Agent` identificável, timeout curto, no máximo uma chamada por
registro (respeita o limite de 1 req/s). Política de uso do Nominatim a
reconfirmar antes de implementar. Falha → `null` → texto "Endereço indisponível";
**nunca bloqueia a publicação**. `Occurrence` ganha `address` (`String?`),
exibido no cartão de localização do registro, no detalhe e na Linha do Tempo.
Serviço injetável para testes.

## 4. Fluxo de dados
`OccurrenceProvider` continua sendo a fonte única (lista + filtro). Nenhuma
mudança de API pública além de, se necessário, `hasActiveFilter`. Telas leem via
`Consumer`; `LocationService` é injetado por construtor com valor padrão.

## 5. Tratamento de erros
Todos os resultados de `LocationResult` têm mensagem em português e uma ação.
Falha ao abrir câmera/galeria: SnackBar com mensagem específica. Imagem que não
carrega: ícone de imagem quebrada (sem exceção).

## 6. Testes
- Substituir `test/widget_test.dart` (template do contador, quebrado) por testes
  reais.
- Unitários: filtro do `OccurrenceProvider`; geração de título padrão.
- Widget: `CategoryChips` (seleção única); `FilterBar` (chip aparece/limpa);
  `NewOccurrenceScreen` (botão desabilitado com motivo; habilita com foto +
  categoria; `LocationService` falso cobre os cinco resultados).
- Verificação manual no aparelho: contar os toques do fluxo, GPS desligado,
  permissão negada, filtro vazio, leitor de tela (TalkBack) nos controles
  principais.

## 7. Riscos e decisões em aberto
- **Endereço (RF2)** — pendente de aprovação do aluno (ver 3.8). Restrição: 100%
  gratuito, sem chave de API e sem dependência nova.
- **Prazo:** 7 dias até a aula, mas a entrega do Teams é hoje; o app precisa
  estar estável antes da avaliação pelos colegas.
