---
name: nimib-theme
description: Use when writing or changing a nimib page theme or publishing a nimib page, so code blocks stay small, scroll inside their box and are highlighted.
metadata:
  status: personal
---

# Theming a nimib page without breaking code blocks

Code blocks are the part of a themed nimib page that keeps breaking, mostly on phones. Follow these rules whenever you write or change a theme, then run the check before you publish.

## 1. Use a nimib that fixes the base (nimib PR #267 or later)
- nimib's own style rules use `:where()`, so any theme rule overrides them, wherever the theme puts it.
- `pre`, `pre > code` and `.nb-output` scroll sideways, and `text-size-adjust: 100%` is set.
- Markdown code fences tagged `nim` in `nbText` are highlighted when the page is built.

If the page pins an older nimib, write code rules as `body pre > code` and `body pre.nb-output`. Older nimib emits `pre > code {font-size:1.2em}` after the theme, which beats a plain `pre code` rule and gave 20px code.

## 2. Pages published as claude.ai artifacts (or anywhere with a CSP)
- Call `nb.inlineAssets` after `nbInit`. Artifacts block stylesheets from any CDN except Google Fonts, and block scripts from `cdn.jsdelivr.net/gh/`, so without it there is no water.css, no highlight colours and no highlight.js.
- Google Fonts is fine. Remote images do not load, so use data: URIs or ship the images as files of the artifact.

## 3. Theme rules for code
- Code blocks and outputs are 12.5 to 13px, smaller than the body text.
- If you give `pre > code` its own background or border, keep `overflow-x: auto` on it. If only `pre` scrolls, the box stops at the screen edge and the text runs on past it.
- Style `pre.nb-output` as well: it has no `<code>` inside.
- A theme that replaces the highlight CSS must still colour the `hljs-*` classes (keyword, string, comment, number, type, built_in, literal, meta, title).
- Code that is not Nim and not an `nbCode` block (a markdown fence tagged `python`, a raw `<pre>`) is highlighted only by highlight.js, so keep highlight.js on (inline it for artifacts), or highlight it at build time. Mark plain output blocks with `language-text` or `nb-output`.

## 4. Check before publishing
The checks ship with this skill, in `scripts/` next to this file. If they are not there (e.g. the skill was saved to a claude.ai account without them), fetch them from [the skills repo](https://github.com/pietroppeter/skills/tree/main/plugins/nimib/skills/nimib-theme/scripts). Run the phone check on the built page (needs Playwright with Chromium):

```sh
node <this skill's folder>/scripts/phonecheck.js path/to/page.html
```

It must print only ✓: the page is not wider than 390px, code is 11 to 14px, every block scrolls inside its box, and every code block is highlighted. Also look at a 390px-wide screenshot of one long code block.

For a page that is not built with nimib (or has raw `<pre>` blocks), `python3 <this skill's folder>/scripts/codeblocks.py path/to/page.html` highlights them at build time with Pygments and adds the scroll rules.

## 5. Publish
Publish the built HTML as a claude.ai artifact, and republish to the same slug when the page changes.
