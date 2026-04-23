# Knowledge Base — Estudos Dudu Haluch

> Base técnica consultável pelos agentes do squad (dieta, reavaliação, futuros).
> Cada ficha extrai da literatura e dos materiais do grupo de estudos do Dudu Haluch **só o que vira decisão prática** na consultoria — não é textbook, é regra operacional.

## Como o agente usa

1. Antes de fechar qualquer dieta, o agente varre o índice abaixo e carrega **as fichas relevantes ao caso** da aluna (não carrega todas).
2. Aluna com relato de controle glicêmico ruim / pré-diabetes / família com DM2 → carregar `obesidade-diabetes-t2.md`.
3. Aluna com DM1 declarado na anamnese → carregar `diabetes-tipo1.md` + flag obrigatória pro Breno revisar (agente NÃO fecha plano de DM1 sozinho).
4. Dúvida sobre distribuir proteína → `proteina-distribuicao.md`.
5. Dúvida sobre tipo de gordura / óleo de coco vs azeite vs óleo de soja → `gorduras-omega6.md`.

## Fichas

| Ficha | O que responde | PDF fonte |
|---|---|---|
| [Proteína — absorção & distribuição](proteina-distribuicao.md) | Quanto por refeição? Quantas refeições? | Absorção de proteína |
| [Metabolismo dos carboidratos](metabolismo-carboidratos.md) | Por que vantagem do carbo pós-treino? Arroz x integral? | Metabolismo dos carboidratos |
| [Gorduras — ômega 6 e inflamação](gorduras-omega6.md) | Óleo de coco é saudável? Óleo de soja é inflamatório? | Ômega 6 e resistência à insulina |
| [Padrões alimentares saudáveis](padroes-alimentares-saudaveis.md) | O que é um alimento saudável? Arroz branco é OK? | O que é um alimento saudável |
| [Obesidade & resistência à insulina (DM2)](obesidade-diabetes-t2.md) | Por que cutting melhora glicemia? Gordura visceral como alvo | Porque a obesidade causa diabetes |
| [Diabetes tipo 1](diabetes-tipo1.md) | Como conduzir aluna com DM1? O que NÃO fazer | Diabetes Tipo 1 |

## Princípio editorial

- **Só entra na ficha o que muda conduta** do agente. Bioquímica descritiva fica resumida em 2–3 linhas.
- Cada ficha tem uma seção **"Como aplica na consultoria"** — é por onde o agente lê primeiro.
- Quando a evidência contradiz senso comum (ex: óleo de soja ≠ vilão, gordura sat ≠ inofensiva), destacar com `⚠️` — isso protege o agente de repetir mitos.

## Atualização

Sempre que o Breno mandar novo material de estudo, o processo é:
1. Extrai texto do PDF (`pdftotext -layout`)
2. Cria ficha nova seguindo o template: **Conceito central · Pontos-chave · Como aplica · Fonte**
3. Registra no índice acima
4. Se a ficha afeta regra dura existente, atualiza também `core/regras-veto-alimento.md` ou `core/dieta-principios.md`
