# From gt and Great Tables to tabelline 0.1.0

tabelline follows gt (R) and Great Tables (Python, "GT" below) part by part. Where the two
differ, it mostly follows Great Tables (`loc.*`, `style.*`). The live map of what is covered,
feature by feature, is the [feature map](https://pietroppeter.github.io/tabelline/coverage/)
(source: `docs/coverage/gt.json` in the tabelline repo); this file is its state at 0.1.0, with
what to write instead when something is missing.

## Translating a call

| gt (R) | Great Tables (Python) | tabelline |
|---|---|---|
| `gt(df, rowname_col = "name", groupname_col = "g")` | `GT(df, rowname_col="name", groupname_col="g")` | `tabella(data, rownameCol = "name", groupnameCol = "g")` |
| `df \|> gt() \|> tab_header(...)` | `GT(df).tab_header(...)` | `tabella(data): tabHeader ...` (one verb per line), or `tabella(data).tabHeader(...)` |
| `fmt_number(columns = c(a, b), decimals = 1)` | `.fmt_number(columns=["a", "b"], decimals=1)` | `fmtNumber ["a", "b"], decimals = 1` |
| `columns = starts_with("x")` | `columns=cs.starts_with("x")` | `startsWith("x")`; `everything()`, `endsWith`, `containing` (not `contains`), `numeric()`, `textual()` |
| `rows = mass > 100` | `rows=pl.col("mass") > 100` | `rows = where(it["mass"] > 100)` |
| `rows = 1:3` (from 1) | `rows=[0, 1, 2]` (from 0) | `rows = 0..2` (from 0, rows of the data, not as shown) |
| `cells_body(columns, rows)` | `loc.body(columns, rows)` | `loc.body(cols, rows)` |
| `cells_column_labels()`, `cells_title()`, `cells_stub()`, `cells_row_groups()`, `cells_column_spanners()` | `loc.column_labels()`, `loc.title()`, `loc.stub()`, `loc.row_groups()`, `loc.spanner_labels()` | `loc.columnLabels()`, `loc.title()`, `loc.stub()`, `loc.rowGroups()`, `loc.spanners()` |
| `cell_fill(color)`, `cell_text(weight = "bold")`, `cell_borders(sides = "top")` | `style.fill(color)`, `style.text(weight="bold")`, `style.borders(sides="top")` | `style.fill(color)`, `style.text(weight = "bold")`, `style.borders(sides = {sTop})` |
| `list(cell_fill(...), cell_text(...))` | `[style.fill(...), style.text(...)]` | `style.fill(...) & style.text(...)` |
| `tab_options(table.font.size = px(14))` | `.tab_options(table_font_size="14px")` | `tabOptions(tableFontSize = "14px")` |
| `md("**x**")`, `html("<b>x</b>")` | `md("**x**")`, `html("<b>x</b>")` | `md("**x**")`, `html("<b>x</b>")` |
| `cols_label(a = "A", b = md("*B*"))` | `.cols_label(a="A", b=md("*B*"))` | `colsLabel {"a": md("A"), "b": md("*B*")}`: all `md()` or all plain in one list |
| `data_color(columns, palette = "viridis", domain = c(0, 100))` | `.data_color(columns, palette="viridis", domain=[0, 100])` | `dataColor cols, palette = palette("viridis"), domain = (0.0, 100.0)` |
| `opt_stylize(style = 2, color = "red")` | `.opt_stylize(style=2, color="red")` | `optStylize(2, "red")` (styles 1 to 3) |
| `sub_missing(missing_text = "---")` | `.sub_missing(missing_text="---")` | `subMissing(missingText = "—")` (all columns by default) |
| `as_raw_html()`, `gtsave("t.html")` | `.as_raw_html()`, `.write_raw_html("t.html")` | `t.toHtml`, `t.save "t.html"` |
| (printing in a notebook) | (Jupyter display) | `nbTable t` in nimib; `echo t` prints text |

## Not in 0.1, and what to write instead

Say in your reply which of these the table needed. Never drop one silently.

| gt / GT | Planned | Instead, today |
|---|---|---|
| `summary_rows()`, `grand_summary_rows()` | 0.2 | Compute the totals in Nim and add them as rows of the data (a `"Total"` row); mark it with `tabStyle style.text(weight = "bold") & style.borders({sTop}), loc.body(rows = where(it["name"] == "Total"))`, and the stub with `loc.stub(...)`. In a grouped table give the Total row a group of its own (`"Total"`, last): a row with no group is shown first, above every group, and 0.1.0 also repeats it in the group of the row above it (a bug). |
| `cols_merge()`, `cols_merge_uncert()`, `cols_merge_range()`, `cols_merge_n_pct()` | 0.2 | Build the merged text column in the data (`&"{n} ({pct:.1f}%)"`) and hide or leave out the sources. |
| `rows_add()`, `rows_hide()` | 0.2 | Add or filter the rows of the data before `tabella`. |
| `cols_add()` | 0.2 | `data.addColumn(name, toValues(xs))` before `tabella`. |
| `cols_align_decimal()` | 0.2 | Same `decimals` in `fmtNumber` and right alignment line up most columns. |
| `tab_stub_indent()` | 0.2 | `tabStyle style.css("padding-left: 1.5em"), loc.stub(rows = ...)` (HTML only). |
| `gt_preview()` | 0.2 | Take the first and last rows of the data yourself. |
| `tab_style_body()`, `from_column()` | 0.2 | A `for` in the body, or one `tabStyle` per `where(...)` condition. |
| `extract_cells()`, `extract_body()` | 0.2 | The values are in your data; `formatNumber` and the other value functions format them. |
| `fmt_units()`, `cols_units()`, `fmt_chem()` | 0.3 | `md("m^2^")`, `md("H~2~O")` in labels; Markdown in the cells with `fmtMarkdown`. |
| `fmt_fraction()`, `fmt_country()`, `fmt_bins()`, `fmt_auto()` | 0.3 | `fmt cols, proc (v: Value): string = ...` with your own mapping. |
| `fmt_date()` month names other than English; full currency list; accounting style | 0.3 | `fmtDate` with a std/times pattern; `fmt` with your own text. |
| `cols_label_rotate()` | 0.3 | `tabStyle style.css("writing-mode: vertical-rl"), loc.columnLabels(...)` (HTML only). |
| `summary_columns()` | 0.3 | Compute the column in the data. |
| Data frames (tibble, pandas, Polars) | 0.3 | Build `tableData:` or `toTableData` from their columns or rows. |
| `fmt_image()`, `fmt_icon()`, `fmt_nanoplot()`, `cols_nanoplot()` | 0.4 | `fmt` with a `RenderContext` proc that returns an inlined `<img src="data:...">` or SVG for `rcHtml` and text otherwise. |
| `gt_group()`, `gt_split()` | 0.5 | Several tables built from one shared start (`let base = tabella(...)`, then `base.rmHeader()...`). |
| `gtsave("t.png" / "t.pdf")`, `as_latex()`, `as_rtf()`, `as_word()` | 0.5 | `t.save "t.html"`, then a browser screenshot (Playwright) for an image. No LaTeX or Word. |
| `opt_interactive()` | not planned | none (sorting and paging is the parked "tabellone" idea). |
| `google_font()` | not planned | `optTableFont("Family, fallback")`, with the font inlined by the page. |
| `tab_info()`, `px()`, `pct()` | not planned | Strings: `"12px"`, `"50%"`. |

## Only in tabelline

- `echo t` prints the table as text, and `toMarkdown` writes a GitHub table (for READMEs).
- `optCssTheme()` and `cssTheme(...)`: a table whose colours and font are the page's CSS variables.
- `tableData:`, the recipe body of `tabella`, `where(it[...])`: Nim's way to write what R and
  Python write with data frames and expressions.
- `tavolaPitagorica(n)` and `planets()` datasets; `loc.header()`, `loc.columnHeader()`, `loc.footer()` for whole parts.
