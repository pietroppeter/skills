---
tags: [tabelline]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

sales.csv has our quarterly sales by store. Write sales.nim, a Nim program that uses tabelline
(github.com/pietroppeter/tabelline) to turn it into sales.html, a standalone page with one
table: stores grouped by region, revenue in euros without cents, margin as a percentage coloured
from red (low) to green (high), a dash where the margin is missing, and a footnote on the margin
column that says "Gross margin, before overheads.".
