## Devlog: the nimib, nimibook and nimib-maintainer skills, and how they are tested.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/nimib_skills.nim
import std/os
import nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-08-nimib-skills.html"
nb.title = "nimib skills: tested by building"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

nbText: """
# nimib skills: tested by building

*2026-11-08 · three draft skills join the nimib plugin*

Three skills move here from a closed nimib PR
([nimib#264](https://github.com/pietroppeter/nimib/pull/264)):
[nimib](../index.html#nimib) (write, build and debug a document),
[nimibook](../index.html#nimibook) (books) and
[nimib-maintainer](../index.html#nimib-maintainer) (the repos themselves).
They sit next to [nimib-blocks](../index.html#nimib-blocks) and
[nimib-theme](../index.html#nimib-theme), which say what a page should look like;
the nimib skill now points to them instead of teaching its own way.

## Why they exist

Models trained before mid-2026 write nimib 0.3: `newNbSlimBlock`, `nb.partials`, mustache
templates. nimib 0.4 removed all of it, and parts of nimib's README still describe it. So the
skills are written from `src/`, not from the docs, and every claim in them is built.
"""

nbText: """
## Test 1: everything the skills teach is built

`plugins/nimib/harness/check_snippets.py` builds every example and every complete nimib
document or book found in a skill's code fences, then checks the output: `nbcheck.py` for pages
(title, outputs, markdown that became a code block, missing images), headless Chromium for
nbJs and karax widgets, `bookcheck.py` for books (every chapter, sidebar, prev/next links).

On nimib 0.4.3 it builds 10 of 10. It already caught one real trap on the way: on nimble 0.26,
`nimble install nimibook` run inside a nimble project installs the project's dependencies and
silently skips nimibook, so CI must install it from another folder.
"""

nbText: """
## Test 2: agents with and without the skills

Eight realistic requests, each run by a subagent twice: with the skills and without.
Most checks read the files the agent produced (the HTML exists only if the program compiled
and ran), a few are judged. Results from 28 October 2026, nimib 0.4.3, one run per arm (checks passed, time):

| Task | With skills | Without |
|---|---|---|
| Word-frequency doc | 5/5, 65 s | 3/5, 137 s |
| README.md and HTML from one source | 2/4, 4/4 after the fix, 72 s | 4/4, 165 s |
| Two interactive converters | 5/5, 78 s | 5/5, 321 s |
| Custom admonition block | 5/5, 56 s | 5/5, 119 s |
| Docs site with nimib.toml | 6/6, 93 s | 6/6, 157 s |
| Port a broken 0.3 doc | 5/5, 130 s | 5/5, 157 s |
| New nimibook | 7/7, 120 s | 7/7, 161 s |
| Prepare release 0.4.4 | 6/6, 23 s | 6/6, 17 s |

Both arms pass 41 of 43 checks: an agent that can read the installed nimib sources finds the
0.4 API by itself. What the skills buy today is time, about half (80 s against 154 s on
average) for the same tokens. Without them, the agent kept the file name as the page title and
typed the counts into the prose by hand. With them, it wrote `readme.md` instead of
`README.md`; the skill now shows `nb.useMdBackend()` with `nb.doc.filename = "README.md"`, and
the rerun passes.

Five cases pass either way, so they do not measure the skills yet. The next round needs harder
cases and three runs per arm.
"""

nbText: """
## Blocks, not HTML, applied to the skills themselves

The merge applied the nimib-blocks rule to the nimib skill. Its custom-block example now keeps
its blocks in `examples/lib/blocks.nim` and its CSS and colour tokens in
`examples/lib/style.nim`; the kind of a callout is an enum. The page itself only calls blocks.
Two graded cases gained a check that the page source holds no HTML, `<style>` or hex colour.

`drift.nim` on the examples still counts 6, all on purpose: `blocks_tour.nim` shows every
block, `nbRawHtml` included, and `interactive.nim` needs the elements its JavaScript fills in.
Each of them carries a comment that says why.

## One rule across five skills

A read of the five skills side by side found the older nimib reference still teaching a callout
whose kind was a string, against the enum that nimib-blocks asks for; it now uses the enum and
points to nimib-blocks for the how-to. The nimib skill now says that nimib-theme builds with an
unreleased nimib (#267) and what to do on 0.4.3, and its verify step names `phonecheck.js` and
`drift.nim` next to `nbcheck.py`. All the skills now name the modules `style.nim` and `blocks.nim`, in English, as their
examples do.

## How to run the tests

The commands are in the
[harness README](https://github.com/pietroppeter/skills/blob/main/plugins/nimib/harness/README.md).
`claude plugin eval` reads the graded cases as they are; in cloud containers, where it cannot
run, `run_graders.py` grades the folder a subagent worked in.
"""

nbSave
