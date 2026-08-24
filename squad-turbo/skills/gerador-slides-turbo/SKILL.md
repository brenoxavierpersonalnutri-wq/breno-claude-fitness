---
name: gerador-slides-turbo
description: >
  Use this skill to generate premium PPTX slide presentations for paid launch
  lessons (aulas do lançamento pago). Trigger for: "gerar slides", "slides da aula",
  "apresentação", "PPTX", "slides premium", "slides 5+1", "slides do evento",
  "slides de aula". Generates dark-mode PPTX via the HTML → Chrome headless PNG →
  python-pptx pipeline with the Turbo Academy design system.
---

# Gerador de Slides Turbo — PPTX Premium para Aulas

## Identidade

Você gera slides de aula em PPTX para o lançamento pago semanal da Turbo Academy.
Cada slide tem UMA ideia. Pouco texto. Impacto visual. Dark mode premium.

---

## Pipeline padrão: HTML → PNG → PPTX

**Nunca desenhe slides com textboxes/shapes nativos do python-pptx.** O desenho
nativo produz slides visualmente pobres: sem gradientes, sem glow, sem sombras,
tipografia dura. O método padrão é renderizar cada slide como HTML e inserir o
PNG no PPTX — assim o slide tem a qualidade visual de uma landing page.

1. **Cada slide é um HTML 1920x1080** com CSS compartilhado (design system Turbo)
2. **Render via Chrome headless:**
   ```
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
     --headless --disable-gpu --hide-scrollbars \
     --force-device-scale-factor=1 \
     --screenshot=sNN.png --window-size=1920,1080 file://sNN.html
   ```
3. **PPTX montado com python-pptx** inserindo os PNGs full-bleed
   (slide 13.333 x 7.5 in, imagem cobrindo 100%)

Script de referência completo (CSS do design system + 1 slide de exemplo por
tipo + loop de render + montagem do PPTX): **`scripts/build_slides.py`**.
Copie-o como base, troque os slides de exemplo pela copy real da aula e ajuste
`WORK`/`OUT`/`BRAND`. Use `/usr/bin/python3` (é o interpretador com python-pptx
instalado no Mac do Leo). Validado em 2026-08-03 na aula "Funil 8 do Zero".

Trade-off aceito: o texto vira imagem (não editável no Keynote/PowerPoint).
Ajustes são feitos no HTML e o deck é regerado — por isso mantenha o script
`.py` da aula junto do `.pptx` entregue.

---

## Design System Turbo (CSS compartilhado)

O CSS canônico completo está em `scripts/build_slides.py`. Os elementos:

```
BACKGROUND: #0a0a0a (quase preto)
GLOW: círculo radial gigante (1400px, blur 90px, opacity .13) na cor do
      accent do slide — canto sup. direito; opcional um 2º glow no inf. esquerdo
CARDS: glassmorphism — rgba(255,255,255,.045), borda rgba(255,255,255,.09),
       radius 26px, sombra profunda, accent line de 5px no topo (::before)
KICKER: label mono letterspaced (.42em) uppercase acima do título, na cor accent
FOOTER: mono #52525b, "MARCA · NOME DA AULA" à esquerda, progresso "NN / total"
        à direita (todo slide exceto capa e encerramento)

CORES (1 accent por slide, define glow + accent line + destaques):
- GREEN:  #4ade80 (positivo, método, CTA)
- YELLOW: #facc15 (alertas, ativadores de chat, números)
- CYAN:   #22d3ee (dados, métricas, telas)
- PURPLE: #a78bfa (conceitos, comandos)
- RED:    #f87171 (problemas, dores, contraste ✗)
- MUTED:  #a1a1aa (texto secundário) · #71717a (terciário) · #52525b (footer)

FONTES:
- Helvetica Neue: títulos, corpo, bullets
- SF Mono: kicker, números gigantes, footer, comandos, contadores

FORMATO: 1920x1080 (16:9) → PPTX 13.333 x 7.5 in
```

---

## Estrutura Padrão de Aula (40 min)

Uma aula de 40 minutos tem ~30 slides:

```
BLOCO 1 — ABERTURA (3-4 slides)
  - Capa (nome da aula + expert, sem footer)
  - Ativador de chat
  - Promessa ("você sai daqui com...")
  - Loop aberto ("fica até o fim...")

BLOCO 2 — CONTEÚDO PRINCIPAL (20-25 slides)
  - Section dividers numerados entre blocos
  - 1 ideia por slide
  - Cards com bullets (máx 4 por slide)
  - Slides de quote/destaque
  - Slides de número/dado

BLOCO 3 — RECAP + ENCERRAMENTO (3-5 slides)
  - Tarefa de casa
  - "Na próxima aula..." (loop)
  - CTA (se aplicável)
  - Encerramento (sem footer)
```

---

## Tipos de Slide

Cada tipo tem um exemplo pronto em `scripts/build_slides.py`:

### 1. Capa
Kicker accent + título 92px com ponto final `.dim` + subtítulo muted + assinatura mono. Sem footer.

### 2. Section Divider
Número gigante mono (200px, cor do bloco) + título 80px + linha de contexto.

### 3. Conteúdo
Kicker + título + card glassmorphism com bullets quadrados na cor accent. Máximo 4 bullets.

### 4. Comparação
2 cards lado a lado (`.cols`): ✗ vermelho vs ✓ verde, cada um com sua accent line; glow duplo (verde + vermelho).

### 5. Quote/Destaque
Aspas Georgia gigantes (190px) na cor accent + frase 70px com trecho-chave colorido. Centralizado.

### 6. Número/Dado
Número gigante mono (até 290px, cor accent) + label explicativo + contexto muted. Centralizado.

### 7. Encerramento
Marca gigante com ponto accent + frase de transição pro Q&A. Sem footer.

---

## Processo de Criação

1. **Receber conteúdo** do @copywriter-turbo (estrutura da aula, pontos de fala)
2. **Mapear slides** — 1 ideia por slide, definir tipo e accent de cada slide
3. **Copiar `scripts/build_slides.py`** para a pasta de trabalho da aula e
   preencher os slides com a copy real
4. **Executar** com `/usr/bin/python3` — gera PNGs + monta o .pptx
5. **Conferir os PNGs** (spot-check visual de 2-3 slides) antes de entregar
6. **Abrir** o .pptx automaticamente para revisão (`open` no macOS)
7. **Guardar o script** da aula junto do .pptx (é a "fonte" editável do deck)

---

## Regras

1. **Máximo 4 bullets por slide** — se tem mais, dividir em 2 slides
2. **Pouco texto** — frase, não parágrafo
3. **Dark mode sempre** — nunca fundo branco
4. **1 accent por slide** — a cor comunica a função do slide (verde=método, vermelho=dor...)
5. **Design system consistente** — mesmo CSS em todas as aulas; mude a copy, não o sistema
6. **Acentuação correta** — português sem erros
7. **Nomes na linguagem do avatar** — não do expert
8. **Entregáveis reais em `_private/`** — nunca commitar copy de aula no repo

---

## Integração

- Recebe conteúdo de: @copywriter-turbo (estrutura de aula)
- Executado por: @designer-turbo (sob direção do @diretor-criativo-turbo)
- Referência de design: `~/.claude/skills/designer-senior-turbo/SKILL.md`
- Exemplo validado: `_private/aulas/Slides-Aula-Funil8-do-Zero.pptx` (2026-08-03)
