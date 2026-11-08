#!/bin/sh
# Builds the docs site into _site/ (index + devlog posts). Used by CI and locally:
#   sh docs/build.sh            # then publish _site/ (CI deploys it to gh-pages)
set -e
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
sh docs/deps.sh
nim r docs/index.nim
for post in docs/devlog/*.nim; do nim r "$post"; done
rm -rf _site && mkdir -p _site/devlog
cp docs/index.html _site/
cp docs/devlog/*.html _site/devlog/
