# 00 · Variáveis Globais — CRM LPSG

> Fonte da verdade da instância. Preencha aqui primeiro; os outros arquivos
> referenciam estas variáveis.

---

## 🎭 Projeto

```yaml
NOME_ESPECIALISTA:    "{NOME_ESPECIALISTA}"
NICHO:                "{NICHO}"
NOME_PRODUTO:         "{NOME_PRODUTO_PRINCIPAL}"
TICKET:               "{TICKET_PRODUTO}"
EDICAO_CORRENTE:      "{LPSG-WNN}"              # Ex: LPSG-W12
```

---

## 🔗 Infra

```yaml
SUPABASE_PROJECT:     "{NOME_PROJETO_SUPABASE}"
SUPABASE_URL:         "{NEXT_PUBLIC_SUPABASE_URL}"
REPO_GITHUB:          "{URL_REPO}"              # privado
EASYPANEL_APP:        "{NOME_DO_SERVICO}"
DOMINIO_CRM:          "{crm.seudominio.com.br}"
```

---

## 🔐 Segredos (vão no `.env.local`, nunca no repositório)

```yaml
SUPABASE_SERVICE_ROLE_KEY:  server-only · ignora RLS · só webhooks
HOTMART_HOTTOK:             valida o webhook da Hotmart
FICHA_WEBHOOK_SECRET:       openssl rand -hex 32 · header X-Ficha-Secret
```

---

## 👥 Papéis

```yaml
admin:   "{NOME}"          # configura, importa, vê tudo
closer:  "{NOME_1..N}"     # 1 fila por closer
cs:      "{NOME_1..N}"     # 1 carteira por CS Oficial
```

Regra de dimensionamento herdada do `cs-lpsg-turbo`: 1 CS Oficial por 25-40
alunos ativos.

---

## ⏱️ SLAs (do `closer-lpsg-turbo`)

```yaml
P1_CHECKOUT_INICIADO: "≤ 30 min"
P2_HOT_COMPLETO:      "D+1 até 19h"
P3_HOT_PARCIAL:       "D+1 manhã"
P4_WARM_ENGAJADO:     "D+2"
P5_RESTO:             "D+3+"
```

---

## 📊 Targets (do `cs-lpsg-turbo`)

```yaml
NPS_ALVO_MIN:         "≥ 70"
RETENCAO_30D:         "≥ 95%"
RETENCAO_90D:         "≥ 80%"
TAXA_DEPOIMENTOS:     "≥ 30% até D60"
TAXA_CHURN:           "≤ 5% no ciclo"
```

---

## 🔁 De onde vem cada dado

| Dado | Origem |
|---|---|
| Lead novo, tier | Webhook da ficha de interesse |
| `checkout_iniciado_em` | Webhook Hotmart |
| `estado = comprou`, matrícula | Webhook Hotmart |
| `presente_pitch`, `aulas_assistidas` | Import CSV ou update manual do admin |
| `clicou_link` | Import CSV ou update manual do admin |
| Interações e objeções | Registradas pelo closer na ficha |
| Marcos D0→D90, NPS | Registrados pelo CS na carteira |
