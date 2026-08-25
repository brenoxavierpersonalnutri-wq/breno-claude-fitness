---
name: avaliacao-postural
description: Gera relatórios de Avaliação e Reavaliação Postural em markdown/PDF para a consultoria do Breno Xavier. Lê fotos (frontal, posterior, laterais), classifica por região em graus Normal/Leve/Alteração, e compara antes/depois quando aplicável.
---

# Skill: Avaliação Postural

> **Caminhos:** todo caminho citado aqui (`core/`, `config.yaml`, `templates/`, `checklists/`) é relativo à **raiz do squad**. Instalado como plugin, a raiz é `${CLAUDE_PLUGIN_ROOT}` (ex: `${CLAUDE_PLUGIN_ROOT}/core/dieta-principios.md`). Com o repo aberto direto, a raiz é a pasta do projeto (ex: `core/dieta-principios.md`). Não achou num, tente o outro **antes** de seguir.
>
> **Nunca** monte a entrega sem ter lido os arquivos da seção "Dependências" no fim deste arquivo. As saídas por aluna (`data/<aluna>/...`) vão para a pasta de trabalho do usuário, nunca para dentro do plugin.


Habilidade técnica acionada pelo **Agente de Reavaliação Postural** (`agents/reavaliacao-postural.md`).

## O que esta skill faz

1. Recebe fotos da aluna + metadados (nome, datas, anamnese)
2. Para cada região anatômica, analisa as views disponíveis e descreve o achado + classifica o grau
3. Monta o relatório usando `templates/reavaliacao-postural.md`
4. Se houver fotos anteriores, gera coluna "Antes" e calcula coluna "Evolução"
5. Salva o MD em `data/<aluna>/reavaliacao-YYYY-MM-DD.md`
6. (Opcional) converte para PDF com mesmo layout do modelo oficial

## Graus

| Grau | Descrição |
|------|-----------|
| Normal | Sem alteração postural identificada. Segmento dentro dos padrões fisiológicos esperados. |
| Leve | Desvio postural discreto, sem comprometimento funcional significativo. Pode ser corrigido com treino e consciência postural. |
| Alteração | Desvio postural evidente que requer atenção no planejamento do treino. Pode impactar o desempenho e aumentar o risco de lesões se não for trabalhado. |

## Regiões avaliadas (ordem fixa do relatório)

1. Cabeça / Cervical — anteriorização cervical, protrusão do queixo
2. Ombros / Tórax — protrusão anterior de ombros, abertura torácica
3. Tórax / Dorsal — cifose, tônus dorsal
4. Abdome — protuberância, tônus, cintura
5. Pelve / Lombar — anteversão pélvica, curvatura lombar
6. Quadril / Glúteos — contorno, tônus, projeção
7. Joelhos — alinhamento sagital, hiperextensão
8. Tornozelos / Pés — alinhamento sagital

## Views mínimas

- **Frontal** + **Posterior** → obrigatórias
- **Lateral D.** + **Lateral E.** → obrigatórias para avaliar cervical, cifose, anteversão, joelho

Se faltar view, a skill anota "Não avaliável" e pede foto específica.

## Coluna "Evolução" (só em reavaliação)

- `Melhorou` — grau caiu (Alteração→Leve, Leve→Normal) OU descrição mostra avanço claro
- `Manteve` — grau e descrição similares
- `Piorou` — grau subiu ou surgiu novo achado

## Entregáveis

- `data/<aluna>/reavaliacao-YYYY-MM-DD.md` (obrigatório)
- `data/<aluna>/reavaliacao-YYYY-MM-DD.pdf` (quando solicitado)
- Log resumido em até 3 frases para o Breno mandar junto no WhatsApp da aluna

## Dependências

- `templates/reavaliacao-postural.md` — modelo do relatório
- `config.yaml` → `reavaliacao` — parâmetros (graus, regiões, views)
- `checklists/reavaliacao.md` — pre-flight antes da entrega
