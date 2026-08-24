# 03 · Telas — requisitos

> Requisitos, não layout. O visual é gerado no brainstorming e auditado pelo
> `@picasso-auditor-turbo`.

**Premissa que atravessa tudo: o closer trabalha do celular**, com o WhatsApp
aberto do lado. A fila é mobile-first. Se exigir notebook, ninguém usa e a
planilha volta.

---

## `/fila` — a tela que fica aberta a semana toda

Fonte: view `fila_closer`, filtrada pelo `responsavel_closer` do usuário (a RLS
já faz isso).

**Cada linha mostra:** prioridade (P1-P5 com cor), nome, tier, contador de
follow-up (`1 de 2`), e tempo desde o último toque.

**No P1, um relógio de SLA** contando a partir de `sla_expira_em`. Estourou,
destaca. É o único item da fila com urgência real.

**Uma ação primária por linha: `Abrir conversa`.**

```
https://wa.me/{whatsapp sem +}?text={script do tier, urlencoded}
```

O script vem do `config.yaml`, com `{{nome}}` substituído. Nunca hardcode script
no componente.

**Ao voltar, registro em três toques:** `respondeu` · `sem resposta` · `fechou`.
Isso grava uma `interacao`. O tipo é `abertura` se for o primeiro toque, senão
`follow_up` — a aplicação decide, o usuário não escolhe.

**Registrou errado?** O autor pode corrigir o próprio registro por **15 minutos**
(a RLS impõe a janela — a interface deve mostrar "corrigir" só enquanto vale, e
explicar o prazo quando expirar). Depois disso, correção é com o admin.

Se a gravação falhar por `uniq_abertura_por_lead`, a interface já registrou uma
abertura para esse lead: grave como `follow_up`.

**Ordenação:** `order by prioridade, ordenar_por`. Nunca ofereça reordenar à mão.

---

## `/lead/[id]` — a ficha

- Sinais que classificaram (tier, presença no pitch, clique, aulas)
- Histórico de interações, mais recente primeiro
- Contador de follow-up **visível**: `1 de 2`
- Botão de **registrar objeção**: tipo (6 opções) + texto livre opcional. Um
  clique. Se der trabalho, ninguém preenche e o relatório do D+7 nasce vazio.
- Ação de marcar `perdido`, com `motivo_perda`

Quando o lead entra em `fora_da_fila`, deixe explícito **por quê** — senão parece
bug.

---

## `/relatorio` — fechamento do D+7

Por edição:

- fechou · não fechou · saiu da fila
- objeções por **tipo**, e cruzadas por **tier**
- taxa de resposta por prioridade
- tempo médio de atendimento do P1 contra o SLA de 30 min

Exportável. É o insumo do debrief com o `@estrategista-turbo` e da pauta da Aula
4 da próxima edição.

---

## `/carteira` — CS

Alunos do CS Oficial (RLS filtra), com marcos D0→D90, status e NPS. Ação de
registrar acompanhamento.

---

## `/risco` — fila de risco do CS

Fonte: view `fila_risco_cs`. Agrupada pelas quatro janelas.

Mesma mecânica de `Abrir conversa` da fila do closer. **O contato é humano** — o
sistema aponta quem, não escreve nem envia.

---

## `/prova-social` — depoimentos

Kanban por estágio: `solicitado` → `coletado` → `autorizado` → `publicado`.

**A passagem para `autorizado` exige `autorizacao_texto` e `autorizado_em`** — o
banco tem constraint, mas a interface precisa deixar claro *por que* está
bloqueado, senão vira suporte.

---

## `/import` — CSV

Só `admin`. Detalhe em `05-import-planilha.md`.

Três passos: upload → mapear colunas → **prévia com o que vai criar, atualizar e
deduplicar** → confirmar. Nunca importe sem prévia.

---

## `/config` — configuração

Só `admin`. Edição corrente, closers e CS ativos, e leitura do `config.yaml`.

Os scripts são **somente leitura** aqui — mudança de script passa pelo
`@revisor-copy-turbo` e entra pelo arquivo, versionado. Se a interface deixar
editar, o gate de copy morre.

---

## Fora do v1

Disparo de mensagem · relatório de tráfego · dashboard de faturamento (é o
`dash-lancamento-turbo`) · qualquer coisa multi-cliente.
