# Princípios de Dieta — Breno Xavier

> Regras duras de como montar qualquer dieta neste método. O agente de dieta LÊ isto antes de cada entrega.

## 1. Os 4 filtros inegociáveis

Toda dieta tem que passar nesses 4 filtros — se falhar em qualquer um, volta para o desenho:

1. **GOSTOSA** — a aluna olha e tem vontade de comer
2. **VOLUME LEGAL** — prato cheio, sensação de saciedade (viável porque come mais limpo)
3. **PROXIMIDADE COM O QUE ELA JÁ COME** — 80-100% dos alimentos precisam estar na rotina dela ou muito próximo
4. **RESPEITA PREFERÊNCIA DECLARADA** — se marcou "não gosto de X" na anamnese, X não entra

### Combinações PROIBIDAS (falham no filtro "GOSTOSA")

- ❌ **Banana/maçã + oleaginosa seca (amêndoa/castanha) + ovo cozido** — combinação fria, sem graça, sem liga. Aluna não come.
- ❌ **Proteína seca sem molho** (frango na chapa sem nada) — tem que ter um tempero, um feijão, um fundo pra aceitar.
- ❌ **Refeição "fit meme"** — salada com peito de frango grelhado e batata-doce 3x no dia. Ninguém aguenta.

### Lanche "sem lácteo / sem whey" — receita default

Quando a aluna não quer lácteo ou não usa whey, o lanche da tarde default é **PANQUECA DE BANANA**:

- 1 banana média (100g)
- 2 ovos inteiros
- 20g aveia em flocos
- Canela a gosto
- Bater tudo, fritar em frigideira antiaderente
- Finaliza com **1 colher de chá de pasta de amendoim integral** por cima

Macros aproximados: ~360 kcal, 39g carbo, 17g proteína, 16g gordura, 5g fibra. Gostoso, quente, sacia. **NÃO** substitui por "banana + amêndoa + ovo cozido" — isso é castigo, não lanche.

## 2. Faixas de macros (referência — validar com Breno)

> ⚠️ **A CONFIRMAR:** Breno ainda não passou os percentuais exatos da metodologia. Os valores abaixo são padrão de protocolos femininos de definição. Atualizar `config.yaml` assim que ele confirmar.

| Macro | Faixa referência |
|-------|-------------------|
| Proteína | 1.8 a 2.2 g/kg de peso corporal |
| Gordura | 20–30% do VCT |
| Carboidrato | o que sobra (tipicamente 40–55% do VCT) |

Distribuição de macros deve **favorecer o objetivo**:
- Em déficit: proteína no topo da faixa, gordura no meio, carbo ajusta
- Em superávit leve (ganho): carbo sobe, concentrado peri-treino

## 3. Lidando com preferência por doce

Aluna que disse "gosto de doce" é sinal para:
- Encaixar frutas estratégicas (banana madura, uva, manga — nos momentos certos do dia)
- Incluir industrializados aceitos como "válvulas de escape" sem sabotar o plano:
  - Bebida 0 / refrigerante zero
  - Energético 0
  - Leite em pó desnatado (ótimo em vitaminas, doces proteicos)
  - Gelatina diet, Whey sabor doce, iogurtes zero açúcar
- Sugestões de receitas simples com esses ingredientes no plano (panqueca proteica, mousse de whey, etc.)

## 4. Atualização mensal

Toda dieta nova mantém a **espinha dorsal** (macros, distribuição, horários) mas muda:
- Rotação de fontes (se estava arroz+frango, troca por batata-doce+tilápia em algumas refeições)
- Uma receita "nova" por semana do mês
- Ajuste fino de calorias baseado na última reavaliação

## 5. Fase x dieta — ligação obrigatória

Antes de montar, o agente SEMPRE consulta `fases-composicao.md` para saber:
- Aluna está em déficit, manutenção ou superávit leve?
- Qual o tamanho do déficit/superávit aplicável?

Dieta fora de fase é o erro mais comum e o que mais quebra resultado.

## 6. Saída padrão de uma dieta

Uma dieta entregue tem, no mínimo:
- Cabeçalho (nome da aluna, fase, VCT total, macros totais)
- 4 a 6 refeições com alimentos, quantidades (g ou medidas caseiras) e alternativas
- Bloco "Industrializados aceitos" personalizado
- Bloco "Observações" (hidratação, suplementos, horários)
- Rodapé oficial "Consultoria online — BRENO XAVIER"

### Tabela final de macros — padrão obrigatório

Toda dieta termina com uma **tabela resumo nutricional** que TEM que conter, na última linha (abaixo do TOTAL DIÁRIO em gramas):

- **% do VCT** para cada macro calórico: **carbo, proteína, gordura insaturada, gordura saturada**
- Fórmula: `(gramas × fator) ÷ VCT × 100`, onde fator = 4 kcal/g para carbo e proteína, 9 kcal/g para gorduras
- Arredondar para 1 casa decimal no máximo (38,6% vira 39%; 9,5% mantém)
- Fibra não entra na conta de % (não contribui kcal no modelo padrão)

Exemplo de footer:
```
| TOTAL DIÁRIO | 1.203 kcal | 138g | 116g | 12,7g | 5,3g | 26g |
| % do VCT     | 100%       | 46%  | 39%  | 9,5%  | 4%   | —   |
```

Razão: aluna/nutricionista vê direto se a dieta está em faixa correta (proteína 30–40%, gordura saturada <10%, carbo 40–55%). Sem a %, só gramas, é difícil interpretar.

## 7. Base técnica — Knowledge Base

Para decisões que exigem fundamentação científica (distribuição de proteína, tipo de gordura, arroz branco vs integral, aluna com resistência à insulina, aluna com DM1/DM2), o agente consulta `core/knowledge-base/` antes de fechar a dieta.

Fichas obrigatórias a considerar:

- **Sempre**: `proteina-distribuicao.md` — confere se a dieta distribui 0,4–0,55 g/kg/refeição em ≥ 3–4 refeições.
- **Sempre**: `gorduras-omega6.md` — confere se o tipo de gordura recomendada segue padrão AHA (PUFA/MUFA priorizados, SFA < 10% VCT).
- **Sempre**: `padroes-alimentares-saudaveis.md` — confere se o padrão entregue está alinhado com os 10 pontos AHA 2021.
- **Se aluna tem sobrepeso/obesidade + resistência à insulina declarada**: `obesidade-diabetes-t2.md`.
- **Se aluna tem DM1**: `diabetes-tipo1.md` — agente **NÃO entrega plano sozinho**, sempre flag pro Breno.
- **Se aluna pergunta sobre carbo pós-treino, jejum, arroz**: `metabolismo-carboidratos.md`.
- **Se aluna usa Mounjaro / Ozempic / Wegovy / Saxenda**: `mounjaro-glp1.md` — VCT calibrado (não forçar), proteína 40% VCT, proteína por refeição ~90g (não 120g+).

Regra: **contradição entre princípio empírico do Breno e evidência da knowledge-base = flagar pro Breno**, não escolher silenciosamente. A metodologia do Breno vence por default, mas o agente sinaliza o ponto de tensão.

## 8. Regras de recomendação de suplementos

Aluna que declara **não usar suplementos** na anamnese: recomendar o mínimo necessário, **sem empilhar**. Cada suplemento entra com justificativa clara e só quando faz diferença real no resultado.

### Whey — qual tipo recomendar

- **Concentrado** = default. Entra em 90% dos casos. Mais barato, palatável, faz o serviço.
- **Isolado** = **SÓ** se aluna declarou **intolerância à lactose** na anamnese.
- **Hidrolisado** = **SÓ** em casos específicos (pós-bariátrica, trato gastrointestinal delicado, má absorção declarada). **Nunca** por padrão — é caro e fora do contexto da maioria das alunas.

### Ômega 3

- **NÃO recomendar proativamente**. Não é suplemento de entrada.
- Só entra quando: aluna traz exame com **LDL alterado**, triglicérides altos, ou histórico CV + marcador bioquímico ruim.
- Frase template se histórico CV familiar aparecer: *"Se nas próximas avaliações de LDL os parâmetros não estiverem ajustados, entramos com suplementação específica."*

### Creatina

- Recomendar pra quem treina força e quer preservar massa magra / performance.
- **Obrigatória** em caso de GLP-1 (Mounjaro, Ozempic, etc) — risco de perda muscular é real.

### Psyllium

- Recomendar quando: Mounjaro / GLP-1, intestino lento declarado, constipação relatada.
- Não é suplemento default.

### Pré-treino

- Opcional. Só se aluna pedir ou relatar que não consegue treinar sem estímulo.
- Base de cafeína resolve — não precisa fórmula cara.

### NUNCA fazer

- ❌ Empilhar suplemento "porque é bom" — cada item precisa resolver um problema concreto da aluna.
- ❌ Recomendar "whey pós-treino" se aluna não pediu e não treina em jejum. Whey é proteína, distribui onde fizer sentido no dia.
- ❌ Sugerir isolado/hidrolisado quando concentrado resolve.

## 9. Regras de porcionamento (default pra TODA dieta)

Aprendidas na prática com o Breno — aplicar em toda dieta, não só GLP-1:

### Arroz, feijão e tubérculos
- **Arroz: mínimo 40g por refeição.** Abaixo disso é porção ridícula, brasileira não aceita.
- **Feijão: padrão 80g (meia concha cheia) por refeição.** Concha cheia de 120g é volume demais, especialmente em apetite reduzido.
- **Sempre mais feijão que arroz** quando ambos estão no prato. Nunca inverter.
- **Arroz + tubérculo vêm juntos.** Quando a refeição tem batata/mandioca, INCLUIR arroz 40g do mesmo jeito — cultura brasileira pede o arroz pra misturar com feijão.
- **Batata inglesa > batata-doce por padrão.** Menos carbo por 100g (12g vs 18g). Batata-doce só se aluna pedir.

### Proteína
- **Almoço/jantar: máximo 90g de proteína animal (4–5 colheres de sopa cheias quando desfiado).** Acima disso a maioria das alunas não come.
- **Nunca separar ovo inteiro + clara na mesma refeição.** "2 ovos + 1 clara" é frescura que aluna não segue. Sempre múltiplos de 1 ovo inteiro.
- **Proteína em TODAS as refeições** — distribuição 0,4–0,55 g/kg/refeição.

### Gorduras
- **Azeite na salada NÃO é padrão.** Só entra se aluna pedir explicitamente. Caso contrário salada é à vontade "limpa".
- **Histórico CV familiar** → priorizar insaturada (PUFA/MUFA), reduzir saturada (<10% VCT).

### Frutas
- **3–4 frutas por dia, distribuídas.**
- **Preferência: frutas comuns e baratas** — banana, mexerica, manga, mamão, laranja, uva, melancia, melão.
- **Kiwi, morango, frutas vermelhas** — só se aluna pedir (são caras, menos acessíveis).

### Sobremesa doce
- **Doce de até 150 kcal em TODAS as opções de almoço** (Trento, Ouro Branco, Sonho de Valsa).
- Entra como "OU" na linha da fruta de sobremesa — válvula de escape que mantém dieta gostosa sem sabotar.
- **NÃO é opcional** — tem que aparecer nas 3 opções do almoço, não só em uma.

### Ingredientes complicados — NÃO incluir por padrão
- ❌ **Linhaça dourada triturada** — complicada (precisa moer, oxida fácil). Só se aluna já usa.
- ❌ **Espinafre** — complicado (amargo cru, oxala cozido). Só se aluna pediu.
- ❌ **Chia + psyllium** na mesma refeição — é fibra demais, trava intestino.

### Lanche sem lácteo / sem whey — default
- Panqueca de banana (banana + 2 ovos + aveia + pasta de amendoim). Ver seção 1.
- **NUNCA** a combinação "banana + amêndoa + ovo cozido" (castigo, não lanche).

## 10. Comunicação com a aluna (o que NÃO escrever na dieta)

- ❌ **Não justifique cada decisão.** "Não empurrei 1500 kcal porque o remédio não deixa" — isso é justificativa que o Breno pediu, não conteúdo pra aluna.
- ❌ **Não explique protocolo pra aluna.** "Esse passo é profilático, não opcional" — já escreveu, assume que é assim.
- ❌ **Não encher a dieta de observações científicas.** Observação é concisa, direta: "Hidratação: 2,5–3L/dia. Chá morno em jejum se intestino não funcionar."
- ✅ **Tom direto, comando curto.** A aluna precisa saber O QUE fazer, não POR QUE.

Regra prática: se o Breno falar "tira essa parte, você tá justificando", vira regra geral — não repetir em outras dietas.
