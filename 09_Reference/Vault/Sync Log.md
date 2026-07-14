---
title: Sync Log
created: 2026-07-10
type: report
tags:
  - topic/vault-structure
  - meta
---

# Sync Log

Morning-sync routine run summaries, newest first. Written automatically by the `morning-vault-sync` scheduled task (weekdays 8:15 AM). Each entry: Monday.com items synced, email and Teams action items, GitHub review requests/failing checks, meeting stubs, repo activity, cleanup actions, and anything needing attention.

<!-- Entries appended below by the sync routine. Do not edit entries by hand; add comments in your daily note instead. -->

## 2026-07-14 08:40

24h lookback.

- **Monday.com**: no new items or status changes for Drew on EL Tasks / AI Weekly Tasks boards since 2026-07-13 — all items already reflected in [[03_Todos/Work TODOs]].
- **Email**: no actionable items added. Skipped: Nathan Sawyer's Voluntary Legal Service Plan thread (not addressed to Drew), TS Summer Gathering itinerary (FYI), an appsupport@ ticket notification (MPAS support ticket #131709, informational only), and a Chris Allen follow-up to Nathan.
- **Teams**: search hit a Graph rate limit (429) immediately (0/48 chats scanned) — skipped, no results available this run.
- **GitHub**: no review requests, no open PRs authored by Drew found via `gh search`, no actionable notifications. Previously-flagged [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) no longer appears in search results — left as-is in [[03_Todos/Work TODOs]] pending manual check.
- **Meetings**: none on today's calendar — no stubs created.
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): `CDH_EL` back on `feature/June/30/RTE-TipTap-cleanup` with commit `37a1927` "Pre-develop fix WIP" (2026-07-13) and 41 dirty files — logged in [[04_Projects/Active/EL]]. All other repos unchanged from last run, no new commits: `InternalIntacctQueryApp` (46 dirty, master), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `CDH_FPA`/`Legal_Service`/`MIDAS_GP_MPAS`/`PEF_MPAS.Web` (1 each).
- **Cleanup**: added missing frontmatter to [[04_Projects/Active/EL Editor Feedback Hardening Spec]] (had none), fixed invalid `type: plan` → `type: project` and stripped non-taxonomy tags (`plan`, `editor`) on [[04_Projects/Active/EL Editor Wargames 2026-07-13]], added both plus the existing Warplan to [[04_Projects/Project Index]] (was missing all three). No broken wikilinks found. Inbox has nothing to triage.
- **Needs attention**: `InternalIntacctQueryApp` still dirty (46 files, `master`) across three runs now — likely forgotten work, worth a look. `CDH_EL` working tree is not clean (41 files) with a WIP commit already on the branch — confirm intentional before doing more branch work. Untracked `90_Archive/Repo Planning/` (raw provenance copies of CDH_EL planning docs) carried into this commit pre-existing, not audited for frontmatter (archived raw material, same treatment as OneNote imports). Teams results were fully unavailable this run (rate-limited before any chats scanned).

## 2026-07-13 08:34

72h lookback (Monday morning covers weekend).

- **Monday.com**: no new items or status changes for Drew since 2026-07-09 on EL Tasks / AI Weekly Tasks boards (W1/W2 still In Progress). Nothing added.
- **Email**: 1 new actionable item added to [[03_Todos/Work TODOs]] (## From Email) — Sage Intacct company "LeadingAgeNY-imp" blocked, deactivates in 30 days. Skipped Claude.ai login links, bonus.ly FYI, parking-lot FYI, and an appsupport@ ticket notification (not addressed directly to Drew).
- **Teams**: search hit a Graph rate limit (429) after 23/48 chats scanned — partial results, no @mentions/DMs to Drew found in the chats that were scanned.
- **GitHub**: no review requests. [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) still has a **failing check** (Workers Build) — noted in [[03_Todos/Work TODOs]] (## GitHub). [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2) unchanged, no CI configured.
- **Meetings**: 1 stub created — [[07_Meetings/2026-07-13 TS Dev Team Planning Meeting]] (Patrick, Nate, Shannon, Drew).
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): `CDH_EL` switched to `develop` (from a cleanup branch) with a "Pre-develop fix stash" present, working tree otherwise clean — see attention note. `CDH_FPA` and `MIDAS_GP_MPAS` unchanged, still 1 dirty file each, no new commits. `TRANCY_CargoWise_Integration` clean, PR #2 unchanged. Other dirty repos unchanged from last run: `InternalIntacctQueryApp` (46 files), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `Legal_Service`/`PEF_MPAS.Web` (1 each).
- **Cleanup**: fixed corrupted/broken wikilinks in 6 files ([[04_Projects/Project Index]], [[05_Areas/Database/Database Index]], [[05_Areas/DevOps/DevOps Index]], [[06_Resources/Runbooks/Runbook Index]], [[06_Resources/Scripts/Script Index]], [[90_Archive/OneNote Raw/Drew @ Work]]) plus [[Home]] — all had a mangled `[[MIDAS GP MPAS Service...` link fragment (looked like a botched find/replace from moving that note into `04_Projects/Done`). Re-pointed all MIDAS links to the new `04_Projects/Done/MIDAS GP MPAS Service` location. Frontmatter on recently-touched notes already compliant. Inbox has nothing to triage.
- **Needs attention**: pre-existing uncommitted changes were already in the working tree before this run (not made by this sync) — moved `Example Project` and `MIDAS GP MPAS Service` from `04_Projects/Active` to `04_Projects/Done`, consolidated `Todo Dashboard` into `Work TODOs`. Both moved notes still show open tasks / "State: active" — verify the Done move was intentional. `CDH_EL` now sits on `develop` with a stash named "Pre-develop fix stash" — confirm no in-progress cleanup-branch work needs to be popped/restored before it's lost. Teams search was only partial (rate-limited). `InternalIntacctQueryApp` still dirty (46 files, `master`) across multiple runs now — possible forgotten work.

## 2026-07-10 09:30

First real run (no prior sync commit found — used 24h lookback).

- **Monday.com**: 21 items assigned to Drew across EL Tasks + AI Weekly Tasks boards seeded into [[03_Todos/Work TODOs]] (## Monday.com). 8/8 EL Tasks items already Done except UAT doc (In Progress). AI Weekly W1/W2 In Progress, W3-W13 Not Started. FPA/MIDAS/Deferred Transactions boards not found in workspace — only EL Tasks + AI Weekly Tasks exist.
- **Email**: 1 actionable item added (EL UAT round 1 questionnaire from Shannon Thai). Skipped 2 FYI/notification threads, 3 newsletters, 3 Claude.ai login-link emails.
- **Teams**: no @mentions/DMs to Drew found in last 24h.
- **GitHub**: no review requests. Drew's open PRs: [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) has a **failing check** (Workers Builds). [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2) and [CDHTS/PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350) have no CI configured, no new comments.
- **Meetings**: 3 stubs created — [[07_Meetings/2026-07-10 Trancy CargoWise Integration Checkpoint]], [[07_Meetings/2026-07-10 EL Repo-Branching Review]], [[07_Meetings/2026-07-10 Drew Check-in]]. Skipped an all-day OOF block ("Summer Friday hours").
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): CDH_EL 1 commit + 16 dirty files (Sprint2/deployment-prep); CDH_FPA 1 dirty file; MIDAS_GP_MPAS 1 dirty file; InternalIntacctQueryApp 46 dirty files (master); Midas_GP 3 dirty; LESCO_sync/MudMCP 2 dirty each; Legal_Service/PEF_MPAS.Web 1 dirty each. CDH_Project_Reporting, MHC_InventoryTransfer, OBD, TRANCY_CargoWise_Integration clean.
- **Cleanup**: no broken wikilinks found; frontmatter on recently-touched notes already compliant; Inbox has nothing to triage.
- **Needs attention**: `C:\Users\dkolaya\source` top level has only "ADSFramework Configurator" (not a repo) and "repos" — actual repos live one level deeper under `source\repos`, scanned there instead. InternalIntacctQueryApp has been dirty (46 files, master) for an unknown period — worth checking it isn't forgotten work. CharacterCafe PR #104 failing Cloudflare Workers build. PEF_MPAS.Web PR #350 doesn't clearly map to an Active project note — left unmapped.
