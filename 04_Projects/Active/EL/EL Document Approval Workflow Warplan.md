---
title: EL Document Approval Workflow Warplan
created: 2026-08-12
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL Document Approval Workflow Warplan

**Status (2026-08-12):** Planned, not started. **P0 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. Blocks [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|P3]]'s send gate; independent of [[04_Projects/Active/EL/EL SharePoint Client Warplan|P1]] and [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]].

> **For agentic workers:** Execute task-by-task; checkboxes track progress. Branch `Drew/Sprint4/DocumentApprovals` off `develop`, one PR into `develop` (repo rule: one branch per task, no mixing unrelated changes). Read repo `AGENTS.md` first. When implementation starts, copy this into the repo at `docs/reference/plans/` as the `.original.md` + compressed `.md` pair per repo doc conventions.

**Goal:** Make `ELDocument.enumDocumentState` actually move. Today the enum and the history table exist but nothing transitions a document — every letter is created `Draft` and stays there forever. Deliver per-letter approval transitions recorded in `ELDocumentApproval`, mirroring the package-level pattern that already works.

**Why it exists:** The SharePoint export button must only appear once *all letters in a package are approved*. That gate is unsatisfiable until this ships.

**Architecture:** Copy the shape already proven one level up. A pure static `DocumentApprovalRules` (mirror of `Lib/Services/EngagementLetters/PackageApprovalRules.cs`) owns legal transitions; `ElDocumentApprovalService` (mirror of `ElPackageApprovalService`) validates, writes one `ELDocumentApproval` row, and advances the document's state in one `SaveChangesAsync`. The workspace's per-letter rows get workflow buttons. No new tables, no migration.

## Current state — verified 2026-08-12

| Thing | Where | Status |
|---|---|---|
| `DocumentState` enum | `Lib/Enums/Enums.cs:127` | Exists: `Draft, ReadyForManagerReview, ManagerApproved, PartnerApproved, Finalized, Inactive` |
| `ELDocumentApproval` model | `Lib/Models/EL/ELDocumentApproval.cs` | Exists — `documentId`, `userRecordId`, `enumStatePrevious`, `enumTrigger`, `enumStateNew`, `comments` |
| DbSet | `Lib/DAL/ELContext.cs:87` | Registered |
| Rules class | — | **Missing** |
| Service | — | **Missing** |
| UI | — | **Missing** |
| Writes to the table | — | **None anywhere in the repo** |
| State assignment | `Lib/Services/EngagementLetters/ElPackageDetailService.cs:191` and `:331` | Hard-codes `DocumentState.Draft` on create |

Per-document reviewer assignment already exists on `ELDocument`: `preparerUserRecordId`, `managerReviewerUserRecordId`, `partnerReviewerUserRecordId` (all nullable `UserRecord` FKs).

## Design decisions

### Reuse `ApprovalTrigger`; append only if forced

`ApprovalTrigger` (`Lib/Enums/Enums.cs:85`) already carries `Submit` ("Submit to RM"), `SubmitPartner`, `Recall`, `ReviewerRequestsChange`, `PartnerRequestsChanges`, `Approve`, `Reject`, `Finalize`, `Inactivate`, `Reactivate`. Its own doc comment at `:83` says the document-vs-package split "will likely need revising" — **this plan is where that gets decided.** Decide with Drew before coding; default recommendation:

| From | Trigger | To |
|---|---|---|
| `Draft` | `Submit` | `ReadyForManagerReview` |
| `ReadyForManagerReview` | `Approve` | `ManagerApproved` |
| `ReadyForManagerReview` | `ReviewerRequestsChange` | `Draft` |
| `ReadyForManagerReview` | `Recall` | `Draft` |
| `ManagerApproved` | `SubmitPartner` | *(no state — see below)* |
| `ManagerApproved` | `Approve` | `PartnerApproved` |
| `ManagerApproved` | `PartnerRequestsChanges` | `Draft` |
| `PartnerApproved` | `Finalize` | `Finalized` |
| `PartnerApproved` | `ReviewerRequestsChange` | `Draft` |

Note the asymmetry to resolve: `DocumentState` has no `ReadyForPartnerReview`, so `ManagerApproved` doubles as "awaiting partner." Either accept that (partner acts from `ManagerApproved`, and `SubmitPartner` is unused at document level) or **append** `ReadyForPartnerReview` to `DocumentState`.

- [ ] **Decision gate — confirm with Drew before Task 1.** Does the document workflow need an explicit `ReadyForPartnerReview` state?

### Enum changes are append-only

`DocumentState` and `ApprovalTrigger` persist as `int` in `ELDocument.enum_document_state`, `ELDocumentApproval.enum_state_previous` / `enum_trigger` / `enum_state_new`, and `ELPackage`/`ELPackageApproval`. Inserting a value mid-enum silently relabels every historical row. **Append at the end, never reorder, never remove.** This repo has already eaten one fleet-wide permissions lockout from an enum-shape change (see the archived audit/permissions warplan) — same hazard class.

### Rules stay pure; the service owns persistence

`PackageApprovalRules` is `internal static`, no DI, three methods (`GetAvailableTriggers`, `CanApply`, `Apply` — `Apply` throws on illegal transitions). Match it exactly so both levels read the same. Business logic must not live in `.razor` per repo `AGENTS.md`.

### Who may act — permission vs. assignment

Package transitions today gate only on `PermissionModule.Workspace` + `PermissionAction.Edit` (`ElPackageWorkspace.razor:504`), with no check that the acting user *is* the assigned reviewer. `PermissionAction` is a fixed 4-value enum (`View/Create/Edit/Admin`), so a distinct "approve" permission does not exist and adding one is out of scope here (see the dynamic-actions warplan).

- [ ] **Decision gate — confirm with Drew.** Does approving a letter require the acting user to *be* the assigned manager/partner reviewer, or is `Workspace:Edit` sufficient (matching current package behavior)? Recommendation: enforce assignment for `Approve` only, and let the plan's rules layer stay identity-free — the check belongs in the service, which already resolves the acting user.

## Task 1 — Rules in Lib

- [ ] New `Lib/Services/EngagementLetters/DocumentApprovalRules.cs`, `internal static`, no DI, file-scoped namespace, modeled line-for-line on `PackageApprovalRules.cs`.
- [ ] `GetAvailableTriggers(DocumentState current)` → `IReadOnlyList<ApprovalTrigger>` using collection expressions (`[...]`) and a `switch` expression, `_ => []` default.
- [ ] `CanApply(DocumentState, ApprovalTrigger)` → `GetAvailableTriggers(current).Contains(trigger)`.
- [ ] `Apply(DocumentState, ApprovalTrigger)` → tuple `switch`, `_ => throw new InvalidOperationException($"Cannot apply {trigger} from {current}.")`.
- [ ] Add `IsApproved(DocumentState)` — the single definition of "approved enough to export," so P3's gate and this workflow can never drift. Returns true for `PartnerApproved` and `Finalized`.
- [ ] XML docs with a `remarks` block stating the transition table and that `Inactive` is terminal, matching the doc style of `PackageApprovalRules`.

## Task 2 — Service in Lib

- [ ] New `Lib/Services/EngagementLetters/IElDocumentApprovalService.cs` with `ApplyDocumentTransitionRequest(int DocumentId, ApprovalTrigger Trigger, string ActingUserEmail, string ActingUserFirstName, string ActingUserLastName, string? Comments)` — same record shape as `ApplyPackageTransitionRequest`.
- [ ] Interface members: `GetAvailableTriggers(DocumentState current)`, `ApplyTransitionAsync(request, ct)` → `Task<ELDocument>`, and `AreAllDocumentsApprovedAsync(int packageId, ct)` → `Task<bool>` (P3 consumes this; it belongs here, next to `IsApproved`, not in the UI).
- [ ] New `ElDocumentApprovalService.cs` using the primary-constructor + `IDbContextFactory<ELContext>` + `IUserAdministrationService` pattern of `ElPackageApprovalService.cs`.
- [ ] `ApplyTransitionAsync`: load document → throw if missing → `CanApply` guard → `EnsureUserByEmailAsync` for the actor → add `ELDocumentApproval` row (previous/trigger/new) → set `enumDocumentState` → one `SaveChangesAsync`.
- [ ] `AreAllDocumentsApprovedAsync`: all non-`Inactive` documents in the package satisfy `DocumentApprovalRules.IsApproved`, **and** the package has at least one such document (an empty package must not read as approved).
- [ ] Register in `CDH_EL/Program.cs` next to `IElPackageApprovalService` (line ~71).

## Task 3 — Workspace UI

- [ ] `CDH_EL/Components/Pages/EngagementLetters/ElPackageWorkspace.razor` — inject `IElDocumentApprovalService`; per-letter workflow actions on the document rows in the left panel (the rows around `:150-165` that already render `canEdit`-gated reorder buttons).
- [ ] Show each letter's current state as an `HxBadge`; add a `DocumentStatusUi` helper in `CDH_EL/Components/Shared/` mirroring `PackageStatusUi.cs` (color + display text; `DocumentState` values have no `[Display]` attributes today, so either add them — append-safe, attributes don't affect stored ints — or map text in the helper).
- [ ] Trigger buttons follow the existing pattern: `HxButton` with `Enabled="@(!isApplying)"`, `Spinner`, and a reload + `HxMessenger` toast after success, as `ApplyTransitionAsync` does at `:551-572`.
- [ ] Gate on the existing `canEdit` (`PermissionModule.Workspace` + `PermissionAction.Edit`) plus whatever the assignment decision above lands on.
- [ ] Use HAVIT components before custom markup; query `Havit.Blazor.Mcp` for any component API before writing markup (global rule). Follow `docs/reference/ui-style-guide.md`.

## Task 4 — Package/document state interplay

- [ ] Decide and document: does a document transition ever move the *package*? Recommendation for this plan: **no** — package transitions stay manual, and P3's gate simply reads `AreAllDocumentsApprovedAsync`. Keeping the two state machines independent avoids a cascade nobody can reason about.
- [ ] Confirm `ElPackageDetailService.cs:191`/`:331` still create documents as `Draft` — correct, leave as-is.
- [ ] Check whether regenerating a package's documents resets an approved letter to `Draft` and whether that's desired; note the finding in the Status Log even if no change is made.

## Task 5 — Tests

- [ ] New `Lib.Tests/Services/EngagementLetters/DocumentApprovalRulesTests.cs`:
  - [ ] Every state's available-trigger set matches the table above.
  - [ ] `Apply` throws for every illegal (state, trigger) pair — iterate the full cross-product rather than spot-checking.
  - [ ] `IsApproved` is true only for `PartnerApproved` / `Finalized`.
  - [ ] **Enum-value stability:** assert the numeric value of each `DocumentState` and each `ApprovalTrigger` member, so a reorder fails a test instead of silently rewriting history.
- [ ] New `ElDocumentApprovalServiceTests.cs` following the existing `ElPackageDetailServiceTests` fixture style: happy-path transition writes exactly one approval row with correct previous/new; illegal transition throws and writes nothing; unknown document throws; `AreAllDocumentsApprovedAsync` false when any non-inactive document is unapproved, false for a package with zero documents, true when all are approved, and inactive documents are ignored.

## Verification

- [ ] `dotnet build` — 0 errors.
- [ ] `dotnet test`. Note pre-existing unrelated failures in `EngagementLetterTemplateServiceTests` (title-uniqueness, effective-date, default-order as of 2026-08-04) — confirm they fail identically before this change via `git stash` before attributing anything.
- [ ] No migration expected. Confirm `dotnet ef migrations list` shows nothing pending and that no model change slipped in (adding `[Display]` attributes does not alter the model snapshot; appending an enum value does not either).
- [ ] Manual smoke on a package in the local `cdhel-sql` container: walk one letter Draft → ReadyForManagerReview → ManagerApproved → PartnerApproved, then request changes back to Draft. Confirm one `ELDocumentApproval` row per click with correct previous/new states and actor.
- [ ] Confirm `AreAllDocumentsApprovedAsync` flips true only after the last letter is approved.
- [ ] Verify desktop + mobile widths: no clipped controls, no text overlap, no page-level horizontal scroll (repo rule).
- [ ] Check the browser console for errors after the UI change.

## Status Log

- 2026-08-12 — Plan authored as P0 of the SharePoint export set. Recon confirmed the gap: `DocumentState` + `ELDocumentApproval` + DbSet all exist, but zero transition logic and zero writers anywhere in the repo; `ElPackageDetailService` hard-codes `Draft` at two sites. Two decision gates left open for Drew: whether `DocumentState` needs an appended `ReadyForPartnerReview`, and whether approving requires being the assigned reviewer or just `Workspace:Edit`.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|P3 — SharePoint Export UI Warplan]] (consumes this plan's gate)
- [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] (where a real approve-permission would come from)
