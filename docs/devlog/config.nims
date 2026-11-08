# Dependencies from deps.sh (SKILLS_DOCS_DEPS, default ./deps).
import std/os
let deps = getEnv("SKILLS_DOCS_DEPS", thisDir() / ".." / "deps")
for d in ["nimib", "fusion", "markdown", "parsetoml", "jsony"]:
  switch("path", deps / d / "src")
switch("hints", "off")
