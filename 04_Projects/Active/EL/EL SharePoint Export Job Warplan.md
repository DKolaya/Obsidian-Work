---
title: EL SharePoint Export Job Warplan
created: 2026-08-12
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL SharePoint Export Job Warplan

**Status (2026-08-12):** Planned, not started. **P2 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. Depends on [[04_Projects/Active/EL/EL SharePoint Client Warplan|P1]] (client + mirror table). Consumed by [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|P3]].

> **For agentic workers:** Execute task-by-task; checkboxes track progress. Branch `Drew/Sprint4/SharePointExportJob` off `develop` **after P1 merges**, one PR into `develop`. Read repo `AGENTS.md` first. Reference implementation: `C:\Users\dkolaya\source\repos\CDH_FPA\CDH_FPA\Web\Jobs\UploadLetterToSPJob.cs` and that repo's `Web/Program.cs` Hangfire block. When implementation starts, copy this into `docs/reference/plans/` as the `.original.md` + compressed `.md` pair.

**Goal:** Render every letter in a package to PDF, push them to SharePoint under one per-package folder with one list item, and mirror the result into SQL — driven by a Hangfire background job so the click returns immediately. Closes the standing **"Set up Hangfire Jobs for EL"** item in [[03_Todos/Work TODOs|Work TODOs]].

**Architecture:** `ElPackageSharePointExportService` in `Lib` owns the whole orchestration and is the only thing that knows the export's business rules; it depends on `IElSharePointContext` (P1), `IElDocumentRenderService`, `IElDocumentRevisionService`, `IFpaService`, and `IDbContextFactory<ELContext>`. A thin `ExportPackageToSharePointJob` in `CDH_EL/Jobs/` is a Hangfire entry point that resolves the service and logs — no logic. Hangfire itself is registered in `CDH_EL` (web owns startup per `AGENTS.md`), SQL-Server-backed, with a dedicated queue, mirroring FPA.

## Grain and layout (locked decisions)

- **One SharePoint list item per package**, not per letter — an EL package can hold several letters (combo + separates), unlike FPA's one-letter-per-FPA.
- **One drive folder per package**, holding every letter PDF. The list item carries the *folder* link, because a package-level row cannot sensibly point at one of N files.
- **Per-letter links live on `ELDocumentFile`** rows (`enumFileKind = DocumentFileKind.Pdf`) — that table already has `sp_id` / `web_url` / `file_path` / `bytes` / `checksum` and no writers.
- **PDF only.** No DOCX export path exists and none is added here; GemBox is documented as the only final layout engine.
- **Re-export overwrites** — folder contents are replaced and the same list item is PATCHed, matching FPA's `updateExistingUpload: true`.

## Two hazards to handle before writing the happy path

### 1. Merge-field values are built inside a `.razor` and are almost empty

`ElPackageWorkspace.razor:401` has a private `BuildMergeFieldValues(document)` that populates exactly **two** fields — `client.name` and `service.line` — and returns `ElMergeFieldValueSet.FromValues(...)`. Everything else in the ~70-field catalog resolves to a `ElMergeFieldResolutionFinding`.

Two consequences:

- **A job has no circuit and no component**, so that method is unreachable from Hangfire. It must move into `Lib` regardless — business logic in a `.razor` also violates the repo's service-boundary rule.
- **Exporting today would ship client-facing PDFs with unresolved merge fields.** This is the single biggest correctness risk in the plan set. The export must therefore treat merge-field findings as a **hard failure by default**, not a warning.

- [ ] **Decision gate — confirm with Drew before Task 3.** Does export fail when any merge field used in a letter cannot be resolved, or does it upload with findings recorded? Recommendation: **fail**, listing the unresolved keys — an engagement letter that reaches a client with a blank fee or client name is worse than a blocked export. Whether the full merge-field value source gets built here or in a follow-on plan is a scope call; see [[04_Projects/Active/EL/EL Index|EL Index]] and the `docs/reference/el-document-variables-catalog.md` picker-tier work.

### 2. Furniture merge values are per-letter, not per-package

`RenderPdfAsync` takes `ElDocumentFurnitureMergeValues(string ClientLegalName, DateOnly LetterDate, int PageNumber = 2)` separately from the body `ElMergeFieldValueSet`. The export must supply both consistently for every letter in the package — same client name, same letter date — or letters in one package will disagree with each other in their headers.

- [ ] Decide the letter date source once, in the service. `Lib/Services/EngagementLetters/EngagementLetterDate.cs` already exists — check it before inventing anything, and use `ElCentralTimeCalendar` rather than `DateTime.Now` if a "today" is needed.

## Task 1 — Hangfire infrastructure

- [ ] `CDH_EL/CDH_EL.csproj`: add `Hangfire.AspNetCore` and `Hangfire.SqlServer`.
- [ ] `CDH_EL/appsettings.json`: add the `Hangfire` section mirroring FPA — `SchemaName: "Job"`, `AutoCreateHangfireTables`, `QueuePollInterval`, `AutomaticRetryAttempts`, `HangfireDashboardPath`, `HangfireDashboardTitle`. FPA sets retries to `0`; **use a small non-zero value here** (recommend `3`) since Graph throttling and transient 429s are expected, and the job is idempotent by design.
- [ ] `Program.cs`: `AddHangfire` with `UseSqlServerStorage(BuildConnectionString(builder.Configuration), ...)` — reuse the existing `BuildConnectionString` helper rather than re-reading `SQL:*` keys. Set `SchemaName`, `PrepareSchemaIfNecessary`, `QueuePollInterval`, `CommandBatchMaxTimeout`, `SlidingInvisibilityTimeout` as FPA does, plus `UseFilter(new AutomaticRetryAttribute { Attempts = ... })`.
- [ ] `AddHangfireServer` with `Queues = ["default", ExportPackageToSharePointJob.QueueName]`.
- [ ] Map the dashboard under `AppBasePath` (config value `/EL`) — verify the resulting URL works under the subfolder deploy, which is the repo's standing gotcha for anything path-based.
- [ ] **Gate the dashboard.** New `CDH_EL/Authorization/HangfireDashboardAuthorizationFilter.cs` implementing `IDashboardAuthorizationFilter`, requiring an authenticated user with `PermissionAction.Admin` on an appropriate module, resolved from `DashboardContext.GetHttpContext().RequestServices`. FPA's dashboard is unauthenticated (`IgnoreAntiforgeryToken = true`, no auth filter) — **do not copy that.** A Hangfire dashboard exposes job arguments and lets anyone re-queue jobs.
- [ ] Confirm Hangfire's schema creation works with the app's SQL login, or have the `Job` schema pre-created (see § Prerequisites).

## Task 2 — Move merge-field assembly into Lib

- [ ] New `Lib/Services/EngagementLetters/ElPackageMergeFieldValueBuilder.cs` (or extend an existing package service) exposing package-level and per-document value construction that both the workspace and the export can call.
- [ ] Move the logic currently in `ElPackageWorkspace.razor:401-420` into it verbatim first — same two fields, same "first source service wins for combo letters" comment — then extend only if the decision gate above says so. **Do not silently change render output while moving code**; a pure move should produce byte-identical PDFs.
- [ ] Update `ElPackageWorkspace.razor` to call the new service, deleting its private method.
- [ ] Also produce the `ElDocumentFurnitureMergeValues` here, so the workspace preview and the export agree on client name and letter date.

## Task 3 — Export service

- [ ] New `Lib/Services/EngagementLetters/IElPackageSharePointExportService.cs`:
  - [ ] `record ExportPackageToSharePointRequest(int PackageId, bool Overwrite, string? ActingUserEmail)`
  - [ ] `record ExportPackageToSharePointResult(int PackageId, string ListItemSpId, string FolderWebUrl, int LetterCount, IReadOnlyList<string> Warnings)`
  - [ ] `Task<ExportPackageToSharePointResult> ExportAsync(request, ct)`
  - [ ] `Task<PackageExportReadiness> GetReadinessAsync(int packageId, ct)` — P3's UI consumes this to decide whether to offer the button and what reason to show when it can't.
- [ ] New `ElPackageSharePointExportService.cs`. Order matters — **validate everything, render everything, and only then touch SharePoint**, so a failure cannot leave a half-uploaded package:
  - [ ] 1. Load the package, its non-inactive documents (ordered by `document_order`), and each document's latest revision via `IElDocumentRevisionService.GetLatestRevisionAsync` (render input is `ELDocumentRevision.editorJson`).
  - [ ] 2. Gate: package state permits export; every document is approved via `IElDocumentApprovalService.AreAllDocumentsApprovedAsync` (P0); every document has a revision; the package has ≥1 document.
  - [ ] 3. Fetch FPA detail: `IFpaService.GetFpaById(package.fpaId, includeInactiveServices: false, includeFpaServiceParagraphs: false, ct)`. From `FpaDetailDto`: `CustomerId` → Intacct customer number, `CustomerName` → client name, `Contact.ContactName` / `Contact.Email` → client signer, `RelationshipManager.Email` → RM reviewer, `Partner.Email` → partner reviewer. (Verified present on `CDH_Bridge_SDK` `origin/develop`.)
  - [ ] 4. Validate collect-all-errors style, mirroring FPA's `ValidateSpListItem` — one exception listing every problem, not the first. Required: title, client name, RM email, partner email, Intacct customer number, signer name, signer email, ≥1 rendered letter. Plus the merge-field-findings rule from the decision gate.
  - [ ] 5. Render each letter: `IElDocumentRenderService.RenderPdfAsync(editorJson, furnitureMergeValues, mergeFieldValues, new ElDocumentRenderOptions(fileName), ct)`. Keep every `ElDocumentRenderResult` — its `Audit` carries `ContentHash`, `ArtifactSha256`, renderer/furniture versions, and asset checksums that belong on the persisted rows.
  - [ ] 6. File naming: deterministic and collision-free across a client's packages — e.g. `{client} - {letter title} - {fiscal year}.pdf`, sanitized for SharePoint's forbidden characters (`" * : < > ? / \ |`), leading/trailing dots and spaces, and a name-length cap. Two letters in one package must never collide; write a test for the sanitizer.
  - [ ] 7. `EnsureFolderAsync(folderName)` → `UploadFileAsync` per letter → `AddOrUpdateListItemAsync` with the mapped fields (existing `sp_id` from `ELPackageSpListItem` when re-exporting).
  - [ ] 8. Persist in one transaction: upsert `ELPackageSpListItem` (folder ids, letter count, reviewer/signer/Intacct values, `date_exported_utc`, clear `export_error`), and one `ELDocumentFile` row per letter (`documentRevisionId`, `enumFileKind = Pdf`, `fileName`, `contentType`, `spId`, `webUrl`, `filePath`, `checksum` from `Audit.ArtifactSha256`, `bytes`, `dateGeneratedUtc`, `generatedByUserRecordId`). Re-export must **update or replace** prior rows for the same revision, not accumulate duplicates.
  - [ ] 9. On failure: record `export_error` + timestamp on `ELPackageSpListItem` so P3's UI can show it, then rethrow. FPA instead stuffs an error flag into approval-note JSON metadata (`UploadLetterToSPJob.SetUploadedToSPNoteError`) — do not copy that; EL has an audit trail and a real column.
  - [ ] XML docs on the public members covering the workflow, the external systems touched (Graph, Bridge), the data mutated, and the failure semantics — required by `AGENTS.md` for integration/IO code.
- [ ] Register in `Program.cs` near the other EL services.

## Task 4 — Hangfire job

- [ ] New `CDH_EL/Jobs/ExportPackageToSharePointJob.cs`, mirroring `UploadLetterToSPJob`'s shape:
  - [ ] `public static readonly string JobName` / `QueueName = "queue_" + JobName`.
  - [ ] `public static void Enqueue(int packageId, bool overwrite = false)` → `BackgroundJob.Enqueue<ExportPackageToSharePointJob>(QueueName, x => x.InvokeAsync(packageId, overwrite))`.
  - [ ] `InvokeAsync`: early-exit with a warning log when `IElSharePointContext.IsDisabled`; call the service; log start/complete in a `finally`; **rethrow** so failures surface on the dashboard.
  - [ ] Hangfire needs a public parameterless-resolvable type — constructor-inject the service and `ILogger<ExportPackageToSharePointJob>`, and register the job type in DI as FPA does.
  - [ ] Keep it thin: no EF queries, no Graph calls, no validation. If logic creeps in here it belongs in the service.
- [ ] Confirm the job's `CancellationToken` story — Hangfire supplies `IJobCancellationToken`; pass a real token into the service rather than `CancellationToken.None`.

## Task 5 — Tests

- [ ] `Lib.Tests/Services/EngagementLetters/ElPackageSharePointExportServiceTests.cs`, with a fake `IElSharePointContext` recording calls, a stub `IFpaService`, and a stub render service:
  - [ ] Gate rejections: package not approved; a document unapproved; a document with no revision; zero documents.
  - [ ] Validation: each missing FPA-sourced value produces an error, and **all** errors surface from one call, not just the first.
  - [ ] Happy path: folder ensured exactly once; one upload per letter; exactly one list item call; one `ELDocumentFile` row per letter with `spId`/`webUrl`/`filePath`/`checksum` set; one `ELPackageSpListItem` row with `letter_count` matching.
  - [ ] Re-export: same list item PATCHed (not a second POST), no duplicate `ELDocumentFile` rows, folder not recreated.
  - [ ] Failure mid-upload: `export_error` recorded, exception rethrown, and no partial `ELDocumentFile` rows committed.
  - [ ] Disabled context: service is never reached from the job (assert at the job level or via an `IsDisabled` guard test).
  - [ ] File-name sanitizer: forbidden characters stripped, length capped, two letters in one package never collide.
- [ ] Merge-field builder tests: the moved logic produces the same values as before the move (guard the "pure move" claim).

## Verification

- [ ] `dotnet build` — 0 errors.
- [ ] `dotnet test` — new tests pass; pre-existing `EngagementLetterTemplateServiceTests` failures unchanged (confirm via `git stash`).
- [ ] App starts with Hangfire enabled against the **local Docker container `cdhel-sql`**; confirm the `Job` schema tables are created (or pre-created) and the dashboard loads at the `AppBasePath`-prefixed path.
- [ ] Dashboard authorization: a non-admin user is refused; an admin gets in. Verify while signed out too.
- [ ] Disabled path first (`SharePoint:IsDisabled = "True"`): enqueue the job, confirm the early-exit warning log and **zero** DB writes and zero Graph calls.
- [ ] Enabled path against the real EL list/library: enqueue for a package with 2+ letters. Verify one folder holds every PDF, one list item carries the metadata, and people columns resolved to real users rather than raw text.
- [ ] Open an exported PDF and read it — confirm no unresolved merge tokens or blank client/fee values reached the artifact. This is the check that matters most.
- [ ] SQL: exactly one `ELPackageSpListItem` for the package; one `ELDocumentFile` per letter with SharePoint columns populated; `date_exported_utc` set; `export_error` null.
- [ ] Re-export the same package: folder contents overwritten, same list item PATCHed, no duplicate rows or items.
- [ ] Failure path: point `DriveName` at a nonexistent library, enqueue, and confirm the job fails visibly on the dashboard, `export_error` is recorded, and no partial `ELDocumentFile` rows remain.
- [ ] Throttling sanity: confirm a retried job does not duplicate uploads or rows (idempotency is what makes non-zero retries safe).

## Prerequisites outside this plan

1. P1 merged (client + `ELPackageSpListItem` + config).
2. P0 merged for the real gate — until then `AreAllDocumentsApprovedAsync` can be exercised by setting `enum_document_state` directly in the local DB (`3` = `PartnerApproved`).
3. EL SharePoint list + document library created; internal column names captured.
4. Graph app registration with `Sites.Selected` (plus site grant) or `Sites.ReadWrite.All`, admin-consented; secret in `appsettings.Development.local.json` (**not** the tracked `appsettings.Development.json`).
5. `CdhBridgeApis:Fpa:BaseUrl` / `ApiKey` configured — they are empty in `appsettings.json` and the export reads FPA detail at runtime.
6. SQL login able to create the Hangfire `Job` schema, or a DBA pre-creating it.

## Status Log

- 2026-08-12 — Plan authored as P2 of the SharePoint export set. Two hazards found during recon and folded in as first-class tasks: (1) merge-field value assembly lives in `ElPackageWorkspace.razor:401` and populates only `client.name` + `service.line`, so it is both unreachable from a job and insufficient for a client-facing artifact — decision gate opened on fail-vs-warn; (2) `ElDocumentFurnitureMergeValues` is passed separately from the body merge set, so package letters can disagree on client name and letter date unless the service owns both. Also noted FPA sets Hangfire retries to 0 and leaves its dashboard unauthenticated — both deliberately diverged from here.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Client Warplan|P1 — SharePoint Client Warplan]] (dependency)
- [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|P0 — Document Approval Workflow Warplan]] (supplies the gate)
- [[03_Todos/Work TODOs|Work TODOs]] (closes "Set up Hangfire Jobs for EL")
