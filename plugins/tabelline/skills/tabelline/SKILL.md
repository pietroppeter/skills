---
name: tabelline
description: Use when making a display table in Nim (a table for people to read, with a title, a stub, row groups, spanners, formatted numbers, colours, summary rows or nanoplots) in a program, a README or a nimib page, or when porting a gt (R) or Great Tables (Python) table to Nim, even if the user never says "tabelline".
metadata:
  status: draft
---

# tabelline

[tabelline](https://github.com/pietroppeter/tabelline) makes display tables in Nim after R's gt
and Python's Great Tables. This skill targets **0.2**. It holds only what tabelline's own docs do
not: where they are, how to work, and the traps agents met. Look names up there.

## Where the docs are

- **[llms.txt](https://pietroppeter.github.io/tabelline/llms.txt)**: the map, plain text.
- **[api.md](https://pietroppeter.github.io/tabelline/api.md)**: the whole API in one Markdown
  file. Read its first ~450 lines (an index, one line per name, with gt's name), then grep for
  what you need: a tabelline name (`### fmtNumber`) or a gt / Great Tables name (`fmt_number`).
  Each entry has the signatures, the doc comment and an example with what it prints.
- Offline: the doc comments in the installed sources (`nimble path tabelline`) are the same text.

Most of gt and Great Tables is there in 0.2, under the same names in camelCase (`summary_rows`
is `summaryRows`, `cells_body()` is `loc.body()`, `cell_fill()` is `style.fill()`). Before
writing a workaround, grep api.md for the gt name. What is missing is in the feature map,
[gt.json](https://pietroppeter.github.io/tabelline/coverage/gt.json) (`status` not `done`).

## Install

Not in nimble's package list. From a folder that is not a nimble project (inside one, nimble
0.26 skips the package you name):

```sh
nimble install -y "https://github.com/pietroppeter/tabelline@#v0.2.0"
```

## Work like this

1. Write the table as a recipe, one verb per line, then `echo t` and run
   (`nim r --hints:off t.nim`). Text shows the parts, groups, formats, summary rows and
   nanoplots (as sparklines); not styles, colours or superscripts.
2. Then write what was asked: `t.save "t.html"` (a page), `t.toHtml`, `t.toMarkdown`, or
   `nbTable t` in nimib, and grep the HTML for the colours and styles you set.

```nim
import tabelline, tabelline/datasets

let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets**")
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
  colsLabel:
    moons: md("*moons*")
  summaryRows:
    total: agg.sum
    columns = "moons"
echo t
```

```text
    The planets
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury │     0 │
│ Venus   │     0 │
│ Earth   │     1 │
│ Mars    │     2 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │     3 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │    95 │
│ Saturn  │   146 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │   241 │
├─────────┼───────┤
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │    44 │
└─────────┴───────┘
```

## Traps agents met

- **`md` with nimib 0.4.3** (the released nimib): `import nimib` and tabelline give
  `ambiguous call; both boost.md ... and core.md`. Write `import nimib except md`.
- **Rows are rows of the data, from 0, not rows as shown.** After `rowOrder`, `rows = [0]` is
  still the first row of the data. For the first rows as shown, build the table, then take
  `t.displayOrder()[0 .. 2]` and style those rows (`t = t.tabStyle(..., loc.body(rows = top))`),
  so the shading follows the data; do not write the names or a threshold by hand. To mean rows by
  content, `where(...)`.
- **A cell is a `Value`, not a string**: `where(it["planet"] in ["Saturn", "Jupiter"])` does not
  compile; write `where($it["planet"] in ["Saturn", "Jupiter"])`. Comparisons with numbers and
  strings work as they are (`it["moons"] > 20`, `it["type"] == "Ice giant"`).
- **A verb outside the recipe returns a new table**: `t.tabHeader("x")` alone changes nothing.
  Inside the recipe every call is read as a verb, except `echo`, `discard` and asserts.
- **A list of pairs is a block in the recipe** (`colsLabel:`, `summaryRows:`, `colsWidth:`), one
  pair per line, and there a `fmtNumber(decimals = 0)` line formats the summary cells.
- **Colours on a styled page**: `optCssTheme()` takes them from the page's CSS variables
  (`--ink`, `--paper`, ...), so in a nimib page with a theme write no hex values.

## Before you finish

The program ran and you read `echo t`; the output asked for exists and holds the styles you set;
every feature of a gt or Great Tables table you could not port is named in your reply, after a
grep of api.md for its gt name.
