# Formato da Dieta — Padrão Breno Xavier

> **REGRA DURA:** toda dieta é entregue neste formato. Sem exceção. Se a saída tem tabela de macros, emojis ou caixinhas coloridas, a skill falhou.

## O que o modelo tem

- **Título:** `Nome da Aluna - Cutting (DEFINIÇÃO)` ou `Nome da Aluna - Manutenção` ou `Nome da Aluna - Ganho`
- **Parágrafo de recomendação** no topo (regras gerais: vegetais mínimo, alimentos pesados prontos, não trocar alimentos sem consultar, uso da I.A de substituição)
- **Refeições em texto corrido**, uma embaixo da outra. NÃO tabela.
- **Múltiplas opções** por refeição (2–4), identificadas como `OPÇÃO 2`, `OPÇÃO 3`...
- **Dica inline no título** quando fizer sentido: `Toast gostoso (Leve na AirFryer)`, `Carne magra = patinho, músculo, acém...`, `Pode acompanhar qualquer bebida zero`
- **Formato dos itens:**
  ```
  Alimento - quantidade em g (equivalência caseira entre parênteses)
  ```
  Exemplos reais:
  - `Pão Francês - 50g ( 1UNIDADE)`
  - `Ovo - 1Un.`
  - `Banana - 80g (~1 unidade)`
  - `Vegetais à escolha - 150g (ou mais)`
- **Parágrafo final "Refeição livre"** com as regras (1 refeição livre/semana, moderada, contenção de danos, álcool conta por 2, etc.)
- **Rodapé em cada página:**
  ```
  @brenoxavieer_
  31 9 7262-8289    www.brenoxavier.com.br
  ```

## O que o modelo NÃO tem

- ❌ Tabela de macros / VCT calculado
- ❌ Bloco "Resumo" com gráficos
- ❌ Emojis (🍳 🍽️ 🌙 🔥 etc.)
- ❌ Caixas coloridas de "Observações" ou "Dica"
- ❌ Bullet points com ✅ ou •
- ❌ "Mensagem para WhatsApp" dentro do PDF
- ❌ Rodapé oficial pomposo com três credenciais
- ❌ Seções numeradas tipo "1. Resumo, 2. Refeições, 3. Observações"

## Tipografia e visual — IDENTIDADE BRENO XAVIER

**Logo no topo, sempre.** Logo oficial "BRENO XAVIER — TREINO E NUTRIÇÃO" (B verde estilizado, nome em verde escuro, "TREINO E NUTRIÇÃO" em verde claro).

**Paleta oficial:**
- Verde escuro (nome da marca, títulos): `#1b5e20`
- Verde claro (detalhes do logo, "TREINO E NUTRIÇÃO"): `#4caf50`
- Laranja de destaque (palavra "Recomendação:"): `#e65100`
- Verde pálido (fundo das tabelas de itens): `#f0f5ea`
- Preto: corpo do texto

**Tipografia:**
- Título da dieta: **serif grande e negrito** (Georgia / Playfair Display), centralizado — ex: "Gabriela Carline - Cutting (DEFINIÇÃO)"
- Corpo: sans-serif (Arial / Helvetica)
- Títulos de refeição ("Café da manhã -"): sans-serif negrito, com linha fina preta embaixo

**Estrutura visual de cada refeição:**
- Título em negrito com linha horizontal embaixo
- Alimentos listados em "tabela invisível" com fundo **verde pálido** `#f0f5ea` sutil — cada alimento uma linha
- Sem bullets, sem números — apenas o nome do alimento + quantidade

**Página:**
- A4, margens 20mm
- Fundo branco
- Logo no topo (centralizado)
- Rodapé: `@brenoxavieer_ · 31 9 7262-8289 · www.brenoxavier.com.br`

**Asset necessário:** arquivo `assets/logo-breno.png` (ou `.svg`) no projeto. Se não existir, renderizar logo via CSS/SVG inline temporariamente, mas **pedir ao Breno o arquivo original** pra substituir.

## Permissões explícitas que entram no texto

Conforme o modelo oficial:
- "Pode acompanhar qualquer bebida zero"
- "Pode trocar a fruta por um doce de 100-150 calorias"
- "Pode comer junto com o café da manhã se quiser"
- "Leve na AirFryer"
- "congela tudo e deixa como estoque"

Essas frases soam humanas. Use livremente quando fizer sentido — é o que diferencia do "texto de robô".

## Base de cálculo de calorias

- **Fonte primária:** Tabela TACO (4ª edição revisada, NEPA/UNICAMP)
- **Fallback:** apenas para alimentos que não estão na TACO (ex.: whey, magic toast, Rap 10, Better PB) → usar dados de marcas consolidadas no Brasil
- Nunca chute valor. Se não tem referência sólida, não usa.

## Tom escrito

- Direto, curto, pessoal
- Uso de `(~1 unidade)` com til pra "aproximadamente"
- Uso de "à vontade" para vegetais e saladas
- Uso de "(ou mais)" como permissão explícita
- Sem floreio, sem "vamos juntas!", sem "você consegue!"
