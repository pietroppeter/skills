# skills

Pietro's personal [Claude skills](https://code.claude.com/docs/en/skills), kept in one place
so they are versioned and can be promoted into project repos when they're ready.

Docs (built with [nimib](https://github.com/pietroppeter/nimib)): https://pietroppeter.github.io/skills/

## Skills

| Plugin | Skill | Status | What it does |
|---|---|---|---|
| nimib | [nimib-theme](plugins/nimib/skills/nimib-theme/SKILL.md) | personal | Theme a nimib page so code blocks and outputs stay small, scroll inside their box and are highlighted, checked at phone width. |
| phone-first | [publish-artifact](plugins/phone-first/skills/publish-artifact/SKILL.md) | personal | Publish any page we build as a claude.ai artifact: self-contained, phone check, republish to the same link. |

Status is `draft` (being written), `personal` (in use from this repo or my account),
or `promoted: <repo>` (copied into a project repo's `.claude/skills/`; this copy stays the source of truth).

## Layout

```
.claude-plugin/marketplace.json      the marketplace: lists the plugins below
plugins/<topic>/                      one plugin per topic (nimib, phone-first, ...)
  .claude-plugin/plugin.json
  skills/<skill>/SKILL.md             one folder per skill, exactly one level under skills/
  skills/<skill>/scripts/...          helper scripts the skill uses
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

**One project repo, without copying.** Add to that repo's `.claude/settings.json`:

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
sh docs/deps.sh          # fetch nimib and its deps at pinned commits into docs/deps (not committed)
nim r docs/index.nim     # writes docs/index.html: a catalog read from every SKILL.md
nim r docs/devlog/<post>.nim  # each devlog post, e.g. nimib_theme.nim
node plugins/nimib/skills/nimib-theme/scripts/phonecheck.js docs/index.html docs/devlog/*.html
```

The **devlog** (`docs/devlog/`) has one explainer post per skill: why each rule is there, with evidence.
A post is a nimib file that sets `nb.doc.filename` to `YYYY-MM-DD-<slug>.html`; the index lists it automatically.

GitHub Pages serves `docs/` from `main`.
