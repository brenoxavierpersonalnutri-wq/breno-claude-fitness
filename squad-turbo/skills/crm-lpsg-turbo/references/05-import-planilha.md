# 05 · Import da planilha

> Como a operação que já existe entra no CRM sem perder histórico.
> Só `admin`.

---

## O que costuma existir hoje

Quem vem do `automacoes-lpsg-turbo` tem uma planilha com estas abas:

**`Leads`** — `phone`, `email`, `nome`, `fonte`, `data_inscricao`,
`estado_atual`, `ficha_preenchida`, `comprou`, `valor_compra`, `janela_compra`,
`em_recuperacao`, `responsavel_closer`, `engajamento_aula_1..N`,
`checkout_iniciado_em`, `manychat_id`

**`Alunos`** — 18 colunas (A-R) do `cs-lpsg-turbo`: `timestamp_compra`, `email`,
`whatsapp`, `nome`, `edicao_lpsg`, `ticket_pago`, `data_acesso`,
`ultima_aula_assistida`, `status`, `nps_d30`, `nps_d90`,
`depoimento_coletado`, `tipo_depoimento`, `link_depoimento`, `ascensao`,
`data_conclusao`, `cs_responsavel`, `notas_internas`

---

## Mapeamento

### `Leads` → `pessoas` + `leads`

| Planilha | CRM | Observação |
|---|---|---|
| `phone` | `pessoas.whatsapp` | **normalizar para E.164** |
| `email`, `nome` | `pessoas.email`, `pessoas.nome` | |
| `fonte`, `data_inscricao` | `leads.fonte`, `leads.data_inscricao` | |
| `ficha_preenchida` | `leads.tier` | sem ficha → `sem_ficha` |
| `engajamento_aula_*` | `leads.aulas_assistidas` | **conte quantas**, não copie |
| `checkout_iniciado_em` | `leads.checkout_iniciado_em` | |
| `responsavel_closer` | `leads.responsavel_closer` | resolver nome → `perfis.id` |
| `comprou` | vira `matricula` | não é campo do lead |
| `estado_atual` | **descartar** | derivado pelo trigger |
| `em_recuperacao` | **descartar** | derivado da fila |
| `manychat_id` | **descartar** | o CRM não dispara mensagem |

Três colunas descartadas de propósito. `estado_atual` e `em_recuperacao` eram
mantidas à mão — é exatamente o trabalho que o CRM elimina. `manychat_id` não
tem uso aqui.

**A planilha não tem `presente_pitch` nem `clicou_link`.** Se você tem esses
dados em outro lugar (relatório do YouTube, encurtador), traga numa coluna extra
e mapeie. Se não tem, entram `false` e a fila fica menos precisa nas prioridades
P2/P3 até a próxima edição.

### `Alunos` → `matriculas` + `acompanhamentos` + `depoimentos`

| Planilha | CRM |
|---|---|
| `whatsapp`, `email`, `nome` | `pessoas` (dedupe com quem já veio de `Leads`) |
| `edicao_lpsg` | `edicoes.codigo` — crie a edição se não existir |
| `timestamp_compra`, `ticket_pago` | `matriculas.comprada_em`, `.ticket_pago` |
| `data_acesso`, `ultima_aula_assistida` | `matriculas` |
| `status` | `matriculas.status_aluno` |
| `cs_responsavel` | resolver nome → `perfis.id` |
| `nps_d30`, `nps_d90` | `acompanhamentos` nos marcos D30 e D90 |
| `depoimento_coletado`, `tipo_depoimento`, `link_depoimento` | `depoimentos` |
| `ascensao`, `data_conclusao`, `notas_internas` | `matriculas` |

**Atenção no depoimento:** a planilha não tem campo de autorização. Todo
depoimento importado entra como `coletado` e `autorizado = false` — mesmo os que
já foram usados. É perda de informação de propósito: sem registro de
autorização, não dá para afirmar que existe. Se você tem os aceites, preencha
depois.

---

## Como o import funciona

**Três passos, sempre com prévia:**

1. **Upload** do CSV (exporte cada aba separadamente)
2. **Mapear colunas** — a tela sugere pelo nome, o admin confirma
3. **Prévia**: quantos vão ser criados, quantos atualizados, quantos duplicados
   e quantas linhas com erro — com as 10 primeiras de cada grupo à mostra
4. **Confirmar**

Nunca importe sem prévia. Dedupe errado em base de lead é caro de desfazer.

---

## Dedupe

Chave: **WhatsApp normalizado em E.164**.

```
"11988887777"        → +5511988887777
"(11) 98888-7777"    → +5511988887777
"5511988887777"      → +5511988887777
"+55 11 98888-7777"  → +5511988887777
```

Regra: tira tudo que não é dígito; 10 ou 11 dígitos assume Brasil e prefixa
`+55`; 12 ou 13 começando com `55` prefixa `+`; já tem `+`, mantém.

Número que não bate `^\+[1-9][0-9]{7,14}$` **não é importado** — vai para o
relatório de erro com o valor original. Não tente adivinhar.

**Sem WhatsApp válido, com email:** importe pelo email e marque para revisão. A
pessoa entra, mas não aparece na fila — o `wa.me` precisa do número.

---

## Ordem

1. `edicoes` (crie as que faltarem)
2. `perfis` (closers e CS já criados no Auth)
3. `Leads` → `pessoas` + `leads`
4. `Alunos` → `pessoas` (dedupe) + `matriculas`
5. `acompanhamentos` e `depoimentos`

Inverter a ordem duplica pessoa que é lead e aluno ao mesmo tempo — que é o caso
comum, não a exceção.

---

## Critério de pronto (fase 5)

A planilha real importa, o total de pessoas bate com o de WhatsApps únicos, e
`fila_closer` devolve uma fila coerente com o que o closer esperaria ver.
