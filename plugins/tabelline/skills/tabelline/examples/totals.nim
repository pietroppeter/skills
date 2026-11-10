## A table with a total row, money in euros, Italian number marks and a colour scale:
## the workaround for gt's grand_summary_rows() until tabelline 0.2 has summary rows.
## Run: nim r --hints:off totals.nim   (prints the text table, writes totals.html)
import std/[os, sequtils, strformat]
import tabelline

type Sale = object
  region, quarter: string
  revenue: float
  share: float

var sales = @[
  Sale(region: "Nord", quarter: "Q1", revenue: 120_500.0, share: 0.41),
  Sale(region: "Centro", quarter: "Q1", revenue: 80_250.5, share: 0.27),
  Sale(region: "Sud", quarter: "Q1", revenue: 93_000.0, share: 0.32),
]
# The total is computed in Nim and added as a row of the data.
sales.add Sale(region: "Total", quarter: "Q1", revenue: sales.mapIt(it.revenue).foldl(a + b),
               share: sales.mapIt(it.share).foldl(a + b))

let t = tabella(sales, rownameCol = "region", locale = "it"):
  tabHeader md("**Sales** by region"), &"quarter {sales[0].quarter}"
  colsHide "quarter"
  colsLabel {"revenue": "Revenue", "share": "Share"}
  fmtCurrency "revenue", currency = "EUR", decimals = 0
  fmtPercent "share", decimals = 0
  dataColor "revenue", rows = where(it["region"] != "Total"), palette = palette("blues"),
    domain = (0.0, 150_000.0)
  tabStyle style.text(weight = "bold") & style.borders({sTop}, color = "#333333", weight = "2px"),
    loc.body(rows = where(it["region"] == "Total")), loc.stub(rows = where(it["region"] == "Total"))
  optStylize(1, "gray")
echo t
t.save currentSourcePath().changeFileExt("html")
