## Devlog: hard tables. What agents lose time on, and the skill table-building.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/table_building.nim
import std/[os, base64]
import nimib except md   # the pinned nimib still has its own `md`; tabelline's is the one used here
import tabelline, tabelline/nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-15-table-building.html"
nb.title = "Hard tables: nobody looked"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

proc shot(name, alt: string) =
  # a screenshot inlined in the page, as in the post on nimib-theme: one-off, so raw HTML
  let data = base64.encode(readFile(here / "img" / (name & ".png")))
  nbRawHtml: "<figure class=\"shot\"><img alt=\"" & alt & "\" src=\"data:image/png;base64," & data &
    "\"><figcaption>" & alt & "</figcaption></figure>"

nbText: """
# Hard tables: nobody looked

*2026-11-15 · a second skill in the tabelline plugin, table-building, and recipes for the first*

[Yesterday's post](2026-11-14-tabelline-skill-0-2.html) left the tabelline skill small and its
ports too easy to test anything. Pietro asked the next question: how should the skill handle
corner cases and complex tables? tabelline's book has some forty ported tables to pick examples
from, so which ones? And is it worth splitting the skill in two, one for building a table and
one for tabelline's specifics?

## Ask the agents where they lose time

Picking examples by taste would repeat the mistake of the 0.1 skill, which copied what the docs
already said. So the examples were picked by evidence. Six hard tasks from the book went to
agents (Sonnet), once with the skill and once without:

- three Table Contest and gt-extras tables with charts drawn in the cells and data shaped with
  Polars (Euro NCAP, the lemurs, an NFL season);
- a railway timetable;
- a board of Super Bowl squares;
- a brief with no original to port: "one table for the owner's yearly report".

Each agent also wrote notes for tabelline's maintainers: what it tried first, what failed,
where it found the answer.

All twelve programs compiled and ran. The notes say where the time went:
"""

let found = tableData:
  what: ["Did not look at the page", "Finding names in the docs", "Data made in code", "HTML or a drawing in a cell",
         "A number printed as `28.`"]
  runs: [12, 12, 11, 8, 3]
  detail: ["Every agent grepped the HTML for its styles. None took a screenshot.",
           "Printing the index of api.md (37 KB) overflowed the tool; `style.text` is filed under `text`.",
           "No group-by, join or pivot in tabelline (by design). Each agent found on its own how to build a table from computed columns.",
           "The short form of `fmt` escapes HTML; `md()` escapes tags; the text output filled with SVG.",
           "Nim's `{x:.0f}` keeps the dot. In `width=\"120.\"` the SVG loses its size."]
let t = tabella(found, rownameCol = "what"):
  tabHeader "Where twelve runs lost time", "runs whose notes mention it, of 12"
  colsLabel:
    runs: "runs"
    detail: "what happened"
  fmtMarkdown "detail"
  fmtMarkdown "what"
  colsWidth:
    detail: "60%"
  tabSourceNote "Counted by keyword in the agents' notes, 15 November 2026, tabelline 0.2.0."
  optCssTheme()
nbTable t

nbText: """
The first line is the one that matters. Here is one of the twelve, as its agent delivered it.
The checks on the HTML passed. The rows are 170px tall because every drawing was written with
`width="120."`.
"""
shot "table-before", "Before: it compiles, the styles are in the HTML, and nobody looked."

nbText: """
## One skill or two

Two, because the findings are of two kinds.

**Specific to tabelline**: how to build its data from code, how to draw in a cell, where a name
is in api.md. These go in the skill `tabelline`, as two short pages that load only when the
table needs them:

- `references/data.md`: reading a cell, grouping, joining, pivoting and sorting in plain Nim,
  then `toTableData`, in one program of thirty lines whose output the harness checks;
- `references/cells.md`: a `fmt` proc that returns HTML, with its answer for the text output, two
  numbers in one cell, one scale for all rows, a fixed size.

The book is not copied into the skill. The skill has a table of seven kinds of hard table (a
timetable, a grid that is not rows of data, a clinical summary...) and the chapter to read for
each, as a link to its source at the release's tag.

**True of any table, with any library**: say what the table is for, shape the data first, build
in the order of the parts, and look at it before saying it is done. This is the new skill,
`table-building`. It works for gt and Great Tables too, and it will not change when tabelline
does. It comes with `scripts/look.js`, which takes two screenshots (1100px and 390px) and lists
what it can measure: a page that scrolls sideways, cut cells, rows far taller than the others,
pictures that did not load. Then the agent reads the two pictures.

## The same six tasks again

One run each with both skills. The book was held out, since it has the answers to five of the
six. All six agents took the screenshots and read them. The same NFL table:
"""
shot "table-after", "After: the same task with both skills."

nbText: """
The lemurs agent wrote in its notes that the axes of its line charts had vanished (`x1="48."`
again), and that it found out "only by looking at the screenshot". The page on cells warned
about it; the agent had read it and still wrote the dot. A warning is read and forgotten. A
picture of the result is not.

The second round's notes were shorter and found smaller things, now in the skill: a name with a
space goes in quotes in a block of pairs; a list in a cell is formatted item by item; `loc.body`
takes `cols`, not `columns`.

Two eval cases keep this: `port-gt-extras` (the drawings are in the HTML and not escaped, no
size ends in a dot, the screenshots exist) and `report-from-brief` for `table-building`. The
first round's runs fail them, the second round's pass.

## For tabelline

The notes are a list of what tabelline could do better, for its backlog: an error for an
unknown palette name when the verb is called; `fmt` for a whole list; a format that sees its
row; a `savePage` for several tables; a shorter index in api.md; `optCss` dropping an `@import`
without a word.
"""

nbSave
