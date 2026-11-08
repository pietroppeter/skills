## Custom blocks with newNbBlock (see references/custom-blocks.md and the nimib-blocks skill).
## The page only uses blocks: they are defined in lib/blocks.nim and styled in lib/style.nim.
import nimib
import lib/[blocks, style]

nbInit
nb.title = "Custom blocks"
nb.useExampleStyle
nb.useLicenseFooter

nbCallout("Custom blocks are plain Nim types in nimib 0.4.")
nbCallout("A typo in the kind does not compile.", ckWarning)

nbDetails("Click to see the code that ran"):
  nbCode:
    echo "nested inside <details>"

nbSave
