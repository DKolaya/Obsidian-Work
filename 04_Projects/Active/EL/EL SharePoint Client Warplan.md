---
title: EL SharePoint Client Warplan
created: 2026-08-12
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL SharePoint Client Warplan

**Status (2026-08-13):** All 5 tasks done. Migration applied to local `cdhel-sql`. **P1 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. No dependencies; ran in parallel with [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|P0]] (which is functionally done). Unblocks [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]] — the real `IElSharePointContext` this plan built is what P2's stub-retiring work consumes.

**Found while starting this plan:** a stub `ISharePointExportService`/`SharePointExportService` already exists in `Lib/Services/EngagementLetters/` and is wired into `ElPackageWorkspace.razor` and `Program.cs` — it logs and returns success with no real Graph call, explicitly so the surrounding UI/workflow could be built ahead of real SharePoint integration. This plan's `IElSharePointContext` is the piece that stub is waiting to be replaced with; P2 (which owns export orchestration) is the natural place to retire the stub, not this plan.

> **For agentic workers:** Execute task-by-task; checkboxes track progress. Branch `Drew/Sprint4/SharePointClient` off `develop`, one PR into `develop`. Read repo `AGENTS.md` first. The reference implementation being ported lives in the sibling repo `C:\Users\dkolaya\source\repos\CDH_FPA` — read `CDH_FPA/Lib/DAL/SPContext.cs` and `CDH_FPA/Lib/Models/SharePoint/SpListItem.cs` before writing code. That folder is gitignored here (`.gitignore:366`), so nothing from it gets committed to this repo. When implementation starts, copy this into `docs/reference/plans/` as the `.original.md` + compressed `.md` pair.

**Goal:** Give CDH_EL a working, async, testable Microsoft Graph client for SharePoint list items and document-library files, plus the package-level mirror table that records what was uploaded. Ships no user-visible behavior — it is the substrate P2 consumes.

**Architecture:** `Lib/Services/SharePoint/` holds a Graph client (`ElSharePointContext`) behind `IElSharePointContext`, configured from an `ElSharePointOptions` record. Graph field mapping is attribute-driven and generic (`Lib/Models/SharePoint/`), ported from FPA's reflection mapper rather than hand-written per entity. `Lib/Models/EL/ELPackageSpListItem.cs` mirrors the SharePoint list item back into SQL; per-letter file artifacts reuse the existing `ELDocumentFile` table, which already has `sp_id` / `web_url` / `file_path` / `bytes` / `checksum` columns and no writers.

## What FPA does, and what changes here

| Aspect | FPA (`SPContext.cs`) | EL (this plan) |
|---|---|---|
| Auth | `ClientSecretCredential` + `GraphServiceClient`, scope `https://graph.microsoft.com/.default` | Same |
| Site resolution | `Sites[{tenant}.sharepoint.com:/{site}]`, asserts the id has ≥2 comma segments and the first matches the tenant, returns segment `[1]` | Same, ported verbatim — that assertion catches misconfiguration early |
| Caching | Lazy `??=` fields for site id, list id, drive id, user map | Same, but per-scope (service is scoped, so the cache lives for one job run) |
| People columns | `User Information List` → dictionary of (id, `EMail`); note the deliberate `"EMail"` casing | Same. **Keep the casing comment** — it is load-bearing |
| Async | `.Result` on every Graph call | **Async all the way** with `CancellationToken`, per repo `AGENTS.md`. FPA's blocking is safe inside a Hangfire worker; a `Lib` service reachable from a Blazor circuit must not block |
| Upload | `Drives[id].Root.ItemWithPath(name).Content.PutAsync(stream)` — overwrites when the name exists | Same, but into a per-package folder |
| Folders | None — flat library root | **New:** `EnsureFolderAsync` |
| List item upsert | POST when `spId` null, else PATCH; on `"The specified list item was not found"` fall back to POST | Same — port the recovery, it handles items deleted in SharePoint |
| Kill switch | `IsDisabled()` from config string `"True"` | Same, but bind a real `bool` |
| Errors | Wraps upload failures in `new Exception(...)`, otherwise raw `Exception` throws | Typed `ElSharePointException` so callers can distinguish config, not-found, and locked-file failures |
| `WriteBytesToDb` config | **Present in appsettings, never read in code.** Dead config | Do not port it |

## Design decisions

### `Lib` is the right home

Repo `AGENTS.md`: `Lib` owns reusable services and entities; only Blazor / HAVIT / Auth0 / MVC dependencies are barred from it. `Microsoft.Graph` + `Azure.Identity` are plain SDKs and belong there. FPA put its `SpContext` in `Web/Wrappers` — do not copy that placement; EL needs the client callable from both a job and (potentially) a controller.

### Generic mapper, not a per-entity mapper

FPA's `SpListItem.FromDictionary` / `ToDictionary` are reflection loops welded onto one class. Port them as `GraphFieldMapper.ToFields<T>(T, resolver)` / `FromFields<T>(dictionary, resolver)` so a second mapped entity costs nothing. The user-lookup translation needs an email↔id resolver — pass it as a small interface (`IGraphUserResolver`) rather than the whole context, so mapper tests need no Graph.

### All SharePoint column names live in one file

SharePoint mangles internal names (`IntacctCust_x0023_`, `FPA_x0020_Document_x0020_ID`, `FPA_x0020_Document_x0020_File_x0` — note that last one is *truncated* at 32 chars by SharePoint). The EL list does not exist yet, so its internal names are unknown at authoring time. Keep every `[GraphField]` string in the model file and nothing else, so relisting is one edit.

- [ ] **Blocked on provisioning.** The EL list + library must be created and their internal column names captured before the `[GraphField]` strings can be filled in. Until then, code against placeholder names and keep the mapper tests name-agnostic.

### Secrets

Values go in `appsettings.Development.local.json` — already loaded at `CDH_EL/Program.cs:37`, gitignored via `appsettings.*.local.json` (`.gitignore:384`). **`appsettings.Development.json` is tracked in this repo; the client secret must not go there.** CDH_FPA's own `appsettings.json` has its Graph client secret committed in cleartext — do not copy that value into any tracked file, and raise rotation with whoever owns that app registration.

## Task 1 — Packages and config

- [x] `Lib/Lib.csproj`: added `Microsoft.Graph` 6.5.0 and `Azure.Identity` 1.21.0 (latest stable, confirmed net10.0-compatible via clean `dotnet build Lib`).
- [x] `CDH_EL/appsettings.json`: added `SharePoint` section, empty secret values, `"IsDisabled": "True"`, key shape matches FPA (`Azure:AppRegistration:TenantId/ClientId/ClientSecret`, `TenantName`, `SiteName`, `ListName`, `DriveName`). `WriteBytesToDb` not ported.
- [x] No `Hangfire` section added — deferred to P2 as planned.
- [x] `Lib/Services/SharePoint/ElSharePointOptions.cs` — `record` with the above, `IsDisabled` as `bool`, plus a `Validate()` returning collected problem strings. Also added a `Bind(IConfiguration)` factory (not in the original plan) since the flat record and the nested tracked-JSON shape (`Azure:AppRegistration:*`) don't line up for a plain `IConfiguration.Get<T>()` bind — needed somewhere for Task 3's DI registration to consume, so it landed here instead of being invented ad hoc later.

**Note:** Verified `Lib`/`Lib.Tests` build and test clean with the new packages. Could not verify the full solution (`CDH_EL`, `CDH_EL.Tests`) — the internal NuGet feed `\\192.168.17.202\Nuget\packages` (source of `CDH.Bridge.Client`) is currently unreachable (network/VPN down), unrelated to this change. Re-run `dotnet build` once connectivity is back, before Task 3's `Program.cs` registration lands.

## Task 2 — Graph field mapping

- [x] `Lib/Models/SharePoint/GraphFieldAttribute.cs` — port FPA's attribute including `LookupTypes { None, User }`.
- [x] `Lib/Models/SharePoint/IGraphUserResolver.cs` — `Task<string?> GetUserIdAsync(string? email, ct)` / `Task<string?> GetUserEmailAsync(string? userId, ct)`.
- [x] `Lib/Models/SharePoint/GraphFieldMapper.cs` — generic `ToFieldsAsync<T>` / `FromFieldsAsync<T>`, skipping properties without the attribute and null/whitespace values on write (FPA's behavior — a null property must not blank a SharePoint column). Both take an optional `ILogger?` so a failed user-lookup fallback is logged, not silent.
- [x] Preserve FPA's id handling: the item id travels as the field key `"Id"` on read (`GraphFieldMapper.IdFieldName`), and must be **removed** from the dictionary before a PATCH via `GraphFieldMapper.RemoveIdField` (see `UpdateRawSpListItem` — sending `Id` as a field fails).

## Task 3 — SharePoint client

- [x] `Lib/Services/SharePoint/IElSharePointContext.cs`:
  - [x] `bool IsDisabled { get; }`
  - [x] `Task<SharePointFolder> EnsureFolderAsync(string folderName, CancellationToken ct)`
  - [x] `Task<SharePointFile> UploadFileAsync(string folderPath, string fileName, byte[] bytes, CancellationToken ct)`
  - [x] `Task<IReadOnlyDictionary<string, object>> AddOrUpdateListItemAsync(string? spId, IReadOnlyDictionary<string, object> fields, CancellationToken ct)`
  - [x] `IGraphUserResolver` implemented by the same class — `IElSharePointContext : IGraphUserResolver`.
  - [x] Small `record` results carrying `Id`, `Name`, `WebUrl`, `FilePath`.
- [x] `ElSharePointContext.cs`:
  - [x] Lazy async caches for site id, list id, drive id, and the user map. Each guarded by its own `SemaphoreSlim`.
  - [x] Port the site-id assertions verbatim (≥2 comma segments; first segment matches the tenant in the site key).
  - [x] `EnsureFolderAsync`: looks for the child folder by name under the drive root (`Children.GetAsync` + name match, not exception-driven); creates it with a `DriveItem { Name, Folder = new Folder() }` POST when absent. Idempotent.
  - [x] `UploadFileAsync`: PUT content to the item path under the folder. A "lock"-mentioning failure wraps as `ElSharePointException` with `FailureKind.FileLocked` and the file name; any other upload failure wraps as `FailureKind.Unknown`.
  - [x] `AddOrUpdateListItemAsync`: POST when `spId` is null; PATCH otherwise; on `"The specified list item was not found"` (case-insensitive) logs a warning and POSTs instead.
  - [x] Every method throws `ElSharePointException` (`FailureKind.Configuration`) when `IsDisabled` — callers must check `IsDisabled` first, as planned.
  - [x] `ILogger<ElSharePointContext>` for resolution steps and not-found recovery. No Serilog in `Lib`.
- [x] Registered in `CDH_EL/Program.cs` (next to the `ISharePointExportService` registration) — scoped, options bound from configuration via `ElSharePointOptions.Bind`, following the explicit-factory style already used for `ElDocumentRenderService`.

**Deviation from the plan:** added an `ElSharePointFailureKind` enum (`Configuration`/`NotFound`/`FileLocked`/`Unknown`) on `ElSharePointException` rather than subclassing per-failure exception types — same "callers can distinguish config/not-found/locked" goal from the plan's Design table, one exception type instead of three.

## Task 4 — Mirror table

- [x] `Lib/Models/EL/ELPackageSpListItem.cs`, `[Table("ELPackageSpListItem")]`, `BaseRecord`-derived, snake_case columns, `[GraphField]`-annotated where the value maps to SharePoint:
  - [x] `id`, `package_id` (FK → `ELPackage`), `sp_id`
  - [x] `title`, `status`, `client_name`, `letter_count`
  - [x] `folder_sp_id`, `folder_web_url`, `folder_file_path`
  - [x] `rm_reviewer_email`, `partner_reviewer_email` (both `LookupTypes.User`)
  - [x] `client_signer_name`, `client_signer_email`, `intacct_customer_number`
  - [x] `docusign_envelope_id`, `docusign_status` (written empty in this plan set; no read-back)
  - [x] `date_exported_utc`, `export_error` (nullable)
- [x] Unique index on `package_id` — `[Index(nameof(packageId), IsUnique = true)]`, matching `ELDocument`'s style.
- [x] Sizing follows this codebase's actual convention (`[Column(..., TypeName = "nvarchar(N)")]`, not FPA's `[MaxLength]` attribute): `nvarchar(100)` for FPA-mirrored short fields, `nvarchar(1000)` for `sp_id`/`folder_sp_id`/`folder_web_url`/`folder_file_path` (matching `ELDocumentFile`'s URL-ish columns) and for `export_error` (free-text message, no FPA precedent to mirror).
- [x] DbSet in `Lib/DAL/ELContext.cs` beside `ELDocumentFile`.
- [x] Migration `Lib/Migrations/20260813191148_add_table_ELPackageSpListItem.cs`.
- [x] **No new attachment table** — confirmed, used `ELDocumentFile` as planned.

**Deviations from the plan:** `letter_count`, `folder_sp_id`, `folder_web_url`, `folder_file_path` are **not** `[GraphField]`-annotated — folder metadata comes back from `EnsureFolderAsync`'s `SharePointFolder` result (drive API), not a list-item field, so it never flows through `GraphFieldMapper`; `letter_count` is EL-derived with no obvious SharePoint column counterpart yet. `intacct_customer_number`'s `[GraphField]` placeholder is a clean name (`"IntacctCustomerNumber"`), not FPA's actual mangled internal name (`IntacctCust_x0023_`) — the EL list doesn't exist yet, so there's no real internal name to port; this is just a readable placeholder pending provisioning, per the plan's own "relisting is one edit" design goal.

## Task 5 — Tests

- [x] New `Lib.Tests/Models/SharePoint/GraphFieldMapperTests.cs`:
  - [x] Round-trip an annotated test type; unannotated properties are ignored.
  - [x] Null / whitespace values are omitted on write (must not blank a column).
  - [x] `LookupTypes.User` writes the resolved lookup id and reads back the email, using a stub resolver.
  - [x] Unresolvable email/id falls back to the raw string rather than throwing, and a `RecordingLogger` test double asserts a warning was logged.
  - [x] `"Id"` is stripped before PATCH (`RemoveIdField`) and present after read (`FromFieldsAsync`).
- [x] New `Lib.Tests/Services/SharePoint/ElSharePointOptionsTests.cs` — `Validate()` reports each missing value (and none when complete); added `Bind()` coverage (nested `Azure:AppRegistration` secret + flat keys, `IsDisabled` default-true) beyond the plan's minimum.
- [x] No live-Graph tests, as planned.

## Verification

- [x] `dotnet build` — `Lib`, `Lib.Tests`, `CDH_EL` all 0 errors. Full `CDH_EL` solution build no longer blocked — internal NuGet feed (`\\192.168.17.202\Nuget\packages`) was still unreachable this session too, but `dotnet restore --ignore-failed-sources` (local package cache already warm) got past it.
- [x] `dotnet test` — all Task 5 tests pass. Same 3 pre-existing `EngagementLetterTemplateServiceTests` failures (title-uniqueness, effective-date, default-order) unchanged. One additional failure surfaced (`ElDocumentPdfPreviewServiceTests.GenerateAsync_RendersContinuationFurnitureForMultiPageBody`) — confirmed order-dependent/flaky, not a regression: passes cleanly in isolation, shares no code with this plan's changes.
- [x] `dotnet ef migrations add add_table_ELPackageSpListItem` + `dotnet ef database update`, against **local Docker `cdhel-sql`**.
- [x] Confirmed columns/types/lengths, unique index on `package_id`, FK to `ELPackage` via `sqlcmd`.
- [x] Confirmed `Down()` drops cleanly and re-`update` recreates (round-tripped as a side effect of a rollback-target mistake — landed on `Down()` two migrations back, which correctly hit the intentionally-irreversible `update_UserRecord_trim_disallowed_permission_actions` migration and stopped there; the intermediate `Down()`/`Up()` for this table both ran and were verified via `__EFMigrationsHistory` + `sys.tables`).
- [x] App starts with `SharePoint:IsDisabled = "True"` and empty secrets — no startup exception (`ElSharePointOptions.Bind` is invoked lazily per-scope, not eagerly at startup, and nothing resolves `IElSharePointContext` yet).
- [ ] Manual Graph smoke — still blocked on provisioning (list/library/secrets don't exist yet), unchanged from plan authoring.
- [ ] Employee-email resolution spot-check — still blocked on provisioning, unchanged from plan authoring.

**Local dev DB config note:** `CDH_EL/appsettings.Development.json`'s `SQL`/`SQL-Log` sections had reverted to the shared `192.168.17.202\CDH_FPA` box (the local `localhost,1433` / `cdhel-sql` pointer from 2026-07-21 was gone — file was back to its tracked, remote-pointing state). Re-pointed both sections at `localhost,1433` / `CDH_EL_DK_S3` / `sa` / `CDH_El_Local1!` before running migrations — intentionally an uncommitted local-only edit, not meant to ship, per the same convention as before.

## Status Log

- 2026-08-12 — Plan authored as P1 of the SharePoint export set. Ported design read out of `CDH_FPA/Lib/DAL/SPContext.cs` + `Lib/Models/SharePoint/SpListItem.cs`. Confirmed `ELDocumentFile` already carries `sp_id`/`web_url`/`file_path`/`bytes`/`checksum` with zero writers anywhere in CDH_EL, so no attachment table is needed. Confirmed FPA's `WriteBytesToDb` config key is never read in FPA code — not ported. Blocked item: the EL list/library must exist before `[GraphField]` internal column names can be filled in.
- 2026-08-13 — Task 1 done: `Microsoft.Graph` 6.5.0 + `Azure.Identity` 1.21.0 added to `Lib.csproj` (confirmed via `dotnet package search` as current latest stable); `SharePoint` config section added to `CDH_EL/appsettings.json` with empty secrets and `IsDisabled: "True"`; `ElSharePointOptions` record + `Validate()` + a `Bind(IConfiguration)` factory added at `Lib/Services/SharePoint/ElSharePointOptions.cs`. Confirmed the tracked FPA config shape by reading `CDH_FPA/Web/appsettings.json` directly rather than guessing (`Azure:AppRegistration:TenantId/ClientId/ClientSecret` nesting). `Lib`/`Lib.Tests` build and test clean. Could not verify the full `CDH_EL` solution build — internal NuGet feed `\\192.168.17.202\Nuget\packages` unreachable this session (VPN/network down); re-check before Task 3 lands `Program.cs` registration. Also found a pre-existing stub `ISharePointExportService` already wired into the workspace UI, waiting on this plan's client — noted above, real replacement is P2's job.
- 2026-08-13 (later same day) — Tasks 2-5 done, all in one pass. Ported `CDH_FPA/Web/Wrappers/SpContext.cs` + `Lib/Models/SharePoint/SpListItem.cs` (read directly from the sibling repo) into `GraphFieldAttribute`/`IGraphUserResolver`/`GraphFieldMapper` (Task 2), `IElSharePointContext`/`ElSharePointContext` (Task 3, registered in `Program.cs`), `ELPackageSpListItem` + migration `20260813191148_add_table_ELPackageSpListItem` (Task 4), and `GraphFieldMapperTests`/`ElSharePointOptionsTests` (Task 5). Full deviation list is inline above each task section. Internal NuGet feed was down again this session too, but `dotnet restore --ignore-failed-sources` got past it using the already-warm local package cache — full `CDH_EL` solution build now verified clean, closing out Task 1's open item. Migration applied to local `cdhel-sql` after discovering `CDH_EL/appsettings.Development.json`'s `SQL` section had reverted to the shared remote box (re-pointed it at `localhost,1433` / `CDH_EL_DK_S3`, per the same uncommitted-local-only convention noted 2026-07-21). All plan checkboxes done except the two explicitly provisioning-blocked verification items (manual Graph smoke, employee-email spot-check) — unchanged, still waiting on the EL SharePoint list/library to exist.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2 — SharePoint Export Job Warplan]] (consumes this client)
- [[04_Projects/Active/FPA|FPA]] (source of the ported design)
