---
name: easy-review
description: Use whenever you hand work back to Pietro (a PR, a page, a release, a change he must check), so he can review and act on it from his phone in a tap or two.
metadata:
  status: draft
---

# Make every result easy to review from the phone

Assume Pietro is on his phone, always. He can tap links, look at pictures and press buttons; he cannot run commands, open local paths or read long diffs comfortably. Every reply that delivers work gives him what he needs to review it and act on it without a laptop.

## Links, always clickable
- A PR: link it. A pushed change to an open PR: link the PR again, not just "pushed".
- Anything rendered (a page, a docs site, a nimib explainer): publish it as an artifact (publish-artifact skill) and link that. Until then, a rendered preview link, e.g. `https://raw.githack.com/<owner>/<repo>/<branch>/<path>.html`.
- A file: link it on GitHub (`https://github.com/<owner>/<repo>/blob/<branch>/<path>`), never a bare local path.
- Settings he must change: the direct settings URL (e.g. `https://github.com/<owner>/<repo>/settings/pages`), with what to pick.

## Releases: one tap to create
When a release is due, do not tell him to create it: give a prefilled link to GitHub's new-release form, with the new tag, title and notes filled in:

```text
https://github.com/<owner>/<repo>/releases/new?tag=v0.4.4&target=main&title=v0.4.4&body=<url-encoded notes>
```

He opens it, checks, and presses *Publish release*. After it exists, link the release page.

## Show, don't describe
- A visual change: attach a phone-width (390px) screenshot, before and after when it fixes something.
- A rule or decision: one line of evidence (a check's output, a number), not a paragraph.

## Keep it skimmable
- Lead with the result and the one thing he needs to do, if any.
- One link per thing, named by what it is ("PR #3", "the docs page"), not "here".
