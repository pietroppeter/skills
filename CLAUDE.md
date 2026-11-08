# Working in this repo

Pietro's personal Claude skills. He works mostly from his phone: changes arrive as PRs he merges there.

- A skill is `plugins/<topic>/skills/<skill>/SKILL.md`, exactly one level under `skills/` (deeper is not discovered).
  Group related skills by topic plugin; add a new plugin to `.claude-plugin/marketplace.json`.
- SKILL.md frontmatter: `name` (= folder name), `description` (when to use it, one sentence), and
  `metadata.status`: `draft`, `personal`, or `promoted: <owner/repo>`.
- When adding or changing a skill: update the table in `README.md`, bump the plugin `version` in its `plugin.json`,
  rebuild the docs (`sh docs/deps.sh && nim r docs/index.nim`), run `phonecheck.js` on `docs/index.html`
  (must print only ✓), and run `claude plugin validate .` if the CLI is available.
- Publish the rebuilt `docs/index.html` as a claude.ai artifact and republish to the same slug on changes.
- Write "nimib" (voice dictation turns it into IMIB/NIMIB).
