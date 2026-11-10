## A nimib page with a table that takes its colours from the page (optCssTheme). The same
## source makes a README with nimib's Markdown backend: nbTable keeps the table's Markdown too.
## Run: nim r --hints:off -d:nimibQuiet page.nim               (writes page.html)
##      nim r --hints:off -d:nimibQuiet -d:mdOutput page.nim   (writes page.md)
import nimib except md   # nimib 0.4.x has its own `md`: drop `except md` from nimib 0.5
import tabelline, tabelline/[nimib, datasets]

proc moonsTable(): Tabella =
  tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader md("The **moons**"), "of the eight planets"
    colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
    rowOrder "moons", reverse = true
    tabSourceNote "NASA Planetary Fact Sheet"
    optCssTheme()

when defined(mdOutput):
  nbInitMd
else:
  nbInit
nb.title = "Moons of the planets"
nbText: """
# Moons of the planets

Saturn has the most moons, and the giants have almost all of them.
"""
nbCode:
  let t = moonsTable()
nbTable t
nbSave
