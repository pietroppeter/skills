#!/bin/sh
# Fetches nimib main (before #267) and its dependencies into $DEMO_OLD_DEPS
# (default docs/deps-old, not committed), for the "before" build of demo.nim.
set -e
here=$(cd "$(dirname "$0")" && pwd)
deps=${DEMO_OLD_DEPS:-$here/../../deps-old}
mkdir -p "$deps"
while read -r name repo commit; do
  d="$deps/$name"
  if [ "$(git -C "$d" rev-parse HEAD 2>/dev/null)" != "$commit" ]; then
    rm -rf "$d" && git init -q "$d"
    git -C "$d" fetch -q --depth 1 "https://github.com/$repo" "$commit"
    git -C "$d" checkout -q FETCH_HEAD
  fi
done <<DEPS
nimib pietroppeter/nimib cf850ee33409859a22b03ed15792a17b12056406
fusion nim-lang/fusion 562467452b32cb7a97410ea177f083e6d8405734
markdown soasme/nim-markdown 995405b78fb49b7658b7f0d94efe1b52f86c0a85
parsetoml NimParsers/parsetoml d297f5a81be2472905d367aa675dcbbca6e7a5d2
jsony treeform/jsony ce1ea84458c721947bd8e86ec065eeefab2656f1
DEPS

exit 0
