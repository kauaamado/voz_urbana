# MEMORY — Voz Urbana

Contexto para agentes de IA. Atualize ao mudar decisões ou estrutura.

## O que é
App Flutter (protótipo acadêmico, CEFET/RJ UnED Petrópolis, disciplina Projeto de Interação,
prof. Luis Retondaro) de mapeamento colaborativo de infraestrutura urbana. O cidadão fotografa,
categoriza e georreferencia ocorrências; o histórico é consultável por mapa e linha do tempo.
Requisitos de origem: `KauaWilliansLopesAmado-VozUrbana-Resumo-e-Requisitos.md`.
Entrega: relatório + apresentação (normas em `compartilhado_professor/NORMAS.pdf`, **não versionar**
essa pasta). Relatório, slides e avaliação heurística (planilha `modelo_av_heuristica.xls`, 5
avaliadores) são feitos pelo aluno e colegas — não inventar notas de avaliadores.

## Stack
Flutter, Dart ^3.12.2, provider, geolocator, flutter_map (tiles OSM), image_picker, intl, uuid.
Sem backend e sem persistência: tudo em memória (`OccurrenceProvider`, com 4 ocorrências de exemplo).

## Estrutura de `lib/`
- `models/occurrence.dart` — `Occurrence`, `OccurrenceCategory` (rótulo, ícone, cor), `Occurrence.titleFor`.
- `providers/occurrence_provider.dart` — lista + filtro de período (estado único para Mapa e Linha do Tempo).
- `services/location_service.dart` — `LocationService` (interface) e `LocationResult` tipado; GPS via geolocator.
- `services/address_service.dart` — `AddressService`; Nominatim (OSM) via `dart:io`, com cache em memória.
- `screens/` — `home_screen` (abas + FAB), `map_screen`, `timeline_screen`, `new_occurrence_screen`.
- `widgets/` — `filter_bar`, `category_chips`, `occurrence_marker`, `occurrence_detail_sheet`,
  `occurrence_image`, `empty_occurrences`, `privacy_notice` (aviso LGPD com painel).

## Decisões
- **RU4 = até 4 toques** (Registrar → foto → categoria → Publicar). O documento original dizia 3;
  categoria obrigatória preserva a qualidade dos dados. Ajustar o texto no relatório.
- Foto e categoria obrigatórias; título e descrição opcionais (título vazio vira o nome da categoria).
- Sem diálogo de confirmação: a própria tela de registro é a revisão (resumo + aviso de publicidade).
- Endereço via Nominatim: 100% gratuito, sem chave, sem dependência nova. Política: ≤1 req/s,
  User-Agent identificável, cache no cliente. Falha → "Endereço indisponível"; nunca bloqueia a publicação.
- Sem upload real (não há backend): feedback de publicação = SnackBar + item novo no topo da lista.
- `DesignSystem.success` = `#15803D` e `secondary` = `#4B5563` (contraste verificado por teste: secundário ≥7:1).
- `FilterBar` mostra ícone de calendário, chip do período e contagem de resultados.
- Rastreabilidade requisito → código/evidência/lacunas: `docs/usabilidade-rastreabilidade.md` (base do relatório; RU3, RU4 e RNF3 divergem do documento original).

## Pendências conhecidas
- Testado no aparelho (Android 14) pelo aluno: roteiro de registro, GPS, mapa, filtro e câmera OK; botões do mapa e do chip fáceis de tocar. **TalkBack não foi testado** (não conseguiu ativar).
- Endereço fica nulo se o usuário publicar antes da resposta do Nominatim; cache do endereço é por instância (por tela).
- Fotos da câmera ficam no cache temporário do app (podem sumir; a UI mostra ícone de imagem quebrada).
- Mapa: `MapController` não é descartado; SnackBars repetidos de GPS se empilham.
- Atribuição "© OpenStreetMap" (ODbL) não é exibida no mapa/endereço.
- `userAgentPackageName` dos tiles ainda é `com.example.voz_urbana`.
- `DESIGN.md` é um template de outro produto ("FeedLoop"), não descreve este app.

## Como testar
- `flutter analyze && flutter test` (testes de modelo, provider, serviços, widgets e telas).
- Manual no aparelho: 4 toques para publicar; GPS desligado; permissão negada/negada para sempre;
  sem internet (endereço indisponível, publica mesmo assim); filtro de período sem resultados;
  sair do formulário com dados; TalkBack nos controles principais.

## Convenções
Conventional commits em português; sem co-autoria de IA nos commits.
