# Workflow — Reavaliação Postural Mensal

Fluxo end-to-end: da foto no WhatsApp até o relatório entregue.

```mermaid
flowchart TD
    A[Aluna manda foto no WhatsApp] --> B{É 1ª foto ou reavaliação?}
    B -->|1ª foto| C[Gerar Avaliação Inicial + plano base]
    B -->|Reavaliação| D[Carregar foto anterior de data/aluna/]
    D --> E[Agente Reavaliação Postural]
    C --> E
    E --> F[Skill avaliacao-postural roda]
    F --> G[Lê template reavaliacao-postural.md]
    G --> H[Analisa 8 regiões anatômicas x 4 views]
    H --> I[Preenche tabela Antes vs Depois + evolução]
    I --> J[Roda checklist reavaliacao.md]
    J --> K{Passou no checklist?}
    K -->|Não| L[Volta pedir info à aluna]
    K -->|Sim| M[Salva em data/aluna/reavaliacao-YYYY-MM-DD.md]
    M --> N[Gera PDF se solicitado]
    N --> O[Prepara resumo 2-3 frases para WhatsApp]
    O --> P[Breno revisa e envia à aluna]
```

## Passos em detalhe

### 1. Ingestão
- Breno (ou automação futura) salva as fotos em `data/<aluna>/fotos/YYYY-MM-DD/`
- Nomenclatura: `frontal.jpg`, `posterior.jpg`, `lateral-d.jpg`, `lateral-e.jpg`

### 2. Classificação do caso
- Existe `data/<aluna>/reavaliacao-*.md` anterior? → **reavaliação comparativa**
- Não existe? → **avaliação inicial** (relatório simplificado + primeiro plano)

### 3. Execução do agente
- Abre `agents/reavaliacao-postural.md` como prompt base
- Carrega: anamnese da aluna + fotos (atual + anterior) + `core/*`
- Aciona `skills/avaliacao-postural/SKILL.md`

### 4. Gate de qualidade
- `checklists/reavaliacao.md` é checklist HARD — qualquer item falho = não entrega

### 5. Persistência
- Arquivo final em `data/<aluna>/reavaliacao-YYYY-MM-DD.md`
- PDF em `data/<aluna>/reavaliacao-YYYY-MM-DD.pdf`
- Log técnico (o que mudou por região, evolução) em `data/<aluna>/logs/reavaliacao-YYYY-MM-DD.yaml`

### 6. Entrega
- Breno recebe preview + mensagem de WhatsApp pronta
- Breno valida e dispara para a aluna

## Handoff para o agente de dieta

Após a reavaliação, a **fase atualizada** da aluna é input direto para o agente de dieta na próxima atualização mensal. O agente de dieta SEMPRE lê a reavaliação mais recente antes de montar.
