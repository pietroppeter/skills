## Devlog: the tabelline skill for 0.2, made minimal, and tested against tabelline's own docs.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/tabelline_skill_0_2.nim
import std/os
import nimib except md   # the pinned nimib still has its own `md`; tabelline's is the one used here
import tabelline, tabelline/nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-14-tabelline-skill-0-2.html"
nb.title = "The tabelline skill for 0.2: smaller, and the docs do the rest"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

nbText: """
# The tabelline skill for 0.2: smaller, and the docs do the rest

*2026-11-14 · the tabelline skill rewritten for tabelline 0.2, with new experiments*

The [first post](2026-11-10-tabelline-skill.html) ended with a weak result. Agents passed the
same checks with the 0.1 skill and without it, because tabelline's names are gt's and its
sources carry doc comments. So Pietro asked for three things once 0.2 was out. The skill should
be minimal and point to tabelline's API reference. There should be new experiments. And
whatever would make skills cheaper should go into tabelline's own docs.

## What moved into tabelline

Most of the old skill was a copy of the API: `references/verbs.md`, and a map from gt and Great
Tables to tabelline (`references/from-gt.md`). A copy goes out of date. tabelline already had
all of it on its Reference page, but only as HTML. Its
[PR #108](https://github.com/pietroppeter/tabelline/pull/108) publishes the same data as plain
text:

- **api.md** opens with an index of one line per name, giving its kind, gt's name and its first
  sentence. Then each name has its signatures, its doc comment, its gt and Great Tables names,
  and a spec example with what it prints. An agent greps it for `fmt_number` and finds
  `fmtNumber`. It covers 404 names, in about 300 KB.
- **api.json** has the same data in JSON.
- **llms.txt** is rewritten for models. It gives the install line first, then the plain-text
  files (api.md, the feature map as JSON, every spec as Markdown), then the pages.

## What is left in the skill

The skill is now one file of about a hundred lines. It says where the docs are and how to read
api.md. It gives the install line. It describes the way of working: write the table as a
recipe, `echo t` to read it as text, then write HTML and grep it for the styles. It has one
example, whose output the harness checks. Then come the traps agents met that the docs do not
warn about: the `md` clash with nimib 0.4.3, rows counted in data order, a cell as a `Value`
and not a string, verbs outside the recipe returning a new table, and list-of-pairs blocks.
"""

nbText: """
## Three arms, three runs each

The new cases are harder and use 0.2:

- a gt port with summary rows per group, a grand summary, a merged range and `data_color`;
- a Great Tables port with nanoplots, Markdown and `opt_stylize`;
- the 0.1 case that was hardest: sort, then shade the top three rows as the reader sees them.

Each ran three times (Sonnet) in three arms. *None* had nothing but tabelline installed.
*Docs* was told where llms.txt and api.md are. *Skill* was told to read the skill. Checks read
the files the agent made.
"""

let runs = tableData:
  task: ["gt port", "Great Tables port", "Top three",
         "Top three, fixed skill"]
  noneOk: ["3/3", "3/3", "2/3", ""]
  noneS: [60, 73, 257, 0]
  noneK: [76, 67, 69, 0]
  docsOk: ["3/3", "3/3", "2/3", ""]
  docsS: [70, 70, 92, 0]
  docsK: [86, 67, 67, 0]
  skillOk: ["3/3", "3/3", "0/3", "3/3"]
  skillS: [57, 66, 100, 38]
  skillK: [69, 61, 61, 58]
let t = tabella(runs, rownameCol = "task"):
  tabHeader "Three arms, three runs each", "runs passed, mean seconds, mean thousands of tokens"
  tabSpanner "none", ["noneOk", "noneS", "noneK"]
  tabSpanner "docs", ["docsOk", "docsS", "docsK"]
  tabSpanner "skill", ["skillOk", "skillS", "skillK"]
  colsLabel:
    noneOk: "pass"
    noneS: "s"
    noneK: "kt"
    docsOk: "pass"
    docsS: "s"
    docsK: "kt"
    skillOk: "pass"
    skillS: "s"
    skillK: "kt"
  subZero ["noneS", "noneK", "docsS", "docsK"], zeroText = ""
  tabSourceNote "14 November 2026, tabelline 0.2.0, nimib 0.4.3. One none run of the third task took 560 s; without it the mean is 106 s."
  optCssTheme()
nbTable t

nbText: """
## What the runs showed

**The two ports are no test of a skill any more.** All 18 runs passed every check in every arm.
In both ports a run with the skill used about a tenth fewer tokens and was a little faster.
Even the arm with nothing found summary rows, merged ranges and nanoplots by reading the
installed sources. That speaks well for tabelline, whose verbs have gt's names and carry their
docs. It also means a skill that copied the API would add nothing here.

**The third task found a rule in the skill that did harm.** The skill said that rows count in
data order, and that rows meant by content are picked with `where(...)`. All three agents with
the skill then picked the top three by content: two wrote the planet names into the code and one
wrote `moons > 20`. The checks on the HTML passed, but this shading does not follow the sort.
Change the data and the wrong rows are shaded. The docs arm found `displayOrder`, which gives
the rows in the order they are shown, by reading api.md (two runs of three). The arm with
nothing either sorted the data before making the table (two runs) or used a threshold too.

So the case gained a check: the code takes the shaded rows from the sort (`displayOrder` or a
sort), not from names or a threshold. The rule in the skill now says to build the table and then
take `t.displayOrder()[0 .. 2]`. In the fourth line of the table all three new runs did that,
in 38 seconds on average.

**What it means for skills.** A skill's rule is followed to the letter, more than any doc an
agent finds. One sentence that is right but incomplete (`where` for rows by content) made the
skill arm the worst of the three. Each trap now says what to do, not only what to avoid, and the
evals check the code as well as the output.

## Next

- After #108 merges, api.md is on the site and the skill's links work as written.
- Then tabelline's page For coding agents lists this skill.
- A case where the skill should matter: a nimib page on a themed site, where `optCssTheme`
  and the `md` clash both come into play.
"""

nbSave
