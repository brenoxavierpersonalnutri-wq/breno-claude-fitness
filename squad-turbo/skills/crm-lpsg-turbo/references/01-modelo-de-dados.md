# 01 · Modelo de dados — o contrato

> `templates/schema.sql` é a fonte da verdade. Este arquivo explica o **porquê**
> de cada decisão. Campos extras do seu nicho vão em tabelas novas com FK, nunca
> alterando as daqui.

---

## Os dois princípios

### 1 · A fila é derivada, nunca digitada

Na planilha, `estado_atual` é uma coluna que alguém preenche à mão, e a fila
P1-P5 é remontada no olho toda semana cruzando três fontes.

No CRM, `fila_closer` é uma **view**. Ninguém escolhe prioridade — ela cai dos
sinais que já chegam sozinhos. Se em algum momento alguém precisar digitar
prioridade, o desenho quebrou e o trabalho manual voltou.

### 2 · Pessoa e participação são coisas diferentes

A mesma pessoa reaparece em várias edições — é para isso que existe o sistema de
tags `LPSG-W{NN}` com as fases PASSADO/PRESENTE/FUTURO/EX-ALUNO. Quem não comprou
na W12 volta na W15.

Por isso `pessoas` guarda o humano (identidade estável) e `leads` guarda a
participação numa edição (efêmera). O dedupe é por WhatsApp em E.164.

---

## Entidades

```
pessoas ──┬─< leads >──── edicoes
          │      │
          │      └──< interacoes >──< objecoes
          │
          └─< matriculas >──┬──< acompanhamentos
                            └──< depoimentos
```

| Tabela | Guarda | Chave natural |
|---|---|---|
| `pessoas` | nome, whatsapp, email | whatsapp E.164 |
| `edicoes` | `LPSG-W12`, abertura e fechamento do carrinho | código |
| `leads` | tier, sinais, estado, responsável | pessoa + edição |
| `interacoes` | canal, tipo, resultado, quando | lead |
| `objecoes` | tipo + texto real | interação |
| `matriculas` | ticket, status de pagamento, jornada do aluno | pessoa + edição |
| `acompanhamentos` | marco D0→D90, NPS | matrícula |
| `depoimentos` | estágio, link, autorização | matrícula |

**Nota:** `depoimentos` é tabela própria, separada de `acompanhamentos`, porque
tem ciclo de vida e regra de autorização próprios — um depoimento não é um marco
de acompanhamento.

---

## Máquina de estados do lead

```
inscrito → engajado → pitch → checkout_iniciado → comprou
                                    ↓
                              perdido | fora_da_fila
```

| Estado | Entra quando | Quem dispara |
|---|---|---|
| `inscrito` | lead criado | webhook da ficha ou import |
| `engajado` | `aulas_assistidas > 0` | trigger |
| `pitch` | `presente_pitch = true` | trigger |
| `checkout_iniciado` | `checkout_iniciado_em` preenchido | webhook Hotmart |
| `comprou` | compra aprovada | webhook Hotmart |
| `perdido` | closer marca, ou carrinho fecha sem compra | manual |
| `fora_da_fila` | 2 interações sem resposta | trigger |

Os três últimos são **terminais**: o trigger `recalcula_estado_lead()` não os
sobrescreve. Os demais são recalculados a cada `insert`/`update`.

### Por que `fora_da_fila` é trigger e não disciplina

O `closer-lpsg-turbo` define: *"1 abertura de conversa por lead, máx 2
follow-ups. Não respondeu 2x → sai da fila."* Hoje esse contador existe só na
memória de quem atende — e memória sob pressão de carrinho aberto falha.

No schema virou duas coisas:

- `uniq_abertura_por_lead` — índice único parcial. Uma segunda abertura no mesmo
  lead **falha no banco**.
- `aplica_cap_follow_up()` — trigger que conta os `sem_resposta` **seguidos** e
  move para `fora_da_fila` no segundo.

A regra deixou de depender de alguém lembrar dela.

Dois detalhes do trigger que importam na operação:

- **Uma resposta zera a série.** O trigger conta só os `sem_resposta` depois do
  último `respondeu`/`fechou`. Quem respondeu tem conversa viva — os toques
  antigos não contam contra ela.
- **O lead pode voltar do `fora_da_fila`.** Se ele responder semanas depois, o
  closer atualiza o estado (qualquer não-terminal — o trigger recalcula pelos
  sinais) e registra a interação normalmente. Só um novo par de `sem_resposta`
  seguidos derruba de novo.

---

## Atributos ortogonais ao estado

| Campo | Origem |
|---|---|
| `tier` (`hot`/`warm`/`cold`/`sem_ficha`) | ficha de interesse |
| `presente_pitch` | import ou update do admin |
| `clicou_link` | import ou update do admin |
| `aulas_assistidas` | import ou update do admin |
| `checkout_iniciado_em` | webhook Hotmart |

---

## Regras da fila (`fila_closer`)

| Prioridade | Condição | SLA |
|---|---|---|
| P1 | `checkout_iniciado_em` preenchido | ≤30 min |
| P2 | `hot` + pitch + clique | D+1 até 19h |
| P3 | `hot` + pitch | D+1 manhã |
| P4 | `warm` + 3 aulas ou mais | D+2 |
| P5 | `cold` ou `sem_ficha` | D+3+ |

**Excluídos:** só `comprou`, `perdido` e `fora_da_fila`. Todo lead ativo entra
na fila — inclusive o `sem_ficha` que nunca apareceu no pitch. A razão é do
método: **todo lead da base pagou o ingresso**. Quem passou o cartão uma vez
merece pelo menos uma abertura, nem que seja a última da fila. (Decisão de
2026-08-12; antes o `sem_ficha` sem pitch ficava fora.)

**Ordem dentro da prioridade:** pelo sinal que a gerou — `checkout_iniciado_em`
no P1, `data_inscricao` nos demais. Mais antigo primeiro.

> Regra de ouro do método, preservada: a fila anda de cima para baixo. Quem
> iniciou checkout hoje vale mais que qualquer ficha de ontem.

---

## Fila de risco do CS (`fila_risco_cs`)

As quatro janelas do `cs-lpsg-turbo`, calculadas:

| Risco | Condição |
|---|---|
| `sem_primeiro_login` | sem `data_acesso` 48h depois da compra |
| `sem_vitoria_d7` | sem atividade 7 dias depois da compra |
| `sumiu_7_dias` | `ultima_atividade_em` há mais de 7 dias |
| `nps_baixo` | algum NPS ≤ 6 |

O sistema aponta quem. **O contato continua humano** — princípio nº2 do
`cs-lpsg-turbo`.

---

## Objeções

`preco · decisor · ceticismo · momento · adiamento · outro`

Espelham a matriz do `closer-lpsg-turbo`. Tipar é o que permite o relatório do
D+7 sair por consulta em vez de redação manual — e é o que transforma "objeção
que apareceu 5x" em pauta da Aula 4 da próxima edição.

---

## RLS

Ligada na primeira migration, sem exceção. As tabelas guardam WhatsApp, email e
valor pago.

| Papel | Enxerga |
|---|---|
| `closer` | leads seus e os sem dono (para poder assumir) |
| `cs` | matrículas sob sua responsabilidade |
| `admin` | tudo, mais import e configuração |

`meu_papel()` e `sou_admin()` são `SECURITY DEFINER` para não recursar dentro das
próprias policies.

**Correção de registro (decisão de 2026-08-12):** interações e objeções aceitam
UPDATE do próprio autor por **15 minutos** — o suficiente pro erro de dedo, curto
demais pra reescrever histórico. Depois da janela, só admin. Não existe DELETE:
registro errado se corrige, não se apaga. Detalhe operacional: corrigir um
`sem_resposta` pra `respondeu` não reativa sozinho um lead que já caiu pra
`fora_da_fila` — o closer reativa pela ficha e o trigger recalcula.

Os webhooks escrevem com a `service_role`, que ignora RLS por definição. Essa
chave é **server-only** — se vazar para o browser, o banco inteiro vaza junto.
