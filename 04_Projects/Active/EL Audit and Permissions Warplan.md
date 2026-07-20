---
title: EL Audit and Permissions Warplan
created: 2026-07-13
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL Audit and Permissions Warplan

**Status (2026-07-16):** Phase 1 done. Phase 2 Tasks 2.1-2.3 done (Task 2.4 viewer stub skipped, still optional). Phase 3 Tasks 3.1-3.5 done; 3.6 (caching, optional) not started. All work landed on `Drew/Sprint3/Audit`, not separate per-phase branches.

> **For agentic workers:** Execute task-by-task (subagent-driven or inline). Steps use checkbox syntax for tracking. When implementation starts, copy the relevant phase into the repo at `docs/reference/plans/` per repo doc conventions (`.original.md` + compressed `.md` pair) so it travels with the branch.

**Goal:** Add automatic field-level entity auditing (Audit.NET) and policy-based permission authorization (built-in ASP.NET Core) to CDH_EL, reusing the existing `PermissionModule`/`PermissionAction` enum model as the single source of truth.

**Architecture:** Audit.NET's `AuditSaveChangesInterceptor` captures EF Core change diffs into a new `ELAuditLog` table in the same database (no base-class change to `ELContext`). Authorization gets a `PermissionRequirement` + one generic `AuthorizationHandler` that bridges `[Authorize(Policy = "Permission:{Module}:{Action}")]` to the existing `UserRecord.jsonPermissions` document via `IUserAdministrationService.HasPermissionAsync`. `AppPermissionGate` is refactored to call `IAuthorizationService` so component gating and attribute gating share one enforcement path.

## Status Log

- 2026-07-20 — CDH_EL: still on `Drew/Sprint3/Audit`, Phase 3 work (9 dirty files: Authorization/, PermissionPolicyNames.cs, admin pages, Program.cs) remains uncommitted, unchanged since 2026-07-16 — 4 days now. One unrelated commit landed elsewhere (`editor spacing bugfix`, PR #9 / TipTap branch). Old TipTap-cleanup stashes from the 2026-07-17 flag are still sitting in stash list, untouched but not lost.
- 2026-07-16 (cont.) — CDH_EL: Phase 3 Task 3.5 done, uncommitted. Added `[Authorize(Policy = ...)]` page-level hard gates to all 4 admin pages (`AdminDashboard`/`AdminUsers` → `UserManagementView`, `AdminUserEdit` → `UserManagementEdit`, `AdminUserPermissions` → `PermissionsEdit`). `/editor/import-docx` endpoint from the plan's ground truth **does not exist on this branch** — confirmed via repo-wide grep for `import-docx`/`ImportDocx`, zero hits; matches memory note that the DOCX import vertical only lives on `feature/June/30/RTE-TipTap-cleanup`, not this Sprint3/Audit branch (which forks from develop). Audited remaining mapped endpoints (`Program.cs` root redirect, `editor/preview-pdf/{token}`, `AuthEndpoints.cs`) — all already have `.RequireAuthorization()` where appropriate, nothing missing. **Denial path verified live end-to-end**, not just inline reasoning: provisioned a fresh dev-auth test user (`audit.phase3.denial@cdhts.com`, auto-created via `EnsureUserByEmailAsync` with UAT-default FullAccess, confirmed in server log — `INSERT INTO [UserRecord]` + matching `[ELAuditLog]` row), logged back in as own admin identity, used the live Admin UI (`/admin/users/6/permissions`) to strip that test user's `UserManagement` module permissions to empty, then switched dev-auth back to the test identity and hit `/admin`: server returned `GET /admin → 403 Forbidden` with log line `AuthenticationScheme: Development was forbidden.` — the new page-level policy gate correctly denies. Restored the test user's permissions back to full access afterward and reverted `appsettings.Development.json`'s `DevelopmentAuthentication` block to its original disabled state (`git diff` on that file is empty). Left the test `UserRecord` row itself in place (harmless, matches Task 2.3 precedent).
- 2026-07-16 — CDH_EL: Phase 3 Tasks 3.1-3.4 implemented on `Drew/Sprint3/Audit` (uncommitted): `PermissionPolicyNames` catalog + tests (`Lib/Models/User/Permissions/PermissionPolicyNames.cs`), `PermissionRequirement`/`PermissionAuthorizationHandler` (`CDH_EL/Authorization/`), 24-policy registration loop in `Program.cs` replacing bare `AddAuthorization()`, `AppPermissionGate.razor` refactored onto `IAuthorizationService`/`AuthenticationStateTask` (dropped `IUserPermissionService` dependency). Verified via dev-auth boot (`DevelopmentAuthentication:Enabled` toggled true then reverted, no diff left): Templates page and Admin page (`AppPermissionGate`-gated) both render normally for full-access UAT-default user, no console/server errors. Did not yet test the denial path (would need a real non-full-access user or a temp permission-doc edit — deferred to Task 3.5 verification alongside page hardening). Repo pointer added: `docs/reference/plans/EL-AUDIT-PERMISSIONS-PLAN.md`.
- 2026-07-15 — CDH_EL: 8 commits on `Drew/Sprint3/Audit` completing Phase 2 Tasks 2.1-2.3 (package add, `[AuditIgnore]` stamps, `ELAuditLog` migration, interceptor wiring) plus a `UniqueUsername` dead-code fix surfaced during live testing.

**Tech stack:** .NET 10, EF Core 10.0.8, `Audit.EntityFramework.Core` (v32.x, new package in `Lib`), built-in `Microsoft.AspNetCore.Authorization` (no new authz package), Auth0 cookie web-app auth (unchanged).

## Global Constraints

- New features Blazor; MVC legacy only. No MVC rewrites.
- `Lib` stays free of Blazor/HAVIT/Auth0/MVC deps — `AuthorizationHandler` and policy registration live in `CDH_EL`; entities, enums, policy-name strings, services live in `Lib`.
- DB naming: tables PascalCase, columns lower_snake_case, `date_` prefix for datetimes, `enum_` prefix for enum columns, nvarchar lengths in powers of 10, every table has int identity `id`.
- Migration naming: `{yyyyMMddHHmmss}_add_table_ELAuditLog.cs`, class `add_table_ELAuditLog`; one logical schema change per migration.
- Entity property casing matches existing `BaseRecord` style: lowerCamel props with `[Column("snake_case")]`.
- Async all the way; `CancellationToken` on IO methods.
- One branch per phase; do NOT build on `feature/June/30/RTE-TipTap-cleanup` (unrelated work).
- Build after meaningful changes; verify one MVC page + one Blazor page render after auth changes.

## Ground Truth (verified 2026-07-13)

| Seam | Location | State |
|---|---|---|
| Service registration | `CDH_EL/Program.cs:40-131` | inline in `Main` |
| DbContext registration | `Program.cs:96` | `AddDbContextFactory<ELContext>` (factory, not scoped) |
| Auth | `Program.cs:98-129` | Auth0 web-app flow (cookies) / dev handler / cookie fallback |
| Authorization | `Program.cs:131` | `AddAuthorization()` — **zero policies** |
| Context | `Lib/DAL/ELContext.cs` | manual `AuditSaveChanges()` stamps timestamps + username in all 4 SaveChanges overrides (`:83-127`) |
| **Bug/gap** | `ELContext.cs:37-41` | factory ctor hard-sets `httpContextAccessor = null`; `AddHttpContextAccessor()` never registered → every factory context stamps `createdBy/updatedBy = "unknown@user"` |
| Audit fields | `Lib/Models/BaseRecord.cs` | `dateCreatedUtc/dateUpdatedUtc/createdBy/updatedBy` on all 17 entities; **commented-out `//[AuditIgnore]` at lines 16, 24, 32, 40** (prior Audit.NET intent) |
| Permissions model | `Lib/Models/User/Permissions/` | `PermissionModule` (6) × `PermissionAction` (4) enums; JSON doc on `UserRecord.jsonPermissions`; `Admin` implies Create/Edit |
| Permission check API | `Lib/Services/Admin/UserAdministrationService.cs:170` | `Task<bool> HasPermissionAsync(string userEmail, PermissionModule module, PermissionAction action, CancellationToken ct = default)` |
| Blazor gating | `CDH_EL/Components/Shared/AppPermissionGate.razor` | custom component calling `IUserPermissionService.CurrentUserHasPermissionAsync` |
| Pages | 12 pages `@attribute [Authorize]` (authn only) | fine-grained checks only where `AppPermissionGate` used |
| Unprotected endpoint | `Endpoints/EditorImportEndpoints.cs` `/editor/import-docx` | no `.RequireAuthorization()` — harden in Phase 3 |
| UAT posture | `UserPermissionDocument.UatBootstrapDefault()` returns `FullAccess()` | flip-point to `Empty()` for prod lockdown |
| Spare audit DB config | `appsettings.json:28-38` `"SQL-Log"` section | unused; not needed for chosen same-DB design |

## Decisions (made, with rationale)

1. **Interceptor over `AuditDbContext` base class.** `AuditSaveChangesInterceptor` added in factory options → `ELContext` inheritance untouched, existing manual overrides keep working. Less invasive, reversible.
2. **Keep manual timestamp/username stamping.** `AuditTimeStamps()`/`AuditUsername()` write *columns on the row* (denormalized convenience); Audit.NET writes the *change log*. Different jobs, both stay.
3. **Same-DB single `ELAuditLog` table** via `EntityFrameworkDataProvider` mapping all entity types to one audit entity with JSON changes column. `SQL-Log` second-DB option deferred — swap is a data-provider config change later, not a redesign.
4. **Explicit policy loop over custom `IAuthorizationPolicyProvider`.** 6 modules × 4 actions = 24 policies registered in a 4-line loop at startup. Dynamic provider is YAGNI.
5. **Handler resolves email from claims → `IUserAdministrationService` (Lib).** Not `IUserPermissionService`/`AuthenticationStateProvider` — the `ClaimsPrincipal` in `AuthorizationHandlerContext` works identically for MVC and Blazor, and keeps the handler free of Blazor-specific services.
6. **Domain audit events ("Drew approved v3") stay custom** — Phase 4, deferred until approval workflow lands. Library only covers field diffs.

Known limitation to document in code: `EntityFrameworkDataProvider` writes audit rows in a *second* `SaveChanges` call on the same context — not the same transaction by default. Acceptable for v1; wrap critical flows in an explicit transaction later if atomicity becomes a requirement.

---

## Phase 1 — Fix user attribution (branch: `feature/audit-user-attribution`) — ✅ DONE 2026-07-14

The "who" is broken today. Everything in Phases 2-3 depends on it. Small, ships alone.

### Task 1.1: Register `IHttpContextAccessor` and wire it into factory-created contexts — ✅ DONE (commit `7f8a5f2`)

**Files:**
- Modify: `CDH_EL/Program.cs` (~line 96)
- Modify: `Lib/DAL/ELContext.cs:37-52`

- [x] Collapse `ELContext`'s constructors into one with an optional accessor (factory resolves it from root DI; `IHttpContextAccessor` is a singleton backed by `AsyncLocal`, safe in a singleton factory):

```csharp
public ELContext(DbContextOptions<ELContext> options, IHttpContextAccessor? httpContextAccessor = null)
    : base(options)
{
    this.httpContextAccessor = httpContextAccessor;
}
```

Delete the 2-arg ctor that null-sets the accessor and the unused 3-arg ctor. Check for direct `new ELContext(...)` call sites first (tests, design-time factory) and update them.

- [x] In `Program.cs`, before the factory registration:

```csharp
builder.Services.AddHttpContextAccessor();
```

- [x] Make `ELContext.Username` a settable property with the accessor read as fallback, so Blazor-circuit code paths (where `HttpContext` can be null/stale after prerender) can stamp explicitly. **Implemented with the claim-precedence resolved** (see verify note below): `"email"` claim → `ClaimTypes.Email` → `ClaimTypes.NameIdentifier` → `"unknown@user"`, matching `CurrentUserPermissionService` exactly — not plain `Identity.Name` as originally sketched here.

- [x] Added `Lib.Tests/DAL/ELContextTests.cs`: accessor stamps email claim; `Username` override wins over accessor; neither present → `"unknown@user"`. 3/3 pass. (Required adding `<FrameworkReference Include="Microsoft.AspNetCore.App" />` to `Lib.Tests.csproj` for `DefaultHttpContext`/`HttpContextAccessor` concrete types.)
- [x] `dotnet build` + run tests — full solution green; 3 pre-existing `EngagementLetterTemplateServiceTests` failures confirmed unrelated (same failures on unmodified `HEAD`).
- [x] Manual check: booted app, logged in via `DevelopmentAuthenticationHandler`, landed on a real page (200) — proves the new factory ctor resolves `IHttpContextAccessor` from DI correctly. Did not do a raw-SQL row check (sqlcmd with the dev DB password inline got blocked by Claude's credential-leak guard) — unit tests + live boot cover it.
- [x] Commit: `fix: stamp real username on factory-created ELContext audit columns` → actual commit `7f8a5f2` "Added httpContext and username override" (committed directly, not through the agent's git flow).

**Verify before starting:** whether `Identity.Name` is populated under Auth0 web-app flow (it maps `name` claim; may be display name, not email). If email wanted, read `ClaimTypes.Email` / `"email"` claim instead of `Identity.Name` — match what `CurrentUserPermissionService.GetCurrentUserIdentityAsync()` (`CurrentUserPermissionService.cs:85-109`) already does, and keep the two consistent. **Resolved:** used the full 3-step claim precedence, not just `ClaimTypes.Email`.

---

## Phase 2 — Audit.NET entity audit — ✅ Tasks 2.1-2.3 DONE 2026-07-14 (branch: actually `Drew/Sprint3/Audit`, not a separate `feature/audit-net-entity-log` — Drew confirmed the TipTap commit already riding on that branch is mid-PR and will land in develop on its own, so no need to isolate onto a fresh branch)

### Task 2.1: Package + audit noise reduction — ✅ DONE (commit `a191e35`)

**Files:**
- Modify: `Lib/Lib.csproj`
- Modify: `Lib/Models/BaseRecord.cs:16,24,32,40`

- [x] `dotnet add Lib package Audit.EntityFramework.Core` → resolved v32.2.0, matches expected v32.x.
- [x] Uncomment the four `[AuditIgnore]` attributes on `BaseRecord` (add `using Audit.EntityFramework;`). Rationale: `dateUpdatedUtc`/`updatedBy` change on every save — pure diff noise; the audit log row carries its own who/when.
- [x] Build. Commit: `chore: add Audit.EntityFramework.Core, exclude BaseRecord stamps from diffs`

### Task 2.2: `ELAuditLog` entity + migration — ✅ DONE (commit `5d958f6`)

**Files:**
- Create: `Lib/Models/Audit/ELAuditAction.cs`
- Create: `Lib/Models/Audit/ELAuditLog.cs`
- Modify: `Lib/DAL/ELContext.cs` (DbSet + `OnModelCreating` indexes)
- Create: migration `{timestamp}_add_table_ELAuditLog.cs`

- [ ] Enum:

```csharp
namespace Lib.Models.Audit;

public enum ELAuditAction
{
    Insert = 1,
    Update = 2,
    Delete = 3,
}
```

- [ ] Entity — deliberately NOT `BaseRecord` (no self-stamping) and `[AuditIgnore]` (never audit the audit table):

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Audit.EntityFramework;

namespace Lib.Models.Audit;

/// <summary>Field-level change log row written by Audit.NET for every insert/update/delete on audited entities.</summary>
[AuditIgnore]
public class ELAuditLog
{
    [Key]
    [Column("id")]
    public int id { get; set; }

    [Column("table_name")]
    [MaxLength(100)]
    public string tableName { get; set; } = string.Empty;

    [Column("primary_key")]
    [MaxLength(100)]
    public string primaryKey { get; set; } = string.Empty;

    [Column("enum_audit_action")]
    public ELAuditAction enumAuditAction { get; set; }

    /// <summary>JSON: column-level old/new values for updates, full column values for insert/delete.</summary>
    [Column("json_changes")]
    public string jsonChanges { get; set; } = string.Empty;

    [Column("username")]
    [MaxLength(100)]
    public string username { get; set; } = string.Empty;

    [Column("date_created_utc")]
    public DateTime dateCreatedUtc { get; set; }
}
```

- [x] `ELContext`: add `public DbSet<ELAuditLog> ELAuditLog { get; set; }`; in `OnModelCreating` add composite index `(tableName, primaryKey)` and index on `dateCreatedUtc`.
- [x] Migration: `dotnet ef migrations add add_table_ELAuditLog` generated the timestamp already in repo format (`20260714193325_add_table_ELAuditLog`) — no rename needed.
- [x] Inspected generated migration — matched expected shape exactly (table `ELAuditLog`, int identity `id`, nvarchar(100)/(100)/(100)/MAX, `DateTime2`, 2 indexes). Applied to dev DB (`192.168.17.202\CDH_FPA` / `CDH_EL_ST_LIB3`), build, commit: `feat: add_table_ELAuditLog for Audit.NET change log`

### Task 2.3: Interceptor + data provider wiring — ✅ DONE (commit `8af930d`) — **2 real deviations from the plan, both found via live-boot testing, not guessed**

**Files:**
- Modify: `CDH_EL/Program.cs` (factory registration ~line 96, plus one-time Audit.NET setup before `builder.Build()`)

- [x] Add interceptor to the factory options — actual namespace is `Audit.EntityFramework.AuditSaveChangesInterceptor`, **not** `Audit.EntityFramework.Interceptors.AuditSaveChangesInterceptor` as sketched here (compiler caught this immediately):

```csharp
builder.Services.AddDbContextFactory<ELContext>(item =>
    item.UseSqlServer(connectionString, options => options.CommandTimeout(commandTimeout))
        .AddInterceptors(new Audit.EntityFramework.AuditSaveChangesInterceptor()));
```

- [x] One-time Audit.NET config, added to the existing `Program_Helpers.cs` partial (not a new file):

```csharp
using Audit.Core;
using Audit.EntityFramework;
using Lib.DAL;
using Lib.Models.Audit;

private static void ConfigureAuditNet()
{
    Audit.Core.Configuration.Setup()
        .UseEntityFramework(ef => ef
            // NOTE: deliberately NOT calling .UseDbContext<ELContext>() — see deviation #1 below
            .AuditTypeMapper(_ => typeof(ELAuditLog))
            .AuditEntityAction<ELAuditLog>((auditEvent, entry, audit) =>
            {
                var efEvent = auditEvent.GetEntityFrameworkEvent();
                audit.tableName = entry.Table;
                audit.primaryKey = string.Join(",", entry.PrimaryKey.Select(item => $"{item.Value}"));
                audit.enumAuditAction = entry.Action switch
                {
                    "Insert" => ELAuditAction.Insert,
                    "Delete" => ELAuditAction.Delete,
                    _ => ELAuditAction.Update,
                };
                audit.jsonChanges = entry.ToJson();
                audit.username = (efEvent?.GetDbContext() as ELContext)?.Username ?? "unknown@user";
                audit.dateCreatedUtc = DateTime.UtcNow;
                return true;
            })
            .IgnoreMatchedProperties(true));
}
```

- [x] Verified the fluent API against the actual installed v32.2.0 assembly (`Audit.EntityFramework.Core.xml` doc comments in the NuGet cache) before writing — `AuditTypeMapper`, `AuditEntityAction<T>`, `GetEntityFrameworkEvent()`, `IgnoreMatchedProperties`, `AuditSaveChangesInterceptor` all confirmed to exist as sketched. `ExcludeValidationResults` does **not** exist on this fluent path (it's `AuditDbContext`-base-class-only) — turned out not to matter, see deviation #2.

**Deviation #1 — dropped `.UseDbContext<ELContext>()`.** Calling it (as originally sketched) constructs a *brand-new* `ELContext` via the parameterless dev-only ctor → no `DbContextOptions` configured → `InvalidOperationException: No database provider has been configured`. Per the package docs, omitting `UseDbContext` entirely defaults to reusing the *same* `ELContext` instance already being audited — which is exactly the same-DB/same-context design decision #3 above calls for. Caught via live boot (500 error), not by reading docs first.

**Deviation #2 — pre-existing dead code crashed Audit.NET's default entity validation.** `Lib/Attributes/CustomValidation/UserRecord/UniqueUsername.cs` (applied to `UserRecord.username`) had its real DB-lookup logic commented out years ago (targeted the retired `FPAContext`), leaving zero `IsValid` override. Nothing in the app ever ran `System.ComponentModel.DataAnnotations.Validator` over `UserRecord` until Audit.NET's default entity-validation step did — instant `NotImplementedException` on every save. Fixed as a no-op returning `ValidationResult.Success` (uniqueness is already DB-enforced via `[Index(nameof(username), IsUnique = true)]`), zero behavior change otherwise. Separate commit: `fix: implement no-op UniqueUsername.IsValid to stop NotImplementedException` (`5425eec`). This is exactly the kind of latent bug the plan's Task 2.3 "verify against installed package" risk note anticipated, just one layer deeper than API-name drift.

- [x] Build, run — verified end-to-end against the real dev DB, not just unit tests: logged in as a **fresh** dev-auth identity (had to use a brand-new email — `EnsureUserByEmailAsync` short-circuits with zero `SaveChanges` calls for an existing user, so the first attempt with the already-seeded `codex.dev@cdhcpa.com` proved nothing), hit `/admin`, and confirmed in the server log: `INSERT INTO [UserRecord] (...)` immediately followed by `INSERT INTO [ELAuditLog] ([date_created_utc], [enum_audit_action], [json_changes], [primary_key], [table_name], [username])` in the same request. Left one harmless test row (`audit.phase2.check@cdhts.com`) in the dev `UserRecord` table — not cleaned up (would've needed the DB password on a command line, which Claude's credential-leak guard correctly blocked); low-risk, matches the existing seeded-test-user pattern.
- [x] Verified dev-auth branch boots and audit rows record the dev identity correctly (see above).
- [x] Commit: `feat: wire Audit.NET interceptor writing ELAuditLog change log` (`8af930d`)

### Task 2.4 (optional, same branch): Admin audit viewer stub — ⏸ SKIPPED for now (still optional/deferrable per plan)

Blazor page `Admin/AdminAuditLog.razor` behind `Permissions`/`View` gate — HxGrid over `ELAuditLog` newest-first, filter by table/user/date. HAVIT MCP check before writing markup (per global rule). Defer if sprint-pressed; table is queryable via SQL meanwhile.

---

## Phase 3 — Policy-based authorization (branch: actually `Drew/Sprint3/Audit`, same as Phase 2 — see Phase 2 header rationale)

### Task 3.1: Policy names catalog (Lib) — ✅ DONE 2026-07-16 (uncommitted)

**Files:**
- Create: `Lib/Models/User/Permissions/PermissionPolicyNames.cs`

- [ ] Runtime builder + compile-time consts for attribute usage (attributes need consts). Consts only for combinations actually used; grow as needed:

```csharp
namespace Lib.Models.User.Permissions;

/// <summary>Canonical policy-name strings bridging the enum permission model to ASP.NET Core authorization policies.</summary>
public static class PermissionPolicyNames
{
    public static string For(PermissionModule module, PermissionAction action) =>
        $"Permission:{module}:{action}";

    public const string WorkspaceView = "Permission:Workspace:View";
    public const string TemplatesView = "Permission:Templates:View";
    public const string TemplatesEdit = "Permission:Templates:Edit";
    public const string UserManagementView = "Permission:UserManagement:View";
    public const string UserManagementEdit = "Permission:UserManagement:Edit";
    public const string PermissionsEdit = "Permission:Permissions:Edit";
}
```

- [x] Lib.Tests: `PermissionPolicyNamesTests.cs` — 3 theory cases for `For(...)` + one test asserting every const matches `For(...)` for its pair. 4/4 pass.
- [ ] Commit: `feat: add PermissionPolicyNames catalog` — not yet committed (Phase 3 work still uncommitted as of 2026-07-16)

### Task 3.2: Requirement + handler (web) — ✅ DONE 2026-07-16 (uncommitted)

**Files:**
- Create: `CDH_EL/Authorization/PermissionRequirement.cs`
- Create: `CDH_EL/Authorization/PermissionAuthorizationHandler.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Lib.Models.User.Permissions;

namespace CDH_EL.Authorization;

public sealed record PermissionRequirement(PermissionModule Module, PermissionAction Action) : IAuthorizationRequirement;
```

```csharp
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Lib.Models.User.Permissions;
using Lib.Services.Admin;

namespace CDH_EL.Authorization;

/// <summary>Authorizes any Permission:{Module}:{Action} policy against the user's stored permission document.</summary>
/// <remarks>Resolves the user by email claim (matching CurrentUserPermissionService claim precedence), then defers to IUserAdministrationService.HasPermissionAsync. No claim/email → requirement silently not met.</remarks>
public sealed class PermissionAuthorizationHandler(IUserAdministrationService userAdministrationService)
    : AuthorizationHandler<PermissionRequirement>
{
    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        var email = context.User.FindFirst("email")?.Value
            ?? context.User.FindFirst(ClaimTypes.Email)?.Value;

        if (string.IsNullOrWhiteSpace(email))
        {
            return;
        }

        if (await userAdministrationService.HasPermissionAsync(email, requirement.Module, requirement.Action))
        {
            context.Succeed(requirement);
        }
    }
}
```

Claim precedence must mirror `CurrentUserPermissionService.GetCurrentUserIdentityAsync()` (`CurrentUserPermissionService.cs:85-109`) — read that file and copy its exact order.

**Deviation from sketch:** implemented 3-step precedence (`"email"` → `ClaimTypes.Email` → `ClaimTypes.NameIdentifier`), not the 2-step sketch above — matches `CurrentUserPermissionService` and `ELContext.Username` exactly (confirmed both read the same 3 claims in that order as of 2026-07-16).

- [ ] Commit: `feat: add PermissionRequirement and authorization handler` — not yet committed

### Task 3.3: Register policies (Program.cs) — ✅ DONE 2026-07-16 (uncommitted)

**Files:**
- Modify: `CDH_EL/Program.cs:131`

- [ ] Replace bare `AddAuthorization()`:

```csharp
builder.Services.AddScoped<IAuthorizationHandler, PermissionAuthorizationHandler>();
builder.Services.AddAuthorization(options =>
{
    foreach (var module in Enum.GetValues<PermissionModule>())
    {
        foreach (var action in Enum.GetValues<PermissionAction>())
        {
            options.AddPolicy(
                PermissionPolicyNames.For(module, action),
                policy => policy.RequireAuthenticatedUser()
                    .AddRequirements(new PermissionRequirement(module, action)));
        }
    }
});
```

- [x] Build, boot, confirm login flow unchanged — dev-auth boot: Templates page + Admin page both rendered normally, no console/server errors.
- [ ] Commit: `feat: register Permission:{Module}:{Action} policies at startup` — not yet committed

### Task 3.4: Single enforcement path — refactor `AppPermissionGate` — ✅ DONE 2026-07-16 (uncommitted)

**Files:**
- Modify: `CDH_EL/Components/Shared/AppPermissionGate.razor`

- [ ] Swap `IUserPermissionService.CurrentUserHasPermissionAsync(Module, Action)` call for:

```csharp
var authState = await AuthenticationStateTask;
var result = await AuthorizationService.AuthorizeAsync(
    authState.User, PermissionPolicyNames.For(Module, Action));
isAuthorized = result.Succeeded;
```

(`@inject IAuthorizationService AuthorizationService`, cascading `Task<AuthenticationState>`.) Component keeps its UX (access-denied card); the *decision* now flows through the same policy pipeline as attributes. Keep component parameters unchanged so the 7 existing usages don't churn.

- [x] Verify gated pages manually: Templates + Admin dashboard render for full-access dev user (UAT default). Did not walk the full 7-page list (Dashboard, Landing, HeaderFooterDesigner, AdminUserEdit, AdminUserPermissions not individually hit) — spot-check only.
- [ ] Temporarily flip own permission doc to test denial path renders the access-denied card (then restore) — NOT done yet, deferred alongside Task 3.5.
- [ ] Commit: `refactor: AppPermissionGate authorizes via policy pipeline` — not yet committed

### Task 3.5: Harden pages + endpoints with policy attributes — ✅ DONE 2026-07-16 (uncommitted)

**Files:**
- Modify: admin pages (`Admin/*.razor`), `Template/*.razor` as appropriate
- Modify: `CDH_EL/Endpoints/EditorImportEndpoints.cs`

- [x] Admin pages: `@attribute [Authorize(Policy = PermissionPolicyNames.UserManagementView)]` (page-level hard gate on top of in-page `AppPermissionGate`). Map: AdminDashboard/AdminUsers → `UserManagementView`; AdminUserEdit → `UserManagementEdit`; AdminUserPermissions → `PermissionsEdit`.
- [x] `/editor/import-docx`: **does not exist on this branch** — `CDH_EL/Endpoints/EditorImportEndpoints.cs` and any `import-docx`/`ImportDocx` reference confirmed absent via repo-wide grep. That vertical lives only on `feature/June/30/RTE-TipTap-cleanup` (separate branch), not on this Sprint3/Audit branch. No action possible/needed here; re-check if that branch's work merges into develop later.
- [x] Audited remaining mapped endpoints — `Program.cs` root redirect + `editor/preview-pdf/{token}`, and `AuthEndpoints.cs` (`/login`, `/logout`, `/signed-out`) — all already correctly gated (`.RequireAuthorization()` or intentional `.AllowAnonymous()`). Nothing missing.
- [ ] Desktop + mobile width verification not done — only functional/authz behavior verified so far (403 test below). Do before commit if this is treated as UI-affecting.
- [x] **Denial path verified live** (stronger than the sketch below): fresh dev-auth test user, stripped `UserManagement` via live Admin UI, confirmed `403 Forbidden` + `AuthenticationScheme: Development was forbidden.` in server log, then restored. See Status Log entry for full sequence.
- [ ] Commit: `feat: enforce permission policies on admin pages and import endpoint` — not yet committed; message should drop "and import endpoint" since that part doesn't apply here, e.g. `feat: enforce permission policies on admin pages`.

### Task 3.6 (optional): Per-request permission caching

`HasPermissionAsync` hits DB per check; a Blazor page render can trigger several. If profiling shows pain: scoped memoization inside the handler (dictionary keyed by email+module+action) or `IMemoryCache` with 30-60s TTL invalidated by `SaveUserPermissionDocumentAsync`. Skip until measured — DB check is one indexed row read.

---

## Phase 4 — Domain audit events (DEFERRED)

Business events ("approved binder v3", "issued document", "inactivated template") are not field diffs — Audit.NET doesn't cover intent. When approval workflow lands (see `ELBinderApproval`/`ELDocumentApproval` entities, currently placeholder-stage): add `ELDomainEvent` table (`add_table_ELDomainEvent`: `enum_event_type`, subject FK columns, `json_payload`, `username`, `date_created_utc`) + `IDomainAuditService` in Lib, called explicitly from workflow services. Design then; entity shapes will be clearer.

### Task 4.x (follow-up): AuditAlways / AuditDoNotDisplay attribute parity with FPA

FPA's hand-rolled audit (`Lib/Models/AuditableBaseRecord.cs` in CDH_FPA) has two custom attrs EL's Audit.NET setup has no equivalent for yet:
- `AuditAlwaysAttribute` — force a field into the changelog even when compare says unchanged (FPA use: fields where "unchanged" is itself meaningful to show).
- `AuditDoNotDisplayAttribute` — capture the field in the audit row but flag it non-UI-displayable (FPA use: sensitive/noisy fields that should log but not render in an activity feed).

EL only has Audit.NET's native `[AuditIgnore]` (all-or-nothing exclude) — no per-field "always include" or "log but hide" granularity. Needed once EL builds an audit/activity viewer (Task 2.4, currently skipped) where field-level display control matters. Add as custom attrs in `Lib/Attributes/CustomAttributes.cs` + check them in the `AuditEntityAction<ELAuditLog>` callback in [Program_Helpers.cs](../../../../source/repos/CDH_EL/CDH_EL/Program_Helpers.cs) before serializing `jsonChanges`.

## Phase 5 — Production lockdown (DEFERRED, pre-go-live gate)

- Flip `UserPermissionDocument.UatBootstrapDefault()` → `Empty()` (3 call sites: `UserRecord` ctor, `FromJson` blank fallback, `GetPermissionDocumentByEmailAsync` unknown-user branch).
- Seed admin permission docs (`seed_UserRecord_ELAdmins`-style migration or admin UI).
- Re-test every page as a zero-permission user — every gate must deny.

## Order + effort

| Phase | Depends on | Size |
|---|---|---|
| 1 — user attribution | — | S (half day) |
| 2 — Audit.NET | 1 | M (1-2 days incl. viewer stub) |
| 3 — policy auth | — (parallel with 2 OK; both touch `Program.cs`, rebase carefully) | M (1-2 days) |
| 4 — domain events | approval workflow exists | design later |
| 5 — lockdown | 3 complete + UAT done | S, gated on go-live |

## Risks / open items

- Audit.NET fluent API names drift across versions — verify against installed package docs before Task 2.3. **Confirmed real**: `AuditSaveChangesInterceptor` namespace and `.UseDbContext<ELContext>()` behavior both differed from the plan's assumption; see Task 2.3 deviations above.
- One harmless test `UserRecord` row (`audit.phase2.check@cdhts.com`) left in the dev DB from Task 2.3 verification — not cleaned up yet.
- `Identity.Name` under Auth0 may be display name, not email — resolve in Task 1.1 before anything downstream trusts `Username`.
- Audit row insert = second `SaveChanges`, not same transaction — documented, acceptable v1.
- `ELDocumentRevision.jsonChanges`-style large JSON bodies (TipTap docs) will produce large audit rows on document saves — if `ELAuditLog` bloats, add `[AuditIgnore]` to the heavy JSON columns or exclude `ELDocumentRevision` and rely on the revision table itself as its own history.
- Blazor Server: `IHttpContextAccessor` after prerender can be null/stale — `Username` settable override is the escape hatch; wire a circuit-level stamp only if `unknown@user` rows reappear.
