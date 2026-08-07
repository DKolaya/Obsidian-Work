# Vault Rules

Placement, frontmatter, and tag rules for this Obsidian vault. Applies to every AI editor (Claude, Codex, Copilot, Gemini, …). Follow mechanically — do not guess. `CLAUDE.md` just points here; this file is canonical.

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

Infra files exempt from frontmatter rule: `AGENTS.md`, `CLAUDE.md`, `README.md`, `scripts/README.md`.

## Project lifecycle (avoid staleness)

`04_Projects/Active` drifts stale fastest — sub-plans linger after their work is done, and a project's own status log stops getting updated once nobody's actively looking at it. Check for this actively, don't wait to be asked:

- **One live overview per initiative.** A project gets one main note in `Active` (status/links/backlog) plus, at most, sub-plan notes that are still genuinely in-progress. A sub-plan whose own task list (§T-style or checkbox) is 100% done (deferred/optional items don't count against this) is not "active" anymore, even if nobody moved it.
- **Fold-and-archive immediately, not on next review.** The moment a `## Status Log` entry you're writing would report a sub-plan's last non-deferred, non-optional task as done, archive it in that *same* edit — don't leave it for a later staleness pass. Steps: (1) add one line to the parent project's `## Status Log` summarizing the outcome and linking the sub-plan's new location, (2) move the sub-plan to `90_Archive/Repo Planning/<repo-or-topic>/<date>/`, (3) add/update an index in that archive folder (index rule below still applies there), (4) remove the parent's link to the old Active path, (5) remove its line from `Project Index.md` (sub-plans are never indexed there in the first place — see Index rule).
- **Move to Done on real completion, not on a clean status log.** A quiet status log doesn't mean done — check repo/PR state before assuming. Conversely, don't block a move to `04_Projects/Done` on a trailing loose end (an open PR, an unmerged branch); move it and note the loose end in the status log instead.
- **Don't reclassify silently.** Moving something to Done, archiving a sub-plan, or merging project notes changes the record of what's finished — confirm with Drew before doing it unless the evidence is unambiguous (e.g. the sub-plan's own tasks are explicitly all checked done). When evidence is mixed or you're relying on the note's prose rather than a checked task list, ask rather than guess.
- **Watch for split/duplicate tracking.** If two index sections (or two notes) cover the same project, that's drift — merge into one; don't leave a project split across an "Active" list and an "Imported Active Projects" list, or similar.

## Index rule

Any subfolder with 2+ notes requires `<Topic> Index.md` (type: index) listing every note in that folder with a one-line description. New note in an indexed folder → add it to the index in the same edit.

**Exception — `04_Projects/Project Index.md`:** one bullet per *initiative*, not per file. A sub-plan note (see Project lifecycle above) never gets its own bullet, indented or otherwise — the parent initiative's own note already links it in its body (e.g. under `## Notes`), and that's the only place a sub-plan should be discoverable from. Before adding a new note under `04_Projects/Active` to this index, ask: is this a new initiative, or a sub-plan of one already listed? Only the former gets a bullet.

## Entry point

`Home.md` (vault root) is the single MOC/dashboard. New top-level content must be reachable from `Home.md` directly or via a linked index. No other root-level dashboards.

## Intentionally empty folders

`04_Projects/Backlog`, `04_Projects/Done`, `06_Resources/Architecture`, `06_Resources/Snippets`, `scripts/` — structure placeholders, do not delete or fill with misc.

`02_Daily` holds exactly one file at a time — today's auto-generated briefing from `morning-vault-sync`, replaced each weekday morning (not a growing archive; the permanent record lives in `09_Reference/Vault/Sync Log/`). Never manually add other notes here.

## Non-note folders

`data/` — external clones and JSON metadata (e.g. MudBlazor repo), not vault notes; never audit or reorganize its contents. `scripts/` — utility scripts, linked from `06_Resources/Scripts/Script Index.md`.
