## The blocks module: the custom blocks of the example pages. Classes only, no styles:
## the classes are styled in style.nim.
import std/[strformat, json]   # JsonNode and % for partials
import nimib

type CalloutKind* = enum ckNote = "note", ckWarning = "warning", ckDanger = "danger"

newNbBlock(NbCallout):
  level: CalloutKind   # an enum, so a typo fails to compile; `$level` is the CSS class
  message: string
  toHtml:
    &"""<div class="callout {blk.level}"><strong>{blk.level}:</strong> {blk.message}</div>"""

func callout*(nb: var Nb, message: string, level = ckNote) =
  nb.add newNbCallout(level = level, message = message)

template nbCallout*(message: string, level = ckNote) =
  ## A highlighted note. `nbCallout("Check the units", ckWarning)`
  nb.callout(message, level)

func nbCalloutToMd(blk: NbBlock, nb: Nb): string =
  let blk = blk.NbCallout
  "> **" & $blk.level & ":** " & blk.message
nbToMd.funcs["NbCallout"] = nbCalloutToMd

newNbBlock(NbDetails of NbContainer):
  summary: string
  toHtml:
    withNewlines:
      &"<details><summary>{blk.summary}</summary>"
      nbContainerToHtml(blk, nb)
      "</details>"

template nbDetails*(tsummary: string, body: untyped) =
  ## A collapsible section holding other blocks.
  # template parameters are substituted everywhere, also on the left of `summary = ...`,
  # so they must not share a name with a block field (hence `tsummary`)
  let blk = newNbDetails(summary = tsummary)
  nb.withContainer(blk):
    body
  nb.add blk

func licenseFooter(blk: JsonNode, nb: Nb): string =
  """<span class="nb-small">CC-BY 4.0</span>"""

proc useLicenseFooter*(nb: var Nb) =
  ## Replace the centre of the footer with the license.
  nb.backend.partials["footer_center"] = licenseFooter
