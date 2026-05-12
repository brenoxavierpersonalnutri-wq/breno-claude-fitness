"""
Gerador de PDF de dieta no padrao Breno Xavier.

Le um dicionario de dieta (Python) e renderiza um PDF A4 estilizado
seguindo core/formato-dieta.md (paleta verde, logo SVG, texto corrido,
sem emojis/caixinhas/tabelas coloridas).

Uso:
    python3 scripts/gerar-dieta-pdf.py data/aluna-teste/dieta-2026-05-12.json

Se rodado sem argumento, gera a dieta de aluna-teste embutida no fim do
arquivo (caso canonico de smoke test do squad).
"""
from __future__ import annotations

import json
import os
import sys
from dataclasses import dataclass, field
from datetime import date
from typing import Optional

from weasyprint import HTML, CSS  # type: ignore


# -------------------- Modelo ----------------------------------------------- #

@dataclass
class Item:
    alimento: str
    quantidade: str
    medida: Optional[str] = None

    def render(self) -> str:
        if self.medida:
            return f"{self.alimento} - {self.quantidade} ({self.medida})"
        return f"{self.alimento} - {self.quantidade}"


@dataclass
class Opcao:
    rotulo: str
    itens: list[Item]
    nota: Optional[str] = None
    sobremesa: Optional[str] = None


@dataclass
class Refeicao:
    titulo: str
    horario: str
    opcoes: list[Opcao]
    dica: Optional[str] = None


@dataclass
class MacrosLinha:
    nome: str
    kcal: str
    carbo: str
    proteina: str
    gord_insat: str
    gord_sat: str
    fibra: str


@dataclass
class Dieta:
    aluna: str
    fase: str
    data: str
    recomendacao: str
    hidratacao: str
    refeicoes: list[Refeicao]
    refeicao_livre: str
    observacoes: list[str]
    macros: list[MacrosLinha]


# -------------------- Conteudo da dieta-teste ------------------------------ #

def dieta_aluna_teste() -> Dieta:
    refeicoes = [
        Refeicao(
            titulo="Cafe da manha",
            horario="07h00",
            opcoes=[
                Opcao(
                    rotulo="OPCAO 1",
                    itens=[
                        Item("Pao de forma light", "50g", "2 fatias"),
                        Item("Ovo mexido", "2 unidades"),
                        Item("Requeijao light", "10g", "1 colher de cha"),
                        Item("Mamao", "100g", "1 fatia media"),
                        Item("Cafe com leite desnatado", "100ml"),
                    ],
                ),
                Opcao(
                    rotulo="OPCAO 2",
                    itens=[
                        Item("Goma de tapioca", "30g", "massa fina"),
                        Item("Frango desfiado caseiro", "60g", "3 colheres de sopa"),
                        Item("Banana com canela", "80g", "~1 unidade"),
                        Item("Cafe preto", "a vontade"),
                    ],
                ),
                Opcao(
                    rotulo="OPCAO 3",
                    itens=[
                        Item("Aveia em flocos", "30g", "3 colheres de sopa"),
                        Item("Leite desnatado", "200ml", "1 copo"),
                        Item("Ovo mexido", "2 unidades"),
                        Item("Mexerica", "100g", "1 unidade"),
                    ],
                    nota="Bate aveia + leite + canela + adocante e cozinha em fogo baixo. Mingau quente sacia mais.",
                ),
            ],
        ),
        Refeicao(
            titulo="Almoco",
            horario="12h30",
            dica="Salada de folhas a vontade em todas as opcoes (sem azeite por padrao).",
            opcoes=[
                Opcao(
                    rotulo="OPCAO 1",
                    itens=[
                        Item("Arroz branco cozido", "60g", "4 colheres de sopa"),
                        Item("Feijao carioca", "100g", "1 concha rasa"),
                        Item("Patinho moido refogado", "90g", "4 colheres de sopa cheias"),
                        Item("Cenoura e beterraba ralada", "60g"),
                        Item("Vegetais a escolha", "a vontade", "ou mais"),
                    ],
                    sobremesa="Sobremesa: laranja - 1 unidade media OU 1 Trento (130 kcal)",
                ),
                Opcao(
                    rotulo="OPCAO 2",
                    itens=[
                        Item("Arroz branco cozido", "50g", "3 colheres de sopa"),
                        Item("Feijao preto", "100g", "1 concha rasa"),
                        Item("Tilapia grelhada", "90g", "1 file medio"),
                        Item("Batata inglesa cozida", "80g", "1 unidade pequena"),
                        Item("Vegetais a escolha", "a vontade", "ou mais"),
                    ],
                    sobremesa="Sobremesa: mamao - 100g OU 1 Ouro Branco (135 kcal)",
                ),
                Opcao(
                    rotulo="OPCAO 3",
                    itens=[
                        Item("Arroz branco cozido", "40g", "3 colheres de sopa rasas"),
                        Item("Feijao carioca", "80g", "meia concha cheia"),
                        Item("Peito de frango grelhado", "90g", "1 file medio"),
                        Item("Abobora refogada", "100g"),
                        Item("Vegetais a escolha", "a vontade", "ou mais"),
                    ],
                    sobremesa="Sobremesa: mexerica - 1 unidade OU 1 Sonho de Valsa (140 kcal)",
                ),
            ],
        ),
        Refeicao(
            titulo="Lanche da tarde",
            horario="16h00",
            opcoes=[
                Opcao(
                    rotulo="OPCAO 1",
                    itens=[
                        Item("Iogurte natural desnatado", "170g", "1 pote"),
                        Item("Granola sem acucar", "20g", "2 colheres de sopa"),
                        Item("Morango", "80g", "5 unidades"),
                    ],
                ),
                Opcao(
                    rotulo="OPCAO 2 (panqueca de banana)",
                    itens=[
                        Item("Banana", "100g", "1 unidade"),
                        Item("Ovo", "2 unidades"),
                        Item("Aveia em flocos", "20g", "2 colheres de sopa"),
                        Item("Canela", "a gosto"),
                        Item("Pasta de amendoim integral", "5g", "1 colher de cha por cima"),
                    ],
                    nota="Bate tudo no liquidificador, frita em frigideira antiaderente. Finaliza com a pasta.",
                ),
            ],
        ),
        Refeicao(
            titulo="Pre-treino",
            horario="17h30",
            dica="Tomar 30-45 min antes de treinar. Carbo simples + cafeina ajudam.",
            opcoes=[
                Opcao(
                    rotulo="OPCAO 1",
                    itens=[
                        Item("Banana", "100g", "1 unidade"),
                        Item("Cafe preto", "a vontade"),
                    ],
                ),
                Opcao(
                    rotulo="OPCAO 2",
                    itens=[
                        Item("Pao frances", "50g", "1 unidade"),
                        Item("Geleia diet", "15g", "1 colher de sopa"),
                        Item("Cafe preto", "a vontade"),
                    ],
                ),
            ],
        ),
        Refeicao(
            titulo="Pos-treino (shake)",
            horario="19h30",
            opcoes=[
                Opcao(
                    rotulo="UNICA",
                    itens=[
                        Item("Whey protein concentrado", "30g", "1 dose"),
                        Item("Agua gelada", "300ml"),
                        Item("Creatina monohidratada", "5g", "1 colher de cha"),
                    ],
                    nota="Tomar logo apos o treino. Creatina pode ir junto - nao precisa horario sagrado.",
                ),
            ],
        ),
        Refeicao(
            titulo="Jantar",
            horario="20h30",
            opcoes=[
                Opcao(
                    rotulo="OPCAO 1 (hamburguer caseiro)",
                    itens=[
                        Item("Pao de hamburguer integral", "50g", "1 unidade"),
                        Item("Patinho cru moido", "110g", "pesar antes da AirFryer"),
                        Item("Mucarela", "15g", "1 fatia fina"),
                        Item("Ketchup OU mostarda OU barbecue", "10g", "max 3 opcoes a escolha"),
                        Item("Salada variada", "a vontade"),
                    ],
                    sobremesa="Sobremesa: mexerica - 1 unidade",
                    nota="Congela tudo e deixa como estoque.",
                ),
                Opcao(
                    rotulo="OPCAO 2 (pizza de Rap 10)",
                    itens=[
                        Item("Rap 10", "1 unidade"),
                        Item("Frango desfiado caseiro", "80g"),
                        Item("Mucarela", "20g"),
                        Item("Molho de tomate natural", "2 colheres de sopa"),
                        Item("Tomate, oregano, salada", "a vontade"),
                    ],
                    sobremesa="Sobremesa: morango - 80g",
                    nota="Leve na AirFryer pra ficar crocante.",
                ),
                Opcao(
                    rotulo="OPCAO 3 (tradicional)",
                    itens=[
                        Item("Arroz branco cozido", "40g", "3 colheres de sopa rasas"),
                        Item("Feijao carioca", "80g", "meia concha cheia"),
                        Item("Peito de frango grelhado", "90g", "1 file medio"),
                        Item("Tomate e pepino", "100g"),
                        Item("Salada de folhas", "a vontade"),
                    ],
                    sobremesa="Sobremesa: mamao - 100g",
                ),
            ],
        ),
    ]

    macros = [
        MacrosLinha("TOTAL DIARIO", "1.900 kcal", "232g", "124g", "38g", "15g", "30g"),
        MacrosLinha("% do VCT", "100%", "49%", "26%", "18%", "7%", "-"),
    ]

    return Dieta(
        aluna="Aluna Teste Padrao",
        fase="Cutting (DEFINICAO)",
        data="12 de maio de 2026",
        recomendacao=(
            "Vegetais ao menos no almoco e jantar. Pesar os alimentos pesados crus "
            "(antes de cozinhar) quando indicado. Nao trocar alimentos sem consultar - "
            "se precisar substituir, manda no WhatsApp que ajustamos. Pode acompanhar "
            "qualquer bebida zero. Pode trocar a fruta da sobremesa do almoco por um "
            "doce de 100-150 calorias (Trento, Ouro Branco, Sonho de Valsa)."
        ),
        hidratacao=(
            "500 ml de agua em jejum logo ao acordar. Meta diaria: 2,5 L de agua."
        ),
        refeicoes=refeicoes,
        refeicao_livre=(
            "1 refeicao livre por semana, sempre com contencao de danos. "
            "Modera no doce, modera no fritura. Alcool conta por 2 - se beber, "
            "ja conta como a livre da semana. Refeicao livre nao e dia livre."
        ),
        observacoes=[
            "Suplementos: whey concentrado 30g pos-treino, creatina 5g/dia (junto do whey ou em qualquer refeicao com agua).",
            "Treino: 4x/semana, forca. Mantenha a serie de gluteos pesada.",
            "Sono: minimo 7h. Sono curto trava resultado mesmo com dieta certa.",
            "Se aparecer fome real entre refeicoes na primeira semana: cha morno + 1 fruta extra. Avisa no WhatsApp se persistir.",
        ],
        macros=macros,
    )


# -------------------- Render HTML/CSS -------------------------------------- #

LOGO_SVG = """
<svg viewBox="0 0 480 96" xmlns="http://www.w3.org/2000/svg">
  <text x="20" y="62" font-family="Georgia, serif" font-size="58"
        font-weight="900" fill="#1b5e20">B</text>
  <text x="78" y="58" font-family="Georgia, serif" font-size="36"
        font-weight="700" fill="#1b5e20" letter-spacing="2">BRENO XAVIER</text>
  <text x="78" y="84" font-family="Helvetica, Arial, sans-serif" font-size="14"
        font-weight="600" fill="#4caf50" letter-spacing="6">TREINO E NUTRICAO</text>
  <line x1="80" y1="66" x2="430" y2="66" stroke="#4caf50" stroke-width="1.2"/>
</svg>
""".strip()


CSS_BASE = """
@page {
  size: A4;
  margin: 18mm 16mm 22mm 16mm;
  @bottom-center {
    content: "@brenoxavieer_  ·  31 9 7262-8289  ·  www.brenoxavier.com.br";
    font-family: Helvetica, Arial, sans-serif;
    font-size: 9pt;
    color: #1b5e20;
  }
}

* { box-sizing: border-box; }

body {
  font-family: Helvetica, Arial, sans-serif;
  color: #111;
  font-size: 10.5pt;
  line-height: 1.45;
}

.logo {
  text-align: center;
  margin-bottom: 6mm;
}
.logo svg {
  height: 22mm;
  width: auto;
}

h1.titulo {
  font-family: Georgia, "Playfair Display", serif;
  font-size: 22pt;
  font-weight: 700;
  color: #1b5e20;
  text-align: center;
  margin: 0 0 2mm 0;
  letter-spacing: 0.5px;
}

p.subtitulo {
  text-align: center;
  font-size: 9.5pt;
  color: #555;
  margin: 0 0 6mm 0;
}

.recomendacao {
  text-align: justify;
  margin: 0 0 4mm 0;
  font-size: 10pt;
}
.recomendacao .lbl {
  color: #e65100;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.hidratacao {
  background: #f0f5ea;
  border-left: 3px solid #1b5e20;
  padding: 3mm 4mm;
  margin: 0 0 5mm 0;
  font-size: 10pt;
}
.hidratacao .lbl {
  color: #1b5e20;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.refeicao {
  margin: 0 0 5mm 0;
  page-break-inside: avoid;
}
.refeicao h2 {
  font-family: Helvetica, Arial, sans-serif;
  font-size: 13pt;
  font-weight: 700;
  color: #1b5e20;
  margin: 0 0 1mm 0;
  padding-bottom: 1mm;
  border-bottom: 1px solid #111;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.refeicao .horario {
  font-size: 10pt;
  font-weight: 400;
  color: #555;
  text-transform: none;
  letter-spacing: 0;
  margin-left: 4px;
}
.refeicao .dica {
  font-size: 9pt;
  color: #555;
  font-style: italic;
  margin: 1mm 0 2mm 0;
}

.opcao {
  margin: 2mm 0 3mm 0;
}
.opcao .rotulo {
  font-size: 10pt;
  font-weight: 700;
  color: #1b5e20;
  margin-bottom: 1mm;
}
.opcao .nota {
  font-size: 9pt;
  color: #555;
  font-style: italic;
  margin-top: 1mm;
}
.opcao .sobremesa {
  font-size: 10pt;
  margin-top: 1mm;
}
.opcao .sobremesa .lbl {
  font-weight: 700;
  color: #1b5e20;
}

.itens {
  background: #f0f5ea;
  border-radius: 2px;
  padding: 2mm 3mm;
}
.itens .item {
  padding: 0.8mm 0;
}
.itens .item + .item {
  border-top: 1px dotted #c5d6b3;
}

.livre {
  margin: 5mm 0 4mm 0;
  background: #fff8f0;
  border-left: 3px solid #e65100;
  padding: 3mm 4mm;
  font-size: 10pt;
}
.livre .lbl {
  color: #e65100;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.observacoes h3 {
  font-size: 11pt;
  font-weight: 700;
  color: #1b5e20;
  margin: 4mm 0 2mm 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.observacoes ul {
  margin: 0;
  padding-left: 5mm;
}
.observacoes li {
  margin-bottom: 1mm;
  font-size: 10pt;
}

.macros {
  margin-top: 5mm;
}
.macros h3 {
  font-size: 11pt;
  font-weight: 700;
  color: #1b5e20;
  margin: 0 0 2mm 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.macros table {
  width: 100%;
  border-collapse: collapse;
  font-size: 9.5pt;
}
.macros th, .macros td {
  padding: 2mm 3mm;
  text-align: center;
  border: 1px solid #c5d6b3;
}
.macros th {
  background: #1b5e20;
  color: white;
  font-weight: 700;
}
.macros tr.total td {
  background: #f0f5ea;
  font-weight: 700;
}
.macros tr.percent td {
  background: #ffffff;
  font-weight: 600;
  color: #1b5e20;
}
.macros td.label {
  text-align: left;
}
"""


def html_escape(s: str) -> str:
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def render_refeicao(r: Refeicao) -> str:
    parts = [f'<section class="refeicao">']
    parts.append(
        f'<h2>{html_escape(r.titulo)} <span class="horario">- {html_escape(r.horario)}</span></h2>'
    )
    if r.dica:
        parts.append(f'<div class="dica">{html_escape(r.dica)}</div>')
    for op in r.opcoes:
        parts.append('<div class="opcao">')
        parts.append(f'<div class="rotulo">{html_escape(op.rotulo)}</div>')
        parts.append('<div class="itens">')
        for it in op.itens:
            parts.append(f'<div class="item">{html_escape(it.render())}</div>')
        parts.append("</div>")
        if op.sobremesa:
            parts.append(
                f'<div class="sobremesa"><span class="lbl">{html_escape(op.sobremesa)}</span></div>'
            )
        if op.nota:
            parts.append(f'<div class="nota">{html_escape(op.nota)}</div>')
        parts.append("</div>")
    parts.append("</section>")
    return "\n".join(parts)


def render_html(d: Dieta) -> str:
    refeicoes_html = "\n".join(render_refeicao(r) for r in d.refeicoes)
    obs_html = "\n".join(f"<li>{html_escape(o)}</li>" for o in d.observacoes)

    macros_rows = []
    macros_rows.append(
        '<tr><th class="label">Linha</th><th>kcal</th><th>Carbo</th>'
        '<th>Proteina</th><th>Gord. insat.</th><th>Gord. sat.</th><th>Fibra</th></tr>'
    )
    for i, m in enumerate(d.macros):
        cls = "total" if i == 0 else "percent"
        macros_rows.append(
            f'<tr class="{cls}"><td class="label">{html_escape(m.nome)}</td>'
            f"<td>{html_escape(m.kcal)}</td><td>{html_escape(m.carbo)}</td>"
            f"<td>{html_escape(m.proteina)}</td><td>{html_escape(m.gord_insat)}</td>"
            f"<td>{html_escape(m.gord_sat)}</td><td>{html_escape(m.fibra)}</td></tr>"
        )

    return f"""<!DOCTYPE html>
<html lang="pt-br">
<head><meta charset="utf-8"><title>{html_escape(d.aluna)} - Dieta</title></head>
<body>
  <div class="logo">{LOGO_SVG}</div>
  <h1 class="titulo">{html_escape(d.aluna)} - {html_escape(d.fase)}</h1>
  <p class="subtitulo">Plano alimentar - {html_escape(d.data)}</p>

  <p class="recomendacao">
    <span class="lbl">Recomendacao:</span> {html_escape(d.recomendacao)}
  </p>

  <div class="hidratacao">
    <span class="lbl">Hidratacao:</span> {html_escape(d.hidratacao)}
  </div>

  {refeicoes_html}

  <div class="livre">
    <span class="lbl">Refeicao livre:</span> {html_escape(d.refeicao_livre)}
  </div>

  <section class="observacoes">
    <h3>Observacoes</h3>
    <ul>{obs_html}</ul>
  </section>

  <section class="macros">
    <h3>Resumo nutricional</h3>
    <table>
      {''.join(macros_rows)}
    </table>
  </section>
</body>
</html>
"""


def gerar_pdf(d: Dieta, out_path: str) -> None:
    html = render_html(d)
    HTML(string=html).write_pdf(out_path, stylesheets=[CSS(string=CSS_BASE)])


# -------------------- CLI -------------------------------------------------- #

def main() -> int:
    if len(sys.argv) > 1:
        with open(sys.argv[1], encoding="utf-8") as f:
            raw = json.load(f)
        d = Dieta(**raw)  # estrutura tem que bater (uso futuro)
        out = os.path.splitext(sys.argv[1])[0] + ".pdf"
    else:
        d = dieta_aluna_teste()
        out = "data/aluna-teste/dieta-2026-05-12.pdf"

    os.makedirs(os.path.dirname(out), exist_ok=True)
    gerar_pdf(d, out)
    print(f"PDF gerado: {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
