#!/bin/sh
# Builds demo.nim four ways and screenshots each at 390px with CDNs blocked like a claude.ai artifact.
#   old:    nimib main (before #267), naive theme
#   new:    nimib #267, naive theme, no nb.inlineAssets
#   inline: nimib #267, naive theme, nb.inlineAssets
#   good:   nimib #267, theme + pre.nb-output rule, nb.inlineAssets
# Writes docs/devlog/img/demo-*.png. Run from anywhere; needs Nim, Playwright.
set -e
here=$(cd "$(dirname "$0")" && pwd)
docs=$here/../..
sh "$docs/deps.sh"; sh "$here/deps-old.sh"
out=$(mktemp -d)
build() { deps=$1; name=$2; shift 2
  p=""; for d in nimib fusion markdown parsetoml jsony; do p="$p --path:$deps/$d/src"; done
  (cd "$here" && env DEMO_OUT="$out/$name.html" "$@" nim r --skipParentCfg --hints:off $p --nimcache:"$out/nc-$name" demo.nim >/dev/null)
}
build "$docs/deps-old" old
build "$docs/deps" new
build "$docs/deps" inline DEMO_INLINE=1
build "$docs/deps" good DEMO_INLINE=1 DEMO_GOOD=1
node "$here/shots.js" "$out"
mkdir -p "$docs/devlog/img"
for n in old new inline good; do cp "$out/$n.png" "$docs/devlog/img/demo-$n.png"; done
node "$docs/../plugins/nimib/skills/nimib-theme/scripts/phonecheck.js" "$out"/old.html "$out"/new.html "$out"/good.html || true
