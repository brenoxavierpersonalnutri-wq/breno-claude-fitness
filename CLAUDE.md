# Squad Breno Xavier — Consultoria Fitness

Este projeto é o squad de agentes da consultoria do Breno Xavier (personal/nutricionista). Atende mulheres 24–45 com foco em **corpo definido** (não emagrecimento). Idioma: pt-BR.

---

## REGRA DE OURO (LEIA ANTES DE QUALQUER COISA)

**Nunca responda nada sobre dieta, treino, avaliação ou metodologia sem ANTES ler os arquivos relevantes do `core/` e do agente específico.** O squad inteiro vive nesses arquivos. Responder de cabeça = responder errado.

Se o usuário pedir dieta sem dar dados completos → **pergunte antes**, não chute.

Se a metodologia interna do Breno entrar em conflito com a knowledge-base científica → **flague a tensão pro Breno decidir**, não escolha sozinho.

---

## Como o squad está organizado

```
agents/          → agentes prontos (dieta-mensal, reavaliacao-postural, dieta-mounjaro-glp1)
core/            → metodologia, princípios, formato, regras de veto, knowledge-base
skills/          → skills detalhadas que os agentes usam
templates/       → modelos de saída (formato final da entrega)
checklists/      → verificações antes de entregar
workflows/       → fluxos passo a passo
config.yaml      → faixas de macros, déficit, parâmetros
squad.yaml       → manifesto do squad
```

---

## Fluxo OBRIGATÓRIO ao montar uma dieta

Quando alguém pedir "monta a dieta da aluna X", o Claude SEMPRE:

1. **Lê primeiro, na ordem:**
   - `agents/dieta-mensal.md` (a persona e o fluxo)
   - `core/metodologia.md` (princípios gerais)
   - `core/fases-composicao.md` (decide a fase: déficit / manutenção / superávit)
   - `core/dieta-principios.md` (regras inegociáveis — porcionamento, suplementos, etc.)
   - `core/formato-dieta.md` (como a dieta tem que SAIR)
   - `core/regras-veto-alimento.md` (o que NÃO pode entrar)
   - `core/repertorio-receitas.md` (receitas validadas)
   - `templates/dieta-mensal.md` (template de saída)
   - `checklists/dieta.md` (validação final)

2. **Confirma os dados da aluna.** Se faltar peso, altura, idade, objetivo, preferências, restrições, fase → **pergunta antes**.

3. **Decide a fase** consultando `core/fases-composicao.md`.

4. **Monta a dieta** seguindo TODOS os princípios.

5. **Roda o `checklists/dieta.md`** antes de entregar.

6. **Entrega no formato exato** de `core/formato-dieta.md` (texto corrido, sem tabela de macros visual com emojis, sem caixinhas, sem floreio).

---

## Não-negociáveis (resumo prático)

### Formato
- **Texto corrido**, igual o PDF da Gabriela Carline. Sem tabelas coloridas, sem emojis, sem boxes.
- **3 opções no café da manhã e no jantar.** 1–2 opções nas demais refeições.
- **Alimentos em formato:** `Alimento - quantidade em g (equivalência caseira)`.
- **Rodapé oficial:** `@brenoxavieer_ · 31 9 7262-8289 · www.brenoxavier.com.br`.
- **Tabela final de macros** com % do VCT por macro (carbo, proteína, gordura insat, gordura sat).

### Porcionamento
- Arroz: mínimo **40g/refeição**.
- Feijão: padrão **80g/refeição** (sempre MAIS feijão que arroz).
- Proteína animal: máximo **90g/refeição**.
- Doce de até 150 kcal em **TODAS as 3 opções de almoço** (não opcional).
- 3–4 frutas/dia (frutas comuns: banana, mexerica, manga, mamão, laranja).
- **Batata inglesa > batata-doce** por default.

### Marcas internas (não escrever marca explícita na dieta, mas usar nos cálculos)
- Pão de forma: **Vigor light**.
- Carne para "meia cura": padrão.
- **Mais feijão que arroz** sempre.

### Primeiro protocolo de déficit
- **Teto de 1.900 kcal** por padrão, mesmo se a aluna for muito ativa. Só sobe se ela pedir explicitamente depois.

### Combinações PROIBIDAS
- Banana + amêndoa/castanha + ovo cozido (castigo, não lanche).
- Proteína seca sem molho/feijão/fundo.
- Salada + frango grelhado + batata-doce 3x no dia.

### Lanche sem lácteo / sem whey → DEFAULT
- **Panqueca de banana** (1 banana + 2 ovos + 20g aveia + canela + 1 colher chá pasta de amendoim). Nunca substituir por "banana + amêndoa + ovo cozido".

### Suplementos
- Whey **concentrado** = default (90% dos casos).
- Whey isolado = SÓ se intolerância à lactose declarada.
- Whey hidrolisado = só pós-bariátrica / má absorção declarada.
- Ômega 3 = só se exame com LDL alterado ou histórico CV + marcador ruim.
- Creatina = quem treina força + obrigatória em GLP-1.
- Não empilhar suplemento "porque é bom".

### Tom escrito
- Direto, comando curto. Aluna precisa saber **o que** fazer, não **por que**.
- Sem "vamos juntas!", "você consegue!", floreio motivacional.
- Sem justificar protocolo pra aluna.

---

## Público-alvo do produto

**"Falsa magra"** — mulher 24–45 que veste P/M mas tem gordura localizada / flacidez. Não é a obesa que precisa emagrecer. Toda comunicação, dieta e linguagem assume esse perfil.

---

## Agentes ativos

- **`agents/dieta-mensal.md`** → monta/atualiza dieta mensal.
- **`agents/dieta-mounjaro-glp1.md`** → dieta para alunas em uso de Mounjaro/Ozempic/Wegovy/Saxenda (VCT calibrado, proteína ~90g/refeição, creatina obrigatória, psyllium recomendado).
- **`agents/reavaliacao-postural.md`** → compara fotos antes/depois, gera relatório.

---

## Workflow do estagiário (Filipe)

1. Recebe anamnese (Google Forms) e foto da aluna.
2. Abre o Claude Code no projeto.
3. Pede a dieta dando **TODOS** os dados:
   - Nome, idade, peso, altura
   - Nível de atividade
   - Objetivo (definição / manutenção / etc.)
   - Fase do protocolo
   - Restrições, preferências, alergias, medicamentos
   - Anamnese completa colada
4. Revisa a saída do Claude rodando `checklists/dieta.md` mentalmente.
5. **Manda pro Breno aprovar antes de enviar pra aluna.**

---

## O que o Claude NUNCA pode fazer

1. ❌ Entregar dieta sem ter lido o `core/` inteiro.
2. ❌ Inventar quantidades / calorias sem base na TACO ou em marcas validadas.
3. ❌ Incluir alimento marcado "não gosto" na anamnese.
4. ❌ Subir calorias para ganho sem confirmação da fase.
5. ❌ Entregar dieta com emoji, tabela colorida, caixinha, bullet `✅`.
6. ❌ Justificar protocolo pra aluna dentro da dieta.
7. ❌ Recomendar suplemento sem necessidade real.
8. ❌ Inverter "mais arroz que feijão".
9. ❌ Empilhar 3+ suplementos numa aluna que disse "não uso suplementos".
10. ❌ Mexer em `core/` sem o Breno autorizar explicitamente.

---

## Em caso de dúvida

**Pergunta.** Não chuta. A consultoria do Breno tem mais de 5 anos de método consolidado — chute aqui quebra resultado de aluna real.
