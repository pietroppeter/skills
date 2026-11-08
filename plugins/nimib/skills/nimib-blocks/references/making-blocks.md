# Making a block (nimib 0.4)

Two shapes cover almost everything: a **leaf** block (fields, no blocks inside) and a
**container** block (other blocks inside, like a card or a gallery). Both are made with
`newNbBlock`, which defines the type, a constructor `newNbX(...)` and registers `toHtml` as the
renderer for the HTML backend.

## A leaf block

```nim
import std/strformat
import nimib

type NotaKind* = enum nkPlain = "", nkInfo = "info", nkWarning = "warning"

newNbBlock(NbNota):
  tipo: NotaKind         # not `kind`: every block already has a `kind` field
  text: string
  toHtml:
    &"""<div class="nota {blk.tipo}">{markdownToHtml(blk.text)}</div>"""

func nota*(nb: var Nb, text: string, tipo = nkPlain) =
  nb.add newNbNota(tipo = tipo, text = text)

template nbNota*(text: string, tipo = nkPlain) =
  nb.nota(text, tipo)
```

Put the logic in a `func` and keep the template a one-liner: template parameters are substituted
everywhere in its body, including the left side of named arguments, so
`template nbNota(text: string) = nb.add newNbNota(text = text)` expands to
`newNbNota("..." = "...")` and fails.

## A container block

```nim
newNbBlock(NbGalleria of NbContainer):
  label: string
  toHtml:
    &"""<div class="galleria" tabindex="0" aria-label="{blk.label}">""" &
      nbContainerToHtml(blk, nb) & "</div>"

template nbGalleria*(what: string, body: untyped) =
  let galleria = newNbGalleria(label = what)   # parameter name differs from the field
  nb.withContainer(galleria):
    body                                       # nbText, nbCode, ... go inside the gallery
  nb.add galleria
```

Containers nest: a gallery of cards is an `nbGalleria` whose body is `nbScheda` blocks, each a
container too. The blocks inside stay blocks, so another backend can render them.

## Often a template is enough

When the new thing is a fixed sequence of existing blocks, compose them:

```nim
template nbEsempio*(title: string, body: untyped) =
  nbText "**" & title & "**"
  nbCode: body
```

## The CSS

`toHtml` writes classes only. The rules for `.nota`, `.nota.warning`, `.galleria` go in the
style module, with colours from tokens (`var(--warning)`), and reach the page the way the theme
adds its CSS (for the default theme, appended to `nb.doc.context["nb_style"]`).

## Pitfalls

- A block renders nothing: you forgot `nb.add blk`, or the active backend has no renderer for it
  (`newNbBlock` registers HTML only; add `nbToMd.funcs["NbNota"] = ...` for Markdown).
- `toHtml` is a `func`: no `echo`, file IO or globals. Compute in the template, store in fields.
- Don't name a field `kind`: it is the block's type tag.
- Fields must serialize to JSON (strings, numbers, enums, seqs and objects of those).
- Escape user text that may contain `<` or `&` (`xmltree.escape`).
