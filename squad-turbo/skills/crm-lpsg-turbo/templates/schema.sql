-- ============================================================================
-- crm-lpsg-turbo · schema.sql
-- CONTRATO IMUTÁVEL. Não edite tabelas, enums, a view fila_closer nem os
-- triggers. Campos extras do seu nicho vão em tabelas novas com FK, nunca
-- alterando as daqui — é isso que mantém a sua instância legível pelas outras
-- skills do Squad Turbo.
--
-- Alvo: Supabase (Postgres 15+). Rode como uma migration única.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1 · Enums
-- ---------------------------------------------------------------------------

create type papel               as enum ('closer', 'cs', 'admin');

create type lead_estado         as enum ('inscrito', 'engajado', 'pitch',
                                         'checkout_iniciado', 'comprou',
                                         'perdido', 'fora_da_fila');

create type lead_tier           as enum ('hot', 'warm', 'cold', 'sem_ficha');

create type interacao_canal     as enum ('whatsapp', 'ligacao', 'outro');
create type interacao_tipo      as enum ('abertura', 'follow_up');
create type interacao_resultado as enum ('respondeu', 'sem_resposta',
                                         'fechou', 'recusou');

create type objecao_tipo        as enum ('preco', 'decisor', 'ceticismo',
                                         'momento', 'adiamento', 'outro');

create type matricula_status    as enum ('pendente', 'aprovada', 'falhou',
                                         'reembolsada', 'cancelada');

create type aluno_status        as enum ('ativo', 'atrasado', 'inativo',
                                         'concluiu', 'cancelou');

create type depoimento_estagio  as enum ('solicitado', 'coletado',
                                         'autorizado', 'publicado');

-- ---------------------------------------------------------------------------
-- 2 · Perfis — liga auth.users ao papel
-- ---------------------------------------------------------------------------

create table perfis (
  id          uuid primary key references auth.users (id) on delete cascade,
  nome        text        not null,
  papel       papel       not null default 'closer',
  ativo       boolean     not null default true,
  criado_em   timestamptz not null default now()
);

-- Papel do usuário autenticado. SECURITY DEFINER para não recursar nas policies.
create or replace function meu_papel()
returns papel
language sql
stable
security definer
set search_path = public
as $$
  select papel from perfis where id = auth.uid()
$$;

create or replace function sou_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(meu_papel() = 'admin', false)
$$;

-- ---------------------------------------------------------------------------
-- 3 · Pessoas — uma linha por humano, atravessa todas as edições
-- ---------------------------------------------------------------------------

create table pessoas (
  id            uuid primary key default gen_random_uuid(),
  nome          text        not null,
  whatsapp      text        not null unique,   -- E.164, ex: +5511988887777
  email         text,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),

  constraint whatsapp_e164 check (whatsapp ~ '^\+[1-9][0-9]{7,14}$')
);

create index idx_pessoas_email on pessoas (email);

-- ---------------------------------------------------------------------------
-- 4 · Edições — a coorte semanal (LPSG-W12)
-- ---------------------------------------------------------------------------

create table edicoes (
  id                uuid primary key default gen_random_uuid(),
  codigo            text        not null unique,   -- LPSG-W12
  carrinho_abre_em  timestamptz not null,
  carrinho_fecha_em timestamptz not null,
  criado_em         timestamptz not null default now(),

  constraint carrinho_coerente check (carrinho_fecha_em > carrinho_abre_em)
);

-- ---------------------------------------------------------------------------
-- 5 · Leads — a participação de uma pessoa numa edição
-- ---------------------------------------------------------------------------

create table leads (
  id                   uuid primary key default gen_random_uuid(),
  pessoa_id            uuid        not null references pessoas (id) on delete cascade,
  edicao_id            uuid        not null references edicoes (id) on delete cascade,

  estado               lead_estado not null default 'inscrito',
  tier                 lead_tier   not null default 'sem_ficha',
  fonte                text,
  data_inscricao       timestamptz not null default now(),

  -- sinais que alimentam a fila
  presente_pitch       boolean     not null default false,
  clicou_link          boolean     not null default false,
  aulas_assistidas     integer     not null default 0,
  checkout_iniciado_em timestamptz,

  responsavel_closer   uuid references perfis (id) on delete set null,
  motivo_perda         text,
  atualizado_em        timestamptz not null default now(),

  constraint aulas_nao_negativa check (aulas_assistidas >= 0),
  constraint um_lead_por_edicao unique (pessoa_id, edicao_id)
);

create index idx_leads_edicao    on leads (edicao_id);
create index idx_leads_estado    on leads (estado);
create index idx_leads_closer    on leads (responsavel_closer);
create index idx_leads_checkout  on leads (checkout_iniciado_em)
  where checkout_iniciado_em is not null;

-- ---------------------------------------------------------------------------
-- 6 · Interações — cada toque 1:1
-- ---------------------------------------------------------------------------

create table interacoes (
  id          uuid primary key default gen_random_uuid(),
  lead_id     uuid            not null references leads (id) on delete cascade,
  autor_id    uuid            not null references perfis (id),
  canal       interacao_canal not null default 'whatsapp',
  tipo        interacao_tipo  not null,
  resultado   interacao_resultado,
  ocorrida_em timestamptz     not null default now(),
  nota        text
);

create index idx_interacoes_lead on interacoes (lead_id, ocorrida_em desc);

-- Trava do método: 1 abertura de conversa por lead.
create unique index uniq_abertura_por_lead
  on interacoes (lead_id)
  where tipo = 'abertura';

-- ---------------------------------------------------------------------------
-- 7 · Objeções — a objeção real dita pelo lead
-- ---------------------------------------------------------------------------

create table objecoes (
  id            uuid primary key default gen_random_uuid(),
  interacao_id  uuid         not null references interacoes (id) on delete cascade,
  tipo          objecao_tipo not null,
  texto         text,
  criada_em     timestamptz  not null default now()
);

create index idx_objecoes_interacao on objecoes (interacao_id);

-- ---------------------------------------------------------------------------
-- 8 · Matrículas — a compra e a jornada do aluno
-- ---------------------------------------------------------------------------

create table matriculas (
  id                   uuid primary key default gen_random_uuid(),
  pessoa_id            uuid             not null references pessoas (id) on delete cascade,
  edicao_id            uuid             not null references edicoes (id) on delete cascade,

  ticket_pago          numeric(10,2)    not null,
  status               matricula_status not null default 'pendente',
  transacao_id         text unique,
  comprada_em          timestamptz      not null default now(),

  -- jornada D0 → D90
  status_aluno         aluno_status     not null default 'ativo',
  data_acesso          timestamptz,
  ultima_atividade_em  timestamptz,
  ultima_aula_assistida integer,
  cs_responsavel       uuid references perfis (id) on delete set null,
  notas_internas       text,
  atualizado_em        timestamptz      not null default now(),

  constraint ticket_nao_negativo check (ticket_pago >= 0),
  constraint uma_matricula_por_edicao unique (pessoa_id, edicao_id)
);

create index idx_matriculas_cs     on matriculas (cs_responsavel);
create index idx_matriculas_status on matriculas (status_aluno);

-- ---------------------------------------------------------------------------
-- 9 · Acompanhamentos — os marcos D0 → D90 e o NPS
-- ---------------------------------------------------------------------------

create table acompanhamentos (
  id            uuid primary key default gen_random_uuid(),
  matricula_id  uuid        not null references matriculas (id) on delete cascade,
  marco         text        not null,   -- D0, D1, D3, D7, D14, D30, D45, D60, D75, D90
  realizado_em  timestamptz,
  nps           integer,
  nota          text,
  criado_em     timestamptz not null default now(),

  constraint nps_valido check (nps is null or nps between 0 and 10),
  constraint um_marco_por_matricula unique (matricula_id, marco)
);

create index idx_acompanhamentos_matricula on acompanhamentos (matricula_id);

-- ---------------------------------------------------------------------------
-- 10 · Depoimentos — prova social com autorização obrigatória
-- ---------------------------------------------------------------------------

create table depoimentos (
  id                uuid primary key default gen_random_uuid(),
  matricula_id      uuid                not null references matriculas (id) on delete cascade,
  estagio           depoimento_estagio  not null default 'solicitado',
  tipo              text,               -- texto | print | video
  link              text,
  autorizado        boolean             not null default false,
  autorizacao_texto text,
  autorizado_em     timestamptz,
  criado_em         timestamptz         not null default now(),

  -- Não existe depoimento autorizado sem registro de quem autorizou e quando.
  constraint autorizacao_completa check (
    autorizado = false
    or (autorizacao_texto is not null and autorizado_em is not null)
  ),
  -- Só sai de 'coletado' com autorização registrada.
  constraint estagio_exige_autorizacao check (
    estagio in ('solicitado', 'coletado') or autorizado = true
  )
);

create index idx_depoimentos_matricula on depoimentos (matricula_id);

-- ---------------------------------------------------------------------------
-- 11 · Triggers — o estado é derivado, nunca digitado
-- ---------------------------------------------------------------------------

-- Recalcula o estado do lead a partir dos sinais.
-- Estados terminais (comprou, perdido, fora_da_fila) não são recalculados.
create or replace function recalcula_estado_lead()
returns trigger
language plpgsql
as $$
begin
  if new.estado in ('comprou', 'perdido', 'fora_da_fila') then
    new.atualizado_em := now();
    return new;
  end if;

  if new.checkout_iniciado_em is not null then
    new.estado := 'checkout_iniciado';
  elsif new.presente_pitch then
    new.estado := 'pitch';
  elsif new.aulas_assistidas > 0 then
    new.estado := 'engajado';
  else
    new.estado := 'inscrito';
  end if;

  new.atualizado_em := now();
  return new;
end;
$$;

create trigger trg_recalcula_estado_lead
  before insert or update on leads
  for each row execute function recalcula_estado_lead();

-- Cap de follow-up: 2 sem resposta SEGUIDOS e o lead sai da fila sozinho.
--
-- Duas decisões deliberadas:
-- 1. Só dispara quando a interação recém-registrada é 'sem_resposta'. Sem isso,
--    registrar um 'respondeu' num lead reativado re-derrubava o lead na mesma
--    hora (o count histórico ainda era >= 2) — beco sem saída.
-- 2. Conta apenas os 'sem_resposta' DEPOIS do último 'respondeu'/'fechou': uma
--    resposta zera a série. É a leitura do método — quem respondeu tem conversa
--    viva, não follow-up pendurado.
create or replace function aplica_cap_follow_up()
returns trigger
language plpgsql
as $$
declare
  serie_sem_resposta integer;
begin
  if new.resultado is distinct from 'sem_resposta' then
    return new;
  end if;

  select count(*) into serie_sem_resposta
  from interacoes
  where lead_id = new.lead_id
    and resultado = 'sem_resposta'
    and ocorrida_em > coalesce(
          (select max(ocorrida_em) from interacoes
            where lead_id = new.lead_id
              and resultado in ('respondeu', 'fechou')),
          '-infinity'::timestamptz
        );

  if serie_sem_resposta >= 2 then
    update leads
       set estado = 'fora_da_fila'
     where id = new.lead_id
       and estado not in ('comprou', 'perdido');
  end if;

  return new;
end;
$$;

create trigger trg_cap_follow_up
  after insert or update on interacoes
  for each row execute function aplica_cap_follow_up();

-- pessoas.atualizado_em acompanha qualquer escrita (a coluna existia mas nada
-- a mantinha — auditoria de 2026-08-12).
create or replace function toca_atualizado_em()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

create trigger trg_pessoas_atualizado
  before update on pessoas
  for each row execute function toca_atualizado_em();

-- ---------------------------------------------------------------------------
-- 12 · A fila — view calculada, nunca uma coluna digitada
-- ---------------------------------------------------------------------------

create or replace view fila_closer as
select
  l.id                  as lead_id,
  l.edicao_id,
  e.codigo              as edicao,
  p.id                  as pessoa_id,
  p.nome,
  p.whatsapp,
  l.tier,
  l.estado,
  l.responsavel_closer,

  case
    when l.checkout_iniciado_em is not null                          then 1
    when l.tier = 'hot'  and l.presente_pitch and l.clicou_link      then 2
    when l.tier = 'hot'  and l.presente_pitch                        then 3
    when l.tier = 'warm' and l.aulas_assistidas >= 3                 then 4
    else 5
  end as prioridade,

  -- o sinal que gerou a prioridade define a ordem dentro dela
  coalesce(l.checkout_iniciado_em, l.data_inscricao) as ordenar_por,

  -- prazo do SLA: só o P1 tem relógio curto (30 min)
  case
    when l.checkout_iniciado_em is not null
    then l.checkout_iniciado_em + interval '30 minutes'
  end as sla_expira_em,

  (select count(*) from interacoes i
    where i.lead_id = l.id and i.tipo = 'follow_up')  as follow_ups,
  (select count(*) from interacoes i
    where i.lead_id = l.id and i.tipo = 'abertura')   as aberturas,
  (select max(i.ocorrida_em) from interacoes i
    where i.lead_id = l.id)                           as ultimo_toque_em

from leads l
join pessoas p on p.id = l.pessoa_id
join edicoes e on e.id = l.edicao_id
where l.estado not in ('comprou', 'perdido', 'fora_da_fila')
  and (
        l.checkout_iniciado_em is not null                      -- P1
     or (l.tier = 'hot'  and l.presente_pitch)                  -- P2, P3
     or (l.tier = 'warm' and l.aulas_assistidas >= 3)           -- P4
     or  l.tier = 'cold'                                        -- P5
     or  l.tier = 'sem_ficha'                                   -- P5: pagou
         -- ingresso — todo lead da base merece pelo menos 1 abertura
  );

-- ---------------------------------------------------------------------------
-- 13 · Fila de risco do CS — as quatro janelas, calculadas
-- ---------------------------------------------------------------------------

create or replace view fila_risco_cs as
select
  m.id as matricula_id,
  p.nome,
  p.whatsapp,
  m.cs_responsavel,
  m.status_aluno,
  case
    when m.data_acesso is null
         and m.comprada_em < now() - interval '48 hours'      then 'sem_primeiro_login'
    when m.ultima_atividade_em is null
         and m.comprada_em < now() - interval '7 days'        then 'sem_vitoria_d7'
    when m.ultima_atividade_em < now() - interval '7 days'    then 'sumiu_7_dias'
    when exists (select 1 from acompanhamentos a
                  where a.matricula_id = m.id and a.nps <= 6) then 'nps_baixo'
  end as risco
from matriculas m
join pessoas p on p.id = m.pessoa_id
where m.status = 'aprovada'
  and m.status_aluno in ('ativo', 'atrasado')
  and (
       (m.data_acesso is null and m.comprada_em < now() - interval '48 hours')
    or (m.ultima_atividade_em is null and m.comprada_em < now() - interval '7 days')
    or  m.ultima_atividade_em < now() - interval '7 days'
    or exists (select 1 from acompanhamentos a
                where a.matricula_id = m.id and a.nps <= 6)
  );

-- ---------------------------------------------------------------------------
-- 14 · RLS — ligada desde a primeira migration
--      As tabelas guardam WhatsApp, email e valor pago. Isso é PII.
-- ---------------------------------------------------------------------------

alter table perfis          enable row level security;
alter table pessoas         enable row level security;
alter table edicoes         enable row level security;
alter table leads           enable row level security;
alter table interacoes      enable row level security;
alter table objecoes        enable row level security;
alter table matriculas      enable row level security;
alter table acompanhamentos enable row level security;
alter table depoimentos     enable row level security;

-- perfis: cada um lê o próprio; admin lê todos
create policy perfis_leitura on perfis for select
  using (id = auth.uid() or sou_admin());
create policy perfis_admin on perfis for all
  using (sou_admin()) with check (sou_admin());

-- edições: todo mundo autenticado lê; só admin escreve
create policy edicoes_leitura on edicoes for select
  using (auth.uid() is not null);
create policy edicoes_escrita on edicoes for all
  using (sou_admin()) with check (sou_admin());

-- pessoas: quem tem lead ou matrícula sob sua responsabilidade enxerga
create policy pessoas_leitura on pessoas for select
  using (
    sou_admin()
    or exists (select 1 from leads l
                where l.pessoa_id = pessoas.id
                  and (l.responsavel_closer = auth.uid()
                       or l.responsavel_closer is null))
    or exists (select 1 from matriculas m
                where m.pessoa_id = pessoas.id
                  and m.cs_responsavel = auth.uid())
  );
create policy pessoas_escrita on pessoas for all
  using (sou_admin()) with check (sou_admin());

-- leads: closer vê os seus e os ainda sem dono (para poder assumir)
create policy leads_leitura on leads for select
  using (
    sou_admin()
    or responsavel_closer = auth.uid()
    or responsavel_closer is null
  );
create policy leads_escrita on leads for update
  using (sou_admin() or responsavel_closer = auth.uid() or responsavel_closer is null)
  with check (sou_admin() or responsavel_closer = auth.uid());
create policy leads_insercao on leads for insert
  with check (sou_admin());

-- interações: o autor e o admin
create policy interacoes_leitura on interacoes for select
  using (
    sou_admin()
    or exists (select 1 from leads l
                where l.id = interacoes.lead_id
                  and (l.responsavel_closer = auth.uid()
                       or l.responsavel_closer is null))
  );
create policy interacoes_insercao on interacoes for insert
  with check (autor_id = auth.uid() or sou_admin());

-- Correção de registro errado (decisão de 2026-08-12): o AUTOR pode corrigir a
-- própria interação por 15 minutos — depois disso o log é imutável e correção
-- vira tarefa de admin. A janela cobre o erro de dedo ("sem resposta" no lugar
-- de "respondeu") sem abrir edição livre de histórico.
-- Obs: corrigir de 'sem_resposta' pra 'respondeu' NÃO reativa sozinho um lead
-- que caiu pra fora_da_fila — estado terminal não é recalculado. O closer
-- reativa o lead na ficha (qualquer estado não-terminal) e o trigger reordena.
create policy interacoes_correcao on interacoes for update
  using (
    sou_admin()
    or (autor_id = auth.uid()
        and ocorrida_em > now() - interval '15 minutes')
  )
  with check (autor_id = auth.uid() or sou_admin());

-- objeções: acompanham a interação
create policy objecoes_leitura on objecoes for select
  using (
    sou_admin()
    or exists (select 1 from interacoes i
                join leads l on l.id = i.lead_id
               where i.id = objecoes.interacao_id
                 and (l.responsavel_closer = auth.uid()
                      or l.responsavel_closer is null))
  );
create policy objecoes_insercao on objecoes for insert
  with check (
    sou_admin()
    or exists (select 1 from interacoes i
                where i.id = objecoes.interacao_id
                  and i.autor_id = auth.uid())
  );

-- Mesma janela de correção das interações: tipou a objeção errada, tem 15 min.
create policy objecoes_correcao on objecoes for update
  using (
    sou_admin()
    or (criada_em > now() - interval '15 minutes'
        and exists (select 1 from interacoes i
                     where i.id = objecoes.interacao_id
                       and i.autor_id = auth.uid()))
  )
  with check (
    sou_admin()
    or exists (select 1 from interacoes i
                where i.id = objecoes.interacao_id
                  and i.autor_id = auth.uid())
  );

-- matrículas: o CS responsável e o admin
create policy matriculas_leitura on matriculas for select
  using (sou_admin() or cs_responsavel = auth.uid() or cs_responsavel is null);
create policy matriculas_escrita on matriculas for update
  using (sou_admin() or cs_responsavel = auth.uid())
  with check (sou_admin() or cs_responsavel = auth.uid());
create policy matriculas_insercao on matriculas for insert
  with check (sou_admin());

-- acompanhamentos e depoimentos: seguem a matrícula
create policy acompanhamentos_tudo on acompanhamentos for all
  using (
    sou_admin()
    or exists (select 1 from matriculas m
                where m.id = acompanhamentos.matricula_id
                  and m.cs_responsavel = auth.uid())
  )
  with check (
    sou_admin()
    or exists (select 1 from matriculas m
                where m.id = acompanhamentos.matricula_id
                  and m.cs_responsavel = auth.uid())
  );

create policy depoimentos_tudo on depoimentos for all
  using (
    sou_admin()
    or exists (select 1 from matriculas m
                where m.id = depoimentos.matricula_id
                  and m.cs_responsavel = auth.uid())
  )
  with check (
    sou_admin()
    or exists (select 1 from matriculas m
                where m.id = depoimentos.matricula_id
                  and m.cs_responsavel = auth.uid())
  );

-- ============================================================================
-- Os webhooks (ficha e Hotmart) escrevem com a service_role key, que ignora
-- RLS por definição. Essa chave é server-only: nunca vai para o browser.
-- ============================================================================
