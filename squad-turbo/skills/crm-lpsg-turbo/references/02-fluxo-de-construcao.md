# 02 · Fluxo de construção — o Fluxo Obrigatório aplicado

> Método do curso Elite dos Sistemas (módulo 04) aplicado a este projeto.
> A tentação de pular o brainstorming e o code review é grande quando o schema
> já vem pronto. Não pule: o schema é 20% do sistema.

---

## O fluxo

```
1. Brainstorm     → o que o SEU nicho precisa além do contrato
2. Spec           → especificação técnica
3. Review da spec → ANTES de existir código
4. Plano          → as 10 fases
5. Implementação  → uma fase por vez, review ao fim de cada
6. Auditoria      → OWASP, antes do primeiro deploy
7. Deploy         → GitHub → EasyPanel → domínio + SSL
```

---

## 1 · Brainstorm

```
/superpowers:brainstorming CRM do LPSG para o nicho {NICHO}
```

O que **não** entra em discussão (é contrato): tabelas, enums, triggers, as views
`fila_closer` e `fila_risco_cs`, a máquina de estados.

O que **precisa** ser decidido por nicho:

- campos extras do lead que o seu nicho usa (tabela nova com FK, nunca `alter
  table` nas existentes)
- como a interface nomeia as coisas na sua língua
- quais telas além das obrigatórias
- se o CS entra no v1 ou fica para depois

## 2 · Spec

A spec sai do brainstorming. Precisa dizer: telas, rotas, contrato de cada
webhook, o que cada papel enxerga, e o critério de "pronto" de cada fase.

## 3 · Review da spec — antes de qualquer código

```
/superpowers:requesting-code-review
```

Revisar a especificação antes de existir código é o passo que o curso mais
enfatiza e o que mais gente pula. Erro de modelagem descoberto aqui custa uma
conversa; descoberto na fase 8 custa uma refatoração.

**Modelo:** Opus. Não economize tokens no review — o curso é explícito: o que
você economiza aqui, gasta multiplicado consertando bug depois.

## 4 · Plano

Quebre nas 10 fases do `SKILL.md`. Cada fase é independente: dá para parar,
esperar o token resetar, e retomar.

## 5 · Implementação

Uma fase por vez. Code review ao fim de cada uma, antes de começar a próxima.

### Ordem e critério de pronto

| # | Entrega | Pronto quando |
|---|---|---|
| 1 | `schema.sql` + policies + seed | Migrations rodam; `seed.example.sql` popula; as consultas de conferência do seed batem |
| 2 | Auth + shell + papéis | Login funciona; RLS verificada com **dois usuários de papéis diferentes** |
| 3 | Fila + ficha + `wa.me` | Fila ordena certo; interação incrementa contador; 2 sem resposta manda pra `fora_da_fila` |
| 4 | Webhooks | POST de teste cria lead e move estado; HOTTOK inválido é **rejeitado** |
| 5 | Import CSV | Planilha real importa com dedupe por WhatsApp |
| 6 | Relatório | Objeções agregam por tipo e tier |
| 7 | Auditoria | Sem achado crítico |
| 8 | Deploy | URL própria com HTTPS |
| 9 | Carteira + risco | As 4 janelas calculam certo |
| 10 | Prova social | Autorização trava o uso |

**Fases 1-8 põem o closer em produção.** Pare aí se quiser — já dá para usar no
ciclo seguinte.

### Testar a fase 1 sem escrever aplicação

Rode `templates/seed.example.sql` e confira:

```sql
select nome, prioridade, follow_ups
  from fila_closer
 order by prioridade, ordenar_por;
```

Cinco linhas, na ordem P1→P5. "Fora Sem Sinal" e "Comprou" não aparecem. Se isso
não bater, pare — não adianta construir interface sobre uma fila errada.

## 6 · Auditoria de segurança

Módulo 06 do curso. Roda **depois** da implementação e **antes** do primeiro
deploy — não dá para auditar o que ainda não existe, e não se sobe PII sem
auditar.

Mande a **arquitetura**. Nunca mande `.env`, credenciais ou dump de dados.

Pontos de atenção específicos deste projeto:

- `service_role` vazando para o browser (o achado mais grave possível aqui)
- webhook aceitando requisição sem validar HOTTOK ou `X-Ficha-Secret`
- RLS desligada em alguma tabela
- rota de import acessível a papel não-admin
- PII em log de erro

## 7 · Deploy

`references/06-deploy-easypanel.md`.

---

## Gates do squad

| Momento | Gate | Quem |
|---|---|---|
| Scripts entrando no `config.yaml` | Revisão anti-IA e de voz | `@revisor-copy-turbo` |
| Interface gerada | Auditoria visual | `@picasso-auditor-turbo` |
| Fim de cada fase | Code review | `superpowers:requesting-code-review` |
| Antes do deploy | Auditoria de segurança | Módulo 06 |

---

## Dicas de operação do Claude Code (módulo 07)

- `/model` → **Opus** para brainstorm, spec e review. Sonnet para executar, se
  precisar economizar.
- `/compact` quando o contexto encher no meio de uma fase; `/clear` entre fases.
- `--resume` para retomar a conversa de uma fase interrompida.
- Terminal nativo, não o Claude dentro do VS Code — só o terminal tem o harness
  completo.
- Erro de deploy: cole a saída inteira no próprio Claude Code antes de abrir
  ticket. Resolve na maioria das vezes.
