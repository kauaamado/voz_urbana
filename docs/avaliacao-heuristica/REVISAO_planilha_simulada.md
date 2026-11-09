# Revisão da avaliação heurística simulada (IA)

**Natureza do material.** `planilha_avaliacao_heuristica_SIMULADA_IA_5_personas.xls` foi preenchida por 5 agentes de IA
(Claude Haiku), cada um assumindo uma persona (Dona Marlene, 68 anos; Lucas, 20; Carlos, entregador; Renata, servidora
pública; Ana, usuária de leitor de tela). Eles avaliaram **lendo o código-fonte** de `lib/`, sem executar o app.
**Não são avaliadores humanos** e não substituem a avaliação dos colegas.

**Esta revisão.** Feita a pedido do aluno, com apoio do Claude Code, para remover inconsistências e erros factuais do
rascunho gerado pelos agentes. Os arquivos originais estão em `dados_simulados/persona*_original.json` e os corrigidos em
`dados_simulados/persona*.json`. Foram **15 alterações**, listadas abaixo.

## Regras aplicadas

1. **Itens de site sem análogo no app** (animação Flash, som, impressão, resolução 800x600, compatibilidade de navegador,
   mapa do site) ficam **N/A para todas as personas**.
2. **Itens com análogo móvel direto** (links → elementos tocáveis; "navegador sem imagens" → imagens/mapa que não
   carregam) são **pontuados por todas as personas**.
3. **Itens de existência** (ex.: "Existe um índice de ajuda?"): a ausência é **pontuada**, como no próprio modelo do
   professor ("Existe um mapa do site? Não."), e não marcada como N/A.
4. **Erros factuais** (comentário que contradiz o código) são corrigidos, com a evidência.

## Alterações

| Persona | Item | Nota (antes → depois) | Motivo |
|---|---|---|---|
| P1 Dona Marlene | 1.4 | N/A → 1 | Item de site (links) adaptado ao análogo móvel (elementos tocáveis); as outras 4 personas já avaliaram assim. |
| P2 Lucas | 3.4 | 0 → N/A | Item sem análogo no app (sem áudio); as outras 4 personas marcaram N/A. |
| P2 Lucas | 3.5 | N/A → 0 | Item de navegador adaptado ao análogo móvel (imagens/mapa que não carregam); P1, P3 e P5 avaliaram assim, P2 e P4 marcaram N/A apesar de descreverem o comportamento. |
| P4 Renata | 3.5 | N/A → 0 | Item de navegador adaptado ao análogo móvel (imagens/mapa que não carregam); P1, P3 e P5 avaliaram assim, P2 e P4 marcaram N/A apesar de descreverem o comportamento. |
| P1 Dona Marlene | 9.2 | N/A → 1 | Item de existência: o app não tem índice/central de ajuda. O modelo do professor pontua a ausência (ex.: 'Existe um mapa do site? Não.'); P4 pontuou, as demais marcaram N/A. |
| P2 Lucas | 9.2 | N/A → 1 | Item de existência: o app não tem índice/central de ajuda. O modelo do professor pontua a ausência (ex.: 'Existe um mapa do site? Não.'); P4 pontuou, as demais marcaram N/A. |
| P3 Carlos | 9.2 | N/A → 1 | Item de existência: o app não tem índice/central de ajuda. O modelo do professor pontua a ausência (ex.: 'Existe um mapa do site? Não.'); P4 pontuou, as demais marcaram N/A. |
| P5 Ana | 9.2 | N/A → 1 | Item de existência: o app não tem índice/central de ajuda. O modelo do professor pontua a ausência (ex.: 'Existe um mapa do site? Não.'); P4 pontuou, as demais marcaram N/A. |
| P5 Ana | 9.3 | N/A → 0 | P1–P4 avaliaram a ajuda existente (nota 0); P5 marcou N/A. |
| P3 Carlos | 4.5 | N/A → 0 | P1 e P2 avaliaram o item pelo código (nota 0); P3 marcou N/A pelo mesmo motivo (não executou). |
| P3 Carlos | 5.3 | 2 → 2 | Removida a afirmação de que um toque duplo pode duplicar o registro: não verificada, e a rota em saída ignora toques. |
| P4 Renata | 1.8 | 0 → 1 | Erro factual: o comentário original dizia que 'Mapa' e 'Linha do Tempo' são títulos de tela; no código a AppBar é sempre 'Voz Urbana' (P1, P2, P3 e P5 apontaram isso). |
| P5 Ana | 4.5 | 1 → 1 | Imprecisão: o botão não fica sem informação (mostra spinner); a lacuna é só para leitor de tela. |
| P4 Renata | 3.6 | (igual) → 1 | Unidade: o Flutter usa pixels lógicos (12 px), não pontos. |
| P4 Renata | 8.8 | (igual) → 1 | Unidade: o Flutter usa pixels lógicos (12 px), não pontos. |

## O que **não** foi alterado

- Diferenças de opinião e de severidade entre as personas: são o objetivo de usar personas diferentes.
- Os "N/A" da persona Ana nos itens puramente visuais (8.4 a 8.8, 8.10 e 8.12): coerentes com uma persona que usa leitor de tela.
- Os achados de maior severidade (não poder desfazer/editar, localização capturada só ao abrir a tela, seletor de
  datas em inglês, falta de busca/filtro por categoria): conferidos no código e mantidos.

## Limites que continuam valendo

- Os agentes não rodaram o app; comentários sobre leitor de tela (ordem de foco, anúncios) não foram verificados com o
  TalkBack e devem ser lidos como hipóteses.
- **O modelo do professor tem os títulos dos grupos 9 e 10 trocados em relação aos itens**: sob "9. Auxiliar os usuários
  a reconhecer, diagnosticar e corrigir erros" estão as perguntas de ajuda (9.1 a 9.3), e sob "10. Ajuda e
  Documentação" estão as de mensagens de erro e desfazer (10.1 e 10.2). A planilha **não foi alterada** quanto a isso;
  no relatório, interprete os itens pelo conteúdo e mencione o ponto.

## Confirmação do aluno

Marque somente depois de ler as alterações acima e conferir os itens no código.

- [ ] Li as 15 alterações e concordo com elas. Nome: ________________  Data: ____/____/______
