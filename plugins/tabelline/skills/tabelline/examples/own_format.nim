## Formats of your own: plain text (escaped in HTML), HTML for the HTML renderer only, Markdown
## cells, and two HTML-only workarounds (an indented stub, rotated labels).
## Run: nim r --hints:off own_format.nim
import std/strutils
import tabelline, tabelline/datasets

let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
  # plain text: escaped in HTML, the same in text and Markdown
  fmt "moons", proc (v: Value): string = repeat("●", min(v.toFloat.int, 5))
  # HTML for the HTML renderer, text for the others
  fmt "rings", proc (v: Value, ctx: RenderContext): string =
    let s = if v.isNull: "" elif v.b: "yes" else: "no"
    if ctx == rcHtml: "<em>" & s & "</em>" else: s
  tabStyle style.css("padding-left: 1.5em"), loc.stub(rows = where(it["type"] != "Terrestrial"))
  tabStyle style.css("writing-mode: vertical-rl"), loc.columnLabels(["moons", "rings"])
echo t
let h = t.toHtml
doAssert "<em>yes</em>" in h and "writing-mode: vertical-rl" in h
