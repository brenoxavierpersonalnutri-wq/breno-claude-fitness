---
name: crm-lpsg-turbo
description: >
  Use esta skill sempre que o usuário quiser CONSTRUIR o CRM próprio do
  Lançamento Pago Semanal — o sistema que substitui as planilhas do closer e do
  CS. Trigger para: "criar meu CRM", "CRM do LPSG", "sistema de fila do closer",
  "parar de usar planilha de leads", "fila P1-P5 automática", "contador de
  follow-up", "sistema de recuperação de carrinho", "CRM de alunos", "fila de
  risco do CS", "acompanhamento D0 D90 automático", "pipeline de depoimento",
  "webhook da Hotmart no meu sistema", "importar planilha de leads", "resolver o
  {CRM} do cs-lpsg-turbo". Conduz a construção completa via Fluxo Obrigatório
  (brainstorm → spec → review → fases → auditoria → deploy) em Next.js +
  Supabase + EasyPanel. Entrega schema.sql como contrato imutável e gera a
  aplicação sob medida para o nicho de quem instala.
  FRONTEIRA: esta skill CONSTRÓI o sistema. O método da fila e dos SLAs é
  `closer-lpsg-turbo`; o cronograma D0→D90 é `cs-lpsg-turbo`; copy de mensagem é
  `mensageria-lpsg-turbo`; dashboard de faturamento ao vivo é
  `dash-lancamento-turbo`. Esta skill não escreve copy e não dispara mensagem.
---

# CRM do LPSG — Squad Turbo

Skill de construção. Conduz quem instala o Squad Turbo a **criar o próprio CRM**
seguindo o Fluxo Obrigatório do curso Elite dos Sistemas — não a instalar um CRM
pronto.

A diferença importa: você sai com um sistema que fala a língua do seu nicho, e
aprende o método construindo algo que vai usar toda segunda-feira.

---

## Pré-requisito

Esta skill assume a stack do **módulo 03** do curso já montada:

- VPS com **EasyPanel** rodando
- **Claude Code CLI** no terminal nativo (não o do VS Code)
- Conta **Supabase**
- Conta **GitHub**

Sem isso, pare aqui e monte a infra primeiro. A skill não tem caminho
alternativo — é um caminho só, de propósito.

---

## O problema que ele resolve

| Hoje | Depois |
|---|---|
| Fila P1-P5 remontada à mão cruzando 3 fontes | View calculada — ninguém digita prioridade |
| Cap de follow-up na memória do closer | Constraint no banco — 2 sem resposta e sai sozinho |
| Relatório de objeções escrito toda semana | Consulta pronta no D+7 |
| Fila de risco do CS levantada no olho | As 4 janelas calculadas |
| Autorização de depoimento sem controle | Constraint: sem autorização, não vira usável |
| `CRM: "{CRM}"` nunca resolvido | Resolvido |

---

## Arquitetura

```
Ficha de interesse (página)  ──┐
Hotmart (checkout + compra)  ──┤ webhook
Planilha atual (CSV)         ──┤ import
                               ↓
                     Next.js 14 (App Router)
                       ├── /api/webhook/ficha
                       ├── /api/webhook/hotmart   valida HOTTOK
                       ├── /fila                  mobile-first · closer
                       ├── /lead/[id]             ficha + objeção
                       ├── /relatorio             fechamento D+7
                       ├── /carteira              CS
                       └── /import                CSV
                               ↓
                Supabase (Postgres + Auth + RLS)
                               ↓
        GitHub → EasyPanel (Docker) → domínio + SSL
```

O envio de mensagem **não passa pelo sistema**. A fila abre `wa.me` com o script
preenchido e quem envia é o humano, do próprio número. Zero infra de mensageria,
zero risco de ban, e a recuperação 1:1 continua sendo o que o método manda que
ela seja: humana.

---

## Fixo vs. livre

**Contrato imutável — não altere:**
- `templates/schema.sql`: tabelas, enums, triggers, as views `fila_closer` e
  `fila_risco_cs`
- a máquina de estados do lead
- as regras de prioridade da fila

Campos extras do seu nicho vão em **tabelas novas com FK**, nunca alterando as
existentes. É isso que mantém a sua instância legível pelas outras skills do
squad.

**Livre — gerado sob medida:**
- toda a interface e o visual
- campos e telas adicionais do seu nicho
- textos, nomenclatura e tom

---

## Fluxo de construção

Siga o Fluxo Obrigatório. Não pule o brainstorming, não pule o code review.

```
1. Brainstorm    skill `superpowers:brainstorming` — o que o SEU nicho precisa
                 além do contrato
2. Spec          gera a especificação técnica
3. Review        `superpowers:requesting-code-review` NA SPEC, antes de existir
                 código
4. Plano         quebrado nas 10 fases abaixo
5. Implementação uma fase por vez, com review ao fim de cada uma
6. Auditoria     módulo 06 do curso (OWASP) — antes do primeiro deploy
7. Deploy        GitHub → EasyPanel → domínio + SSL
```

Detalhe em `references/02-fluxo-de-construcao.md`.

### As 10 fases

| # | Entrega | Pronto quando |
|---|---|---|
| 1 | `schema.sql` + policies + seed | Migrations rodam; seed popula; policies criadas |
| 2 | Auth + shell + papéis | Login funciona; RLS verificada com 2 usuários de papéis diferentes |
| 3 | Fila + ficha + `wa.me` | Fila ordena certo; interação incrementa contador; cap manda pra `fora_da_fila` |
| 4 | Webhooks ficha + Hotmart | POST de teste cria lead e move estado; HOTTOK inválido é rejeitado |
| 5 | Import CSV | Planilha real importa com dedupe por WhatsApp |
| 6 | Relatório de fechamento | Objeções agregam por tipo e tier |
| 7 | Auditoria de segurança | Roda sem achado crítico |
| 8 | Deploy | URL própria com HTTPS — **closer em produção** |
| 9 | Carteira + fila de risco | As 4 janelas calculam certo |
| 10 | Pipeline de prova social | Autorização trava o uso do depoimento |

**Fases 1-8 entregam o CRM do closer em produção.** Dá pra parar aí e já usar no
ciclo seguinte. As fases 9-10 cobrem o CS e reentram na auditoria antes de subir.

---

## Regras inegociáveis

1. **A fila é derivada, nunca digitada.** Se alguém precisar escolher a
   prioridade na mão, o desenho está errado — o trabalho manual voltou.
2. **O sistema não escreve copy.** Os scripts moram no `config.yaml` e entram lá
   depois de passar pelo `@revisor-copy-turbo`.
3. **O sistema não dispara mensagem.** Abre `wa.me`. Quem envia é gente.
4. **RLS na primeira migration.** A tabela guarda WhatsApp, email e valor pago.
   Não é opcional e não fica pra depois.
5. **`service_role` é server-only.** Só os webhooks usam. Nunca vai pro browser.
6. **Mobile-first na fila.** O closer trabalha do celular com o WhatsApp do lado.
   Se exigir notebook, ninguém usa e a planilha volta.
7. **Auditoria antes do primeiro deploy.** Não se sobe PII sem auditar.
8. **Contato de risco do CS continua humano.** O sistema aponta quem, não
   substitui a conversa — princípio nº2 do `cs-lpsg-turbo`.

---

## Arquivos

```
templates/
  schema.sql            contrato imutável
  seed.example.sql      dados de exemplo pra testar a fila
  .env.example          variáveis do Supabase
  config.example.yaml   nicho, SLAs, scripts por tier

references/
  00-variaveis-globais.md
  01-modelo-de-dados.md      estados, transições, regras da fila
  02-fluxo-de-construcao.md  o Fluxo Obrigatório aplicado
  03-telas.md                requisitos de cada tela
  04-webhooks.md             contrato de ficha e Hotmart
  05-import-planilha.md      migração de quem já tem Sheets
  06-deploy-easypanel.md     GitHub → Docker → domínio + SSL
```

---

## Fronteiras

| Não faz | Quem faz |
|---|---|
| Escrever script ou copy de mensagem | `@copywriter-turbo` via `mensageria-lpsg-turbo` |
| Disparo em massa | `mensageria-lpsg-turbo` (WABA oficial) |
| Dashboard de faturamento ao vivo | `dash-lancamento-turbo` |
| Definir o método da fila e os SLAs | `closer-lpsg-turbo` — esta skill implementa |
| Definir o cronograma D0→D90 | `cs-lpsg-turbo` — esta skill implementa |
| Auditar a interface gerada | `@picasso-auditor-turbo` |

## Handoffs

- **Recebe de:** webhook da ficha de interesse · webhook da Hotmart · CSV da
  planilha atual
- **Entrega para:** `@estrategista-turbo` (relatório de objeções → debrief e Aula
  4 da próxima edição) · fluxo de CS (lista de compradores → onboarding D0)

> O relatório de objeções é o ativo estratégico da operação: objeção que apareceu
> 5x no 1:1 vira conteúdo da Aula 4 ou criativo de quebra de objeção na próxima
> edição. Antes era redigido à mão; agora é uma consulta.
