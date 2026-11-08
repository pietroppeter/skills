## Devlog: why each rule of the nimib-theme skill is there, shown on a demo page.
## Build from the repo root:  sh docs/deps.sh && nim r docs/devlog/nimib_theme.nim
## Screenshots come from docs/devlog/demo/build.sh.
import std/[os, base64]
import nimib
import ../site

let here = currentSourcePath().parentDir

nbInit
nb.doc.filename = here / "2026-11-08-nimib-theme.html"
nb.title = "nimib-theme: does each rule earn its place?"
nb.useSiteTheme(home = "../index.html", tab = "devlog")

proc shot(name, alt: string) =
  let data = base64.encode(readFile(here / "img" / ("demo-" & name & ".png")))
  nbRawHtml: "<figure class=\"shot\"><img alt=\"" & alt & "\" src=\"data:image/png;base64," & data &
    "\"><figcaption>" & alt & "</figcaption></figure>"

nbText: """
# nimib-theme: does each rule earn its place?

*2026-11-08 · first devlog post*

The [nimib-theme skill](../index.html#nimib-theme) exists because our nimib pages kept breaking on the phone:
20px code spilling out of its box in *Declarative Dragging*, no highlighting at all in *Cartographer*.
Its rules were written while fixing those pages. This post checks them one by one on a small demo page,
so you can decide which ones stay.

## The experiment

[demo.nim](https://github.com/pietroppeter/skills/blob/main/docs/devlog/demo/demo.nim) has a code block with
a long line, its output, and a Nim fence in markdown. Its theme is the kind anyone writes by hand:

```css
pre code { font: 13px/1.5 monospace; background: #f3efe6;
           border: 1px solid #d9d0bb; display: block; padding: 8px }
```

It is built three ways and screenshotted at 390px, with CDN stylesheets and `cdn.jsdelivr.net/gh/` scripts
blocked the way a claude.ai artifact blocks them. Each build also goes through `phonecheck.js`.
"""

nbText: """
## 1. nimib 0.4.3 (before #267)
"""
shot("old", "nimib 0.4.3: 20px code, the page is wider than the phone, no colours")
nbText: """
```text
✗ old.html
    page is 548px wide at 390px
    20.4px code: let languages = @["nim", "python", "javascript", "
    17px code: nim, python, javascript, rust, zig, odin, c, cpp,
    pre does not scroll: nim, python, javascript, rust, zig, odin, c, cpp,
    20.4px code: proc greet(name: string): string = "hello, " & nam
```

The theme asks for 13px and gets 20.4px: nimib's own `pre > code {font-size: 1.2em}` comes *after* the theme
in the page and is more specific than `pre code`. The output doesn't scroll, so the whole page becomes
548px wide and slides sideways. There are no colours: the highlight theme is a CDN stylesheet, and the artifact blocks it.

That is **rule 1** (use nimib #267, or write `body pre > code` on older nimib) and the reason for **rule 2**.
"""

nbText: """
## 2. nimib #267, without `nb.inlineAssets`
"""
shot("new", "nimib #267: size and scrolling fixed, still no colours, output too big")
nbText: """
```text
✗ new.html
    17px code: nim, python, javascript, rust, zig, odin, c, cpp,
```

#267 makes nimib's base rules lose to any theme rule, and makes every block scroll inside its box.
The code is 13px and the page fits. Two things are still wrong. There are still no colours,
because the highlight CSS still comes from a CDN: that is **rule 2**, call `nb.inlineAssets`.
And the output is 17px, because outputs are `pre.nb-output` with no `<code>` inside,
so the theme's `pre code` rule never reaches them: that is the **`pre.nb-output` line of rule 3**.
phonecheck caught that; I would not have spotted it in the screenshot.
"""

nbText: """
## 3. nimib #267 + `nb.inlineAssets` + one more theme rule
"""
shot("good", "nimib #267 with inlined assets and a pre.nb-output rule: passes")
nbText: """
```text
✓ good.html
```

The only change to the theme is `pre.nb-output {font: 13px/1.5 monospace}`.
"""

nbText: """
## Verdict, rule by rule

| Rule | Shown here? | Keep? |
|---|---|---|
| 1. nimib #267, else `body pre > code` | yes, build 1 | keep; shrink the fallback once #267 is released |
| 2. `nb.inlineAssets` for artifacts | yes, builds 1-2 | keep |
| 3. code 12.5-13px | taste | your call |
| 3. `overflow-x` on a code box with a background | only on old nimib | fold into rule 1's fallback |
| 3. style `pre.nb-output` too | yes, build 2 | keep |
| 3. colour the `hljs-*` classes | when replacing nimib's highlight CSS | keep, it is one line |
| 3. non-Nim code needs highlight.js | not tested | shorten or drop |
| 4. phonecheck at 390px | caught every problem above | keep |
| 5. publish as an artifact | not about themes | move to its own skill |

phonecheck had one bug of its own: given a path that doesn't exist, it printed ✓.
Fixed in the skill's copy of the script.

## What changed

Pietro agreed to the split, so the skill is now two:

- **nimib-theme**: build with nimib #267 (or the `body pre > code` fallback), the theme rules this demo proved
  (12.5-13px, style `pre.nb-output`, colour `hljs-*` when replacing the highlight CSS), and the phone check.
- **publish-artifact**, in a new **workflow** plugin: make the page self-contained (`nb.inlineAssets` for nimib),
  check it at phone width, publish as a claude.ai artifact and republish to the same link.
  Publishing is about working with Claude, not about nimib: any page we build for the phone needs it.

Dropped: the rule about non-Nim code and highlight.js (never tested here), and the bundled `codeblocks.py`,
which is for pages not built with nimib and stays in claude-artifacts.
Once #267 is in a nimib release, rule 1 becomes "needs nimib ≥ 0.4.4".
"""
nbSave
