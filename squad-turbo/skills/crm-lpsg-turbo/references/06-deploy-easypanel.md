# 06 · Deploy — GitHub → EasyPanel → domínio + SSL

> Módulo 05 do curso aplicado a este projeto. Fase 8, depois da auditoria.
> Nunca antes: a base tem WhatsApp, email e valor pago.

---

## Antes de subir

- [ ] Auditoria de segurança rodou sem achado crítico (fase 7)
- [ ] `.env.local` **não** está no repositório — confira o `.gitignore`
- [ ] `SUPABASE_SERVICE_ROLE_KEY` só aparece em Route Handler, nunca em componente cliente
- [ ] RLS ligada em todas as tabelas
- [ ] Repositório **privado**

O item da `service_role` é o mais importante da lista. Ela ignora RLS por
definição — se for para o browser, o banco inteiro fica exposto, e nenhuma
policy salva.

```bash
git grep -n "SERVICE_ROLE" -- src | grep -v "app/api"
```

Qualquer resultado fora de `app/api` é bug de segurança. Corrija antes de
continuar.

---

## 1 · GitHub

Repositório **privado**. Se ainda não configurou SSH, é a aula "Conectando ao
GitHub e Autenticando" do módulo 05.

```bash
git init
git add .
git commit -m "CRM LPSG — fases 1-7"
git branch -M main
git remote add origin git@github.com:SEU_USUARIO/crm-lpsg.git
git push -u origin main
```

---

## 2 · Dockerfile

Next.js em modo `standalone` — imagem menor e sem `node_modules` no runtime.

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
USER nextjs
EXPOSE 3000
ENV PORT=3000 HOSTNAME=0.0.0.0
CMD ["node", "server.js"]
```

Exige `output: 'standalone'` no `next.config.js`. Sem isso o build passa e o
container sobe vazio — é o erro mais comum aqui.

---

## 3 · EasyPanel

1. **Create Service → App**
2. **Source:** GitHub, com Personal Access Token. Branch `main`
3. **Build:** Dockerfile
4. **Environment:** cole o conteúdo do `.env.local`

   As `NEXT_PUBLIC_*` são lidas **no build**. Mudou uma delas, precisa rebuildar
   — só reiniciar não resolve.
5. **Deploy** e acompanhe o log

### Erros comuns

| Sintoma | Causa |
|---|---|
| `Cannot find module '/app/server.js'` | falta `output: 'standalone'` |
| Build passa, app não responde | `HOSTNAME` diferente de `0.0.0.0` |
| `supabaseUrl is required` | `NEXT_PUBLIC_*` ausente **no build** |
| 401 em toda query | anon key de outro projeto Supabase |
| Webhook 500 | `SUPABASE_SERVICE_ROLE_KEY` não configurada |

Cole o log inteiro no próprio Claude Code — resolve na maioria das vezes.

---

## 4 · Domínio e SSL

1. **Domains → Add Domain:** `crm.seudominio.com.br`, porta `3000`
2. No seu DNS, um registro **A** apontando para o IP da VPS
3. Espere propagar (minutos, às vezes mais)
4. **Enable HTTPS** → Let's Encrypt

Emitir o certificado antes do DNS propagar falha. Se falhar, espere e tente de
novo — não é erro de configuração.

---

## 5 · Depois de subir

- [ ] Login funciona no domínio
- [ ] Um usuário `closer` vê só a própria fila
- [ ] Webhook da ficha responde `200` no domínio de produção
- [ ] HOTTOK inválido responde `401`
- [ ] Aponte a ficha de interesse e a Hotmart para as URLs de produção
- [ ] Faça **uma compra de teste real** e confirme que o lead vira `comprou`

O último item é o que de fato prova o sistema. Sem uma transação real
atravessando a ponta, você tem uma aplicação, não uma operação.

---

## Atualizações

```bash
git add . && git commit -m "descrição" && git push
```

EasyPanel rebuilda. Para as fases 9-10 (CS), o ciclo é o mesmo: implementa,
revisa, **audita de novo**, e sobe.
