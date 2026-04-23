# Checklist — Antes de entregar uma Dieta Mensal

> O Agente de Dieta Mensal roda esta lista. **Qualquer "não" → volta corrigir antes de entregar.**

## Inputs lidos

- [ ] Li `core/metodologia.md`?
- [ ] Li `core/fases-composicao.md` e **decidi explicitamente** a fase?
- [ ] Li `core/dieta-principios.md`?
- [ ] Li `config.yaml` e usei as faixas de macros de lá?
- [ ] Li a **anamnese** atual da aluna?
- [ ] Li a **dieta anterior** (se existir)?
- [ ] Li o **relato do mês** (se existir)?

## Decisão de fase

- [ ] A fase (déficit leve / moderado / manutenção / superávit leve) está declarada no cabeçalho da dieta?
- [ ] A fase é coerente com o que a foto/reavaliação mostra?
- [ ] Se mudou de fase em relação ao mês anterior, a mudança é justificada (foto + relato)?

## Macros

- [ ] VCT calculado com fórmula documentada?
- [ ] Proteína dentro de `config.yaml.dieta.macros.proteina_g_por_kg`?
- [ ] Gordura dentro de `config.yaml.dieta.macros.gordura_percent_vct`?
- [ ] Carboidrato = sobra (VCT - prot_kcal - gord_kcal)?
- [ ] Déficit (se aplicável) dentro de `config.yaml.dieta.deficit_calorico`?

## Alimentos

- [ ] Nenhum alimento da lista "não gosto" entrou?
- [ ] Respeitei todas as restrições (intolerância, alergia, medicamento)?
- [ ] Pelo menos 80% dos alimentos são do "come hoje" ou "gosta"?
- [ ] Cada refeição tem **alternativas**?
- [ ] Volume visual de comida está bom (prato cheio, saciedade)?
- [ ] Se aluna tem perfil "doce" → incluí industrializados aceitos relevantes?

## Rotação (a partir da 2ª dieta)

- [ ] Troquei pelo menos 1 fonte de proteína vs. mês anterior?
- [ ] Troquei pelo menos 1 fonte de carbo?
- [ ] Incluí pelo menos 1 receita/preparo "novo"?

## Forma

- [ ] Cabeçalho com nome, fase, VCT, macros, data?
- [ ] 4 a 6 refeições com horário, alimentos, quantidade em g + medida caseira?
- [ ] Bloco "O que mudou em relação ao mês anterior" preenchido?
- [ ] Bloco "Observações" (hidratação, suplementação, timing) preenchido?
- [ ] Mensagem curta de WhatsApp (3–5 linhas) incluída?
- [ ] Rodapé "Consultoria online — BRENO XAVIER"?

## Entrega

- [ ] Salvei em `data/<aluna>/dieta-YYYY-MM-DD.md`?
- [ ] Log de macros e fase salvo (auditável)?
