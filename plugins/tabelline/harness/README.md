# Testing the tabelline skills

Same two layers as the nimib plugin ([its harness](../../nimib/harness/README.md)).

## 1. Everything the skills teach runs (`check_snippets.nim`, in CI)

```sh
nimble install -y "https://github.com/pietroppeter/tabelline@#v0.1.0"   # from a folder that is not a nimble project
nimble install -y nimib
nim r plugins/tabelline/harness/check_snippets.nim
```

- every ```` ```nim ```` fence in a skill's Markdown that imports tabelline is compiled and run;
  when the next fence is ```` ```text ````, the output must be that text, so the tables shown in
  the skill are the tables tabelline draws; a fence with `nbSave` must write its page;
- every `skills/*/examples/*.nim` runs in a copy of its folder (an example that mentions
  `mdOutput` runs again with `-d:mdOutput` and must write its `.md`).

A fence opts out with `# snippet: skip`. CI (`.github/workflows/tabelline-skills.yml`) runs it
against the release the skill targets and, without blocking, against tabelline's `main`, weekly too.

## 2. Agents with and without the skill (`skills/*/evals/`)

Each case is a folder in the `claude plugin eval` format (`prompt.md`, `case.yaml`, `graders/`),
graded with the nimib plugin's grader:

```sh
python3 plugins/nimib/harness/run_graders.py plugins/tabelline/skills/tabelline/evals/<case> <run_dir> \
   --final-message final.md --json grading.json
```

Where `claude plugin eval` cannot run (cloud containers), run each case with a subagent in an
empty folder, once with the skill and once without, and grade both folders. Results are in the
devlog post [tabelline skill](https://pietroppeter.github.io/skills/devlog/2026-11-10-tabelline-skill.html).
