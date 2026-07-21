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

## 2026-07-21 08:36

- **Monday.com**: no new/completed items for Drew across EL Tasks or AI Weekly Tasks boards since 2026-07-20 (all in-progress items unchanged: W1/W2 platform research, EL audit trail/notes/permissions). Patrick posted an update re: in-person interviews Wednesday in Itasca.
- **Email**: 1 actionable item added — Shannon Thai shared "CDH EL User Acceptance Testing - Sprint 2" for edit (2026-07-20). Skipped: ticket notification, Bonusly playlist newsletter, Trancy prep meeting invite (covered by calendar stub).
- **Teams**: search hit a Graph rate limit partway through (21/47 chats scanned) — no @mentions/DMs surfaced in the portion covered; results incomplete.
- **GitHub**: no new review requests, no actionable notifications. Drew's 4 open PRs unchanged — [CDH_EL#9](https://github.com/CDHTS/CDH_EL/pull/9) (no checks on branch), [CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) (Workers Build still failing), [TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2), [PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350) — no new activity.
- **Meeting stubs created**: [[07_Meetings/2026-07-21 Trancy prep|Trancy prep]], [[07_Meetings/2026-07-21 Trancy CargoWise Integration Checkpoint|Trancy CargoWise Integration Checkpoint]], [[07_Meetings/2026-07-21 Innovation and Technology Group Monthly Meeting|Innovation and Technology Group Monthly Meeting]] — all added to Meeting Index.
- **Repo activity** (read-only): `CDH_EL` still on `Drew/Sprint3/Audit` — 9 dirty files, unchanged since 2026-07-16, now 5 days uncommitted. `InternalIntacctQueryApp` still dirty (46 files). `CDH_FPA`, `CDH_Project_Reporting`, `LESCO_sync`, `Legal_Service`, `MIDAS_GP_MPAS`, `Midas_GP`, `MudMCP`, `PEF_MPAS.Web` each carry small pre-existing diffs (1-3 files), no new commits since 2026-07-20. `MHC_InventoryTransfer`, `OBD`, `TRANCY_CargoWise_Integration` clean. Logged in [[04_Projects/Active/EL Audit and Permissions Warplan]].
- **Cleanup**: fixed non-compliant frontmatter on [[06_Resources/Scripts/Grant EL Admin Permissions]] (`type: script-note` → `resource`; `project/cdh-el` → `project/el` per taxonomy). Inbox empty, indexes current, no broken links found in touched files.
- **Needs attention**: CDH_EL Phase 3 work now 5 days uncommitted — commit before it rides alongside more branch activity. Teams scan incomplete due to rate limit, re-check tomorrow. Pre-existing uncommitted files in this vault (`Grant EL Admin Permissions.md`, `Grant-ELAdminPermissions.sql`, `KeepAwake.ps1`, modified `Script Index.md`) included in this commit.

## 2026-07-20 08:xx (72h lookback, Monday)

- **Monday.com**: connector unavailable — `get_user_context` failed `net::ERR_NETWORK_IO_SUSPENDED` on two attempts. Skipped entirely.
- **Email**: connector unavailable — same network error on `outlook_email_search`. Skipped.
- **Teams**: connector unavailable — same network error on `chat_message_search`. Skipped.
- **Calendar**: connector unavailable — same outage. No meeting stubs created.
- **GitHub**: no review requests, no actionable notifications. Drew's 4 open PRs checked for new comments/failing checks since 2026-07-17: [CDHTS/CDH_EL#9](https://github.com/CDHTS/CDH_EL/pull/9) (no new checks, Drew's own bugfix comment 2026-07-17), [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) (Workers Build still failing, already flagged), [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2) (no CI, unchanged), [CDHTS/PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350) (no CI, unchanged).
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): `CDH_EL` now on `Drew/Sprint3/Audit` (moved off `feature/June/30/RTE-TipTap-cleanup`) — Phase 3 audit/permissions work (9 dirty files) still uncommitted, unchanged since 2026-07-16 (logged in [[04_Projects/Active/EL Audit and Permissions Warplan]]). Old TipTap-cleanup stashes from the 2026-07-17 flag remain untouched in the stash list, not lost. One new commit across all refs: "editor spacing bugfix" (PR #9, TipTap branch). Dirty-file counts otherwise unchanged: `InternalIntacctQueryApp` (46, `master`), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `CDH_FPA`/`Legal_Service`/`MIDAS_GP_MPAS`/`PEF_MPAS.Web` (1 each); `CDH_Project_Reporting`/`MHC_InventoryTransfer`/`OBD`/`TRANCY_CargoWise_Integration` clean.
- **Cleanup**: no broken wikilinks; all indexed folders current including new [[06_Resources/AI Platforms/Microsoft Copilot Company Profile]] and [[06_Resources/AI Platforms/OpenAI Company Profile]] (already linked from [[06_Resources/AI Platforms/AI Platforms Index]], frontmatter-compliant). Inbox empty of triageable items.
- **Pre-existing uncommitted work** (from a prior session, included in this run's commit): Microsoft Copilot + OpenAI company profile research (new notes, index/AI Initiative updates).
- **Needs attention**: all Microsoft 365 tools (Monday.com + Outlook + Teams) hit the same `net::ERR_NETWORK_IO_SUSPENDED` error across every tool this run — worth checking the M365/Monday MCP connection if this repeats. `CDH_EL` Phase 3 work has now been uncommitted for 4+ days on `Drew/Sprint3/Audit` — recommend committing before it risks getting lost or tangled with more branch work. `InternalIntacctQueryApp` still dirty (46 files, `master`) across many runs — likely forgotten work.

## 2026-07-17 08:15 (24h lookback)

- **Monday.com**: no new items or status changes for Drew on EL Tasks / AI Weekly Tasks boards since 2026-07-16 — all already reflected in [[03_Todos/Work TODOs]]. Ownerless "Clean up MVC code if unused" item (created 07-14) still has no owner — not added.
- **Email**: no actionable items added. 7 emails since last run; only one unread (Nathan Sawyer reply on Integration Testing/Transactions thread) but addressed to the team, not a direct ask of Drew — skipped. Rest were FYI (GP server maintenance, Legal Service Plan update, group/team join notices, vendor marketing).
- **Teams**: searched, 0 mentions/DMs found for Drew since last run.
- **Calendar**: 1 real meeting today — created [[07_Meetings/2026-07-17 Drew Check-in|Drew Check-in]] (1:1 w/ Patrick, 12:00 PM ET) and added to [[07_Meetings/Meeting Index]]. Skipped Drew's own "Summer Friday hours" OOF block (self-organized, not a meeting).
- **GitHub**: no review requests, no notifications. [DKolaya/CharacterCafe#108](https://github.com/DKolaya/CharacterCafe/pull/108) closed (not merged) 2026-07-16 — no longer in Drew's open PR list. Remaining 4 open PRs: [CDHTS/CDH_EL#9](https://github.com/CDHTS/CDH_EL/pull/9) (new commit "Code Suggestion for #9" landed 2026-07-16, no failing checks), [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) (Workers Build still failing, already flagged in [[03_Todos/Work TODOs]]), [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2), [CDHTS/PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350) (stale since Feb, unchanged).
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): `CDH_EL` now on `feature/June/30/RTE-TipTap-cleanup` (8 dirty files, GemBox/renderer WIP) — new commit `c94ede7` synced to PR #9. Separately, `Drew/Sprint3/Audit`'s Phase 3 work (Tasks 3.1-3.5, per [[04_Projects/Active/EL Audit and Permissions Warplan]]) is **not committed** — it's sitting in `stash@{0}` ("WIP on Drew/Sprint3/Audit"); repo has since moved to the TipTap branch. No other repo had new commits. Dirty-file counts otherwise unchanged: `InternalIntacctQueryApp` (46, `master`), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `CDH_FPA`/`Legal_Service`/`MIDAS_GP_MPAS`/`PEF_MPAS.Web` (1 each); `CDH_Project_Reporting`/`MHC_InventoryTransfer`/`OBD`/`TRANCY_CargoWise_Integration` clean.
- **Cleanup**: no broken wikilinks found in files touched this run; all indexed folders current; Inbox has only its standing triage checklist, nothing new to move.
- **Pre-existing uncommitted work** (from a prior session, included in this run's commit): [[04_Projects/Active/EL Audit and Permissions Warplan]] updated with Phase 3 Tasks 3.1-3.5 status (all done, uncommitted in the repo — see repo activity above).
- **Needs attention**: `CDH_EL`'s Phase 3 audit/permissions work is real and verified (per the Warplan's Status Log) but only exists as a stash on a branch the repo isn't even checked out to anymore — recommend committing it before more TipTap-branch work piles on top and risks a messy stash pop. `InternalIntacctQueryApp` still dirty (46 files, `master`) across six-plus runs now — likely forgotten work.

## 2026-07-16 (24h lookback)

- **Monday.com**: connector unavailable — `get_user_context` failed `net::ERR_NETWORK_IO_SUSPENDED` on two attempts. Skipped entirely, no items pulled.
- **Email**: connector unavailable — same network error on `get_me`. Skipped.
- **Teams**: connector unavailable — same network error, no search attempted. Third run in a row with degraded/no Teams coverage (prior two runs hit Graph rate limits); combined with today's outage across all Microsoft 365 tools, worth checking the M365 MCP connection.
- **Calendar**: skipped (same connector outage).
- **GitHub**: no review requests, no notifications. Drew's 5 open PRs unchanged: [CDHTS/CDH_EL#9](https://github.com/CDHTS/CDH_EL/pull/9), [DKolaya/CharacterCafe#108](https://github.com/DKolaya/CharacterCafe/pull/108), [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104), [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2), [CDHTS/PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350).
- **Meetings**: no stubs created (calendar connector down).
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): no new commits in any repo since last run — `CDH_EL`'s 8 Phase-2 audit commits (already logged in [[04_Projects/Active/EL Audit and Permissions Warplan]]) all predate 2026-07-15's sync. Dirty-file counts unchanged: `InternalIntacctQueryApp` (46, `master`), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `CDH_FPA`/`Legal_Service`/`MIDAS_GP_MPAS`/`PEF_MPAS.Web` (1 each).
- **Cleanup**: no broken wikilinks found in files touched this run; all indexed folders current; Inbox empty of triageable items.
- **Pre-existing uncommitted work** (from a prior session, included in this run's commit): new [[06_Resources/AI Platforms/Anthropic Company Profile]] plus updates to [[06_Resources/AI Platforms/AI Platforms Index]], [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison]], and [[04_Projects/Active/AI Initiative]] linking it in — deep Anthropic research (business, product, security, pricing, pilot design). Verified frontmatter-compliant and all wikilinks resolve.
- **Needs attention**: `InternalIntacctQueryApp` still dirty (46 files, `master`) across five runs now — likely forgotten work. All three Microsoft 365 connector tools (Monday is separate but also down) failed with the same network-suspended error this run — if this repeats tomorrow, connector needs a real look rather than a retry.

## 2026-07-15 08:15

24h lookback.

- **Monday.com**: no new items or status changes for Drew on EL Tasks / AI Weekly Tasks boards since 2026-07-14 — all already reflected in [[03_Todos/Work TODOs]]. One new EL Tasks item appeared ("Clean up MVC code if unused", created 2026-07-14 16:11) but has no owner — not added.
- **Email**: no actionable items added. Skipped: continuation of Nathan Sawyer's Voluntary Legal Service Plan thread with Chris Allen (Drew not the direct addressee) and an appsupport@ ticket auto-notification (#131760, informational only).
- **Teams**: search hit Graph rate limits on both attempts (0/48, then 0/48 again) — skipped, no results available this run.
- **GitHub**: no review requests. Drew's open PRs unchanged from last check: [CDHTS/CDH_EL#9](https://github.com/CDHTS/CDH_EL/pull/9), [DKolaya/CharacterCafe#108](https://github.com/DKolaya/CharacterCafe/pull/108), [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104), [CDHTS/TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2), [CDHTS/PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350). No notifications surfaced. Did not re-check individual CI status this run (timeboxed).
- **Meetings**: only event today is an all-day "TS Summer Gathering" placeholder (`showAs: free`) — skipped per rule, no stub created.
- **Repo activity** (`C:\Users\dkolaya\source\repos`, read-only): `CDH_EL` (`Drew/Sprint3/Audit`) — 8 new commits completing Phase 2 Tasks 2.1-2.3 of the audit/permissions warplan (package add, `ELAuditLog` migration, interceptor wiring, plus a `UniqueUsername` dead-code fix) — logged in [[04_Projects/Active/EL Audit and Permissions Warplan]]. No other repo had new commits. Dirty-file counts unchanged from last run: `InternalIntacctQueryApp` (46, `master`), `Midas_GP` (3), `LESCO_sync`/`MudMCP` (2 each), `Legal_Service`/`CDH_FPA`/`MIDAS_GP_MPAS`/`PEF_MPAS.Web` (1 each).
- **Cleanup**: no broken wikilinks found; all indexed folders' indexes still current; Inbox has nothing to triage; no notes modified in the last 3 days besides the Warplan (already frontmatter-compliant).
- **Needs attention**: `InternalIntacctQueryApp` still dirty (46 files, `master`) across four runs now — likely forgotten work. Teams results fully unavailable again this run (rate-limited on both attempts, 0 chats scanned either time) — two runs in a row with degraded/no Teams coverage, may be worth checking the connector. Pre-existing uncommitted change to [[04_Projects/Active/EL Audit and Permissions Warplan]] from prior session work (Phase 1-2 checkbox updates) included in this run's commit.

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
