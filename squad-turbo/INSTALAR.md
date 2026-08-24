# Squad Turbo · LPSG 7.0

Squad de **lançamento e marketing** (método LPSG), da Turbo Academy.
Vive neste repo lado a lado com o squad de consultoria fitness do Breno —
são coisas separadas. **Nada aqui altera `core/`, `agents/`, `skills/`,
`config.yaml` ou `squad.yaml` da consultoria.**

- Fonte oficial: <https://github.com/Turbo-Academy/squad-turbo-lpsg-7.0>
- Manual do zero: <https://turbo-academy.github.io/squad-turbo-lpsg-7.0/instalacao-do-zero.html>

## O que já está aqui

```
squad-turbo/
  skills/       43 skills (SKILL.md + references/ + templates/)
  agents/       13 agentes
  squad-core/   templates · checklists · frameworks (usados pelo @pesquisador-turbo)
```

Isso é o conteúdo que o instalador oficial (`instalar-squad.sh`, etapas 2–4)
descompacta. Está versionado no repo, então acompanha o projeto em qualquer
máquina ou sessão — não precisa reinstalar.

## Ativar (1 comando)

Skills e agentes só carregam se estiverem em `.claude/`. Rode na raiz do repo:

```bash
mkdir -p .claude/skills .claude/agents
cp -r squad-turbo/skills/.  .claude/skills/
cp    squad-turbo/agents/*.md .claude/agents/
```

Para deixar disponível em **todos** os projetos, use `~/.claude/` no lugar de
`.claude/` — é o destino padrão do instalador oficial, e é o caminho que os
agentes referenciam internamente (`~/.claude/skills/...`).

**Depois de copiar, abra uma sessão nova.** Skills e agentes não carregam na
sessão que os instalou.

Conferir:

- `/skills` deve listar `lpsg-master-turbo`, `oferta-lpsg-turbo`, `watch`…
- `@estrategista-turbo se apresenta em 2 linhas` deve responder.

## Os 13 agentes

| Agente | Faz o quê |
|---|---|
| `@estrategista-turbo` | Orquestra o squad, diagnostica campanha e lançamento |
| `@pesquisador-turbo` | Fundação do projeto: voz, avatar, oferta, briefing |
| `@pesquisador-mercado-turbo` | Concorrência, benchmarks, objeções de mercado |
| `@copywriter-turbo` | Copy: páginas, aulas, pitch, emails, mensageria |
| `@diretor-criativo-turbo` | Direção visual |
| `@designer-turbo` | Execução: landing pages, criativos, slides |
| `@trafego-turbo` | Meta Ads e Google Ads |
| `@social-turbo` | Reels, stories, calendário orgânico |
| `@automacao-turbo` | Fluxos n8n, ManyChat, mensageria do evento |
| `@closer-turbo` | Vendas 1:1, recuperação de carrinho D+1–D+7 |
| `@cs-turbo` | Pós-venda: onboarding, NPS, depoimentos, retenção |
| `@picasso-auditor-turbo` | Gate visual: elimina cara de design feito por IA |
| `@revisor-copy-turbo` | Gate textual: caça clichê de IA |

O `@lpsg-master-turbo` (skill) roda as 10 fases do lançamento de ponta a ponta.

## Opcionais pesados — não instalados, não obrigatórios

O instalador oficial oferece três extras que **não são necessários** pro squad
funcionar. Nenhum foi instalado aqui:

| Extra | Tamanho | Pra quê | Como instalar |
|---|---|---|---|
| faster-whisper | ~220 MB + ~3,5 GB no 1º uso | skill `watch` transcrever vídeo sem chave de API | `bash ~/.claude/skills/watch/whisper-local/instalar.sh` |
| Scrapling | ~1,5 GB | Claude ler páginas web (concorrente, landing, anúncio) | `instalar-scrapling.sh` do repo oficial |
| OpenWA | — | WhatsApp no chat; só com servidor próprio | `instalar-openwa.sh` do repo oficial |

Também não foram tocados: Homebrew, ffmpeg, yt-dlp e a stack Picasso (via
`npx`) — todos são dependências da máquina, não do repo.

## Atualizar

```bash
git clone --depth 1 https://github.com/Turbo-Academy/squad-turbo-lpsg-7.0.git /tmp/squad-turbo
```

e reextrair os zips de `/tmp/squad-turbo/99-skills-compartilhaveis/` por cima
de `squad-turbo/skills/` (pulando `squad-turbo-completo.zip` e
`squad-core-turbo.zip`, que são bundles).
