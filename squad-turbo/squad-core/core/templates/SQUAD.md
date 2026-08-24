# SQUAD — {NOME DO PROJETO}

> Responsável: @estrategista-turbo

---

## Projeto
- **Nome:**
- **Expert:**
- **Produto:**
- **Tipo de funil:**
- **Ticket:** R$
- **Timeline:**
- **Status:** draft / planning / in_production / in_review / live / completed
- **Criado em:**
- **Pasta:** `projects/{YYYY-MM}-{slug}/`

## Squad Turbo Escalado

| Agente | Função no Projeto | Pasta | Status |
|--------|------------------|-------|--------|
| @estrategista-turbo | Orquestração e triage | `02-estrategia/` | |
| @pesquisador-turbo | Fundação do expert | `00-fundacao/` + `01-extratos/` | |
| @pesquisador-mercado-turbo | Inteligência competitiva | `02-mercado/` | |
| @copywriter-turbo | Copy de todas as peças | `03-copy/` | |
| @diretor-criativo-turbo | Direção visual | `04-direcao/` | |
| @designer-turbo | Execução visual (criativos, slides, páginas) | `05-visual/` | |
| @social-turbo | Conteúdo orgânico (reels, stories) | `06-social/` | |
| @trafego-turbo | Tráfego pago | `07-trafego/` | |
| @automacao-turbo | Mensageria e automações | `08-automacao/` | |
| @cs-turbo | Pós-venda | `09-cs/` | |

## Tarefas do DONO (manual)

| Área | Tarefa | Pasta | Status |
|------|--------|-------|--------|
| Tráfego | Configurar campanhas no gerenciador | `07-trafego/` | |
| Automação | Configurar fluxos (n8n/Make/ManyChat) | `06-automacoes/` | |
| Vendas | Calls e fechamento (se high ticket) | `09-vendas/` | |
| Métricas | Monitorar KPIs no gerenciador | `08-metricas/` | |
| Tracking | Pixel, GTM, conversões | `05-paginas/` | |

## Estrutura de Pastas

```
projects/{YYYY-MM}-{slug}/
├── README.md
├── 00-briefing/
├── 01-pesquisa/
├── 02-estrategia/
├── 03-copy/
│   ├── emails/
│   ├── whatsapp/
│   └── scripts/
├── 04-criativos/
│   ├── brandbook/
│   ├── ads/
│   └── slides/
├── 05-paginas/
├── 06-automacoes/
├── 07-trafego/
├── 08-metricas/
└── 09-vendas/ (se high ticket)
```

## Entregas Esperadas

| # | Peça | Responsável | Pasta | Status |
|---|------|------------|-------|--------|
| 1 | Briefing Estratégico | @estrategista-turbo | `00-briefing/` | |
| 2 | Briefing de Copy | @estrategista-turbo | `00-briefing/` | |
| 3 | Avatar | @estrategista-turbo | `00-briefing/` | |
| 4 | Oferta | @estrategista-turbo | `00-briefing/` | |
| 5 | Definição de Funil | @estrategista-turbo | `02-estrategia/` | |
| 6 | Brandbook | @diretor-criativo-turbo | `04-criativos/brandbook/` | |
| 7 | Copy das Páginas | @copywriter-turbo | `03-copy/` | |
| 8 | Sequência de Emails | @copywriter-turbo | `03-copy/emails/` | |
| 9 | Landing Pages HTML | @diretor-criativo-turbo | `05-paginas/` | |
| 10 | Criativos de Ads | @diretor-criativo-turbo | `04-criativos/ads/` | |
| 11 | Campanhas de Tráfego | DONO | `07-trafego/` | |
| 12 | Automações | DONO | `06-automacoes/` | |

## Gates Pendentes

- [ ] QG-001 — Briefing Completo
- [ ] QG-002 — Estratégia Aprovada
- [ ] QG-003 — Squad Montado
- [ ] QG-004 — Copy Revisada (≥80%)
- [ ] QG-005 — Pré-Lançamento
- [ ] QG-006 — Aprovação Final

## Notas do Estrategista

_Adicionar observações, decisões e ajustes durante o projeto._