# Conformidade com os Requisitos de Usabilidade — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fechar as lacunas que restaram nos requisitos de usabilidade aplicáveis ao protótipo (RU1, RU2, RU5, RNF2) e documentar, requisito a requisito, o que o app atende, o que mudou e o que ficou fora.

**Architecture:** Mudanças pequenas e localizadas sobre o app já mesclado na `main`: `FilterBar` ganha ícone de calendário e contagem de resultados; o tema ganha contraste verificado por teste; o aviso de privacidade vira um widget próprio; a rastreabilidade vai para um documento em `docs/`.

**Tech Stack:** Flutter, Dart ^3.12.2, provider, intl. **Nenhuma dependência nova.**

**Spec:** `docs/superpowers/specs/2026-11-08-ajustes-usabilidade-design.md` (spec base do app) e `KauaWilliansLopesAmado-VozUrbana-Resumo-e-Requisitos.md` (requisitos do aluno). Este plano não altera a arquitetura da spec base.

## Global Constraints

- Executar em uma branch nova a partir da `main`: `git checkout -b feat/conformidade-usabilidade`.
- Nenhuma dependência nova em `pubspec.yaml`.
- Todo texto visível em português do Brasil, com acentuação correta.
- Alvos de toque ≥ 44 px (`DesignSystem.minTouchTarget`); texto de conteúdo ≥ 14 px; metadados ≥ 12 px.
- Decisões já aprovadas pelo aluno e que **não** mudam: RU4 = até 4 toques; sem diálogo de confirmação de publicação (a tela de registro é a revisão); foto e categoria obrigatórias; endereço via Nominatim.
- Fora do escopo: iOS (RNF3), upload real, persistência, edição da posição do pino, onboarding, "Ver no mapa" após publicar. Entram só como "trabalhos futuros" na documentação (Task 5).
- Commits em conventional commits, em português, **sem co-autoria de IA**, um por tarefa. Antes de cada commit: `flutter analyze` sem avisos e `flutter test` verde.
- Contrato de textos novos (usado nos testes): título da tela `'Registrar ocorrência'`; diálogo `'Descartar ocorrência?'`; contagem `'1 ocorrência'` / `'N ocorrências'`; `'Saiba mais'`; `'Privacidade e LGPD'`; `'Entendi'`; `'Evite fotografar rostos e placas de veículos.'`.

## Review Focus

1. Contagem no singular e no zero: `'1 ocorrência'` e `'0 ocorrências'`; atualiza sozinha quando uma ocorrência nova entra dentro do período filtrado. (Task 2)
2. Fonte do sistema a 200 %: Linha do Tempo, filtro, registro e detalhe sem `RenderFlex overflowed`. (Task 3)
3. Todas as cores de categoria mantêm ≥3:1 sobre branco e o texto secundário ≥7:1. (Task 3)
4. Aviso de privacidade em tela pequena com texto ampliado: o painel rola e o botão "Entendi" continua alcançável. (Task 4)
5. Mudança de rótulos não quebra os testes que procuram `'Nova Ocorrência'`/`'Descartar registro?'`. (Task 1)

---

### Task 1: Ícone de calendário e terminologia consistente (RU2)

**Files:**
- Modify: `lib/widgets/filter_bar.dart`, `lib/screens/new_occurrence_screen.dart`
- Test: `test/widgets/filter_bar_test.dart`, `test/screens/new_occurrence_screen_test.dart`

**Interfaces:**
- Produces: nenhuma assinatura nova. Textos conforme o contrato em Global Constraints.

- [ ] **Step 1: Escrever os testes.** Em `filter_bar_test.dart`: `'botão de filtro usa ícone de calendário'` — `find.byIcon(Icons.calendar_month)` encontra um widget, com e sem filtro ativo, e `find.byIcon(Icons.filter_alt)` não encontra nenhum. Em `new_occurrence_screen_test.dart`: trocar as expectativas de `'Nova Ocorrência'` por `'Registrar ocorrência'` e de `'Descartar registro?'` por `'Descartar ocorrência?'`; acrescentar o teste `'título da tela é "Registrar ocorrência"'`.
- [ ] **Step 2: Rodar** `flutter test test/widgets/filter_bar_test.dart test/screens/new_occurrence_screen_test.dart` → **Expected:** FALHA nos testes alterados.
- [ ] **Step 3: Implementar.** `FilterBar`: trocar o ícone do botão por `Icons.calendar_month`. `NewOccurrenceScreen`: `AppBar(title: Text('Registrar ocorrência'))` e título do diálogo `'Descartar ocorrência?'`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → **Expected:** sem avisos, tudo verde.
- [ ] **Step 5: Commit** `feat(ui): ícone de calendário no filtro e terminologia consistente`

---

### Task 2: Contagem de resultados do filtro (RU1)

**Files:**
- Modify: `lib/widgets/filter_bar.dart`
- Test: `test/widgets/filter_bar_test.dart`

**Interfaces:**
- Consumes: `OccurrenceProvider.hasActiveFilter`, `occurrences`, `setFilterDateRange`, `addOccurrence`.
- Produces: com filtro ativo, `FilterBar` mostra `Text` com `'1 ocorrência'` ou `'N ocorrências'` (N ≠ 1, inclusive 0), dentro de `Semantics(liveRegion: true)`. Sem filtro, nada é mostrado. A linha passa a quebrar (`Wrap`) em telas estreitas em vez de estourar.

- [ ] **Step 1: Escrever os testes** em `filter_bar_test.dart` (provider real, com o filtro apontando para dias em que se controla o conteúdo via `addOccurrence` com `dateTime` explícito): `'mostra "1 ocorrência" no singular'`; `'mostra "0 ocorrências" quando nada bate'`; `'não mostra contagem sem filtro'` (`find.textContaining('ocorrência')` vazio); `'a contagem atualiza ao entrar uma ocorrência dentro do período'` (adiciona uma ocorrência no intervalo, `pump`, contagem sobe de 1 para 2).
- [ ] **Step 2: Rodar** `flutter test test/widgets/filter_bar_test.dart` → **Expected:** FALHA (contagem inexistente).
- [ ] **Step 3: Implementar** a contagem em `FilterBar`, lendo `provider.occurrences.length`; trocar o `Row` por `Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8)`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → **Expected:** verde.
- [ ] **Step 5: Commit** `feat(filtro): mostra a quantidade de ocorrências do período`

---

### Task 3: Contraste e fonte ampliada (RU5)

**Files:**
- Modify: `lib/theme/design_system.dart` (`secondary`) e, se os testes de fonte ampliada acusarem, os widgets que estourarem
- Create: `test/helpers/contrast.dart`, `test/theme/contrast_test.dart`, `test/accessibility/text_scale_test.dart`

**Interfaces:**
- Produces: `double contrastRatio(Color a, Color b)` em `test/helpers/contrast.dart` (fórmula WCAG 2.x de luminância relativa).
- `DesignSystem.secondary` passa a `Color(0xFF4B5563)`.

- [ ] **Step 1: Escrever os testes de contraste** em `contrast_test.dart`: `contrastRatio(Colors.black, Colors.white)` ≈ 21; `secondary` sobre `background` e sobre `surface` ≥ 7.0; texto branco sobre `primary`, sobre `success` e sobre `error` ≥ 4.5; cada `OccurrenceCategory.color` sobre `Colors.white` ≥ 3.0.
- [ ] **Step 2: Escrever o teste de fonte ampliada** em `text_scale_test.dart`: envolver cada tela em `MaterialApp` com `builder` aplicando `MediaQuery(data: ..., textScaler: TextScaler.linear(2.0))`, em tela de 400×800, e esperar `tester.takeException()` nulo após `pumpAndSettle` para: `TimelineScreen` (provider real), `FilterBar` com filtro ativo, `NewOccurrenceScreen` (fakes de `test/helpers/fakes.dart`, foto e categoria escolhidas) e `showOccurrenceDetails` de uma ocorrência com endereço e foto inexistente.
- [ ] **Step 3: Rodar** `flutter test test/theme test/accessibility` → **Expected:** contraste do `secondary` FALHA (≈4,8:1 < 7); fonte ampliada pode falhar com `RenderFlex overflowed` — anotar quais telas.
- [ ] **Step 4: Implementar:** trocar `secondary` para `0xFF4B5563`. Para cada tela que estourar a 200 %, corrigir o layout (`Flexible`/`Expanded`, `Wrap`, `maxLines` + `overflow: TextOverflow.ellipsis` só onde o texto não for conteúdo essencial); não reduzir o tamanho de fonte.
- [ ] **Step 5: Rodar** `flutter analyze && flutter test` → **Expected:** verde.
- [ ] **Step 6: Commit** `feat(acessibilidade): contraste reforçado e layout estável com fonte ampliada`

---

### Task 4: Aviso de privacidade e LGPD (RNF2)

**Files:**
- Create: `lib/widgets/privacy_notice.dart`
- Modify: `lib/screens/new_occurrence_screen.dart` (usar o widget no lugar do texto fixo)
- Test: `test/widgets/privacy_notice_test.dart`

**Interfaces:**
- Produces: `PrivacyNotice({super.key})` — mostra `'Sua publicação é anônima. A foto e a localização ficarão visíveis para todos no mapa.'` e um `TextButton('Saiba mais')` (altura ≥44). O botão abre um `showModalBottomSheet` (`isScrollControlled: true`, conteúdo em `SingleChildScrollView`) com título `'Privacidade e LGPD'`, e os itens: `'Ficam públicos: foto, localização, data e categoria.'`, `'Não coletamos: nome, conta, telefone ou e-mail.'`, `'Evite fotografar rostos e placas de veículos.'`, `'Neste protótipo os dados ficam apenas na memória do aparelho.'`, e um botão `'Entendi'` que fecha o painel.

- [ ] **Step 1: Escrever os testes** em `privacy_notice_test.dart`: mostra o aviso e o botão `'Saiba mais'`; tocar em `'Saiba mais'` mostra `'Privacidade e LGPD'` e `'Evite fotografar rostos e placas de veículos.'`; `'Entendi'` fecha o painel; com fonte a 200 % e tela de 400×500 o painel não estoura e `'Entendi'` é alcançável (`scrollUntilVisible`) (Review Focus 4). Em `new_occurrence_screen_test.dart`: a tela contém `'Saiba mais'`.
- [ ] **Step 2: Rodar** `flutter test test/widgets/privacy_notice_test.dart test/screens/new_occurrence_screen_test.dart` → **Expected:** FALHA.
- [ ] **Step 3: Implementar** `PrivacyNotice` e substituir, em `NewOccurrenceScreen`, o `Text` do aviso por `const PrivacyNotice()`.
- [ ] **Step 4: Rodar** `flutter analyze && flutter test` → **Expected:** verde.
- [ ] **Step 5: Commit** `feat(privacidade): aviso de LGPD com painel explicativo`

---

### Task 5: Rastreabilidade dos requisitos e verificação manual

**Files:**
- Create: `docs/usabilidade-rastreabilidade.md`
- Modify: `MEMORY.md`

**Interfaces:**
- Produces: tabela `Requisito | Situação | Evidência | Nota para o relatório`, uma linha para cada RF1–RF5, RU1–RU5 e RNF1–RNF3 do documento do aluno. Situações permitidas: `Atende`, `Atende com ajuste`, `Não atende (justificado)`, `Não verificado`. Nunca preencher resultado de teste que o aluno não informou.

- [ ] **Step 1: Escrever `docs/usabilidade-rastreabilidade.md`** com a tabela e estas linhas já decididas: **RU3 — Atende com ajuste** (sem diálogo; a própria tela de registro é a revisão, com foto, categoria, localização, endereço e aviso visíveis antes de "Publicar"; o texto do requisito deve ser ajustado); **RU4 — Atende com ajuste** (até 4 toques, categoria obrigatória); **RNF3 — Não atende (justificado)** (somente Android; o projeto não tem `ios/`); **RU1** (upload) — sem backend, o feedback de envio é o SnackBar e o item novo na lista; **RU5** (leitor de tela) — `Não verificado` até o aluno testar o TalkBack; **RNF1** — `Não verificado` até medir. Incluir seção `Trabalhos futuros` (edição da posição do pino, onboarding/ajuda, persistência, "Ver no mapa" após publicar, desfazer/editar/excluir, iOS) e seção `Checklist manual no aparelho` (4 toques; TalkBack nos controles principais; tempo de carregamento do mapa e das miniaturas ≤2 s em 4G/Wi-Fi; leitura ao ar livre sob sol; fonte do sistema ampliada), cada item com `[ ]` e campo "Resultado:" em branco.
- [ ] **Step 2: Atualizar `MEMORY.md`:** referenciar o novo documento, registrar a nova cor `secondary`, o `PrivacyNotice` e a contagem no `FilterBar`, e remover pendências que as tarefas 1–4 resolveram.
- [ ] **Step 3: Verificar** `flutter analyze && flutter test` → **Expected:** verde (nada de código muda nesta tarefa).
- [ ] **Step 4: Commit** `docs: adiciona matriz de rastreabilidade de requisitos de usabilidade`
