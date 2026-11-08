# Testing the nimib skills

Skills are code that rots: nimib changes, and an example that compiled last month can fail
today. Two layers keep them honest. Why, and the first results: the devlog post
[nimib skills: tested by building](https://pietroppeter.github.io/skills/devlog/2026-11-08-nimib-skills.html).

## 1. Everything the skills teach is built (`check_snippets.py`, run in CI)

- every `skills/*/examples/*.nim` is built and checked with `skills/nimib/scripts/nbcheck.py`;
  pages with nbJs/karax are also opened in headless Chromium (`browser_check.mjs`);
- every complete nimib document in a ```` ```nim ```` fence of any skill markdown (an
  `import ... nimib` line and a top-level `nbSave`) is extracted and built;
- every book declared in a fence (`nimibookCli`) is built with `init`/`build` and checked with
  `skills/nimibook/scripts/bookcheck.py`.

Fragments that are not complete documents should have their pattern covered by an example file.
A fence can opt out with a `# snippet: skip` line. Subfolders of `examples/` (such as `lib/`)
hold modules the examples import; they are not built as pages.

## 2. Agents are benchmarked with and without the skills (`skills/*/evals/`)

Each graded case is a folder in the `claude plugin eval` format: `prompt.md` (settings and the
request), `case.yaml`, and `graders/`. Graders are mostly deterministic checks on the files the
agent produced: the HTML exists (nimib only writes it if the program compiled and ran), contains
code outputs, the image path resolves, the page holds no HTML or colours... An LLM judge covers
what a regex cannot. nimib-blocks' cases are prompts with their pass criteria in the text.

```sh
bash plugins/nimib/harness/setup-nim.sh        # Nim + nimib + nimibook + karax + libpcre, works in sandboxes
python3 plugins/nimib/harness/check_snippets.py   # layer 1
claude plugin eval plugins/nimib --scaffold --allow-tools Write Edit Bash \
   --judge-model sonnet --runs 3                  # layer 2 (real, billed model runs)
```

Where `claude plugin eval` cannot run (in cloud containers it runs as root with a read-only
working folder), run each case with a subagent in its own folder and grade the folder:

```sh
python3 plugins/nimib/harness/run_graders.py plugins/nimib/skills/nimib/evals/<case> <run_dir> \
   --final-message final.md --json grading.json
```

Re-run both after each nimib or nimibook release, and when a skill changes. When a with-skill
run fails, read its transcript: the fix is usually a clearer explanation in the skill, not
another rule. When a check passes just as often without the skill, the advice it tests may be
unnecessary: consider pruning it.
