## Docs for github.com/pietroppeter/skills: a catalog read from every SKILL.md.
## Build from the repo root:  sh docs/deps.sh && nim r docs/index.nim   (writes docs/index.html)
import std/[os, strutils, algorithm, json]
import nimib

const
  repoUrl = "https://github.com/pietroppeter/skills"
  styleCss = staticRead("style.css")
let root = currentSourcePath().parentDir.parentDir

nbInit
nb.doc.filename = root / "docs" / "index.html"
nb.title = "Pietro's skills"
nb.inlineAssets  # artifacts block CDN assets: ship highlight.js inside the page

nb.doc.context["stylesheet"] = %("""
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>""" & styleCss & "</style>")
nb.doc.context["highlight"] = %""   # style.css colours the hljs-* classes
nb.backend.partials["header"] = proc (blk: JsonNode, nb: Nb): string =
  """<header class="masthead"><span class="tab">index</span><a href="""" & repoUrl &
  """">pietroppeter/skills</a></header>"""

type Skill = object
  plugin, name, description, status, body, path: string

proc readSkill(plugin, file: string): Skill =
  ## Split a SKILL.md into its frontmatter fields and body.
  let text = readFile(file)
  let parts = text.split("---\n", maxsplit = 2)
  doAssert parts.len == 3 and parts[0] == "", "no frontmatter in " & file
  result = Skill(plugin: plugin, body: parts[2].strip,
                 path: file.relativePath(root), status: "draft")
  for line in parts[1].splitLines:
    let l = line.strip
    if l.startsWith("name:"): result.name = l["name:".len..^1].strip
    elif l.startsWith("description:"): result.description = l["description:".len..^1].strip
    elif l.startsWith("status:"): result.status = l["status:".len..^1].strip

var skills: seq[Skill]
for pdir in walkDirs(root / "plugins" / "*"):
  for sdir in walkDirs(pdir / "skills" / "*"):
    if fileExists(sdir / "SKILL.md"):
      skills.add readSkill(pdir.lastPathPart, sdir / "SKILL.md")
skills.sort(proc (a, b: Skill): int = cmp(a.plugin & a.name, b.plugin & b.name))

proc demote(md: string): string =
  ## Skill bodies start at `#`: push them two levels down under the page's own headings.
  var inFence = false
  var lines: seq[string]
  for line in md.splitLines:
    if line.startsWith("```"): inFence = not inFence
    lines.add(if not inFence and line.startsWith("#"): "##" & line else: line)
  lines.join("\n")

nbText: """
# Pietro's skills

Personal [Claude skills](https://code.claude.com/docs/en/skills), kept in one repo so they are
versioned, and promoted into project repos when they are ready. Each topic is a plugin;
each skill is a folder with a `SKILL.md`. This page is built from those files, so it is always in step with them.
"""

nbText: """
## How to use them

- **On the phone, everywhere:** ask Claude to post a save card from a skill here and tap *Save*.
  It becomes an account skill, so claude.ai chats and every cloud thread load it.
- **In one project:** a PR copies the skill into that repo's `.claude/skills/`,
  or turns on its plugin in the repo's `.claude/settings.json`.
- **In Claude Code:** `/plugin marketplace add pietroppeter/skills`, then `/plugin install nimib@pietroppeter-skills`.

Status: **draft** is being written, **personal** is in use from here or my account,
**promoted** means a copy lives in a project repo.
"""

var catalog = "<h2>Catalog</h2>\n"
var lastPlugin = ""
for s in skills:
  if s.plugin != lastPlugin:
    if lastPlugin != "": catalog.add "</ul>\n"
    catalog.add "<h3 class=\"plugin\">plugin · " & s.plugin & "</h3>\n<ul class=\"cards\">\n"
    lastPlugin = s.plugin
  let statusClass = s.status.split(":")[0].strip
  catalog.add "<li class=\"card\"><a class=\"name\" href=\"#" & s.name & "\">" & s.name &
    "</a> <span class=\"status " & statusClass & "\">" & s.status & "</span><p>" &
    s.description & "</p><a class=\"src\" href=\"" & repoUrl & "/blob/main/" & s.path &
    "\">" & s.path & "</a></li>\n"
if lastPlugin != "": catalog.add "</ul>\n"
nbRawHtml: catalog

for s in skills:
  nbRawHtml: "<section class=\"skill\" id=\"" & s.name & "\"><p class=\"kicker\">" &
    s.plugin & " / " & s.name & "</p>"
  nbText: s.body.demote
  nbRawHtml: "</section>"

nbSave
