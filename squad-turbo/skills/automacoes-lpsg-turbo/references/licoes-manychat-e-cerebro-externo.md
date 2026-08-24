# Lições do incidente ManyChat 17-19/08/2026 — o que muda decisão de projeto

Vem do monitoramento em produção de um closer de IA rodando no direct do Instagram e da
migração dele pro padrão cérebro externo (n8n + Postgres + API Claude). Números e
comportamentos são de operação real; a narrativa completa do incidente fica no diário
interno de quem operou. Aqui só o que muda decisão de projeto.

---

## 1. Se você for colocar IA (bloco "Ações do Claude") dentro de um fluxo ManyChat: trate como último recurso

A integração de modelo da ManyChat **já parou de completar chamadas duas vezes, em dois
modelos diferentes (Opus 5 e depois Sonnet 5), sem gerar UM log em Configurações→Registros.**
O sintoma é sempre o mesmo: `historico` cresce a cada turno, `resposta` fica congelada byte
a byte — parece bug de fluxo, mas é a plataforma comendo a chamada. Não existe retry, não
existe timeout configurável, não existe fallback nativo.

**Decisão:** para qualquer fluxo novo que precise de um "cérebro" (SPIN, qualificação,
suporte, closer), o padrão passa a ser **tirar a IA de dentro do ManyChat**. O bloco Claude
nativo só se justifica para protótipo descartável ou volume baixíssimo onde uma falha
silenciosa não custa lead real. Ver item 5 (padrão que resolve).

Se mesmo assim o bloco nativo for usado: fixar o modelo em **Claude Sonnet 5** (validado em
produção; Opus 5 é o que quebrou) e revisar Configurações→Registros manualmente — não confiar
que erro vai aparecer lá.

## 2. Se você for usar Coleta de Dados como "espera resposta": a saída "Se o contato não respondeu" TEM que apontar pra um nó terminal

Por padrão essa saída fica vazia. Vazia não significa "não faz nada" — significa **cair no
"Próximo Passo" quando a coleta expira**, exatamente como se a pessoa tivesse respondido.
Num desenho `coleta → IA → condição → coleta`, isso vira um loop que chama a IA de novo a
cada expiração, com o campo de mensagem vazio. Foi a causa raiz confirmada de 11 dos 16 leads
reais queimados no incidente: pessoas que **nunca escreveram nada** receberam 6 a 8 turnos de
IA tentando adivinhar o que aconteceu.

**Checklist obrigatório em qualquer nó de Coleta de Dados que abre um loop de IA:**
- "Se o contato não respondeu" **precisa** ir pra um nó de Ações terminal (grava estado de
  encerrado, tag opcional, não segue pra lugar nenhum) — nunca ficar vazio.
- Se não for possível criar esse nó no momento (ex.: disjuntor de edição esgotado, fora de
  janela), documentar como risco aberto explicitamente — não presumir que "vazio" é seguro.
- Alternativa complementar, não substituta: revisar o tempo de expiração da coleta pra reduzir
  o dano por ciclo.

## 3. Se você for limpar um campo na entrada de um fluxo: nunca use "Clear Field" em campo que será referenciado depois

Campo limpo por "Clear Field" e depois referenciado por outra ação (ex.: dentro de um contexto
montado pra IA) não vira string vazia — vira o **token literal** `{{cuf_NNN}}` cru. Esse token
entra no histórico/contexto e contamina o primeiro turno da conversa.

**Regra:** para zerar um campo que será lido depois, usar **Definir campo com valor `.`**
(ponto). Não usar espaço — a ManyChat trima espaço na gravação, então "vazio com espaço"
volta a ser vazio de verdade e reabre o mesmo bug. `.` é o valor neutro validado.

## 4. Se o lead responder em áudio/figurinha/imagem: o ManyChat não entrega isso como texto em NENHUM campo de sistema

`spin_msg` (e equivalentes) espelham exatamente `last_input_text`, que é só texto. Áudio,
figurinha e imagem não populam esse campo — chegam como "vazio" pro fluxo, mesmo a pessoa
tendo respondido. A Coleta de Dados da ManyChat tem tipo **Imagem**, mas não tem tipo
Áudio/Arquivo, e **não existe campo de sistema com URL de anexo** em nenhum tipo de coleta.

**Consequência de projeto:** se o público responde por áudio (DM de Instagram no Brasil, isso
é regra, não exceção — no incidente bateu ~47% do volume real), um fluxo puramente ManyChat
não tem como capturar essa mensagem. A única rota pra transcrever é a **Instagram Graph API**
oficial (`attachments[].payload.url`), fora do ManyChat. Sem isso, o mínimo aceitável é uma
escada de "não recebi, me manda em texto" que desiste com elegância — nunca ecoar o token cru
nem insistir indefinidamente.

## 5. Padrão que resolve os quatro pontos acima: tirar o cérebro da plataforma

Toda vez que o fluxo precisar de lógica com estado (contar turno, decidir fase, decidir
oferta, decidir fechamento), a arquitetura recomendada é:

```
ManyChat (gatilho, coleta, entrega de mídia, janela 24h — o que ela faz bem)
   → nó Solicitação Externa / Requisição Externa (substitui o bloco "Ações do Claude")
   → webhook em n8n
   → Postgres (histórico real, com papéis alternados — não string "Pessoa:...Voce:...";
     contagem de fase por SQL, não por prompt tentando contar turnos)
   → API do Claude direto (com timeout, retry, sanitização em código: colapsa \n, aplica
     teto de caracteres, detecta marcador de fechamento)
   → responde 200 SEMPRE — se a API falhar mesmo com retry, devolve uma mensagem de espera
     pré-definida e dispara alerta (nunca deixa o lead sem resposta nenhuma)
   → mapeia a resposta de volta pros campos do ManyChat (ex.: spin_resposta, spin_fechou)
```

**ManyChat vira transporte, não cérebro.** Isso resolve simultaneamente: falha silenciosa
(loga e reporta em código), quebra de linha matando conversa (sanitiza em código), token
literal (nunca chega — o Postgres é a fonte, os campos ManyChat viram espelho), e contagem de
fase (SQL determinístico em vez de prompt "conte os turnos" — que também vaza raciocínio na
resposta se o prompt não blindar isso).

**Quando usar o bloco nativo mesmo assim:** só quando não há lógica de estado real (uma
resposta única, sem histórico, sem fases) ou quando o volume é baixo o suficiente pra falha
silenciosa não ter custo — nesses casos o ganho de tirar a IA da plataforma não paga a
complexidade extra de subir n8n/Postgres.

## 6. Se for hospedar o cérebro externo (ou qualquer serviço novo) num VPS que já roda outros projetos: proxy compartilhado, nunca proxy por projeto

Layout validado: cada projeto mora em `/opt/<projeto>/` com o próprio `docker-compose.yml`
(app + banco, se tiver). Um único **Caddy compartilhado** em `/opt/proxy` é o dono exclusivo
das portas 80/443 e faz SSL automático por subdomínio; os serviços web de cada projeto entram
numa rede docker externa chamada `web` pra ficarem alcançáveis pelo proxy. Banco de dados
**nunca** entra na rede `web` — fica só na rede interna do projeto.

**Regra dura:** nenhum compose de projeto publica 80/443 diretamente. Se um projeto novo
precisar expor um serviço, ele entra na rede `web` e ganha um arquivo de rota em
`/opt/proxy/sites/<projeto>.caddy` apontando pro container — nunca abre porta própria.

## 7. Se for integrar com OpenWA (WhatsApp) pra alertas: autenticação e rota corretas

- Header de autenticação é **`x-api-key`**, não `Authorization: Bearer`.
- O Swagger fica desligado por padrão em produção — descobrir rota lendo o controller
  compilado no container (`docker exec <container> cat /app/dist/modules/<modulo>/<x>.controller.js`
  e grepando por `Post(` / `Get(`), não confiando em documentação interativa.
- Rota validada de envio de texto: `POST /api/sessions/<sessionId>/messages/send-text`, body
  `{"chatId":"...","text":"..."}`.
- Uso é só alerta 1:1 pro operador — nunca disparo em massa por esse canal (número em
  aquecimento anti-ban).
