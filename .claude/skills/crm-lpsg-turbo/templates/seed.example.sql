-- ============================================================================
-- crm-lpsg-turbo · seed.example.sql
-- Dados de exemplo para validar a fila ANTES de ter dado real.
--
-- ANTES DE RODAR: crie os usuários no Supabase Auth (Authentication → Users) e
-- troque os UUIDs abaixo pelos reais. `perfis.id` referencia `auth.users.id`.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Perfis — troque os UUIDs pelos que o Supabase Auth gerou
-- ---------------------------------------------------------------------------

insert into perfis (id, nome, papel) values
  ('00000000-0000-0000-0000-000000000001', 'Admin',        'admin'),
  ('00000000-0000-0000-0000-000000000002', 'Closer Um',    'closer'),
  ('00000000-0000-0000-0000-000000000003', 'CS Oficial Um', 'cs');

-- ---------------------------------------------------------------------------
-- Edição corrente
-- ---------------------------------------------------------------------------

insert into edicoes (id, codigo, carrinho_abre_em, carrinho_fecha_em) values
  ('10000000-0000-0000-0000-000000000001',
   'LPSG-W99',
   now() - interval '1 day',
   now() + interval '4 days');

-- ---------------------------------------------------------------------------
-- Pessoas — uma por prioridade da fila, para conferir a ordenação
-- ---------------------------------------------------------------------------

insert into pessoas (id, nome, whatsapp, email) values
  ('20000000-0000-0000-0000-000000000001', 'P1 Checkout',    '+5511900000001', 'p1@exemplo.com'),
  ('20000000-0000-0000-0000-000000000002', 'P2 Hot Clicou',  '+5511900000002', 'p2@exemplo.com'),
  ('20000000-0000-0000-0000-000000000003', 'P3 Hot Pitch',   '+5511900000003', 'p3@exemplo.com'),
  ('20000000-0000-0000-0000-000000000004', 'P4 Warm 3Aulas', '+5511900000004', 'p4@exemplo.com'),
  ('20000000-0000-0000-0000-000000000005', 'P5 Cold',        '+5511900000005', 'p5@exemplo.com'),
  ('20000000-0000-0000-0000-000000000006', 'Fora Sem Sinal', '+5511900000006', 'p6@exemplo.com'),
  ('20000000-0000-0000-0000-000000000007', 'Comprou',        '+5511900000007', 'p7@exemplo.com');

-- ---------------------------------------------------------------------------
-- Leads — o estado é recalculado pelo trigger, não precisa informar
-- ---------------------------------------------------------------------------

insert into leads (id, pessoa_id, edicao_id, tier, presente_pitch, clicou_link,
                   aulas_assistidas, checkout_iniciado_em, responsavel_closer) values
  -- P1 · checkout iniciado há 10 min → SLA de 30 min correndo
  ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001', 'hot',  true,  true,  4,
   now() - interval '10 minutes', '00000000-0000-0000-0000-000000000002'),

  -- P2 · hot + pitch + clique
  ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002',
   '10000000-0000-0000-0000-000000000001', 'hot',  true,  true,  3, null,
   '00000000-0000-0000-0000-000000000002'),

  -- P3 · hot + pitch, sem clique
  ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003',
   '10000000-0000-0000-0000-000000000001', 'hot',  true,  false, 2, null,
   '00000000-0000-0000-0000-000000000002'),

  -- P4 · warm com 3 aulas
  ('30000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000004',
   '10000000-0000-0000-0000-000000000001', 'warm', false, false, 3, null,
   '00000000-0000-0000-0000-000000000002'),

  -- P5 · cold
  ('30000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000005',
   '10000000-0000-0000-0000-000000000001', 'cold', false, false, 0, null,
   '00000000-0000-0000-0000-000000000002'),

  -- NÃO deve aparecer: sem ficha e sem presença no pitch
  ('30000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000006',
   '10000000-0000-0000-0000-000000000001', 'sem_ficha', false, false, 1, null,
   '00000000-0000-0000-0000-000000000002');

-- NÃO deve aparecer: já comprou
insert into leads (id, pessoa_id, edicao_id, tier, presente_pitch, estado,
                   responsavel_closer) values
  ('30000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000007',
   '10000000-0000-0000-0000-000000000001', 'hot', true, 'comprou',
   '00000000-0000-0000-0000-000000000002');

-- ---------------------------------------------------------------------------
-- Conferência esperada
-- ---------------------------------------------------------------------------
--
--   select nome, prioridade, follow_ups from fila_closer
--    order by prioridade, ordenar_por;
--
--   → 5 linhas, na ordem P1 · P2 · P3 · P4 · P5
--   → "Fora Sem Sinal" e "Comprou" NÃO aparecem
--
-- Teste do cap de follow-up (dois "sem resposta" tiram o lead da fila):
--
--   insert into interacoes (lead_id, autor_id, tipo, resultado) values
--     ('30000000-0000-0000-0000-000000000005',
--      '00000000-0000-0000-0000-000000000002', 'abertura',  'sem_resposta'),
--     ('30000000-0000-0000-0000-000000000005',
--      '00000000-0000-0000-0000-000000000002', 'follow_up', 'sem_resposta');
--
--   → "P5 Cold" sai da fila e o estado vira 'fora_da_fila'
--
-- Teste da trava de abertura única (a segunda deve falhar):
--
--   insert into interacoes (lead_id, autor_id, tipo) values
--     ('30000000-0000-0000-0000-000000000002',
--      '00000000-0000-0000-0000-000000000002', 'abertura');
--   insert into interacoes (lead_id, autor_id, tipo) values
--     ('30000000-0000-0000-0000-000000000002',
--      '00000000-0000-0000-0000-000000000002', 'abertura');
--
--   → a segunda viola uniq_abertura_por_lead
-- ---------------------------------------------------------------------------
