# Voz Urbana — Rastreabilidade dos requisitos

Relação entre os requisitos do documento `KauaWilliansLopesAmado-VozUrbana-Resumo-e-Requisitos.md`
e o protótipo. Serve de base para o capítulo **Resultados** do relatório e para a avaliação
heurística (Nielsen). Situações: **Atende**, **Atende com ajuste**, **Não atende (justificado)**,
**Não verificado**.

## Matriz

| Requisito | Situação | Evidência | Nota para o relatório |
|---|---|---|---|
| **RF1** Foto pela câmera ou galeria | Atende | `lib/screens/new_occurrence_screen.dart` (botões Câmera/Galeria; foto obrigatória) | Roteiro de registro testado pelo aluno no aparelho (Android 14). |
| **RF2** Coordenadas e endereço automáticos | Atende com ajuste | `lib/services/location_service.dart`, `lib/services/address_service.dart` | GPS captura as coordenadas; o endereço vem do Nominatim (OpenStreetMap, gratuito) e depende de internet. Sem rede o app mostra "Endereço indisponível" e publica mesmo assim. |
| **RF3** Categorização | Atende | `lib/widgets/category_chips.dart`, `lib/models/occurrence.dart` | 6 categorias (iluminação pública, pavimentação, saneamento, segurança, patrimônio, lazer), com ícone. Categoria obrigatória. |
| **RF4** Filtro temporal e histórico | Atende com ajuste | `lib/widgets/filter_bar.dart`, `lib/providers/occurrence_provider.dart` | Filtro por intervalo de datas (seletor de calendário), compartilhado entre Mapa e Linha do Tempo, com chip do período e contagem de resultados. **Não há** filtro por local/área nem por mandato. |
| **RF5** Mapa com ícones e miniaturas | Atende | `lib/screens/map_screen.dart`, `lib/widgets/occurrence_marker.dart` | Marcador circular com ícone e cor da categoria; mostra a miniatura da foto quando existe. O ícone não é o pino clássico de mapa. |
| **RU1** Visibilidade do status | Atende com ajuste | Cartão de localização (carregando/capturada/falha), botão "minha localização" com indicador, chip e contagem do filtro | **Não há upload real** (não existe backend): o feedback de publicação é o aviso de sucesso e o item novo no topo da lista. Não há indicador de carregamento dos blocos do mapa. |
| **RU2** Correspondência com o mundo real | Atende com ajuste | Ícones: câmera, galeria, calendário, localização, categoria; termo "ocorrência" nos títulos, diálogos e mensagens | O requisito cita "pino de mapa": o marcador é um círculo com o ícone da categoria, não o pino clássico. O botão flutuante diz "Registrar" e o detalhe diz "Registrado em" (mesma família de termos, mas não idênticos). Os testes cobrem o ícone de calendário e os rótulos principais. |
| **RU3** Prevenção de erros | Atende com ajuste | Botão "Publicar" desabilitado com o motivo ("Falta: foto, categoria"); alerta de GPS persistente com ação na tela de registro; confirmação ao descartar o formulário | **O documento pedia tela de confirmação antes da publicação. Ela foi substituída:** a própria tela de registro é a revisão (foto, categoria, localização, endereço e aviso de publicidade ficam visíveis antes de "Publicar"). Ajustar o texto do requisito no relatório. No mapa, a falha do GPS (botão "minha localização") aparece como aviso passageiro, não persistente. |
| **RU4** Mínima carga cognitiva | Atende com ajuste | Fluxo: Registrar → foto → categoria → Publicar | **São 4 toques, não 3.** A categoria é obrigatória para preservar a qualidade dos dados. Ajustar o texto do requisito para "até 4 toques". A contagem não inclui os toques dentro do aplicativo de câmera do sistema (obturador e confirmação). |
| **RU5** Alto contraste | Atende com ajuste | `test/theme/contrast_test.dart` | Texto secundário ≥7:1; texto branco sobre as cores de ação ≥4,5:1; cores de categoria ≥3:1. **A leitura sob sol real não foi verificada.** |
| **RU5** Leitores de tela | Não verificado | `Semantics` em marcador, foto, cartão de localização e contagem do filtro | Os rótulos foram implementados, mas o aluno não conseguiu ativar o TalkBack. Não afirmar suporte comprovado. |
| **RNF1** Carga em até 2 s | Não verificado | — | Não foi medido (depende da rede e dos blocos do OpenStreetMap). Ver checklist abaixo. |
| **RNF2** Anonimato e LGPD | Atende com ajuste | `lib/widgets/privacy_notice.dart` | Não há login nem conta, e o app não pede nome, telefone ou e-mail. **Mas a localização sai do aparelho:** ao capturá-la, as coordenadas exatas são enviadas ao OpenStreetMap (Nominatim) para obter o endereço, e os blocos do mapa também são baixados de lá (o que expõe o IP). O painel "Privacidade e LGPD" declara isso. Não há servidor próprio: os registros ficam só na memória do aparelho, então a frase "visíveis para todos no mapa" descreve a intenção do produto, não algo que o protótipo faça hoje. Não há política formal nem consentimento registrado. |
| **RNF3** Android e iOS | Não atende (justificado) | O projeto só tem a pasta `android/` | O protótipo é **somente Android**. O iOS exigiria gerar a plataforma e compilar em um Mac. Há testes automatizados de fonte a 200 % em tela de 400 px para quatro componentes (Linha do Tempo, filtro, registro e detalhe); o mapa e a tela inicial não têm teste automatizado, e tablets não foram verificados. |

## Mudanças em relação ao documento original

1. **RU3:** confirmação em tela separada substituída pela tela de registro como revisão.
2. **RU4:** de 3 para 4 toques.
3. **RNF3:** somente Android.
4. **RU2:** o marcador do mapa não é o pino clássico citado no requisito.
5. **RNF2:** a localização é enviada ao OpenStreetMap para obter o endereço; "anônimo" significa sem conta e sem dados pessoais pedidos, não sem tráfego de rede.

## Trabalhos futuros (lacunas assumidas)

- Editar a posição do pino (hoje só se registra no local do GPS) e filtro por local/área (RF4).
- Onboarding e ajuda, explicando antes o motivo da permissão de localização.
- Persistência dos dados e envio real da foto a um servidor (feedback de upload).
- "Ver no mapa" depois de publicar; desfazer, editar e excluir registros.
- Suporte a iOS; atribuição "© OpenStreetMap" no mapa.

## Checklist manual no aparelho

Preencha com os resultados reais. Itens em branco continuam "Não verificado".

- [ ] 4 toques para publicar (Registrar → foto → categoria → Publicar). Resultado:
- [ ] TalkBack: os controles principais são lidos e acionáveis. Resultado:
- [ ] Tempo de carregamento do mapa e das miniaturas em 4G/Wi-Fi (meta ≤2 s). Resultado:
- [ ] Leitura ao ar livre sob sol. Resultado:
- [ ] Fonte do sistema ampliada: telas sem texto cortado. Resultado:
