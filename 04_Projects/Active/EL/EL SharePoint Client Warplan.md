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

**Status (2026-08-12):** Planned, not started. **P1 of 4** in the SharePoint export plan set — see [[04_Projects/Active/EL/EL Index|EL Index]]. No dependencies; can start immediately and in parallel with [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|P0]]. Blocks [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]].

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

- [ ] `Lib/Lib.csproj`: add `Microsoft.Graph` and `Azure.Identity` (latest stable compatible with `net10.0`).
- [ ] `CDH_EL/appsettings.json`: add a `SharePoint` section with **empty** secret values and `"IsDisabled": "True"`, mirroring FPA's key shape (`Azure:AppRegistration:TenantId/ClientId/ClientSecret`, `TenantName`, `SiteName`, `ListName`, `DriveName`). Do **not** port `WriteBytesToDb` (dead config in FPA).
- [ ] Do not add the `Hangfire` section here — that belongs to P2.
- [ ] `Lib/Services/SharePoint/ElSharePointOptions.cs` — `record` with the above, `IsDisabled` as `bool`. Include a `Validate()` returning collected problems (empty tenant/client/secret/site/list/drive) so misconfiguration surfaces as a clear message rather than a Graph 401.

## Task 2 — Graph field mapping

- [ ] `Lib/Models/SharePoint/GraphFieldAttribute.cs` — port FPA's attribute including `LookupTypes { None, User }`.
- [ ] `Lib/Models/SharePoint/IGraphUserResolver.cs` — `Task<string?> GetUserIdAsync(string? email, ct)` / `Task<string?> GetUserEmailAsync(string? userId, ct)`.
- [ ] `Lib/Models/SharePoint/GraphFieldMapper.cs` — generic `ToFieldsAsync<T>` / `FromFieldsAsync<T>`, skipping properties without the attribute and null/whitespace values on write (FPA's behavior — a null property must not blank a SharePoint column).
- [ ] Preserve FPA's id handling: the item id travels as the field key `"Id"` on read, and must be **removed** from the dictionary before a PATCH (see `UpdateRawSpListItem` — sending `Id` as a field fails).

## Task 3 — SharePoint client

- [ ] `Lib/Services/SharePoint/IElSharePointContext.cs`:
  - [ ] `bool IsDisabled { get; }`
  - [ ] `Task<SharePointFolder> EnsureFolderAsync(string folderName, CancellationToken ct)`
  - [ ] `Task<SharePointFile> UploadFileAsync(string folderPath, string fileName, byte[] bytes, CancellationToken ct)`
  - [ ] `Task<IReadOnlyDictionary<string, object>> AddOrUpdateListItemAsync(string? spId, IReadOnlyDictionary<string, object> fields, CancellationToken ct)`
  - [ ] `IGraphUserResolver` implemented by the same class (or exposed off it) so the mapper can translate people columns.
  - [ ] Small `record` results carrying `Id`, `Name`, `WebUrl`, `FilePath`.
- [ ] `ElSharePointContext.cs`:
  - [ ] Lazy async caches for site id, list id, drive id, and the user map. Guard each with a `SemaphoreSlim` — FPA's `??=` is not safe once the calls are genuinely concurrent.
  - [ ] Port the site-id assertions verbatim (≥2 comma segments; first segment matches the tenant in the site key).
  - [ ] `EnsureFolderAsync`: look for the child folder by name under the drive root; create it with a `DriveItem { Name, Folder = new Folder() }` POST when absent; return the existing one when present. Idempotent — re-export must not create `Folder (1)`.
  - [ ] `UploadFileAsync`: PUT content to the item path under the folder. A file open by a user cannot be overwritten — surface that as a distinct exception with the file name, as FPA's comment describes.
  - [ ] `AddOrUpdateListItemAsync`: POST when `spId` is null; PATCH otherwise; on `"The specified list item was not found"` (case-insensitive) log a warning and POST instead.
  - [ ] Every method returns early / throws a clear `ElSharePointException` when `IsDisabled` — decide one and document it; recommendation: **throw**, and let the caller check `IsDisabled` first (as FPA's job does), so a disabled tenant can never look like a successful upload.
  - [ ] `ILogger<ElSharePointContext>` for the resolution steps and the not-found recovery. `Lib` may take `Microsoft.Extensions.Logging.Abstractions`; do not pull Serilog into `Lib`.
- [ ] Register in `CDH_EL/Program.cs` — scoped, options bound from configuration, following the explicit-factory style already used for `ElDocumentRenderService` at `:85`.

## Task 4 — Mirror table

- [ ] `Lib/Models/EL/ELPackageSpListItem.cs`, `[Table("ELPackageSpListItem")]`, `BaseRecord`-derived, snake_case columns per `docs/reference/db-design-guide.md`, `[GraphField]`-annotated where the value maps to SharePoint:
  - [ ] `id`, `package_id` (FK → `ELPackage`), `sp_id`
  - [ ] `title`, `status`, `client_name`, `letter_count`
  - [ ] `folder_sp_id`, `folder_web_url`, `folder_file_path`
  - [ ] `rm_reviewer_email`, `partner_reviewer_email` (both `LookupTypes.User`)
  - [ ] `client_signer_name`, `client_signer_email`, `intacct_customer_number`
  - [ ] `docusign_envelope_id`, `docusign_status` (written empty in this plan set; no read-back)
  - [ ] `date_exported_utc`, `export_error` (nullable) — the UI needs "when" and "why it failed"; FPA has neither and instead stuffs an error flag into approval-note JSON metadata, which is worse
- [ ] Unique index on `package_id` — one live list item per package (the grain decision). Follow the `[Index(..., IsUnique = true)]` style used on `ELDocument`.
- [ ] `MaxLength` on every string column; do not default to `nvarchar(max)`. Mirror FPA's 100/255 sizing except SharePoint URLs, which the existing `ELDocumentFile` sizes at `nvarchar(1000)` — match that.
- [ ] DbSet in `Lib/DAL/ELContext.cs` beside `ELDocumentFile` (`:84`).
- [ ] Migration `Lib/Migrations/{yyyyMMddHHmmss}_add_table_ELPackageSpListItem.cs` — one logical change, per repo naming rules (`add_table_<Entity>`, preserving `EL` casing).
- [ ] **No new attachment table.** Per-letter artifacts use `ELDocumentFile` (`enumFileKind = DocumentFileKind.Pdf`), whose `sp_id`/`web_url`/`file_path`/`bytes`/`checksum` columns exist and are currently unwritten. Confirm before adding anything.

## Task 5 — Tests

- [ ] New `Lib.Tests/Models/SharePoint/GraphFieldMapperTests.cs`:
  - [ ] Round-trip an annotated test type; unannotated properties are ignored.
  - [ ] Null / whitespace values are omitted on write (must not blank a column).
  - [ ] `LookupTypes.User` writes the resolved lookup id and reads back the email, using a stub resolver.
  - [ ] Unresolvable email falls back to the raw string rather than throwing (FPA's behavior) — and assert that a log/finding records it, because a silent fallback is how a people column ends up holding plain text.
  - [ ] `"Id"` is stripped before PATCH and present after read.
- [ ] New `ElSharePointOptionsTests.cs` — `Validate()` reports each missing value.
- [ ] No live-Graph tests. `ElSharePointContext` is verified by P2's fake-backed orchestration tests plus the manual smoke below.

## Verification

- [ ] `dotnet build` — 0 errors.
- [ ] `dotnet test` — new tests pass; pre-existing `EngagementLetterTemplateServiceTests` failures (title-uniqueness, effective-date, default-order) unchanged; confirm via `git stash` before attributing.
- [ ] `dotnet ef migrations add add_table_ELPackageSpListItem --project Lib --startup-project CDH_EL`, then `dotnet ef database update` against the **local Docker container `cdhel-sql` (sqlcmd → localhost)**, not the shared `192.168.17.202\CDH_FPA` box.
- [ ] Confirm the created table's columns, types, lengths, unique index on `package_id`, and FK to `ELPackage`.
- [ ] Confirm `Down()` drops cleanly and re-`update` recreates.
- [ ] App still starts with `SharePoint:IsDisabled = "True"` and empty secrets — no startup exception from options binding.
- [ ] Manual Graph smoke (once the list exists and secrets are in `appsettings.Development.local.json`): a scratch console call or temporary endpoint that resolves site/list/drive ids, calls `EnsureFolderAsync` twice with the same name (second is a no-op, not a duplicate), uploads a small file twice (second overwrites), and creates then PATCHes one list item. Remove any scratch code before the PR.
- [ ] Confirm employee emails resolve against the site's User Information List — the FPA job feeds it `relationshipManagerEmployee.username`, while Bridge hands EL `EmployeeDto.Email` (Intacct primary). If those diverge for real employees, the lookup returns null and writes raw text. Spot-check several.

## Status Log

- 2026-08-12 — Plan authored as P1 of the SharePoint export set. Ported design read out of `CDH_FPA/Lib/DAL/SPContext.cs` + `Lib/Models/SharePoint/SpListItem.cs`. Confirmed `ELDocumentFile` already carries `sp_id`/`web_url`/`file_path`/`bytes`/`checksum` with zero writers anywhere in CDH_EL, so no attachment table is needed. Confirmed FPA's `WriteBytesToDb` config key is never read in FPA code — not ported. Blocked item: the EL list/library must exist before `[GraphField]` internal column names can be filled in.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[EL|EL]]
- [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2 — SharePoint Export Job Warplan]] (consumes this client)
- [[04_Projects/Active/FPA|FPA]] (source of the ported design)
