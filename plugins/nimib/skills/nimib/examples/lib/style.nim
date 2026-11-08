## The style module: every colour and CSS rule of the example pages, from named tokens.
import std/json
import nimib

const
  tokens = {"--note": "#3b82f6", "--warning": "#d97706", "--danger": "#dc2626"}
  css = """
.callout { padding: .5em 1em; border-left: 4px solid var(--note); }
.callout.warning { border-left-color: var(--warning); }
.callout.danger { border-left-color: var(--danger); }
"""

proc useExampleStyle*(nb: var Nb) =
  ## Add the tokens and the CSS of the custom blocks to the default theme.
  var root = ":root {"
  for (name, value) in tokens:
    root.add " " & name & ": " & value & ";"
  root.add " }"
  nb.doc.context["nb_style"] = %(nb.doc.context["nb_style"].getStr &
    "<style>" & root & css & "</style>")
