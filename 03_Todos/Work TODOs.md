---
title: Work TODOs
created: 2026-07-08
type: todo
source: [[90_Archive/OneNote Raw/Drew @ Work]]
tags:
  - todo/work
  - work
  - dashboard
---

# Work TODOs

## Next

- [ ] 

## Waiting

- [ ] Shannon to investigate Billing app duplicate-client display (CCI 1984 / Custom Cylinders) — from [[07_Meetings/2026-07-09 TS Internal Projects Touch Point|2026-07-09 touchpoint]].
- [ ] EL UAT feedback due back from admin/stakeholder testers by 2026-07-17.

## Backlog

- [ ] Continue Blazor course.
- [ ] Continue Intacct course.

## Active

- [ ] Look into the Intacct REST API.
- [x] Review logging needs on EL APP. ✅ 2026-08-17
- [ ] Set up Hangfire Jobs for EL. — covered by [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|SharePoint Export Job Warplan]] (P2), which adds Hangfire + SQL storage + a gated dashboard.
- [ ] EL SharePoint export, four plans (P0-P3), all `Drew/Sprint4/*` off `develop` — index and ordering in [[04_Projects/Active/EL/EL Index|EL Index]]:
    - [ ] P0 [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|Document Approval Workflow]] — prerequisite; nothing transitions `ELDocument.enumDocumentState` today.
    - [ ] P1 [[04_Projects/Active/EL/EL SharePoint Client Warplan|SharePoint Client]] — Graph client, mapper, `ELPackageSpListItem` + migration, config. No dependencies.
    - [ ] P2 [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|SharePoint Export Job]] — export service + Hangfire job. Needs P1.
    - [ ] P3 [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|SharePoint Export UI]] — `Sent to SharePoint` state + gated Send button. Needs P0 + P2.
- [ ] Provision the EL SharePoint list + document library and capture their **internal** column names — blocks P1's field mapping and all of P2's enabled-path testing.
- [ ] Confirm the Graph app registration for EL (`Sites.Selected` + site grant, or `Sites.ReadWrite.All`, admin-consented) and place the client secret in `appsettings.Development.local.json`, not the git-tracked `appsettings.Development.json`.
- [ ] Raise rotation of CDH_FPA's Graph client secret — it is committed in cleartext in that repo's `appsettings.json`.
- [ ] Work EL editor backlog in [[EL]].
- [ ] Digest core toolkit + CSAC reference, start ORDA repo — [[04_Projects/Active/ORDA Positive Pay]] (after vacation).
- [ ] Review new support tickets.
- [ ] Complete Trancy check-in.
- [ ] Review timesheet entry.
- [ ] Server maintenance assigned this month — setup begins 2026-08-13.

## Monday.com

EL Tasks board (owner: Drew):
- [x] Create text editor for letter creation/editing screens
- [x] Review C# coding styles and standardization
- [x] Select UI/UX for application
- [x] Create user acceptance testing document (with Shannon Thai) — In Progress ✅ 2026-07-13
- [x] Determine paragraph editing toolset features
- [x] Create Solution and Repository
- [x] Create engagement letter overview/search screen
- [x] Setting up AI tools for developement
- [ ] Implement audit trail — Pending Deploy (was Waiting for review)
- [ ] Implement application permissions including approval workflows — Pending Deploy (was In Progress)
- [ ] Implement notes (with Nathan Sawyer) — Pending Deploy (was In Progress)
- [ ] Export letter to SharePoint — In Progress, unchanged (matches active [[04_Projects/Active/EL/EL SharePoint Client Warplan|SharePoint Client]]/[[04_Projects/Active/EL/EL Document Approval Workflow Warplan|Document Approval Workflow]] work)
- [ ] Initial SharePoint planning for meeting prep with Esther (High) — assigned to Drew by Shannon Thai 2026-08-17, no status yet.

AI Weekly Tasks board (owner: Drew) — full breakdown in [[04_Projects/Active/AI Initiative]]:
- [ ] W1: Platform research - Claude (Anthropic) — In Progress
- [ ] W2: Platform research - ChatGPT Enterprise/OpenAI — In Progress
- [x] W3: Platform research - Microsoft 365 Copilot ✅ 2026-07-17
- [ ] W4: Platform research - Google Gemini — In Progress (moved off "overdue" 2026-08-10)
- [ ] W5: Platform research - Codex vs Claude Code — In Progress (moved off "overdue" 2026-08-10)
- [ ] W6: Draft v1 platform comparison brief (overdue, was due 2026-08-07, still Not Started)
- [ ] W7: Research accounting AI add-ons - Sage Intacct, QuickBooks (overdue, was due 2026-08-14, still Not Started)
- [ ] W8: Research accounting AI add-ons - CCH Axcess, CoCounsel, Karbon (overdue, was due 2026-08-17, still Not Started)
- [ ] W9: Fold accounting-tool findings into brief
- [ ] W10: Support playbook - gather usage examples
- [ ] W11: Support playbook - draft sections
- [ ] W12: Finalize comparison brief v2
- [ ] W13: Present brief at Q1 checkpoint

Positive Pay Export board (owner: Drew) — full breakdown in [[04_Projects/Active/ORDA Positive Pay]]:
- [x] Fork Intacct_Toolkit_Core repo
- [x] Customize app logo, name and settings
- [x] Verify core app framework runs with login
- [x] Confirm file format from ORDA
- [x] Test data sync for required Positive Pay fields — board caught up to Done 2026-08-10 (was blocked/stale on the board, already tracked done in the project note)
- [ ] Setup Auth0 app and update Action — In Progress (only item on the board still not Done)
- [x] Add any table customizations — board flipped Done 2026-08-12
- [x] Add custom data sync for required Positive Pay fields — board flipped Done 2026-08-12
- [x] Add any export customizations — board flipped Done 2026-08-12
- [x] Test export feature — board flipped Done 2026-08-12
- [ ] Release Final Export Feature — Not Started, unassigned

## From Email

- [x] Respond to EL UAT round 1 questionnaire (Shannon Thai, sthai@cdhts.com) — links + questionnaire for Engagement Letter app UAT. ✅ 2026-07-13
- [x] Sage Intacct company "LeadingAgeNY-imp" (Implementation) blocked, deactivates in 30 days (noreply@intacct.com, 2026-07-13) — reactivate or confirm deactivation. ✅ 2026-07-13
- [ ] Review/edit "CDH EL User Acceptance Testing - Sprint 2" (Shannon Thai, sthai@cdhts.com, shared 2026-07-20) — SharePoint doc shared for edit access.
- [x] Reply re: Dept 100 pass-through invoice handling (Tim Wright, twright@trancyamerica.com, 2026-07-21) — question on Integration Testing and Transactions thread, unread. ✅ 2026-07-23
- [ ] Sage Intacct company "cc-institute-imp" (Implementation) blocked, deactivates in 30 days (noreply@intacct.com, 2026-08-04) — reactivate or confirm deactivation.
- [ ] Submit July expense reports by EOD today, approved by Monday morning (Sharon Wells, swells@cdhcpa.com, 2026-08-06) — broadcast to staff, not addressed to Drew individually, but deadline applies.

## From Teams

- [ ] Confirm to Shannon Thai whether server maintenance happens this week or next (asked 2026-08-17, Drew's reply in-thread didn't pin a week).
- Scan mostly completed this run (46/47 chats before Graph rate limit — first non-zero scan in six runs).

## GitHub

- No open PRs waiting on Drew's review. No actionable notifications.
- Flagged: [DKolaya/CharacterCafe#104](https://github.com/DKolaya/CharacterCafe/pull/104) — Workers Build check still failing (checked 2026-08-18).
- [TRANCY_CargoWise_Integration#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2), [PEF_MPAS.Web#350](https://github.com/CDHTS/PEF_MPAS.Web/pull/350) — open, no checks configured, unchanged.

## Done This Week

- [x] Vault scaffold created

## Project Links

- [[EL]]
- [[04_Projects/Done/MIDAS GP MPAS Service]]
- [[04_Projects/Active/FPA]]
- [[04_Projects/Done/Deferred Transactions]]
- [[06_Resources/Intacct/Intacct Hints]]
- [[04_Projects/Active/ORDA Positive Pay]]
