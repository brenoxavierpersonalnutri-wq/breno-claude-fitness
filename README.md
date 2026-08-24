# SQUAD BRENO XAVIER — Consultoria Fitness

Squad de agentes que replica a consultoria fitness do Breno Xavier, voltada para **mulheres 24–45 anos com objetivo de corpo definido** (não é programa de emagrecimento).

## Estrutura

| Pasta | O que vive aqui |
|-------|------------------|
| `agents/` | Definição de cada agente do squad (persona, escopo, inputs/outputs) |
| `skills/` | Skills técnicas que os agentes acionam (cada skill = uma pasta com SKILL.md) |
| `core/` | Metodologia, princípios e regras de decisão da consultoria |
| `templates/` | Modelos prontos (relatório de reavaliação, plano de dieta) |
| `checklists/` | Checklists operacionais que cada agente segue antes de entregar |
| `workflows/` | Fluxos end-to-end (ex.: aluna manda foto → reavaliação pronta) |
| `data/` | Dados das alunas (anamnese, histórico, fotos) — ignorado no git |
| `tasks/` | Tasks ativas / em andamento |
| `config.yaml` | Parâmetros globais (macros default, fontes de dados) |
| `squad.yaml` | Manifesto do squad (lista agentes, skills, workflows) |
| `squad-turbo/` | Squad Turbo · LPSG 7.0 — marketing/lançamento, separado da consultoria (ver `squad-turbo/INSTALAR.md`) |

## Agentes no ar

1. **Agente Reavaliação Postural** (`agents/reavaliacao-postural.md`) — compara fotos antes/depois e gera relatório no modelo oficial do Breno
2. **Agente Dieta Mensal** (`agents/dieta-mensal.md`) — monta/atualiza dieta mensal da aluna respeitando princípios da metodologia e fase de composição corporal

## Próximos a entrar (pendentes de briefing do Breno)

- Agente de Treino
- Agente de Acompanhamento / Follow-up
- Agente de Captação / Vendas
- Agente de Anamnese (migração do Google Forms)

## Público e posicionamento

- **Público:** mulheres 24–45
- **Desejo principal:** corpo definido, perder gordura é meio — definição é o fim
- **Diferencial:** aderência (dieta gostosa, com volume de comida) + lógica de fases (secar antes de ganhar massa, sem ganhar barriga)
