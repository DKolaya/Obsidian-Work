# Vault Rules

Placement, frontmatter, and tag rules for this Obsidian vault. AI editors: follow these mechanically — do not guess.

## Placement decision tree

Answer in order; first "yes" wins.

1. Unprocessed capture / raw import landing? → `01_Inbox` (must graduate out once processed — inbox stays empty)
2. Daily note? → `02_Daily`
3. Task list / todo rollup? → `03_Todos`
4. Time-bound deliverable with an end state? → `04_Projects/Active` (or `Backlog`, `Done`)
5. Meeting note? → `07_Meetings`
6. Template? → `08_Templates`
7. Superseded, frozen, or provenance-only? → `90_Archive` (never leave "SUPERSEDED" notes in active folders)
8. About a work domain I own (clients, database, devops, development, team)? → `05_Areas/<Domain>/`
9. Reusable work artifact you'd hand a coworker (API payloads, runbooks, scripts, vendor docs, snippets, platform comparisons)? → `06_Resources/<Topic>/`
10. Meta "how I work" (AI/agent workflows, prompts, tooling, this vault's structure)? → `09_Reference/<Topic>/`

The 05/06/09 line: **Areas** = domains of responsibility. **Resources** = artifacts for doing work. **Reference** = process/tooling/meta about how work gets done.

Exception on record: `05_Areas/Development/Performance Review Notes.md` stays in Development (career note; too few career notes to justify its own area yet).

## Frontmatter schema

Every note. Exact key order. No BOM before opening `---`.

```yaml
---
title:      # required
created:    # required, YYYY-MM-DD
type:       # required: project|area|resource|reference|meeting|daily|template|index|report|import|dashboard|todo
source:     # optional — wikilink or URL; omit key entirely if none
tags:       # required, at least 1
---
```

`type` by location: `04_Projects` → `project`; `05_Areas` content → `area`; `06_Resources` → `resource`; `09_Reference` → `reference`; any `<Topic> Index.md` → `index`; `08_Templates` → `template`; dashboards → `dashboard`; todo rollups → `todo`; archived imports → `import`; dated point-in-time reports → `report`.

## Tag taxonomy

Namespaced only, in frontmatter:

- `area/<domain>` — development, database, devops, intacct, career, team, clients
- `project/<slug>` — ai-initiative, el, fpa, midas, deferred-transactions, …
- `resource/<kind>` — api, vendor, runbook, script, snippet (kind of artifact, NOT domain — domain uses `area/*`)
- `topic/<subject>` — subject matter of reference notes: codex, claude-code, ai-workflows, ai-platforms, prompting, vault-structure, obsidian, …
- `imported/<source>` — onenote, teams, …
- `todo/<scope>` — work, …

Flat tag whitelist (only these allowed unnamespaced): `dashboard`, `meta`, `work`. Everything else must be namespaced or dropped. Body hashtags (`#important` etc.) are free-form and exempt.

Infra files exempt from frontmatter rule: `CLAUDE.md`, `README.md`, `scripts/README.md`.

## Index rule

Any subfolder with 2+ notes requires `<Topic> Index.md` (type: index) listing every note in that folder with a one-line description. New note in an indexed folder → add it to the index in the same edit.

## Entry point

`Home.md` (vault root) is the single MOC/dashboard. New top-level content must be reachable from `Home.md` directly or via a linked index. No other root-level dashboards.

## Intentionally empty folders

`02_Daily`, `04_Projects/Backlog`, `04_Projects/Done`, `06_Resources/Architecture`, `06_Resources/Snippets`, `scripts/` — structure placeholders, do not delete or fill with misc.

## Non-note folders

`data/` — external clones and JSON metadata (e.g. MudBlazor repo), not vault notes; never audit or reorganize its contents. `scripts/` — utility scripts, linked from `06_Resources/Scripts/Script Index.md`.
