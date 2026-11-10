## Devlog: the tabelline skill, and what testing it showed.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/tabelline_skill.nim
import std/os
import nimib except md   # the pinned nimib still has its own `md`; tabelline's is the one used here
import tabelline, tabelline/nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-10-tabelline-skill.html"
nb.title = "A skill for tabelline, and what the agents found"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

nbText: """
# A skill for tabelline, and what the agents found

*2026-11-10 · a new plugin, tabelline, with one draft skill*

[tabelline](https://github.com/pietroppeter/tabelline) makes display tables in Nim, after R's
gt and Python's Great Tables. Its 0.1.0 was released today. The new plugin `tabelline` has one
skill, [tabelline](../index.html#tabelline), for anyone *using* it: in a program, a README or a
nimib page, or porting a table written with gt or Great Tables.

## Why one skill, and what is in it

Models know gt and Great Tables well and tabelline not at all. So the skill is mostly a
translation: gt's verbs in camelCase, Great Tables' `loc.*` and `style.*`, R's row expressions
as `where(it["mass"] > 100)`. Next to it, `references/from-gt.md` lists what 0.1 does not have
(summary rows, merged columns, `rows_add`, images, LaTeX...) and what to write instead, and
`references/verbs.md` lists every verb with its arguments, read from the 0.1.0 sources.

Working on tabelline itself does not get a skill: the repository's AGENTS.md and its OpenSpec
skills already cover it, and a copy would drift.

## Tested by running it

`plugins/tabelline/harness/check_snippets.nim` (in Nim, like tabelline) compiles and runs every
snippet of the skill that imports tabelline, and compares what it prints with the text block
under it, the way tabelline checks the examples of its own specs. The table drawn in the skill
is the table tabelline draws. It also runs the three examples (a total row, formats of your own,
a nimib page that is also a README). CI runs it against v0.1.0 and, without blocking, against
tabelline's `main`, once a week too, so a change upstream shows up before a user meets it.
"""

nbText: """
## Agents with and without the skill

Four requests, each run by an agent (Sonnet) twice: once told to read the skill, once not. Both
had tabelline and nimib installed, so neither had to find out how to install it. Checks read the
files the agent made, a few are judged by reading the code.
"""

let runs = tableData:
  task: ["A nimib page of Italian regions", "A CSV report, grouped and coloured",
         "Port a gt table (merged columns, a grand total)", "Sorted, then shade the top three rows"]
  withChecks: ["7/7", "8/8", "8/8", "6/6"]
  withSeconds: [24, 21, 50, 21]
  withoutChecks: ["7/7", "8/8", "8/8", "6/6"]
  withoutSeconds: [31, 22, 46, 48]
let t = tabella(runs, rownameCol = "task"):
  tabHeader "With and without the skill", "checks passed, and seconds"
  tabSpanner "with the skill", ["withChecks", "withSeconds"]
  tabSpanner "without", ["withoutChecks", "withoutSeconds"]
  colsLabel {"withChecks": "checks", "withSeconds": "s", "withoutChecks": "checks", "withoutSeconds": "s"}
  tabSourceNote "One run per arm, 10 November 2026, tabelline 0.1.0, nimib 0.4.3."
  optCssTheme()
nbTable t

nbText: """
All four pass with and without the skill. With it the agents were a little faster, 29 seconds
on average against 37, and the fourth task shows where the time goes. Without the skill, the
agent met the `md` clash with nimib, worked around it by moving the bold title out of the
table into the page's heading, and found by reading the sources that rows count in data order.
With the skill, it read both facts and was done in five steps instead of ten.

The first three tasks pass either way, and take about as long. tabelline's verbs carry doc
comments and its names are gt's, so an agent that reads the installed sources finds its way.
That is a good sign for tabelline, and it means those three cases do not measure the skill yet.

## What the agents found

Reading what the agents did, and trying the skill's own claims, found more than the scores:

- **A bug in tabelline 0.1.0.** In a grouped table, a row whose group is missing is shown first,
  above the groups, *and again* inside the group of the row above it. Both port agents met the
  first half (a Total row) and gave it a group of its own; the skill now says to.
- **`md` with nimib 0.4.3.** `import nimib` with tabelline fails on an ambiguous `md`
  (nimib's old template); `import nimib except md` until nimib 0.5. The agents without the skill
  never used `md`, so they never met it: the fourth task asks for a bold word in the title.
- **Rows are rows of the data.** `loc.body(rows = [0])` after `rowOrder` styles the first row of
  the data, not the first row shown. The fourth task asks for exactly that.
- **Small things that do not compile**, now in the skill: `colsLabel` with plain strings and
  `md()` in one list, and `it["planet"] in [...]` (a `Value` is not a string: `$it["planet"]`).
- **Rounding.** €184,250.5 with no decimals shows as €184,250: tabelline rounds half to even.

## Next

Harder cases (a nimib page on a themed site, a Great Tables port with nanoplots), three runs per
arm, and a line on tabelline's page For coding agents, which already says it will list skills
when there are some.
"""

nbSave
