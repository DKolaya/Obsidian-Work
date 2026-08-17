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

**Status (2026-08-13):** Tasks 1-4 done, landed on `Drew/Sprint4/SharePoint-Client` (Shannon's package-workflow commits rebased onto it). Task 5 (tests) closed out this session. **P0 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. Blocks [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|P3]]'s send gate; independent of [[04_Projects/Active/EL/EL SharePoint Client Warplan|P1]] and [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]].

**Implementation diverged from this plan in two ways worth recording:**
1. The `ReadyForPartnerReview` decision gate below was resolved differently than the plan's default recommendation — instead of appending that state, the shipped design appends **`ChangesRequested`** and unifies both `ReviewerRequestsChange` (from `ReadyForManagerReview`) and `PartnerRequestsChanges` (from `ManagerApproved` **or** `PartnerApproved`) onto it. A resubmitted letter (`Submit` from `ChangesRequested`) restarts at `ReadyForManagerReview` rather than resuming wherever it left off. See `Lib/Services/EngagementLetters/DocumentApprovalRules.cs` remarks for the full rationale, including why `PartnerRequestsChanges` stays legal even once `PartnerApproved` (a correction can still be requested on an already-approved, locked letter).
2. `IsApproved`/`AreAllDocumentsApprovedAsync` (originally scoped for this plan, for P3 to consume) were **not** built here. Instead, `ElDocumentApprovalService.ApplyTransitionAsync` calls a new `ElPackageStateService.RecomputePackageStateAsync` after every letter transition, which derives `ELPackage.enumPackageState` from all its letters' states (`PackageStateRules.Derive` in `Lib/Services/EngagementLetters/ElPackageStateService.cs`: `Approved` only when every letter is `PartnerApproved`, logged to `ELPackageApproval`). P3's send gate should read `PackageState.Approved` directly rather than a per-document helper — `ElPackageStateService.MarkSentToSharePointAsync` already throws unless the package is `Approved`, so the gate this plan was securing already exists one level up and P3 may need less new work than its own plan currently assumes.

> **For agentic workers:** Execute task-by-task; checkboxes track progress. Branch `Drew/Sprint4/DocumentApprovals` off `develop`, one PR into `develop` (repo rule: one branch per task, no mixing unrelated changes). Read repo `AGENTS.md` first. When implementation starts, copy this into the repo at `docs/reference/plans/` as the `.original.md` + compressed `.md` pair per repo doc conventions.

**Goal:** Make `ELDocument.enumDocumentState` actually move. Today the enum and the history table exist but nothing transitions a document — every letter is created `Draft` and stays there forever. Deliver per-letter approval transitions recorded in `ELDocumentApproval`, mirroring the package-level pattern that already works.

**Why it exists:** The SharePoint export button must only appear once *all letters in a package are approved*. That gate is unsatisfiable until this ships.

**Architecture:** Copy the shape already proven one level up. A pure static `DocumentApprovalRules` (mirror of `Lib/Services/EngagementLetters/PackageApprovalRules.cs`) owns legal transitions; `ElDocumentApprovalService` (mirror of `ElPackageApprovalService`) validates, writes one `ELDocumentApproval` row, and advances the document's state in one `SaveChangesAsync`. The workspace's per-letter rows get workflow buttons. No new tables, no migration.

## Current state — verified 2026-08-13 (superseded the 2026-08-12 recon below the line changed)

| Thing | Where | Status |
|---|---|---|
| `DocumentState` enum | `Lib/Enums/Enums.cs:158` | `Draft, ReadyForManagerReview, ManagerApproved, PartnerApproved, Finalized, Inactive, ChangesRequested` (7th value appended, not in original plan) |
| `ELDocumentApproval` model | `Lib/Models/EL/ELDocumentApproval.cs` | Exists — `documentId`, `userRecordId`, `enumStatePrevious`, `enumTrigger`, `enumStateNew`, `comments` |
| DbSet | `Lib/DAL/ELContext.cs` | Registered |
| Rules class | `Lib/Services/EngagementLetters/DocumentApprovalRules.cs` | **Done** |
| Service | `Lib/Services/EngagementLetters/ElDocumentApprovalService.cs` + `IElDocumentApprovalService.cs` | **Done** |
| UI | `CDH_EL/Components/Pages/EngagementLetters/ElPackageWorkspace.razor` | **Done** |
| Writes to the table | `ElDocumentApprovalService.ApplyTransitionAsync` | Writing, unit-tested |
| State assignment | `Lib/Services/EngagementLetters/ElPackageDetailService.cs:191` and `:331` | Still hard-codes `DocumentState.Draft` on create — correct, unchanged |
| Package-state derivation | `Lib/Services/EngagementLetters/ElPackageStateService.cs` (`PackageStateRules.Derive`) | New, not in original plan — see divergence note #2 |

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

- [x] **Decision gate — confirm with Drew before Task 1.** Does the document workflow need an explicit `ReadyForPartnerReview` state? **Resolved: no — `ChangesRequested` appended instead, see divergence note above.**

### Enum changes are append-only

`DocumentState` and `ApprovalTrigger` persist as `int` in `ELDocument.enum_document_state`, `ELDocumentApproval.enum_state_previous` / `enum_trigger` / `enum_state_new`, and `ELPackage`/`ELPackageApproval`. Inserting a value mid-enum silently relabels every historical row. **Append at the end, never reorder, never remove.** This repo has already eaten one fleet-wide permissions lockout from an enum-shape change (see the archived audit/permissions warplan) — same hazard class.

### Rules stay pure; the service owns persistence

`PackageApprovalRules` is `internal static`, no DI, three methods (`GetAvailableTriggers`, `CanApply`, `Apply` — `Apply` throws on illegal transitions). Match it exactly so both levels read the same. Business logic must not live in `.razor` per repo `AGENTS.md`.

### Who may act — permission vs. assignment

Package transitions today gate only on `PermissionModule.Workspace` + `PermissionAction.Edit` (`ElPackageWorkspace.razor:504`), with no check that the acting user *is* the assigned reviewer. `PermissionAction` is a fixed 4-value enum (`View/Create/Edit/Admin`), so a distinct "approve" permission does not exist and adding one is out of scope here (see the dynamic-actions warplan).

- [x] **Decision gate — confirm with Drew.** Does approving a letter require the acting user to *be* the assigned manager/partner reviewer, or is `Workspace:Edit` sufficient (matching current package behavior)? **Resolved: `Workspace:Edit` gates the UI; `ElDocumentApprovalService.ApplyTransitionAsync` records whichever acting user submits/approves as `managerReviewerUserRecordId`/`partnerReviewerUserRecordId` rather than checking a pre-assigned reviewer — assignment-is-recorded, not assignment-is-enforced. Matches current package-level behavior; no separate approve-permission was added (still out of scope, needs [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|dynamic permission actions]]).**

## Task 1 — Rules in Lib

- [x] New `Lib/Services/EngagementLetters/DocumentApprovalRules.cs`, `internal static`, no DI, file-scoped namespace, modeled line-for-line on `PackageApprovalRules.cs`.
- [x] `GetAvailableTriggers(DocumentState current)` → `IReadOnlyList<ApprovalTrigger>` using collection expressions (`[...]`) and a `switch` expression, `_ => []` default.
- [x] `CanApply(DocumentState, ApprovalTrigger)` → `GetAvailableTriggers(current).Contains(trigger)`.
- [x] `Apply(DocumentState, ApprovalTrigger)` → tuple `switch`, `_ => throw new InvalidOperationException($"Cannot apply {trigger} from {current}.")`.
- [x] ~~Add `IsApproved(DocumentState)`~~ — **not built; superseded.** Shipped as `IsLocked(DocumentState)` (true only for `PartnerApproved`, meaning "content can't be edited"), a different concept. The "approved enough to export" definition moved up a level into `PackageStateRules.Derive` — see divergence note #2 above.
- [x] XML docs with a `remarks` block stating the transition table and that `Inactive` is terminal, matching the doc style of `PackageApprovalRules`.

## Task 2 — Service in Lib

- [x] New `Lib/Services/EngagementLetters/IElDocumentApprovalService.cs` with `ApplyDocumentTransitionRequest(int DocumentId, ApprovalTrigger Trigger, string ActingUserEmail, string ActingUserFirstName, string ActingUserLastName, string? Comments)` — same record shape as `ApplyPackageTransitionRequest`.
- [x] Interface members: `GetAvailableTriggers(DocumentState current)`, `ApplyTransitionAsync(request, ct)` → `Task<ELDocument>`. ~~`AreAllDocumentsApprovedAsync`~~ not added here — see divergence note #2 above; `ApplyTransitionAsync` instead calls `IElPackageStateService.RecomputePackageStateAsync` inline so the package's derived state is always current.
- [x] New `ElDocumentApprovalService.cs` using the primary-constructor + `IDbContextFactory<ELContext>` + `IUserAdministrationService` pattern of `ElPackageApprovalService.cs` (also takes `IElPackageStateService`).
- [x] `ApplyTransitionAsync`: load document → throw if missing → completed-package guard (new, not in original plan) → `CanApply` guard → `EnsureUserByEmailAsync` for the actor → add `ELDocumentApproval` row (previous/trigger/new) → set `enumDocumentState` → stamps `managerReviewerUserRecordId`/`partnerReviewerUserRecordId` from the acting user on `SubmitPartner`/`Approve` → one `SaveChangesAsync` → recompute package state.
- [x] ~~`AreAllDocumentsApprovedAsync`~~ — see above; package-level `PackageStateRules.Derive` covers this instead.
- [x] Register in `CDH_EL/Program.cs` next to `IElPackageApprovalService`.

## Task 3 — Workspace UI

- [x] `CDH_EL/Components/Pages/EngagementLetters/ElPackageWorkspace.razor` — `IElDocumentApprovalService` injected; per-letter workflow actions on the document rows.
- [x] Each letter's current state shown via `DocumentStateUi.DisplayText` (helper named `DocumentStateUi`, not `DocumentStatusUi` as this plan guessed — same purpose).
- [x] Trigger buttons follow the existing `HxButton`/spinner/toast pattern, plus an unsaved-changes warning before workflow actions (extra polish beyond this plan's scope, landed in the same branch).
- [x] Gated on `canEdit` (`PermissionModule.Workspace` + `PermissionAction.Edit`); assignment-enforcement decision resolved as "record, don't enforce" — see decision-gate note above.
- [x] HAVIT components used per repo rule.

## Task 4 — Package/document state interplay

- [x] Decide and document: does a document transition ever move the *package*? **Resolved differently than this plan's recommendation** — the shipped design says yes: every letter transition triggers `RecomputePackageStateAsync`, which derives the package's state from all its letters (`PackageStateRules.Derive`). Not the "keep them fully independent" recommendation this plan made, but the cascade is a pure, single-direction derivation (letters → package, never the reverse), not a two-way loop, so the "nobody can reason about it" risk this plan was guarding against doesn't apply.
- [x] Confirmed `ElPackageDetailService.cs:191`/`:331` still create documents as `Draft` — correct, unchanged.
- [ ] Check whether regenerating a package's documents resets an approved letter to `Draft` and whether that's desired — **not checked this session**, still open.

## Task 5 — Tests

- [x] New `Lib.Tests/Services/EngagementLetters/DocumentApprovalRulesTests.cs`:
  - [x] Every state's available-trigger set matches the actual (shipped) transition table.
  - [x] `Apply` throws for every illegal (state, trigger) pair — full cross-product (7 states × 13 triggers = 91 cases via `[MemberData]`), not spot-checked.
  - [x] `IsLocked` (renamed from planned `IsApproved`, see Task 1) is true only for `PartnerApproved`.
  - [x] **Enum-value stability:** numeric value of every `DocumentState` and `ApprovalTrigger` member asserted individually, plus a count assertion so a newly-appended member without a matching assertion also fails.
- [x] Extended existing `ElDocumentApprovalServiceTests.cs` (didn't need a new file — one already existed from the Task 2 work): illegal transition throws and writes nothing; unknown document throws; completed-package guard throws. ~~`AreAllDocumentsApprovedAsync` cases~~ dropped — method doesn't exist, see Task 2.
- 202/202 `Lib.Tests` pass; 407/410 full `Lib.Tests` pass (3 pre-existing unrelated failures, see Verification).

## Verification

- [x] `dotnet build` — 0 errors (4 pre-existing warnings, unrelated: `Program.cs` nullability, `PermissionMatrixEditor.razor` unused field, `ELDashboard.razor` unused field).
- [x] `dotnet test` — 407/410 `Lib.Tests` pass, 6/6 `CDH_EL.Tests` pass. The 3 failures are the same pre-existing `EngagementLetterTemplateServiceTests` failures this plan already flagged (title-uniqueness, effective-date, default-order) — confirmed same three, not new ones; did not re-run `git stash` since this plan had already established they're pre-existing as of 2026-08-04.
- [x] No migration expected. `dotnet ef migrations has-pending-model-changes` → "No changes have been made to the model since the last migration." (Better check than the plan's suggested `migrations list` — that command can't determine pending-vs-applied without a live DB connection; `has-pending-model-changes` doesn't need one.)
- [ ] Manual smoke on `cdhel-sql`: walk one letter through the full transition chain, confirm one `ELDocumentApproval` row per click — **not done this session** (writes to a real DB, held back pending explicit go-ahead).
- [x] ~~Confirm `AreAllDocumentsApprovedAsync` flips true~~ — N/A, method doesn't exist; equivalent behavior (`ELPackage.enumPackageState` → `Approved`) is exercised indirectly by the existing `ApplyTransitionAsync_StampsAuditRowsWithTheActingUsersEmail_NotAClaimIdentifier` test's package-approval assertions, but no dedicated "all letters approved ⇒ package approved" test exists yet.
- [ ] Verify desktop + mobile widths — **not done this session** (no browser check requested/run).
- [ ] Check browser console for errors — **not done this session**, same reason.

## Status Log

- 2026-08-12 — Plan authored as P0 of the SharePoint export set. Recon confirmed the gap: `DocumentState` + `ELDocumentApproval` + DbSet all exist, but zero transition logic and zero writers anywhere in the repo; `ElPackageDetailService` hard-codes `Draft` at two sites. Two decision gates left open for Drew: whether `DocumentState` needs an appended `ReadyForPartnerReview`, and whether approving requires being the assigned reviewer or just `Workspace:Edit`.
- 2026-08-13 — Found Tasks 1-4 already implemented on `Drew/Sprint4/SharePoint-Client` (Nate/Shannon's "WIP Document and Package approval workflow" line, rebased onto this branch) — plan not updated to reflect it until now. Reconciled every task/decision-gate checkbox against the live code (see divergence notes + inline strikethroughs above). Closed the one real gap: wrote `DocumentApprovalRulesTests.cs` (91-case cross-product + enum-stability pins) and extended `ElDocumentApprovalServiceTests.cs` with illegal-transition, unknown-document, and completed-package-guard cases. `dotnet build` clean, `dotnet test` 407/410 (3 pre-existing unrelated failures), `dotnet ef migrations has-pending-model-changes` clean. Still open: whether package-regeneration resets an approved letter to `Draft` (unchecked), manual DB smoke test, and desktop/mobile/console UI verification (none run — no live DB write or browser session in this pass). P0 is functionally done; only verification-polish items remain.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|P3 — SharePoint Export UI Warplan]] (consumes this plan's gate)
- [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] (where a real approve-permission would come from)
