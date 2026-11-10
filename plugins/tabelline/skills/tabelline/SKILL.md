---
name: tabelline
description: Use when making a display table in Nim (a table for people to read, with a title, a stub, row groups, spanners, formatted numbers, colours or footnotes) in a program, a README or a nimib page, or when porting a gt (R) or Great Tables (Python) table to Nim, even if the user never says "tabelline".
metadata:
  status: draft
---

# tabelline

[tabelline](https://github.com/pietroppeter/tabelline) makes display tables in Nim, after R's
gt and Python's Great Tables: a header, a stub, row groups, spanners over columns, formatted
numbers, colours and notes, rendered to HTML, to text and to Markdown. It needs only Nim's
standard library; nimib is used only by `tabelline/nimib` (`nbTable`).

This skill targets **tabelline 0.1.0** (Nim 2.2 or later). Models know gt and Great Tables
well and tabelline not at all, so the fastest way in is the map from gt's names to tabelline's,
[references/from-gt.md](references/from-gt.md). Every verb with its arguments is in
[references/verbs.md](references/verbs.md). When you are not sure of a name, those two files,
then the installed sources (`nimble path tabelline`), are the ground truth: do not guess from gt.

**Bundled files.** `references/` and `examples/` sit next to this file. If they are not there,
read them in [the skills repo](https://github.com/pietroppeter/skills/tree/main/plugins/tabelline/skills/tabelline).

## The idea, in four lines

1. `tabella(data)` makes a table, a `Tabella`: the data (never changed) and a spec of how to show it.
2. Every verb (gt's name in camelCase: `tab_header` is `tabHeader`) takes a `Tabella` and returns a new one.
3. Formats and styles pick their columns and rows when the verb is called, and run when the table is rendered.
4. `echo t` draws it as text, `t.save "t.html"` writes a page, `nbTable t` puts it in a nimib page.

## Workflow

1. **Install it.** tabelline is not in nimble's package list yet, so install it by URL:
   ```sh
   nimble install -y "https://github.com/pietroppeter/tabelline@#v0.1.0"
   ```
   Run that from a folder that is not a nimble project (nimble 0.26, inside a project, installs
   the project's dependencies and skips the package you named). In a nimble project, add
   `requires "https://github.com/pietroppeter/tabelline#v0.1.0"`; with atlas, `atlas use
   https://github.com/pietroppeter/tabelline`. Check with `nimble path tabelline`.
2. **Write the table** with the recipe form, `tabella(data, ...): body` (below).
3. **Look at it as text first**: `echo t` and `nim r --hints:off file.nim`. It is the fastest
   loop and shows almost everything: the parts, the groups, the spanners, the formatted values,
   the footnote marks. It does not show styles and colours, nor superscripts of `md()`.
4. **Then render** what was asked: `t.save "t.html"` (a standalone page), `t.toHtml` (a
   fragment with its own scoped CSS), `t.toMarkdown` (a GitHub table), or `nbTable t`.
5. **Check the HTML** for what text cannot show: `grep` for the colours you set, and for a
   page someone will read, a screenshot (at phone width, 390px, if it will be read on a phone).

## A whole table

```nim
import tabelline, tabelline/datasets

let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets**"), "of the Solar System"
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
  tabSpanner "Size", ["mass", "diameter"]
  fmtNumber "mass", decimals = 3, dropTrailingZeros = true
  fmtInteger "diameter"
  tabFootnote "As of 2024.", loc.columnLabels("moons")
  tabSourceNote "NASA Planetary Fact Sheet"
echo t
```

```text
              The planets
          of the Solar System
┌─────────┬───────┬──────────┬─────────┐
│         │       Size       │         │
│         │  mass │ diameter │ moons^1 │
╞═════════╪═══════╪══════════╪═════════╡
│ Terrestrial                          │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Mercury │  0.33 │    4,879 │       0 │
│ Venus   │  4.87 │   12,104 │       0 │
│ Earth   │  5.97 │   12,756 │       1 │
│ Mars    │ 0.642 │    6,792 │       2 │
├─────────┼───────┼──────────┼─────────┤
│ Gas giant                            │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Jupiter │ 1,898 │  142,984 │      95 │
│ Saturn  │   568 │  120,536 │     146 │
├─────────┼───────┼──────────┼─────────┤
│ Ice giant                            │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Uranus  │  86.8 │   51,118 │      28 │
│ Neptune │   102 │   49,528 │      16 │
└─────────┴───────┴──────────┴─────────┘
1 As of 2024.
NASA Planetary Fact Sheet
```

Each line of the body is a verb without its table: `tabHeader "x"` stands for
`t = t.tabHeader("x")`, inside `for`, `if`, `when` and `block` too. The same table can be
chained instead: `tabella(planets()).tabHeader("The planets").fmtNumber("mass")`. `rownameCol`
makes a column the stub (gt's `rowname_col`), `groupnameCol` groups the rows by a column.

## Data in

- **A seq of objects or named tuples**: one column per field, in field order:
  `tabella(@[(city: "Roma", pop: 2748109)])`.
- **Columns**, with `tableData:`, one `name: [values]` per line; `nil` is a missing value, and a
  column can mix numbers with `nil`. Names may have dots (`size.mass`, for `tabSpannerDelim`)
  or be quoted (`` `mass (kg)` ``); a `for` adds computed columns (`$j: collect(...)`).
- **CSV**: `parseCsv(text)` or `readCsv(path)` (with `sep` and `comment = "#"`); types are
  inferred, empty and `NA` are missing, a column of ints and floats is a float column.
- **Datasets** for examples, in `tabelline/datasets`: `planets()`, `exibble()` (gt's), `tavolaPitagorica(n)`.
- No data-frame interop yet (nanuq, datamancer): build `tableData:` from their columns.

A cell is a `Value` (missing, bool, int, float or string) and compares with plain Nim values:
`it["moons"] > 20`, `it["type"] == "Gas giant"`.

## Picking columns and rows

- **Columns** (`ColSel`): a name `"mass"`, an array `["mass", "diameter"]` or seq, or a rule:
  `everything()`, `numeric()`, `textual()`, `startsWith("d")`, `endsWith`, `containing` (gt's
  `contains()`; `contains` is Nim's `in`).
- **Rows** (`RowSel`): an index, an array `[0, 2]`, a slice `1..3`, or `where(cond)` with `it`
  as the row: `where(it["mass"] > 100 and it["type"] != "Ice giant")`.
  A `Value` is not a string: for a list of names write `where($it["planet"] in ["Saturn", "Jupiter"])`
  (`it["planet"] in [...]` does not compile).
- **Indices are rows of the data, counted from 0, not rows as shown.** After `rowOrder` or
  with groups, `[0]` is still the first row of the data. To mean a row by its content, use `where`.
- A name that is not a column raises a `KeyError` listing the columns there are.

## Formats

`fmtNumber`, `fmtInteger`, `fmtPercent`, `fmtCurrency`, `fmtScientific`, `fmtEngineering`,
`fmtNumberSi`, `fmtBytes`, `fmtDate`, `fmtTime`, `fmtDatetime`, `fmtDuration`, `fmtTf`,
`fmtMarkdown`, `fmtUrl`, `fmtFlag`, ... (all in [references/verbs.md](references/verbs.md)),
then substitutions after them: `subMissing` (missing values blank by default; `subMissing()`
shows an em dash), `subZero`, `subSmallVals`, `subLargeVals`, `subValues`.

- The last format that covers a cell wins.
- A table-wide `locale` sets the marks of every number format: `tabella(data, locale = "it")`
  gives `1.234,5`. Negative numbers get a real minus sign (−).
- Your own format: `fmt "moons", proc (v: Value): string = ...`. Its text is escaped in HTML. To
  write HTML, take the renderer too: `proc (v: Value, ctx: RenderContext): string` and return
  HTML when `ctx == rcHtml`; or write Markdown in the cells and use `fmtMarkdown`.

## Styles and options

- **Styles at locations**: `tabStyle style.fill("#FFF3B0") & style.text(weight = "bold"),
  loc.body(cols = "mean_temp", rows = where(it["mean_temp"] > 100))`. Styles are `style.fill`,
  `style.text(color, font, size, align, weight, style, ...)`, `style.borders(...)`,
  `style.css("any: css")`, joined with `&`. Locations are Great Tables' `loc.*` in camelCase:
  `loc.title()`, `loc.columnLabels(cols)`, `loc.spanners(labels)`, `loc.stub(rows)`,
  `loc.rowGroups(groups)`, `loc.body(cols, rows)` (data cells only; the stub is `loc.stub`),
  `loc.footer()`, and `loc.header()`, `loc.columnHeader()` for whole parts.
- **Colour by value**: `dataColor "pop", palette = palette("blues")`: numbers along the palette
  (`domain = (lo, hi)`, a high-to-low domain reverses it), text by category, the text colour
  kept readable. Palettes: `blues`, `rdbu`, `viridis`, `pastelli`, `quaderno`, ..., or
  `@["#FFFFFF", "#1F4E99"]`.
- **Options**: `tabOptions(rowStriping = true, tableFontSize = "14px")` sets any option by name
  (checked when compiling); presets `optRowStriping`, `optStylize(style, color)`,
  `optAllCaps`, `optTableFont`, `optTableLines("none")`, `optTableOutline`, `optFootnoteMarks("letters")`, `optCss`.
- **A table on a styled page**: `optCssTheme()` takes every colour and the font from the page's
  CSS variables `--ink`, `--paper`, `--line`, `--shade`, `--primary`, `--font` (black on white
  without them). Map them to the page's own: `optCssTheme(ink = "--text", paper = "--bg")`.
  Prefer it to hard-coded colours on any page that has a theme: the table follows the page,
  in light and dark.

## In a nimib page

```nim
import nimib except md   # nimib 0.4.x has its own `md`: drop `except md` from nimib 0.5
import tabelline, tabelline/[nimib, datasets]

nbInit
nb.title = "Moons"
nbText: "## Who has the most moons"
nbCode:
  let t = tabella(planets(), rownameCol = "planet"):
    colsHide everything()
    colsUnhide "moons"
    rowOrder "moons", reverse = true
    optCssTheme()
nbTable t
nbSave
```

- `nbTable t` is the block for a table. Do not write `nbRawHtml t.toHtml`: `nbTable` also keeps
  the table's Markdown, so the same page renders with `nbInitMd` (a README.md), and it is not
  raw HTML in a page.
- **`Error: ambiguous call; both boost.md(s: string) ... and core.md(s: string)`**: nimib 0.4.x
  exports a deprecated `md` template. Import `nimib except md`; nimib 0.5 removed it.
- Build in the code block (`nbCode:`) when the reader should see how the table is made, and
  outside it when only the table matters.
- Follow the nimib skills for the rest of the page (the **nimib-blocks** skill: no HTML, CSS or
  colours in a page; a colour in a table on a themed page is a CSS variable, as `optCssTheme` does).

## Coming from gt or Great Tables

Read [references/from-gt.md](references/from-gt.md) before porting. The rules that cover most of it:

- Verbs: snake_case to camelCase (`fmt_number` → `fmtNumber`, `cols_label` → `colsLabel`,
  `opt_stylize` → `optStylize`). Locations and styles are Great Tables' `loc.*` and `style.*`
  (gt's `cells_body()` is `loc.body()`, `cell_fill()` is `style.fill()`).
- Columns are strings: R's `c(mass, diameter)` and Python's `["mass", "diameter"]` are
  `["mass", "diameter"]`; tidyselect helpers are `ColSel` rules; a row expression (`rows = mass > 100`)
  is `where(it["mass"] > 100)`. Sizes are strings: `px(12)` is `"12px"`.
- `colsLabel {"mass": "Mass"}`: all labels plain strings, or all `md(...)` (mixing them in one
  list does not compile: `type mismatch: got '(string, Text)'`).
- **Not everything is there in 0.1** (summary rows, merged columns, `rows_add`, `cols_align_decimal`,
  stub indent, nanoplots, images, units, LaTeX/Word/PNG output). When a table needs one, say so
  plainly, use the workaround in from-gt.md if there is one, and never drop it silently.

## Mistakes to avoid

- A verb outside a body returns a new table: `t.tabHeader("x")` alone changes nothing (Nim
  refuses an unused value); write `let t2 = t.tabHeader("x")`, or use the body.
- In a `tabella(...): body`, *every* call statement is read as a verb on the table, except
  `echo`, `discard`, `doAssert`, `assert`: call other procs outside the body, or in a `let`.
- Two spanners of one level must not overlap (`ValueError`); put the higher one at `level = 2`.
- In a grouped table, give every row a group. A row whose `groupnameCol` is missing is shown first, above the groups, and tabelline 0.1.0 also repeats it inside the group of the row above it in the data (a bug).
- Footnote marks are numbered in reading order of their places, not in the order you added them.
- `echo` does not show styles and colours: check the HTML for those.

## Before you finish

- The program compiles and runs; you looked at `echo t`.
- The HTML (or Markdown, or the nimib page) was written and you checked what text cannot show.
- Every gt or Great Tables feature you could not port is named in your reply.
