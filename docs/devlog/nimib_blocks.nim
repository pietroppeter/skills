## Devlog: why the nimib-blocks skill exists, with the numbers from tabelline's pages.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/nimib_blocks.nim
import std/os
import nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-08-nimib-blocks.html"
nb.title = "nimib-blocks: blocks, not HTML"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

nbText: """
# nimib-blocks: blocks, not HTML

*2026-11-08 · draft skill*

nimib exists so that a page says *what* it shows, with blocks made for it, and not *how* it is
drawn. The [nimib-blocks skill](../index.html#nimib-blocks) is there because agents writing nimib
pages drift the other way: they know HTML better than they know nimib's block API, so a gallery
becomes a string of `<div>`s in `nbRawHtml`, and every page gets its own `<style>` and its own
hex colours.

## The evidence

On 8 November 2026 the tabelline devlog post *Blocks, not HTML* counted what its 23 pages wrote
by hand, outside the theme: 35 `nbRawHtml` calls, 25 `nbText` blocks with HTML tags in them,
10 `<style>` blocks, 5 `<script>` blocks and 101 distinct hex colours. Most of those pages were
written by agents, quickly. The post's own gallery, made with a container block in eight lines,
replaced a 25-line template that rendered blocks to a string and pasted the string back.

## What each rule is for

- **The decision, in order** (Markdown, nimib's blocks, the project's blocks, a new block,
  `nbRawHtml` last): an agent asks the questions in the order that leads away from HTML.
- **A new block the second time**, not the third: by the third copy, the copies have already
  diverged.
- **A style module and a blocks module**: changing a colour is one line, and a page reads as what
  it shows.
- **Enums for kinds**: a note kind spelled wrong fails to compile instead of rendering unstyled.
- **The drift counter** (`scripts/drift.nim`): the agent sees its own drift before a PR, and a
  migrated project can fail CI on new drift.

## How it will be tested

Three evals ship with the skill: add a warning note, a gallery of three tables, a page of cards.
Each passes only if the result uses blocks and adds no raw HTML or colour to the page. The skill
moves from draft to personal once tabelline's pages are migrated with it.

This post is written the way the skill asks: Markdown and nimib's blocks only.
"""
nbSave
