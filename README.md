# skills

Pietro's personal [Claude skills](https://code.claude.com/docs/en/skills), kept in one place
so they are versioned and can be promoted into project repos when they're ready.

Docs (built with [nimib](https://github.com/pietroppeter/nimib)): https://pietroppeter.github.io/skills/

## Skills

| Plugin | Skill | Status | What it does |
|---|---|---|---|
| nimib | [nimib](plugins/nimib/skills/nimib/SKILL.md) | draft | Write, build and debug nimib 0.4 documents: blocks, config and paths, nbJs/karax, Markdown output; `nbcheck.py` builds a page and flags what renders wrong. |
| nimib | [nimib-blocks](plugins/nimib/skills/nimib-blocks/SKILL.md) | draft | Write nimib pages with blocks instead of HTML: when to make a custom block, how, and where styles and colours go; `drift.nim` counts what drifted. |
| nimib | [nimib-theme](plugins/nimib/skills/nimib-theme/SKILL.md) | personal | Theme a nimib page so code blocks and outputs stay small, scroll inside their box and are highlighted, checked at phone width. |
| nimib | [nimibook](plugins/nimib/skills/nimibook/SKILL.md) | draft | Create, build and publish nimibook books; `bookcheck.py` checks every chapter, the sidebar and prev/next links. |
| nimib | [nimib-maintainer](plugins/nimib/skills/nimib-maintainer/SKILL.md) | draft | Maintain the nimib repos: releases, CI, README/docs sync, downstream checks, triage, the nimib-land move. |
| phone-first | [publish-artifact](plugins/phone-first/skills/publish-artifact/SKILL.md) | personal | Publish any page we build as a claude.ai artifact: self-contained, phone check, republish to the same link. |
| phone-first | [easy-review](plugins/phone-first/skills/easy-review/SKILL.md) | draft | Hand work back so it can be reviewed from the phone: PR and artifact links, release link with tag + notes to paste, phone-width screenshots. |

Status is `draft` (being written), `personal` (in use from this repo or my account),
or `promoted: <repo>` (copied into a project repo's `.claude/skills/`; this copy stays the source of truth).

## Layout

```
.claude-plugin/marketplace.json      the marketplace: lists the plugins below
plugins/<topic>/                      one plugin per topic (nimib, phone-first, ...)
  .claude-plugin/plugin.json
  skills/<skill>/SKILL.md             one folder per skill, exactly one level under skills/
  skills/<skill>/scripts/...          helper scripts the skill uses
  skills/<skill>/evals/<case>/        test cases (prompt.md; case.yaml + graders/ where graded)
  harness/                            plugin-wide test tools (nimib plugin: snippet check, graders)
docs/                                 nimib sources of the docs site (index.nim -> index.html)
```

## Using these skills

**claude.ai account (works everywhere, including the phone app and cloud sessions).**
Ask Claude to post a "save skill" card from a `SKILL.md` here and tap Save,
or upload the skill folder as a zip in claude.ai Settings → Capabilities → Skills.
Re-save after the skill changes here.

**Claude Code, as a plugin.**

```
/plugin marketplace add pietroppeter/skills
/plugin install nimib@pietroppeter-skills
```

or, on Claude Code 2.1.275 or later, in one step:

```
/plugin install nimib --marketplace pietroppeter/skills
```

**Every Claude cloud thread of a project (tested 2026-11-08).** Add to the cloud environment's setup script:

```sh
if command -v claude >/dev/null; then
  claude plugin marketplace add pietroppeter/skills && claude plugin install nimib@pietroppeter-skills && claude plugin install phone-first@pietroppeter-skills || true
fi
```

Each new thread then installs the latest `main`. A repo's `.claude/settings.json`
(`extraKnownMarketplaces` + `enabledPlugins`) is **not** read by project threads, which start outside the repo;
it does work for Claude Code opened inside the repo on a laptop:

```json
{
  "extraKnownMarketplaces": {
    "pietroppeter-skills": { "source": { "source": "github", "repo": "pietroppeter/skills" } }
  },
  "enabledPlugins": { "nimib@pietroppeter-skills": true, "phone-first@pietroppeter-skills": true }
}
```

**Promote into a project repo.** Copy `plugins/<topic>/skills/<skill>/` to
`<repo>/.claude/skills/<skill>/` in a PR, then set the skill's status here to `promoted: <repo>`.
Keep editing it here and re-copy, or hand ownership to the project repo and say so in the status.

## Docs

```sh
sh docs/build.sh        # fetch pinned nimib, build index + devlog posts into _site/
node plugins/nimib/skills/nimib-theme/scripts/phonecheck.js _site/index.html _site/devlog/*.html
```

Built HTML is not committed (CI fails if any is). CI (`.github/workflows/docs.yml`, same layout as tabelline's)
builds the docs on every PR and push, runs the phone check, and on `main` deploys `_site/` with GitHub Pages'
own Actions deployment (Pages source: *GitHub Actions*): https://pietroppeter.github.io/skills/

The **devlog** (`docs/devlog/`) has one explainer post per skill: why each rule is there, with evidence.
A post is a nimib file that sets `nb.doc.filename` to `YYYY-MM-DD-<slug>.html`; the index lists it automatically.
