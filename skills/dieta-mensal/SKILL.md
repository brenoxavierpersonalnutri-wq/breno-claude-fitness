---
name: dieta-mensal
description: Monta dieta mensal individualizada para alunas da consultoria Breno Xavier. Calcula VCT e macros conforme a fase (déficit/manutenção/superávit leve), respeita preferências da anamnese, entrega no template oficial e prepara mensagem de WhatsApp para a aluna.
---

# Skill: Dieta Mensal

Habilidade técnica acionada pelo **Agente de Dieta Mensal** (`agents/dieta-mensal.md`).

## O que esta skill faz

1. Lê `core/metodologia.md`, `core/fases-composicao.md`, `core/dieta-principios.md`, `config.yaml`
2. Determina a **fase** da aluna (árvore de decisão em `fases-composicao.md`)
3. Calcula VCT e macros:
   - VCT base ≈ 25–30 kcal × peso (ajustar conforme atividade e fase)
   - Proteína g/kg pela faixa do `config.yaml`
   - Gordura % VCT pela faixa do `config.yaml`
   - Carbo = sobra em kcal → converte para g
4. Distribui em 4–6 refeições respeitando rotina da aluna
5. Seleciona alimentos por refeição:
   - Cruza com `gosta` / `come_hoje` da anamnese
   - Cruza com `não_gosta` / `restricoes` da anamnese (remove)
   - Prioriza fontes que dão **volume** (verduras, proteínas magras, carbos com fibra)
6. Rotaciona vs. dieta anterior (pelo menos 1 proteína, 1 carbo, 1 receita "nova")
7. Encaixa industrializados aceitos (`config.yaml.dieta.industrializados_aceitos`) se a aluna tem perfil "doce"
8. Renderiza em `templates/dieta-mensal.md`
9. Gera a mensagem curta de WhatsApp acompanhante
10. Salva em `data/<aluna>/dieta-YYYY-MM-DD.md`

## Fórmulas de referência

```
VCT_manutencao ≈ peso_kg * fator_atividade
onde fator_atividade ∈ [25, 32] kcal/kg dependendo de nível de treino

Se fase = déficit_leve:       VCT_alvo = VCT_manutencao * (1 - 0.10 a 0.15)
Se fase = déficit_moderado:   VCT_alvo = VCT_manutencao * (1 - 0.15 a 0.20)
Se fase = manutencao:         VCT_alvo = VCT_manutencao
Se fase = superavit_leve:     VCT_alvo = VCT_manutencao * (1 + 0.05 a 0.10)

Proteína (g)   = peso_kg * X        onde X ∈ [1.8, 2.2]
Gordura (kcal) = VCT_alvo * Y       onde Y ∈ [0.20, 0.30]
Carbo (kcal)   = VCT_alvo - prot_kcal - gordura_kcal
```

> ⚠️ As faixas aqui são placeholders até o Breno confirmar. Elas vivem em `config.yaml` — atualize lá, não na skill.

## Inputs esperados (estrutura)

```yaml
aluna:
  nome: "Nome da aluna"
  peso_kg: 64
  altura_cm: 165
  idade: 32
  objetivo_declarado: "corpo definido"
  rotina:
    acorda: "06:30"
    trabalha: "08:00-17:00"
    treino_horario: "18:30"
    dorme: "23:00"
  preferencias:
    gosta: [frango, ovo, pão francês, banana, café com leite, chocolate]
    nao_gosta: [peixe branco, berinjela]
    come_hoje: [...]
  restricoes: [intolerância lactose leve]
fase_decidida: "deficit_leve"
dieta_anterior: "data/ellen-cassia/dieta-2026-03-17.md"  # opcional
relato_mes: "Fome controlada, treinou 5x, queixa: fome noturna"  # opcional
```

## Entregáveis

- `data/<aluna>/dieta-YYYY-MM-DD.md` (dieta no template oficial)
- Mensagem curta pronta para WhatsApp (dentro do mesmo arquivo, bloco final)
- Log de macros calculados + fase usada (auditável)

## Dependências

- `core/metodologia.md`, `core/fases-composicao.md`, `core/dieta-principios.md`
- `config.yaml`
- `templates/dieta-mensal.md`
- `checklists/dieta.md`
