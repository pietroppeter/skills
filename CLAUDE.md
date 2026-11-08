# Working in this repo

Pietro's personal Claude skills. He works mostly from his phone: changes arrive as PRs he merges there.

- A skill is `plugins/<topic>/skills/<skill>/SKILL.md`, exactly one level under `skills/` (deeper is not discovered).
  Group related skills by topic plugin; add a new plugin to `.claude-plugin/marketplace.json`.
- SKILL.md frontmatter: `name` (= folder name), `description` (when to use it, one sentence), and
  `metadata.status`: `draft`, `personal`, or `promoted: <owner/repo>`.
- When adding or changing a skill: update the table in `README.md`, bump the plugin `version` in its `plugin.json`,
  rebuild the docs (`sh docs/build.sh`), run `phonecheck.js` on `_site/index.html _site/devlog/*.html`
  (must print only ✓; CI runs it too), and run `claude plugin validate .` if the CLI is available.
- New skill, or a real change to one: write or update its devlog post in `docs/devlog/` (why each rule exists, with evidence).
- Built HTML is not committed (CI deploys to gh-pages). Publish `_site/index.html` plus `_site/devlog/*.html` (same relative paths) as one claude.ai artifact (slug e889b2b5-f103-4694-998b-a5a9794462c3) and republish to the same slug on changes.
- Write "nimib" (voice dictation turns it into IMIB/NIMIB).
