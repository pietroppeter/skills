---
tags: [tabelline, nimib]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I want a small nimib page, regions.nim, with a nice table made with tabelline (the Nim library
for display tables, github.com/pietroppeter/tabelline) of these Italian regions: name, population
and area in km². Add the density (people per km²) computed in Nim, format the numbers so they
read well, give the table a title and a source note ("ISTAT, 2024"), and highlight the largest
region by area. Build it so I get regions.html.

Lombardia 10035481 23864; Lazio 5715190 17232; Campania 5590076 13671; Sicilia 4794512 25832;
Veneto 4851972 18345; Piemonte 4252279 25387; Toscana 3664798 22987.
