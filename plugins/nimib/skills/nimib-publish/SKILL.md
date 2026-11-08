---
name: nimib-publish
description: Use when publishing a nimib page as a claude.ai artifact (or anywhere with a content security policy), so its styles and highlighting still load and Pietro can read it on his phone.
metadata:
  status: personal
---

# Publishing a nimib page as a claude.ai artifact

Pietro reads nimib pages on his phone, so every nimib page we build is also published as a claude.ai artifact.

## 1. Make the page self-contained
- Call `nb.inlineAssets` after `nbInit` (needs nimib with #267). Artifacts block stylesheets from any CDN except Google Fonts, and scripts from `cdn.jsdelivr.net/gh/`. Without it there is no water.css, no highlight colours and no highlight.js.
- Google Fonts is fine.
- Remote images do not load: use data: URIs, or publish the images as files of the artifact.
- If the page has its own theme, follow the nimib-theme skill too.

## 2. Check
Run the phone check from the nimib-theme skill on the built page (`../nimib-theme/scripts/phonecheck.js` from this folder, or from [the skills repo](https://github.com/pietroppeter/skills/tree/main/plugins/nimib/skills/nimib-theme/scripts)). It must print only ✓.

## 3. Publish
- Publish the built HTML as a claude.ai artifact and give Pietro the link, along with any PR.
- When the page changes, republish to the same artifact (same slug), so his link keeps working.
- A page made of several HTML files (an index and posts, say) goes up as one artifact with the same relative paths.
