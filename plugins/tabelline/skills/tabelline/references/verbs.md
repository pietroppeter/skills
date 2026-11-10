# tabelline 0.1.0: every verb

Read from `src/tabelline/` at tag v0.1.0. Every verb takes the table first (`t: sink Tabella`,
left out below) and returns a new `Tabella`. `ColSel` is a column selection (a name, an array or
seq of names, or `everything()`, `numeric()`, `textual()`, `startsWith(s)`, `endsWith(s)`,
`containing(s)`); `RowSel` is a row selection (an index, an array or seq of indices, a slice, or
`where(cond)` with `it` the row); `allRows()` is every row. `Text` is a plain string, `md(s)`
(inline Markdown: `**b**`, `*i*`, `` `c` ``, links, `^sup^`, `~sub~`) or `html(s)`.

The full docs, with an example for every requirement: the
[specs page](https://pietroppeter.github.io/tabelline/specs/) and the
[Guide](https://pietroppeter.github.io/tabelline/explainer/).

## Making a table

| Call | Notes |
|---|---|
| `tabella(data, rownameCol = "", groupnameCol = "", id = "", locale = "")` | `data`: a `TableData` or an `openArray` of objects or named tuples. With a body, `tabella(data, ...): body` applies one verb per line. |
| `tableData: name: [values] ...` | Columns; `nil` is missing; dotted or quoted names; `for`/`if` lines; `$j: [...]` or `(expr): [...]` for computed names. |
| `parseCsv(text, sep = ',', comment = "")`, `readCsv(path, sep = ',', comment = "")` | Header row; ints, floats, bools inferred; empty and `NA` missing. |
| `toTableData(rows)`, `d.addColumn(name, toValues(xs))` | Build data by hand. `d.nrows`, `d.ncols`, `d.names`. |
| `planets()`, `exibble()`, `tavolaPitagorica(n)` | `import tabelline/datasets`. |

## Parts

| Verb | gt / Great Tables |
|---|---|
| `tabHeader(title: Text, subtitle: Text = "")` | `tab_header` |
| `tabStubhead(label)` | `tab_stubhead` |
| `tabSpanner(label, columns: ColSel, level = 1)` | `tab_spanner` (no overlap within a level) |
| `tabSpannerDelim(delim = ".", columns = everything(), split = "last", limit = -1, reverse = false)` | `tab_spanner_delim` |
| `tabRowGroup(label, rows: RowSel, id = "")` | `tab_row_group` |
| `tabFootnote(note, locations: varargs[Loc])` | `tab_footnote`; no location: a note without a mark |
| `tabSourceNote(note)` | `tab_source_note` |
| `tabCaption(caption)` | `tab_caption` |
| `rmHeader()`, `rmStubhead()`, `rmCaption()`, `rmSpanners(spanners = [], levels = [])`, `rmFootnotes(indices = [])`, `rmSourceNotes(indices = [])` | `rm_*`; indices from 0 in the order added |

## Columns and rows

| Verb | Notes |
|---|---|
| `colsLabel(column, label)`, `colsLabel({"a": "A", ...})`, `colsLabel({"a": md("A"), ...})` | all plain or all `md()` in one list |
| `colsLabelWith(columns = everything(), fn: proc (s: string): string)` | |
| `colsAlign(align: Align, columns = everything())` | `alAuto`, `alLeft`, `alCenter`, `alRight` |
| `colsWidth({"a": "120px", ...})` | |
| `colsHide(columns)`, `colsUnhide(columns)` | |
| `colsMove(columns, after: string)`, `colsMoveToStart(columns)`, `colsMoveToEnd(columns)`, `colsReorder(columns)` | |
| `rowOrder(columns, reverse = false)` | within groups; missing last |
| `rowGroupOrder(groups: openArray[string])` | the others after, as they were |

## Formats and substitutions

All take `columns` and `rows = allRows()`. Where `columns` has a default, it is `numeric()`.

| Verb | Arguments after `columns, rows` |
|---|---|
| `fmtNumber` | `decimals = 2, dropTrailingZeros = false, useSeps = true, scaleBy = 1.0, compact = false, pattern = "{x}", forceSign = false, locale = "", sepMark = "", decMark = ""` |
| `fmtInteger` | `useSeps = true, scaleBy = 1.0, pattern = "{x}", locale = "", sepMark = ""` |
| `fmtPercent` | `decimals = 1, scaleValues = true, locale = ""` (0.123 is 12.3%) |
| `fmtCurrency` | `currency = "USD", decimals = -1, placement = "left", locale = ""` (USD EUR GBP JPY CHF CNY INR BRL KRW ITL) |
| `fmtScientific`, `fmtEngineering` | `decimals = 2, locale = ""` |
| `fmtNumberSi` | `unit = "", decimals = 2, inclSpace = true, locale = ""` |
| `fmtPartsper` | `toUnits = "per-mille", decimals = 2, scaleValues = true, inclSpace = "auto", locale = ""` |
| `fmtBytes` | `standard = "decimal", decimals = 1, inclSpace = true, locale = ""` |
| `fmtRoman` | `upper = true` |
| `fmtIndex` | `upper = true, indexAlgo = "repeat"` |
| `fmtSpelledNum` | (English, 0 to 100) |
| `fmtDate` | `dateStyle = "iso"`: `iso`, `wday_month_day_year`, `month_day_year`, `day_month_year`, `day_m_year`, `m_day_year`, `year_month`, `dd/mm/yyyy`, `mm/dd/yyyy`, or a std/times pattern |
| `fmtTime` | `timeStyle = "iso"`: `iso`, `iso-short`, `h_m_s_p`, `h_m_p`, `h_p`, `h_m`, `h_m_s` |
| `fmtDatetime` | `dateStyle = "iso", timeStyle = "iso", sep = " "` |
| `fmtDuration` | `inputUnits = "seconds", outputUnits = [], durationStyle = "narrow", trimZeroUnits = true, maxOutputUnits = 0` |
| `fmtTf` | `tfStyle = "check-mark", trueText = "", falseText = "", naText = "", colors = [], html = false` (styles `true-false`, `yes-no`, `up-down`, `check-mark`, `circles`, `squares`, `diamonds`, `arrows`, `triangles`, `triangles-lr`) |
| `fmtMarkdown` | cells read as inline Markdown |
| `fmtUrl`, `fmtEmail` | `label = "", asButton = false, color = "", target = "", showUnderline = true` |
| `fmtFlag` | `sep = " ", useTitle = true` (two-letter codes as emoji flags) |
| `fmt(columns, fn: proc (v: Value): string, rows)` | your text, escaped in HTML |
| `fmt(columns, fn: proc (v: Value, ctx: RenderContext): string, rows)` | `ctx` is `rcHtml`, `rcText` or `rcMarkdown`: return HTML for `rcHtml` |
| `subMissing` | `missingText = "—"` (default columns: `everything()`) |
| `subZero` | `zeroText = "nil"` |
| `subSmallVals` | `threshold = 0.01, smallPattern = "<{x}", sign = "+"` |
| `subLargeVals` | `threshold = 1e12, largePattern = ">={x}", sign = "+"` |
| `subValues` | `values = [...]` or `fn = proc (v: Value): bool`, then `replacement` |
| `textTransform(fn, locations)`, `textReplace(pattern, replacement, locations)`, `textCaseMatch(cases, default = "", replace = "all", locations)` | change the shown text of any location |

Every format has a public value function too, for use outside a table: `formatNumber`,
`formatPercent`, `formatCurrency`, `formatBytes`, `formatDate`, `formatDuration`, ...

## Styles, colours and options

| Call | Notes |
|---|---|
| `tabStyle(style, locations: varargs[Loc])` | `style.fill(color)`, `style.text(color, font, size, align, weight, style, decorate, transform, whitespace)`, `style.borders(sides = {sTop, sRight, sBottom, sLeft}, color, style = "solid", weight = "1px")`, `style.css("decl: v; ...")`, joined with `&` |
| locations | `loc.title()`, `loc.subtitle()`, `loc.header()`, `loc.stubhead()`, `loc.columnHeader()`, `loc.columnLabels(cols = everything())`, `loc.spanners(labels...)`, `loc.stub(rows = allRows())`, `loc.rowGroups(groups...)`, `loc.body(cols = everything(), rows = allRows())`, `loc.footer()`, `loc.footnotes()`, `loc.sourceNotes()` |
| `dataColor(columns = numeric(), rows, palette = palette("blues"), domain = (NaN, NaN), reverse = false, naColor = "#F0F0F0", autoColorText = true, apply = "fill")` | `apply = "text"` colours the text |
| `palette(name)` | `pastelli`, `viridis`, `blues`, `reds`, `greens`, `rdbu`, `rdylgn`, `quaderno`, `matite`, or `"#fff,#000"` |
| `tabOptions(name = value, ...)` | any field of `TabOptions` (below), checked at compile time |
| `optRowStriping(on = true)`, `optAlignTableHeader(align = "left")`, `optAllCaps(on = true)`, `optTableFont(font)`, `optStylize(style = 1, color = "blue")` | gt's presets (`optStylize`: styles 1 to 3; colours blue, cyan, pink, green, red, gray) |
| `optCssTheme(ink = "--ink", paper = "--paper", line = "--line", shade = "--shade", primary = "--primary", font = "--font")`, `cssTheme(...)` | colours from the page's CSS variables; an argument not starting with `--` is a value |
| `optVerticalPadding(scale = 1.0)`, `optHorizontalPadding(scale = 1.0)`, `optTableOutline(style = "solid", width = "3px", color = "#D3D3D3")`, `optTableLines(extent = "default")` | `extent`: `all`, `none`, `default` |
| `optFootnoteMarks(marks)`, `optFootnoteSpec(specRef = "^", specFtr = "^")`, `optFootnoteOrder(order = "marks_first")` | marks: `numbers`, `letters`, `LETTERS`, `standard`, `extended`, or your list |
| `optCss(css, add = true)` | CSS scoped to the table |

`TabOptions` fields: tableWidth tableMarginLeft tableMarginRight tableFontNames tableFontSize
tableFontColor tableBackgroundColor tableBorderTopColor tableBorderTopWidth tableBorderTopStyle
tableBorderBottomColor tableBorderBottomWidth tableBorderBottomStyle tableBorderLeftStyle
tableBorderLeftWidth tableBorderLeftColor tableBorderRightStyle tableBorderRightWidth
tableBorderRightColor headingAlign headingBackgroundColor headingTitleFontSize
headingTitleFontWeight headingSubtitleFontSize headingSubtitleFontWeight headingBorderBottomColor
headingPadding headingPaddingHorizontal columnLabelsBackgroundColor columnLabelsFontSize
columnLabelsFontWeight columnLabelsTextTransform columnLabelsBorderBottomColor
columnLabelsBorderBottomWidth columnLabelsPadding columnLabelsPaddingHorizontal
rowGroupBackgroundColor rowGroupFontWeight rowGroupBorderColor stubBackgroundColor
stubFontWeight dataRowPadding dataRowPaddingHorizontal tableBodyVlinesColor tableBodyHlinesColor
rowStriping rowStripingBackgroundColor footnotesFontSize footnotesMarks footnotesSpecRef
footnotesSpecFtr footnotesOrder sourceNotesFontSize containerOverflowX extraCss.

## Output

| Call | Gives |
|---|---|
| `echo t`, `$t`, `t.toText` | the table drawn with box characters |
| `t.toHtml` | a `<div id=...>` with its own scoped `<style>` and the `<table>`; same table, same HTML |
| `t.toHtml(makePage = true)`, `t.save(path)` | a standalone page titled after the table |
| `t.toMarkdown` | a GitHub pipe table, title in bold, groups as bold rows, notes below |
| `nbTable t` | a nimib block (`import tabelline/nimib`), HTML and Markdown backends |
