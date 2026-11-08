## Shared look for the docs pages: index-card theme, inlined assets, masthead.
import std/json
import nimib

const
  repoUrl* = "https://github.com/pietroppeter/skills"
  styleCss = staticRead("style.css")

proc useSiteTheme*(nb: var Nb, home = "index.html", tab = "index") =
  nb.inlineAssets  # artifacts block CDN assets: ship highlight.js inside the page
  nb.doc.context["stylesheet"] = %("""
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,600;9..144,800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>""" & styleCss & "</style>")
  nb.doc.context["highlight"] = %""   # style.css colours the hljs-* classes
  let header = "<header class=\"masthead\"><span class=\"tab\">" & tab & "</span><a href=\"" &
    home & "\">pietroppeter/skills</a></header>"
  nb.backend.partials["header"] = proc (blk: JsonNode, nb: Nb): string = header
