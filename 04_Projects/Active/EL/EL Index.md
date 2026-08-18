---
title: EL Index
created: 2026-08-12
type: index
tags:
  - project/el
  - area/development
---

# EL Index

Every note in `04_Projects/Active/EL/`. The initiative's own overview is [[EL|EL]]; everything else here is a sub-plan and is discoverable only from that note (sub-plans never get their own bullet in [[04_Projects/Project Index|Project Index]]).

## Overview

- [[EL|EL]] — the initiative note: status log, editor/template backlog, meeting feedback, links.

## Active sub-plans

- [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] — per-module declared permission action sets with label overrides, grant-time dependency assignment, per-module cards replacing the fixed 4-column matrix.

### SharePoint export plan set (P0–P3, authored 2026-08-12)

Four plans, one branch and PR each, all `Drew/Sprint4/*` off `develop`. Goal: a **Send to SharePoint** button on an approved EL package that uploads every letter PDF into a per-package SharePoint folder with one list item, mirrored back into SQL — matching how the FPA app behaves.

- [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|EL Document Approval Workflow Warplan]] — **P0, prerequisite.** Makes `ELDocument.enumDocumentState` actually move: document approval rules, service, and per-letter workflow UI. Nothing transitions a document today, so the export's all-letters-approved gate is unsatisfiable without it.
- [[04_Projects/Active/EL/EL SharePoint Client Warplan|EL SharePoint Client Warplan]] — **P1, no dependencies.** Microsoft Graph client in `Lib`, generic `[GraphField]` mapper, `ELPackageSpListItem` mirror table + migration, SharePoint config section.
- [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|EL SharePoint Export Job Warplan]] — **P2, needs P1.** Export orchestration service (render → validate → upload → mirror) plus Hangfire infrastructure and the background job. Closes the standing "Set up Hangfire Jobs for EL" item in [[03_Todos/Work TODOs|Work TODOs]].
- [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|EL SharePoint Export UI Warplan]] — **P3, needs P0 + P2.** Appends `PackageState.SentToSharePoint` and `ApprovalTrigger.SendToSharePoint`, rewires the package approval rules, and adds the gated button plus export status display to the workspace.

Order: P0 and P1 can run in parallel → P2 after P1 → P3 last.

#### Companion brief (not a plan)

- [[04_Projects/Active/EL/EL SharePoint Structure and DocuSign Brief|EL SharePoint Structure and DocuSign Brief]] — **discussion brief, authored 2026-08-17.** The SharePoint layout (one list item + one folder per package, per-file routing columns) and the outbound Power Automate flow that turns a package into one multi-document DocuSign envelope. Covers the handoff P0–P3 stop short of. Status return path deliberately out of scope. Carries three open decisions: signature-tab placement, per-letter signer source, and the merge-field hard-failure gate.

## Links

- [[04_Projects/Project Index|Project Index]]
- [[03_Todos/Work TODOs|Work TODOs]]
- [[04_Projects/Active/FPA|FPA]] — source of the ported SharePoint design
- [[90_Archive/Repo Planning/CDH_EL/2026-08-06/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]] (archived)
