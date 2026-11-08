## The same small page, built against two nimib versions to show what nimib-theme fixes.
## Build: see docs/devlog/build-demo.sh (needs nimib main and nimib #267 in two deps folders).
import std/[os, strutils, json]
import nimib

nbInit
nb.doc.filename = getEnv("DEMO_OUT", "demo.html")
nb.title = "demo"
# A typical hand-written theme: plain `pre code` rule, code box with its own background.
nb.doc.context["stylesheet"] = %"""<style>
body{font:17px/1.6 Georgia,serif;max-width:720px;margin:0 auto;padding:0 16px}
pre code{font:13px/1.5 monospace;background:#f3efe6;border:1px solid #d9d0bb;display:block;padding:8px}
</style>"""
if existsEnv("DEMO_GOOD"):  # the one rule the theme above misses: outputs have no <code>
  nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr &
    "<style>pre.nb-output{font:13px/1.5 monospace}</style>")
when compiles(nb.inlineAssets):
  if existsEnv("DEMO_INLINE"): nb.inlineAssets

nbText: "A code block with one long line, and its output:"
nbCode:
  let languages = @["nim", "python", "javascript", "rust", "zig", "odin", "c", "cpp", "go"]
  echo languages.join(", ")

nbText: """
A Nim fence in markdown:

```nim
proc greet(name: string): string = "hello, " & name & "! this line is long enough to scroll on a phone"
```
"""
nbSave
