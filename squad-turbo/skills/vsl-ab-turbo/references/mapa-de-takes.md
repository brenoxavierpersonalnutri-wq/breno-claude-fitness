# Mapa de takes — classificação de blocos e convenções de gravação

## Por que mapa de takes

O talento grava uma vez; o editor monta duas versões. Sem um mapa com IDs, a comunicação entre roteiro, sessão de gravação e timeline vira telefone sem fio. O mapa é o contrato entre as três pontas: cada trecho falado tem um ID, e o roteiro de edição referencia esses IDs.

## Classificação dos blocos (faça isso ANTES de gerar qualquer documento)

Percorra o roteiro aprovado (11 blocos da `criador-vsl-turbo`) e etiquete cada um:

| Etiqueta | Critério | Tratamento |
|---|---|---|
| **Compartilhado** | Texto idêntico nas duas versões | Um take só, entra nas duas montagens |
| **Específico A / Específico B** | Texto diferente por versão | Dois takes, um por versão |
| **Parcial** | Só a abertura (1º parágrafo) muda | Take da variante A + take da variante B + take da continuação compartilhada — a emenda vira ponto de corte |
| **Só-A** | Existe apenas na Linha A (ex.: parágrafo de revelação do método no bloco de mecanismo) | Um take isolado, com pausa antes E depois — na montagem B ele é simplesmente pulado |

Distribuição típica num roteiro 11 blocos com A/B de consciência:
- Blocos 1 (hook), 2-abertura e 3 (credibilidade): específicos ou parciais.
- Bloco 4 (mecanismo): compartilhado + um trecho Só-A (a revelação).
- Blocos 5-11: compartilhados.

Se a divergência passar disso (ex.: oferta diferente por versão), questione — provavelmente não é um teste A/B de consciência, são dois produtos, e aí é outro projeto.

## Convenção de IDs

- `A1, A2, A3...` — takes específicos da versão A, na ordem do roteiro.
- `B1, B2, B3...` — específicos da versão B.
- `2C, 4, 4F, 5...` — compartilhados (número do bloco; sufixo quando o bloco foi partido: `2C` = continuação do bloco 2, `4F` = fechamento do bloco 4).
- `4A` (ou similar) — trecho Só-A dentro de bloco compartilhado.
- `EXTRA A2, EXTRA B3...` — hooks alternativos gravados como takes avulsos.

## Convenções de gravação (anote no teleprompter como direção)

- **Entre takes:** pausa de ~3 segundos, olhar pra câmera, retomar. É o ponto de corte do editor — sem a pausa, não há onde cortar limpo.
- **Trecho Só-A:** pausa deliberada antes E depois, porque na montagem B ele sai inteiro e as duas pontas precisam emendar.
- **FAQ:** cada pergunta-resposta é um mini-take com pausa entre elas — permite reordenar, cortar ou clipar respostas individualmente.
- **Blocos condicionados** (ex.: escassez pendente de mecanismo real): GRAVAR mesmo assim — regravar depois custa outra sessão; o que se segura é a publicação, não a gravação. Marcar a condição no teleprompter e no roteiro de edição.

## Ordem de gravação (Parte 1 → 2 → 3)

1. **Parte 1 — Versão A completa, do hook ao fechamento.** O talento mantém o arco emocional de uma VSL inteira (energia do hook, gravidade da oferta, urgência do fechamento). Os takes compartilhados saem desta passada.
2. **Parte 2 — só os takes divergentes da versão B.** Poucos minutos. O talento acabou de falar o conteúdo, está aquecido.
3. **Parte 3 (opcional) — hooks alternativos**, ~15s cada. Viram variações de abertura pro teste e cortes de anúncio. Gravar os que houver energia.

## Exemplo real (VSL Squad Turbo, 2026-07)

Roteiro de 11 blocos, A/B dor-ampla × método-explícito (LPSG). Resultado do mapeamento:

| Take | Conteúdo | Entra em |
|---|---|---|
| A1 | Hook dor ampla | Só A |
| A2 | Problema — abertura A | Só A |
| 2C | Problema — continuação (freelancer/agência/tráfego/teto) | A e B |
| A3 | Credibilidade — versão A (sem a sigla do método) | Só A |
| 4 | Mecanismo parte 1 | A e B |
| 4A | Revelação do método (nomeia o LPSG pela 1ª vez) | **Só A** |
| 4F | Mecanismo fechamento ("vira maestro") | A e B |
| 5–11 | Quebra de crença, prova, depoimentos, future pacing, oferta, FAQ, escassez, fechamento | A e B |
| B1, B2, B3 | Hook B, abertura B, credibilidade B | Só B |
| EXTRAS | 6 hooks alternativos | Reserva |

Montagem A: `A1 → A2 → 2C → A3 → 4 → 4A → 4F → 5…11`
Montagem B: `B1 → B2 → 2C → B3 → 4 → 4F → 5…11` (pula o 4A; a emenda 4→4F é coberta com screencast)

Custo real da segunda versão: ~2 minutos a mais de gravação.
