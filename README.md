# SQUAD BRENO XAVIER — Consultoria Fitness

Squad de agentes que replica a consultoria fitness do Breno Xavier, voltada para **mulheres 24–45 anos com objetivo de corpo definido** (não é programa de emagrecimento).

---

## Instalação (para o time)

Dentro do Claude Code, rode os dois comandos:

```
/plugin marketplace add brenoxavierpersonalnutri-wq/breno-claude-fitness
/plugin install squad-breno@breno-xavier
```

Depois rode `/reload-plugins` se a instalação pedir.

Pronto — os agentes e as skills ficam disponíveis em qualquer pasta, sem precisar clonar nada.

**Pré-requisitos:** o repositório é privado, então quem for instalar precisa ter acesso a ele no GitHub (o Breno adiciona como colaborador em Settings → Collaborators). Para o auto-update funcionar em repo privado, rode uma vez:

```
gh auth setup-git
```

### Como usar depois de instalado

As skills ficam com o prefixo do plugin:

- `/squad-breno:dieta-mensal`
- `/squad-breno:avaliacao-postural`

Os agentes (`dieta-mensal`, `dieta-mounjaro-glp1`, `reavaliacao-postural`) são acionados automaticamente pelo contexto do pedido, ou você pode chamar pelo nome.

### Alternativa: abrir o repo direto

Também dá para clonar e abrir o Claude Code dentro da pasta. Nesse modo o `CLAUDE.md` é carregado e vale a REGRA DE OURO dele. Os dois modos funcionam — os agentes resolvem o caminho dos arquivos sozinhos.

---

## Estrutura

| Pasta | O que vive aqui |
|-------|------------------|
| `.claude-plugin/` | Manifesto do plugin e do marketplace (distribuição) |
| `agents/` | Definição de cada agente do squad (persona, escopo, inputs/outputs) |
| `skills/` | Skills técnicas que os agentes acionam (cada skill = uma pasta com SKILL.md) |
| `core/` | Metodologia, princípios e regras de decisão da consultoria |
| `core/knowledge-base/` | Fichas técnicas consultáveis (estudos Dudu Haluch) |
| `templates/` | Modelos prontos (relatório de reavaliação, plano de dieta) |
| `checklists/` | Checklists operacionais que cada agente segue antes de entregar |
| `workflows/` | Fluxos end-to-end (ex.: aluna manda foto → reavaliação pronta) |
| `data/` | Dados das alunas (anamnese, histórico, fotos) — ignorado no git |
| `tasks/` | Tasks ativas / em andamento |
| `config.yaml` | Parâmetros globais (macros default, fontes de dados) |
| `squad.yaml` | Manifesto do squad (lista agentes, skills, workflows) |

## Agentes no ar

1. **Agente Reavaliação Postural** (`agents/reavaliacao-postural.md`) — compara fotos antes/depois e gera relatório no modelo oficial do Breno
2. **Agente Dieta Mensal** (`agents/dieta-mensal.md`) — monta/atualiza dieta mensal da aluna respeitando princípios da metodologia e fase de composição corporal
3. **Agente Dieta Mounjaro / GLP-1** (`agents/dieta-mounjaro-glp1.md`) — dieta calibrada para aluna em uso de caneta emagrecedora; substitui o agente de dieta mensal nesses casos

## Próximos a entrar (pendentes de briefing do Breno)

- Agente de Treino
- Agente de Acompanhamento / Follow-up
- Agente de Captação / Vendas
- Agente de Anamnese (migração do Google Forms)

## Público e posicionamento

- **Público:** mulheres 24–45
- **Desejo principal:** corpo definido, perder gordura é meio — definição é o fim
- **Diferencial:** aderência (dieta gostosa, com volume de comida) + lógica de fases (secar antes de ganhar massa, sem ganhar barriga)

---

## Publicar uma atualização

O plugin lê a versão de `.claude-plugin/plugin.json`. Para o time receber uma mudança:

1. Faça a alteração e suba pro `main`
2. Suba o campo `version` em `.claude-plugin/plugin.json` (ex: `0.1.0` → `0.1.1`)
3. O time roda `/plugin marketplace update breno-xavier`

Sem bump de versão, a atualização não é entregue.
