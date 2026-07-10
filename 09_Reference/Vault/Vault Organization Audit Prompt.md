---
title: Vault Organization Audit Prompt
created: 2026-07-10
type: reference
tags:
  - topic/vault-structure
  - topic/prompting
  - topic/obsidian
  - meta
---

# Vault Organization Audit Prompt

## Purpose

Run this when AI (or you) keep second-guessing where a note belongs — Area vs Resource vs Project vs Reference — and edits start landing in inconsistent spots. Audits the actual folder tree + frontmatter/tag conventions currently in use, finds ambiguity and violations, and outputs a paste-ready placement ruleset for a root instruction file (`CLAUDE.md`/`AGENTS.md`) so future AI edits stop guessing.

## Known gap (found 2026-07-10)

No root-level instruction file exists defining placement rules. `05_Areas`, `06_Resources`, `09_Reference` all hold conceptually similar "ongoing topic" notes with no written rule distinguishing them. Subfolder index-file convention (`<Topic> Index.md`) is used in some subfolders (Team, Clients, Database, DevOps, Development, Runbooks, Scripts, AI Platforms, Codex, Project) but not enforced — nothing states it's mandatory. Frontmatter fields vary (`type` present on some notes, absent on others; tags mix flat terms like `reference` with namespaced ones like `area/development`, `project/el`).

## Full Prompt

```text
You are auditing the organization of my Obsidian vault at [vault root path]. I use a PARA-ish numbered folder system, but I never wrote down the actual rules, so both I and AI editors keep guessing wrong about where new notes go.

STEP 0 — Map current state (report before analyzing):
- List every top-level folder and its immediate subfolders, with file counts.
- List every "<Topic> Index.md" file found and which folder it lives in.
- Sample 3-5 notes per top-level folder and report their frontmatter fields verbatim (don't normalize yet — I want to see the actual inconsistency).
- Report folders that have subfolders with no index file, and subfolders that have an index file with no folder-level rule explaining scope.

STEP 1 — Infer current implicit rules:
- For each top-level folder (00_Home, 01_Inbox, 02_Daily, 03_Todos, 04_Projects, 05_Areas, 06_Resources, 07_Meetings, 08_Templates, 09_Reference, 90_Archive), infer the rule I'm apparently already following, based on what's actually filed there — not on generic PARA theory.
- Flag any two folders whose inferred rules overlap or contradict (e.g. "ongoing topic reference" applies to both 05_Areas and 06_Resources).
- Flag any note whose content doesn't match its folder's inferred rule — name the note, its current location, and where it should go instead, with a one-line reason.

STEP 2 — Find structural violations:
- Orphaned notes: not linked from any index and not linked from any other note.
- Duplicate/split topics: the same subject with notes in two different folders.
- Missing indices: subfolders with 2+ notes and no "<Topic> Index.md".
- Frontmatter drift: list every distinct frontmatter schema in use (which fields, in what order) and how many notes use each variant.
- Tag taxonomy drift: list every distinct tag naming convention in use (flat vs namespaced like area/x, project/x) and how many notes use each.

STEP 3 — Produce the fix:
- A placement decision tree: given a new note's content, which folder does it go in, expressed as an ordered set of yes/no questions an AI editor can follow mechanically (no folder should require judgment calls if avoidable).
- A canonical frontmatter schema: required fields, optional fields, exact key order, one example per note type (project, area, resource, reference, meeting, daily, template).
- A canonical tag taxonomy: one naming convention only, migration mapping from every variant found in Step 2 to the new convention.
- An index-file rule: state exactly when a subfolder requires an "<Topic> Index.md" (e.g. "any subfolder with 2+ notes") and what that index file must contain.
- A list of every specific move/rename/merge needed to bring existing notes into compliance — file path, action, destination.

OUTPUT:
- Step 0 map (concise, table format).
- Step 1 findings: inferred rule per folder + overlaps/contradictions + misfiled notes.
- Step 2 findings: orphans, duplicates, missing indices, frontmatter/tag drift — as counts + examples, not exhaustive lists if there are many.
- Step 3 deliverables: decision tree, frontmatter schema, tag taxonomy + migration map, index-file rule, move/rename/merge list.
- A ready-to-paste block for a root CLAUDE.md/AGENTS.md containing the decision tree + frontmatter schema + tag rule + index rule, condensed to the minimum an AI editor needs to stop guessing.

RULES:
- Base every inferred rule on what's actually in the vault, not on generic PARA/Zettelkasten theory — I want rules that match how I actually use this vault, not a textbook system.
- Don't propose a full re-architecture unless the current structure is genuinely broken — prefer the smallest rule set that resolves the actual ambiguity you found.
- Cite specific file paths for every violation. No finding without a path.
- If a rule can't be inferred because too few notes exist in a folder to tell, say so explicitly rather than inventing one.
```

## Short Prompt

```text
Audit my Obsidian vault's folder structure (00_Home through 90_Archive). Map what's actually filed where, infer the implicit placement rule per folder, flag overlapping/contradictory rules (esp. 05_Areas vs 06_Resources vs 09_Reference), flag misfiled notes, missing indices, and frontmatter/tag drift. Output a mechanical placement decision tree, a canonical frontmatter schema, a canonical tag taxonomy with migration map, and a paste-ready CLAUDE.md/AGENTS.md block so AI editors stop guessing where new notes go.
```

## Suggested follow-up ask

```text
Apply the move/rename/merge list from the audit. Before moving anything, show me the full list of file moves so I can confirm, since some of these notes are linked from other notes and I don't want broken links.
```

## Related

- [[AI Agent Workflow Audit Prompt]] — same audit pattern, applied to AI coding workflow instead of vault structure.
