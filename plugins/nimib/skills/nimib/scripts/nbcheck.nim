## nbcheck: build a nimib document and check the rendered HTML.
##
##   nim r nbcheck.nim doc.nim [nim options...]   build with `nim r`, then check
##   nim r nbcheck.nim --html doc.html            only check an existing html file
##   nim r nbcheck.nim doc.nim --json             machine-readable report
##
## The build runs `nim r --hints:off --warnings:off [nim options] doc.nim` from the
## current directory (nimib finds nimib.toml from there), reads nimib's log to find
## the written file, then reports what the page contains and flags common
## rendering mistakes. Exit code: 0 ok (warnings allowed), 1 build failed or
## errors found, 2 usage error. Only the standard library is used.
import std/[os, osproc, strutils, sequtils, json, unicode]

const usage = """usage:
  nim r nbcheck.nim doc.nim [nim options...]   build with `nim r`, then check
  nim r nbcheck.nim --html doc.html            only check an existing html file
  nim r nbcheck.nim doc.nim --json             machine-readable report"""

const voidTags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta",
                  "source", "track", "wbr"]

type
  Page = object
    ## The parts of a nimib page we care about (only inside <main>).
    title: string
    codeBlocks: seq[string]               # nim code shown by nbCode (statically highlighted)
    outputs: seq[string]                  # <pre class="nb-output">
    mdCode: seq[tuple[content, cls: string]]  # <pre><code> from markdown (``` or indented)
    texts: seq[string]                    # prose text chunks (outside pre/code/script)
    headings, images: seq[string]
    scripts, figures: int
  Parser = object
    page: Page
    inTitle: bool
    inMain: int
    stack: seq[string]                    # open tags inside main
    inPre: bool
    preKind, preBuf, preCls: string

# --- a small HTML reader: tags, attributes, text and entities -------------------------------

proc decodeEntities(s: string): string =
  var i = 0
  while i < s.len:
    if s[i] == '&':
      let j = s.find(';', i)
      if j > i + 1 and j - i <= 10:
        let e = s[i + 1 ..< j]
        var r = ""
        case e
        of "amp": r = "&"
        of "lt": r = "<"
        of "gt": r = ">"
        of "quot": r = "\""
        of "apos": r = "'"
        of "nbsp": r = " "
        else:
          if e.len > 1 and e[0] == '#':
            try:
              let n = if e[1] in {'x', 'X'}: parseHexInt(e[2 .. ^1]) else: parseInt(e[1 .. ^1])
              r = $Rune(n)
            except ValueError: discard
        if r.len > 0:
          result.add r
          i = j + 1
          continue
    result.add s[i]
    inc i

proc parseAttrs(s: string): seq[(string, string)] =
  var i = 0
  while i < s.len:
    while i < s.len and (s[i] in Whitespace or s[i] == '/'): inc i
    let a = i
    while i < s.len and s[i] notin Whitespace + {'=', '/'}: inc i
    if i == a:
      inc i
      continue
    let name = s[a ..< i].toLowerAscii
    while i < s.len and s[i] in Whitespace: inc i
    var value = ""
    if i < s.len and s[i] == '=':
      inc i
      while i < s.len and s[i] in Whitespace: inc i
      if i < s.len and s[i] in {'"', '\''}:
        let b = s.find(s[i], i + 1)
        let e = if b < 0: s.len else: b
        value = s[i + 1 ..< e]
        i = e + 1
      else:
        let b = i
        while i < s.len and s[i] notin Whitespace: inc i
        value = s[b ..< i]
    result.add (name, decodeEntities(value))

proc attr(attrs: seq[(string, string)], name: string): string =
  for (k, v) in attrs:
    if k == name: return v

proc startTag(p: var Parser, tag: string, attrs: seq[(string, string)]) =
  if tag == "title": p.inTitle = true
  if tag == "main":
    inc p.inMain
    return
  if p.inMain == 0: return
  if tag notin voidTags: p.stack.add tag
  let cls = attrs.attr("class")
  if tag == "pre":
    p.inPre = true
    p.preKind = if "nb-output" in cls: "output" else: "pre"
    p.preBuf = ""
    p.preCls = ""
  elif tag == "code" and p.inPre and p.preKind == "pre":
    p.preKind = if "nim" in cls and "nohighlight" in cls: "nim" else: "md"
    p.preCls = cls
  elif tag == "img": p.page.images.add attrs.attr("src")
  elif tag == "script": inc p.page.scripts
  elif tag == "figure": inc p.page.figures

proc endTag(p: var Parser, tag: string) =
  if tag == "title": p.inTitle = false
  if tag == "main":
    dec p.inMain
    return
  if p.inMain == 0: return
  if tag == "pre" and p.inPre:
    case p.preKind
    of "output": p.page.outputs.add p.preBuf
    of "nim": p.page.codeBlocks.add p.preBuf
    of "md": p.page.mdCode.add (p.preBuf, p.preCls)
    else: discard  # a bare <pre> (e.g. the file name of nbFile) is ignored
    p.inPre = false
  if p.stack.len > 0 and p.stack[^1] == tag: discard p.stack.pop
  elif tag in p.stack:
    while p.stack.len > 0 and p.stack.pop != tag: discard

proc data(p: var Parser, d: string) =
  if p.inTitle: p.page.title.add d
  if p.inMain == 0: return
  if p.inPre:
    p.preBuf.add d
    return
  if "script" in p.stack or "style" in p.stack or "code" in p.stack: return
  if p.stack.len > 0 and p.stack[^1] in ["h1", "h2", "h3", "h4", "h5", "h6"]:
    p.page.headings.add d.strip
  if d.strip.len > 0: p.page.texts.add d

proc parsePage(html: string): Page =
  var p: Parser
  var text = ""
  var i = 0
  template flush =
    if text.len > 0:
      p.data(decodeEntities(text))
      text = ""
  template skipTo(s: string) =
    let e = html.find(s, i)
    i = if e < 0: html.len else: e + s.len
  while i < html.len:
    if html[i] != '<':
      text.add html[i]
      inc i
      continue
    if html.continuesWith("<!--", i):
      flush
      skipTo("-->")
      continue
    if i + 1 < html.len and html[i + 1] in {'!', '?'}:  # doctype
      flush
      skipTo(">")
      continue
    let closing = i + 1 < html.len and html[i + 1] == '/'
    let a = i + 1 + ord(closing)
    var j = a
    while j < html.len and html[j] in IdentChars + {'-', ':'}: inc j
    if j == a:  # a lone '<' is text
      text.add '<'
      inc i
      continue
    let tag = html[a ..< j].toLowerAscii
    var k = j  # the closing '>', skipping quoted attribute values
    var quote = '\0'
    while k < html.len:
      let c = html[k]
      if quote != '\0':
        if c == quote: quote = '\0'
      elif c in {'"', '\''} and html[k - 1] == '=': quote = c
      elif c == '>': break
      inc k
    flush
    i = k + 1
    if closing:
      p.endTag(tag)
      continue
    let inner = html[j ..< min(k, html.len)]
    p.startTag(tag, parseAttrs(inner))
    if tag in ["script", "style"]:  # raw text up to the end tag
      let e = html.find("</" & tag, i)
      let stop = if e < 0: html.len else: e
      p.data(html[min(i, stop) ..< stop])
      i = stop
    elif inner.strip.endsWith("/") and tag notin voidTags:
      p.endTag(tag)
  flush
  p.page

# --- the checks ------------------------------------------------------------------------------

proc pyRepr(s: string): string =
  ## A quoted string, as Python's repr writes it (the report used to come from Python).
  let q = if '\'' in s and '"' notin s: '"' else: '\''
  result.add q
  for c in s:
    case c
    of '\\': result.add "\\\\"
    of '\n': result.add "\\n"
    of '\t': result.add "\\t"
    of '\r': result.add "\\r"
    else:
      if c == q: result.add '\\'
      result.add c
  result.add q

proc cut(s: string, n = 80): string = s.runeSubStr(0, n)

proc isMdHeading(s: string): bool =
  var n = 0
  while n < s.len and s[n] == '#': inc n
  n in 1..6 and n < s.len and s[n] in Whitespace

proc hasBold(s: string): bool =
  ## Raw **bold** markers: `**`, a character that is not `*` or a space, no `*`, then `**`.
  var i = s.find("**")
  while i >= 0:
    let c = i + 2
    if c < s.len and s[c] notin Whitespace + {'*'}:
      var j = c + 1
      while j < s.len and s[j] != '*': inc j
      if j + 1 < s.len and s[j + 1] == '*': return true
    i = s.find("**", i + 1)

proc longWords(s: string): int =
  ## How many runs of 3 or more ASCII letters.
  var run = 0
  for c in s & " ":
    if c in Letters: inc run
    else:
      if run >= 3: inc result
      run = 0

proc looksLikeCode(s: string): bool =
  if s.anyIt(it in "=(){};:[]"): return true
  for line in s.splitLines:
    let l = line.strip(trailing = false)
    for kw in ["import", "let", "var", "proc", "echo", "def"]:
      if l.startsWith(kw) and (l.len == kw.len or l[kw.len] notin IdentChars): return true

proc placeholder(s: string): string =
  ## The first `{name}` left in text, if any.
  for i in 0 ..< s.len - 1:
    if s[i] == '{' and s[i + 1] in Letters + {'_'}:
      var j = i + 2
      while j < s.len and s[j] in IdentChars + {'.', '[', ']', '(', ')'}: inc j
      if j < s.len and s[j] == '}': return s[i .. j]

proc check(htmlPath: string, nimFile = ""): JsonNode =
  result = %*{"file": htmlPath, "errors": [], "warnings": [], "info": {}}
  let text = readFile(htmlPath)
  if htmlPath.endsWith(".md"):
    result["info"]["markdown_chars"] = %text.runeLen
    result["info"]["code_fences"] = %(text.count("```") div 2)
    return
  let p = parsePage(text)
  let prose = p.texts.join("\n")
  let title = p.title.strip
  result["info"] = %*{
    "title": title,
    "headings": p.headings[0 ..< min(20, p.headings.len)],
    "nim_code_blocks": p.codeBlocks.len,
    "outputs": p.outputs.len,
    "markdown_code_blocks": p.mdCode.len,
    "images": p.images,
    "scripts_in_main": p.scripts,
    "prose_chars": prose.runeLen,
  }
  var errors, warnings: seq[string]
  if p.codeBlocks.len == 0 and prose.strip.len == 0 and p.images.len == 0 and p.scripts == 0 and
     p.mdCode.len == 0:
    errors.add "the page has no blocks: nothing between nbInit and nbSave, or blocks have no html renderer"
  if nimFile.len > 0 and title.endsWith(extractFilename(nimFile)):
    warnings.add "title is the default (file path '" & title & "'): set nb.title = \"...\" after nbInit"
  # markdown that did not render
  for line in prose.splitLines:
    let s = line.strip
    if isMdHeading(s):
      warnings.add "raw markdown heading in text (indentation or missing blank line?): " & pyRepr(s.cut)
    elif s.startsWith("```"):
      warnings.add "raw code fence in text: " & pyRepr(s.cut)
    elif hasBold(s):
      warnings.add "raw **bold** markers in text: " & pyRepr(s.cut)
  # prose that became a code block because of 4-space indentation
  for (content, cls) in p.mdCode:
    if cls.strip.len == 0 and longWords(content) >= 6 and not looksLikeCode(content):
      warnings.add "text rendered as a code block (lines indented 4+ spaces in nbText?): " &
        pyRepr(content.strip.cut)
  # fmt placeholders left in text (string not interpolated)
  let ph = placeholder(prose)
  if ph.len > 0:
    warnings.add "possible un-interpolated placeholder " & ph & " in text (missing & or fmt before the string?)"
  # local images that do not exist
  let base = parentDir(absolutePath(htmlPath))
  for src in p.images:
    if src.len == 0 or ["http:", "https:", "data:", "//"].anyIt(src.startsWith(it)): continue
    let path = if src.isAbsolute: src else: normalizedPath(base / src)
    if not fileExists(path):
      warnings.add "image not found relative to the page: " & src & " (nbImage urls are relative to the root, see SKILL.md)"
  if p.codeBlocks.len > 0 and p.outputs.len == 0:
    result["info"]["note"] = %"no code block produced output (only echo/stdout is shown)"
  for o in p.outputs:
    if ["Error", "Traceback", "unhandled exception"].anyIt(it in o):
      warnings.add "an output contains an error message: " & pyRepr(o.strip.cut)
  result["errors"] = %errors
  result["warnings"] = %warnings

# --- building --------------------------------------------------------------------------------

proc build(nimFile: string, opts: seq[string]): tuple[code: int, output, path: string, cmd: seq[string]] =
  result.cmd = @["nim", "r", "--hints:off", "--warnings:off"] & opts & @[nimFile]
  (result.output, result.code) = execCmdEx(result.cmd.map(quoteShell).join(" "))
  var saved = ""
  var cwd = getCurrentDir()
  for line in result.output.splitLines:
    var k = line.find("current directory: ")
    if k >= 0: cwd = line[k + "current directory: ".len .. ^1].strip
    k = line.find("saving file: ")
    if k >= 0:
      saved = line[k + "saving file: ".len .. ^1]
      saved.removePrefix(']')
      saved = saved.strip
  if saved.len > 0:
    result.path = if saved.isAbsolute: saved else: normalizedPath(cwd / saved)

proc guessHtml(nimFile: string): string =
  for ext in ["html", "md"]:
    if fileExists(nimFile.changeFileExt(ext)): return nimFile.changeFileExt(ext)

proc show(v: JsonNode): string =
  case v.kind
  of JString: v.getStr
  of JArray: "[" & v.elems.mapIt(if it.kind == JString: pyRepr(it.getStr) else: $it).join(", ") & "]"
  else: $v

proc main(): int =
  var args = commandLineParams()
  if args.len == 0 or args[0] in ["-h", "--help"]:
    echo usage
    return 2
  let asJson = "--json" in args
  args.keepItIf(it != "--json")
  var rep: JsonNode
  if args[0] == "--html":
    if args.len < 2:
      echo usage
      return 2
    rep = check(args[1])
  else:
    let nimFile = args[0]
    var (code, output, path, cmd) = build(nimFile, args[1 .. ^1])
    if code != 0:
      let lines = output.strip.splitLines
      let tail = lines[max(0, lines.len - 30) .. ^1]
      let errs = lines.filterIt("Error" in it)
      if asJson:
        echo pretty(%*{"build": "failed", "command": cmd.join(" "),
                       "first_error": (if errs.len > 0: %errs[0] else: newJNull()), "tail": tail})
      else:
        echo "BUILD FAILED: ", cmd.join(" ")
        if errs.len > 0: echo "first error: ", errs[0]
        echo tail.join("\n")
      return 1
    if path.len == 0: path = guessHtml(nimFile)
    if path.len == 0 or not fileExists(path):
      echo "built, but could not find the output file (run without -d:nimibQuiet so nimib logs where it saves)"
      return 1
    rep = check(path, nimFile)
  if asJson:
    echo pretty(rep)
  else:
    echo "output: ", rep["file"].getStr
    for k, v in rep["info"]: echo "  ", k, ": ", show(v)
    for w in rep["warnings"]: echo "WARNING: ", w.getStr
    for e in rep["errors"]: echo "ERROR: ", e.getStr
    echo(if rep["errors"].len == 0: "OK" else: "FAILED")
  if rep["errors"].len > 0: 1 else: 0

quit main()
