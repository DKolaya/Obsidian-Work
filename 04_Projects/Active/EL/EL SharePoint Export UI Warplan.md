---
title: EL SharePoint Export UI Warplan
created: 2026-08-12
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL SharePoint Export UI Warplan

**Status (2026-08-12):** Planned, not started. **P3 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. Depends on [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]] for the enqueue target and on [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|P0]] for the gate. Land last.

> **For agentic workers:** Execute task-by-task; checkboxes track progress. Branch `Drew/Sprint4/SharePointExportUi` off `develop` **after P0 and P2 merge**, one PR into `develop`. Read repo `AGENTS.md` and `docs/reference/ui-style-guide.md` first, and query `Havit.Blazor.Mcp` for any HAVIT component API before writing markup (global rule — never guess `Hx*` parameters). When implementation starts, copy this into `docs/reference/plans/` as the `.original.md` + compressed `.md` pair.

**Goal:** Give the package workspace the actual button. After every letter is approved, a **Send to SharePoint** action moves the package to a new `Sent to SharePoint` state and enqueues the export; **Complete Package** becomes available only from there; **Request Changes** sends the package back into the workflow. The workspace shows where the files landed and whether the last export failed.

**Architecture:** Two appended enum values, three rules-table edits, one status-UI mapping, and workspace wiring. No new services — P2's export service and P0's approval service supply everything; this plan is presentation plus state machine.

## The workflow being built

```
Approved ──SendToSharePoint──▶ Sent to SharePoint ──Finalize──▶ Completed
                                       │
                                       └──ReviewerRequestsChange──▶ Draft
```

Gate on the `SendToSharePoint` button: package is `Approved` **and** every letter is approved (`IElDocumentApprovalService.AreAllDocumentsApprovedAsync`, P0).

Note what this changes about today's flow: `Finalize` currently fires from `Approved` (`PackageApprovalRules.cs:22`). After this plan, `Approved` offers only `SendToSharePoint`, and `Finalize` moves to the new state. That is the intended behavior — a package must not be completable without its letters reaching SharePoint.

## Enum changes are append-only — read this before touching `Enums.cs`

`PackageState` and `ApprovalTrigger` persist as `int` in `ELPackage.enum_package_state`, `ELPackageApproval.enum_state_previous` / `enum_trigger` / `enum_state_new`, and the document-level equivalents. **Appending is safe; inserting or reordering silently relabels every historical row.** `PackageState.Inactive` is currently the last member — the new value goes after it, and its numeric value will be `6` even though it sits logically between `Approved` and `Completed`. That ordering mismatch is correct and intentional; do not "tidy" it.

This repo has already taken one fleet-wide permissions lockout from an enum-shape change (see [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] § defect 3). Same hazard class.

## Task 1 — Enums

- [ ] `Lib/Enums/Enums.cs` — **append** to `PackageState`:
      `[Display(Name = "Sent to SharePoint")] SentToSharePoint` (after `Inactive`).
- [ ] **Append** to `ApprovalTrigger`:
      `[Display(Name = "Send to SharePoint", ShortName = "Sent to SharePoint", Description = "Sending to SharePoint")] SendToSharePoint` — match the three-part `Display` style every other trigger uses; `ShortName` is what history rows read as.
- [ ] Do **not** add a new "request changes" trigger — `ReviewerRequestsChange` ("Request Changes") already exists and is reused here.
- [ ] Confirm no `switch` elsewhere on `PackageState` breaks on the new member. Grep `PackageState` across the repo; `PackageStatusUi` and `ElPackageDocumentEditor.razor` are the known consumers.

## Task 2 — Approval rules

- [ ] `Lib/Services/EngagementLetters/PackageApprovalRules.cs` — `GetAvailableTriggers`:
  - [ ] `Approved => [ApprovalTrigger.SendToSharePoint]` (Finalize moves off `Approved`)
  - [ ] `SentToSharePoint => [ApprovalTrigger.Finalize, ApprovalTrigger.ReviewerRequestsChange]`
- [ ] `Apply` mappings:
  - [ ] `(Approved, SendToSharePoint) => SentToSharePoint`
  - [ ] `(SentToSharePoint, Finalize) => Completed`
  - [ ] `(SentToSharePoint, ReviewerRequestsChange) => Draft`
- [ ] Update the class's `remarks` doc comment — it currently describes the old `Draft → Submit → ReadyForReview → Approve → Approved → Finalize` chain and would be stale.
- [ ] The rules layer stays identity-free and gate-free. The all-letters-approved check belongs in the UI/service layer, not here — `PackageApprovalRules` takes only a state and a trigger, and keeping it that way is what makes it trivially testable.

## Task 3 — Status presentation

- [ ] `CDH_EL/Components/Shared/PackageStatusUi.cs` — add `PackageState.SentToSharePoint => ThemeColor.Primary` to `Color`. `DisplayText` already falls through to `GetDisplayName()`, so the `[Display]` name carries it; verify rather than assume.
- [ ] `ElPackageWorkspace.razor:808` `GetTriggerButtonText` — add `ApprovalTrigger.SendToSharePoint => "Send to SharePoint"` and change `ApprovalTrigger.Finalize => "Complete Package"` (Drew's wording; display-only, no enum change).
- [ ] `:818` `GetTriggerButtonColor` — `SendToSharePoint => ThemeColor.Primary`, and consider `ReviewerRequestsChange => ThemeColor.Warning` so "request changes" doesn't read as a primary action next to Complete Package.
- [ ] Check the EL dashboard (`ELDashboard.razor`) and any status filter/column that enumerates `PackageState` — a new state must appear correctly there too, not just in the workspace.

## Task 4 — Workspace wiring

- [ ] `CDH_EL/Components/Pages/EngagementLetters/ElPackageWorkspace.razor` — inject `IElDocumentApprovalService` and `IElPackageSharePointExportService`.
- [ ] The Workflow card at `:332` already renders every trigger `availableTriggers` returns, so the button appears automatically once Task 2 lands. What's needed is the **gate**: filter `SendToSharePoint` out of the rendered list unless readiness passes, and show a muted reason line instead (e.g. "2 of 3 letters still need approval", or "SharePoint export is disabled"). Reuse P2's `GetReadinessAsync` rather than recomputing the rule here.
- [ ] Compute readiness in `LoadAsync` alongside `availableTriggers` (`:540`) so a render pass never awaits.
- [ ] On click: enqueue via `ExportPackageToSharePointJob.Enqueue(packageId, overwrite: true)`, then apply the state transition through the existing `ApplyTransitionAsync` path (`:551`) so the `ELPackageApproval` history row is written exactly like every other transition. **Order matters** — decide and document whether the state flips before or after enqueue; recommendation: **transition first, then enqueue**, so a queue failure leaves a package in `Sent to SharePoint` with a visible export error rather than a silently un-enqueued success. Overwrite is `true` to match FPA's `updateExistingUpload: true` and to make re-export idempotent.
- [ ] Toast via `HxMessenger` that the upload is running in the background and the page can be left — the job is async and the UI must not imply completion.
- [ ] Surface export state from `ELPackageSpListItem`: SharePoint folder link (`HxButton`/anchor with `Href` to `folder_web_url`, opening in a new tab), letter count, `date_exported_utc`, and `export_error` in an `HxAlert` with `Color="ThemeColor.Danger"` when set — plus a re-send action when an export failed. Read it through P2's service or the package detail service; **no EF queries in the `.razor`** (`AGENTS.md`).
- [ ] Permissions: reuse the existing `canEdit` (`PermissionModule.Workspace` + `PermissionAction.Edit`, `:504`). `PermissionAction` is a fixed four-value enum — no new action and no permission-catalog change in this plan.
- [ ] Navigation/links must stay base-path-safe for the `/EL` subfolder deploy: relative `Href` for app pages; the SharePoint folder URL is external and absolute, which is fine.

## Task 5 — Docs

- [ ] New doc pair `docs/reference/el-sharepoint-export.md` (compressed) + `.original.md` (prose), per repo doc convention: config keys, required Graph permissions, list/library and column contract, job + queue names, the state machine above, failure handling and re-export semantics, and where the mirror rows live.
- [ ] Add the export flow to the docs index section of `AGENTS.md` if the pattern is one another agent would need to find.
- [ ] If this introduces a new Blazor pattern worth reusing (background-job-triggering button with readiness gating), note it in `docs/reference/ui-style-guide.md` per `AGENTS.md`.

## Task 6 — Tests

- [ ] `Lib.Tests` — extend the `PackageApprovalRules` tests:
  - [ ] `Approved` offers exactly `[SendToSharePoint]` — explicitly assert `Finalize` is **no longer** available from `Approved`, since that is the behavior change most likely to surprise.
  - [ ] `SentToSharePoint` offers exactly `[Finalize, ReviewerRequestsChange]`.
  - [ ] All three new `Apply` mappings; illegal pairs still throw.
  - [ ] **Enum-value stability:** assert the numeric value of every `PackageState` and `ApprovalTrigger` member so a future reorder fails a test instead of rewriting approval history.
- [ ] Readiness gating: a package whose letters are not all approved does not offer the trigger; one whose letters are, does.

## Verification

- [ ] `dotnet build` — 0 errors.
- [ ] `dotnet test` — new assertions pass; pre-existing `EngagementLetterTemplateServiceTests` failures unchanged (confirm via `git stash`).
- [ ] No migration expected — appending enum members and `[Display]` attributes does not change the EF model. Confirm with `dotnet ef migrations list` / an empty `migrations add` dry run that nothing is pending, and **verify existing rows still read correctly** (a package sitting at `Completed` = `4` must still display "Complete").
- [ ] Walk the full workflow on the local `cdhel-sql` container: Draft → Submit → Ready for Review → Approve → Approved. Confirm **Send to SharePoint** is hidden while any letter is unapproved and appears once all are, with the reason line correct in between.
- [ ] Click it: state becomes `Sent to SharePoint`, the toast appears, the Hangfire dashboard shows the job, and one `ELPackageApproval` row records `Approved → SendToSharePoint → SentToSharePoint` with the right actor.
- [ ] From `Sent to SharePoint`: **Complete Package** reaches `Completed`; **Request Changes** returns to `Draft`. Confirm history rows for both.
- [ ] Failure display: force an export failure (point `DriveName` at a nonexistent library), confirm the danger alert and the re-send action appear, and that re-sending after fixing config succeeds without duplicating rows or list items.
- [ ] With `SharePoint:IsDisabled = "True"`, confirm the UI says so rather than offering a button that silently no-ops.
- [ ] Verify desktop **and** mobile widths: no text overlap, no clipped controls, no page-level horizontal scroll — the workspace is a three-panel layout and the Workflow card is in the collapsible right panel, so check both collapsed and expanded.
- [ ] Check the browser console for errors, and confirm the EL dashboard renders the new status correctly.

## Status Log

- 2026-08-12 — Plan authored as P3 of the SharePoint export set. Confirmed the Workflow card at `ElPackageWorkspace.razor:332` renders whatever `availableTriggers` returns, so the button needs no new markup — only the rules change plus gating. Confirmed `Finalize` currently fires from `Approved` (`PackageApprovalRules.cs:22`) and its button reads "Finalize"; both change here (state source and label → "Complete Package"). `PackageState.Inactive` is the current last member, so `SentToSharePoint` takes value `6` despite sitting logically mid-flow — deliberate, append-only.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2 — SharePoint Export Job Warplan]] (dependency)
- [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|P0 — Document Approval Workflow Warplan]] (supplies the gate)
- [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] (enum-change hazard precedent)
