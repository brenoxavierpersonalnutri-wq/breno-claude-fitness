# 04 · Webhooks — ficha e Hotmart

> São eles que fazem o P1 existir em tempo real. Sem webhook de checkout
> iniciado, o SLA de 30 minutos vira ficção.

Ambos rodam como **Route Handlers do Next.js**, escrevem com a `service_role`
(que ignora RLS) e são **server-only**.

---

## Regras comuns

1. **Rejeite antes de processar.** Assinatura inválida → `401`, sem tocar no
   banco.
2. **Responda rápido.** `200` assim que gravar. Plataforma que espera demais
   reenvia e duplica.
3. **Seja idempotente.** O mesmo evento chega duas vezes — é normal, não é bug.
   Dedupe por `transacao_id` na compra e por WhatsApp no lead.
4. **Nunca logue PII.** Log de erro com WhatsApp e email dentro é achado de
   auditoria.
5. **Normalize o WhatsApp para E164** antes de qualquer coisa. O banco tem
   constraint; se você não normalizar, o insert falha.

---

## `POST /api/webhook/ficha`

Recebe a ficha de interesse da página (11 etapas).

**Autenticação:** header `X-Ficha-Secret` igual a `FICHA_WEBHOOK_SECRET`.

**Payload esperado:**

```json
{
  "nome": "Fulano de Tal",
  "whatsapp": "11988887777",
  "email": "fulano@exemplo.com",
  "tier": "hot",
  "edicao": "LPSG-W12",
  "fonte": "pagina-ingresso",
  "respostas": { }
}
```

**O que faz:**

1. Normaliza o WhatsApp para E.164
2. `upsert` em `pessoas` por WhatsApp
3. `upsert` em `leads` por (pessoa, edição), gravando `tier` e `fonte`
4. O trigger cuida do estado

`edicao` ausente → usa `EDICAO_CORRENTE`.

**Tier:** se a página já classifica, respeite. Se manda as respostas cruas,
classifique no handler segundo a regra do seu nicho — mas **em um só lugar**,
nunca espalhado.

---

## `POST /api/webhook/hotmart`

**Autenticação:** header `X-Hotmart-Hottok` igual a `HOTMART_HOTTOK`. Diferente →
`401`.

**Eventos que importam:**

| Evento | Efeito |
|---|---|
| `PURCHASE_BILLET_PRINTED` / checkout iniciado | grava `checkout_iniciado_em` → **lead vira P1** |
| `PURCHASE_APPROVED` | estado `comprou` + cria `matricula` aprovada |
| `PURCHASE_PROTEST` / `PURCHASE_REFUNDED` | matrícula `reembolsada`, aluno `cancelou` |
| `PURCHASE_CANCELED` | matrícula `cancelada` |

> Confira os nomes de evento na documentação da Hotmart da sua conta — eles
> variam por versão da API. O que **não** varia é o mapeamento acima.

**Checkout iniciado:**

1. Acha ou cria a pessoa pelo WhatsApp (ou email, se não vier telefone)
2. Acha ou cria o lead na edição corrente
3. Grava `checkout_iniciado_em` **só se ainda estiver vazio** — reescrever
   reinicia o SLA e mascara lead esquecido
4. O trigger move o estado

**Compra aprovada:**

1. `upsert` em `matriculas` por `transacao_id`
2. Marca o lead como `comprou` (estado terminal — sai da fila)
3. `cs_responsavel` fica nulo; a atribuição é do admin

---

## Testar (fase 4)

```bash
# ficha
curl -X POST "$APP/api/webhook/ficha" \
  -H "Content-Type: application/json" \
  -H "X-Ficha-Secret: $FICHA_WEBHOOK_SECRET" \
  -d '{"nome":"Teste","whatsapp":"11988887777","tier":"hot","edicao":"LPSG-W99"}'

# segredo errado → precisa dar 401
curl -i -X POST "$APP/api/webhook/ficha" \
  -H "Content-Type: application/json" \
  -H "X-Ficha-Secret: errado" -d '{}'
```

**Critério de pronto:** o POST válido cria o lead e move o estado; o inválido
devolve `401` sem gravar nada.

---

## Quando o dado não vem por webhook

`presente_pitch`, `clicou_link` e `aulas_assistidas` não têm webhook — vêm do
YouTube, do encurtador e da presença. No v1 entram por **import CSV** ou update
do admin.

Não invente integração aqui. Sem esses três sinais a fila ainda funciona: o P1
vem do checkout e o tier vem da ficha. P2 a P5 ficam menos precisos até o import
rodar.
