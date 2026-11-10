## Builds and runs the code the tabelline skills teach, so they cannot drift from tabelline.
##
##   nim r plugins/tabelline/harness/check_snippets.nim [--verbose] [--keep]
##
## 1. Every ```nim fence in skills/**/*.md that imports tabelline is compiled and run. When the
##    next fence is a ```text block, the program's output must be that text (as tabelline's own
##    spec examples are checked). A fence that calls `nbSave` must write its HTML page.
## 2. Every skills/*/examples/*.nim is compiled and run in a copy of its folder; an example that
##    mentions `mdOutput` is also run with -d:mdOutput and must write its Markdown file.
##
## A fence opts out with a `# snippet: skip` line. Fences and examples that import nimib are
## skipped, and said so, when nimib is not installed. Exit code 0 only if everything passes.
import std/[os, osproc, strutils, strformat, sequtils]

let
  root = currentSourcePath().parentDir.parentDir      # plugins/tabelline
  verbose = "--verbose" in commandLineParams()
  keep = "--keep" in commandLineParams()
  work = getTempDir() / "tabelline-snippets"

type Fence = object
  lang, code: string
  line: int

proc fences(path: string): seq[Fence] =
  ## The fenced code blocks of a Markdown file, in order.
  var inFence = false
  var cur: Fence
  for i, line in readFile(path).splitLines.toSeq:
    let l = line.strip
    if not inFence and l.startsWith("```"):
      inFence = true
      cur = Fence(lang: l[3..^1].strip, line: i + 1)
    elif inFence and l == "```":
      inFence = false
      result.add cur
    elif inFence:
      cur.code.add line & "\n"

proc tidy(s: string): string =
  s.splitLines.mapIt(it.strip(leading = false)).join("\n").strip

proc have(module: string): bool =
  ## True when `import <module>` compiles here.
  let probe = work / "probe_" & module.replace("/", "_") & ".nim"
  writeFile(probe, "import " & module & "\n")
  execCmdEx("nim check --hints:off " & quoteShell(probe)).exitCode == 0

var failures, passes, skips = 0

proc report(ok: bool, label: string, detail = "") =
  if ok: inc passes else: inc failures
  echo (if ok: "✓ " else: "✗ "), label
  if detail.len > 0 and (verbose or not ok): echo detail.indent(4)

proc run(file: string, defines = ""): (string, int) =
  let cache = work / "cache" / file.splitFile.name & defines.replace(":", "_").replace(" ", "")
  let cmd = &"nim r --hints:off --warnings:off -d:nimibQuiet {defines} --nimcache:{quoteShell(cache)} {quoteShell(file)}"
  let (output, code) = execCmdEx(cmd, workingDir = file.parentDir)
  (output, code)

removeDir(work)
createDir(work)
let hasNimib = have("nimib")
if not have("tabelline"):
  quit "tabelline is not installed: nimble install -y \"https://github.com/pietroppeter/tabelline@#v0.1.0\""

# 1. fences in the skills' markdown
var n = 0
for md in walkDirRec(root / "skills"):
  if not md.endsWith(".md"): continue
  let fs = fences(md)
  for k, f in fs:
    if f.lang != "nim" or "import tabelline" notin f.code: continue
    let label = &"{md.relativePath(root)}:{f.line}"
    if "# snippet: skip" in f.code:
      inc skips; echo "- ", label, " (skip)"; continue
    let usesNimib = "import nimib" in f.code
    if usesNimib and not hasNimib:
      inc skips; echo "- ", label, " (nimib not installed)"; continue
    inc n
    let dir = work / &"fence{n}"
    createDir(dir)
    let file = dir / &"snippet{n}.nim"
    writeFile(file, f.code)
    let (output, code) = run(file)
    if code != 0:
      report(false, label & " compiles and runs", output); continue
    if "nbSave" in f.code and not fileExists(dir / &"snippet{n}.html"):
      report(false, label & " writes its page", output); continue
    if k + 1 < fs.len and fs[k + 1].lang == "text":
      let want = tidy(fs[k + 1].code)
      let got = tidy(output)
      report(got == want, label & " prints its text block",
             if got == want: "" else: "expected:\n" & want & "\ngot:\n" & got)
    else:
      report(true, label & " compiles and runs")

# 2. examples, run in a copy of their folder so outputs stay out of the repo
for exdir in walkDirs(root / "skills" / "*" / "examples"):
  let skill = exdir.parentDir.lastPathPart
  let copy = work / "examples-" & skill
  copyDir(exdir, copy)
  for file in walkFiles(copy / "*.nim"):
    let label = &"skills/{skill}/examples/{file.extractFilename}"
    let src = readFile(file)
    if "import nimib" in src and not hasNimib:
      inc skips; echo "- ", label, " (nimib not installed)"; continue
    let (output, code) = run(file)
    report(code == 0, label & " compiles and runs", output)
    if code == 0 and "mdOutput" in src:
      let (o2, c2) = run(file, "-d:mdOutput")
      let mdFile = file.changeFileExt("md")
      report(c2 == 0 and fileExists(mdFile), label & " with -d:mdOutput writes " & mdFile.extractFilename, o2)

echo &"\n{passes} passed, {failures} failed, {skips} skipped"
if not keep: removeDir(work)
if failures > 0: quit 1
