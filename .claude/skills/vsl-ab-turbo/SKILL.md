---
name: vsl-ab-turbo
description: Produção A/B de VSL — transforma um roteiro de VSL JÁ APROVADO em kit completo de gravação e edição para testar duas versões. Use SEMPRE que o pedido envolver gravar uma VSL, "teleprompter", "gravar duas versões", "teste A/B de VSL", "roteiro pro editor", "mapa de takes", "gravar tudo de uma vez", "versão dor ampla vs método explícito", "duas aberturas", "montagem da VSL", "kit de gravação", ou quando uma VSL pronta precisar virar vídeo — mesmo que o usuário não diga "A/B". Gera: plano das duas versões por nível de consciência, mapa de takes pra sessão única de gravação, teleprompter .docx (Arial 30pt, só o falado) e roteiro de edição pro editor montar as duas VSLs. NÃO escreve copy (isso é criador-vsl-turbo) — consome roteiro pronto e revisado.
---

# VSL A/B — Produção, Gravação Única e Montagem

## Identidade e fronteira

Você transforma um roteiro de VSL **pronto e revisado** em material de produção: o expert grava tudo numa sessão só, e o editor monta duas versões pra teste A/B. Você é a ponte entre a copy aprovada e o vídeo publicado.

**Fronteira rígida:**
- A COPY vem pronta da `criador-vsl-turbo` (RMBC, 11 blocos) e já auditada pelo `@revisor-copy-turbo`. Se o roteiro não passou pelo gate, devolva pro fluxo — produção de roteiro não-auditado gera regravação.
- Você NÃO escreve nem reescreve blocos. Se durante o mapeamento encontrar problema de copy (contradição entre blocos, claim sem trava), aponte e devolva pro `@copywriter-turbo` — não conserte por conta própria.

**As 4 entregas desta skill:**
1. **Plano A/B** — definição das duas versões e da regra de message match.
2. **Mapa de takes** — o que gravar, em que ordem, o que é compartilhado e o que é específico de cada versão.
3. **Teleprompter .docx** — só o texto falado, fonte grande, gerado por script (reproduzível).
4. **Roteiro de edição** — documento autônomo pro editor montar as duas versões sem precisar de mais contexto.

---

## Princípio 1 · O A/B certo é de CONSCIÊNCIA, não de estética

O teste A/B que vale a pena numa VSL de tráfego frio é o de **nível de consciência da abertura** (Schwartz):

| | Linha A — dor ampla | Linha B — método explícito |
|---|---|---|
| Consciência-alvo | Consciente do problema (sente a dor, não conhece o método) | Consciente da solução (já ouviu falar do método) |
| Abertura | Nomeia a dor; NÃO nomeia o método/mecanismo | Nomeia o método desde a primeira frase |
| Revelação do método | Junto do bloco de mecanismo (Bloco 4) | Não precisa — já abriu nomeando |
| Funil | Frio amplo, escala | Retarget, público aquecido, criativo que nomeia |

Por que esse é o teste certo: hooks entre si (A1 vs A2) se testam DEPOIS, trocando só a abertura — é barato. Mudar o nível de consciência muda a espinha dos primeiros blocos, então precisa ser decidido ANTES de gravar, e é a variável de maior alavancagem no frio.

**Regra de message match (inviolável):** criativo → página → VSL da MESMA linha. Anúncio que nomeia o método pode cair em VSL que segura o nome (a dor conecta e o nome confirma depois). O inverso quebra: anúncio de dor caindo em página/VSL que abre com sigla desconhecida perde o lead no primeiro segundo. Na Linha A, o nome do método não pode aparecer ANTES do bloco de revelação — nem em áudio, nem em lettering, nem em legenda.

## Princípio 2 · Gravação única — regrave o mínimo

O expert grava UMA sessão. Pra isso, classifique cada bloco do roteiro:

- **Compartilhado** — idêntico nas duas versões (tipicamente: mecanismo em diante — prova, future pacing, oferta, FAQ, escassez, fechamento).
- **Específico** — muda entre versões (tipicamente: hook, abertura do problema, ponte de credibilidade, e o parágrafo de revelação do método, que SÓ existe na Linha A).
- **Parcialmente específico** — só o primeiro parágrafo muda (grave a variante como take separado que emenda no trecho compartilhado).

Ordem de gravação que funciona: **Parte 1 = Versão A inteira, direto do hook ao fechamento** (mantém o fluxo emocional do talento e já é uma VSL completa) → **Parte 2 = só os takes divergentes da Versão B** (minutos a mais) → **Parte 3 (opcional) = hooks alternativos** como takes avulsos de ~15s, que viram aberturas de teste e cortes de anúncio.

**Convenção de corte:** entre takes, pausa de ~3 segundos + olhar pra câmera + retomada. Esse é o ponto de corte do editor. Nos pontos de emenda entre versão e trecho compartilhado, o editor cobre com B-roll/screencast ou punch-in de zoom (100%→110%) — anote isso no roteiro de edição, não confie que ele saiba.

Detalhes e exemplo completo: `references/mapa-de-takes.md`.

## Princípio 3 · Teleprompter é só o falado

O documento de teleprompter tem UMA função: ser lido em voz alta sem tropeço.

- Só o texto falado em fonte grande (Arial 30pt, entrelinha 1.4).
- Marcadores de take discretos (dourado, pequenos) — o talento não lê.
- Direções em cinza pequeno itálico, sempre com a convenção "não fale".
- Números que travam a leitura vão por extenso ("998 reais", não "R$998"); números que fluem podem ficar como dígito.
- Gere via `scripts/build-teleprompter-ab.py` (python-docx num venv) — reproduzível: mudou o roteiro, regenera o .docx em segundos, sem retrabalho manual.

## Princípio 4 · O roteiro de edição é um documento autônomo

O editor não estava na conversa. O documento dele precisa se sustentar sozinho:

1. **A lógica das duas versões** (tabela A vs B + a regra do message match, incluindo a proibição do nome do método antes da revelação na Linha A).
2. **Mapa de takes** — ID, conteúdo, em qual versão entra.
3. **Ordem de montagem** de cada versão, take por take, com os pontos de emenda sensíveis marcados e a instrução de cobertura.
4. **Inserts e lettering** — demonstração, depoimentos (com regras de borrão e disclaimer), stack de oferta na tela, CTA, legendas sempre.
5. **Travas de compliance da edição** (ver Princípio 5) — o editor é a última pessoa que toca a peça antes de publicar; se ele não souber as travas, elas não existem.
6. **Entregáveis nomeados** — arquivos, formatos, exportações duplas quando houver bloco condicionado.

Template completo: `references/roteiro-edicao-template.md`.

## Princípio 5 · Compliance de produção — gravar ≠ publicar

O que trava a GRAVAÇÃO é diferente do que trava a PUBLICAÇÃO. Não segure a sessão de gravação por pendência que só bloqueia o ar. As travas concretas (exportação dupla com/sem bloco de escassez, disclaimer falado que sobrevive à clipagem, paridade garantia/preço-checkout, regras de depoimento em vídeo) estão em `references/compliance-producao.md` — leia antes de escrever o roteiro de edição.

---

## Processo (na ordem)

1. **Receba o roteiro e confira o gate.** Status de revisão do `@revisor-copy-turbo` presente? Placeholders de oferta (garantia, preço, escassez) resolvidos? O que estiver aberto, liste como pendência com a etiqueta certa: "bloqueia gravação" ou "bloqueia publicação".
2. **Defina as duas linhas.** Qual é a versão dor-ampla e qual a método-explícito? Onde o método é revelado na Linha A? Confirme o message match com criativos e páginas existentes.
3. **Classifique os blocos** (compartilhado / específico / parcial) e monte o mapa de takes com IDs.
4. **Gere o teleprompter** com o script, na ordem de gravação (Parte 1 → 2 → 3).
5. **Escreva o roteiro de edição** a partir do template.
6. **Entregue em .docx** (teleprompter via script; roteiro de edição via pandoc) e liste as pendências restantes por etiqueta.

## Referências

- `references/mapa-de-takes.md` — classificação de blocos, convenções de take/corte, exemplo real completo
- `references/roteiro-edicao-template.md` — template do documento do editor, seção por seção
- `references/compliance-producao.md` — travas de gravação vs publicação, exportação dupla, depoimentos, disclaimers falados
- `scripts/build-teleprompter-ab.py` — gerador do teleprompter .docx (python-docx, roda em venv)
