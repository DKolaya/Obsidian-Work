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

> **For agentic workers:** Execute task-by-task (subagent-driven or inline). Steps use checkbox syntax for tracking. When implementation starts, copy the relevant phase into the repo at `docs/reference/plans/` per repo doc conventions (`.original.md` + compressed `.md` pair) so it travels with the branch.

**Goal:** Add automatic field-level entity auditing (Audit.NET) and policy-based permission authorization (built-in ASP.NET Core) to CDH_EL, reusing the existing `PermissionModule`/`PermissionAction` enum model as the single source of truth.

**Architecture:** Audit.NET's `AuditSaveChangesInterceptor` captures EF Core change diffs into a new `ELAuditLog` table in the same database (no base-class change to `ELContext`). Authorization gets a `PermissionRequirement` + one generic `AuthorizationHandler` that bridges `[Authorize(Policy = "Permission:{Module}:{Action}")]` to the existing `UserRecord.jsonPermissions` document via `IUserAdministrationService.HasPermissionAsync`. `AppPermissionGate` is refactored to call `IAuthorizationService` so component gating and attribute gating share one enforcement path.

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

## Phase 1 — Fix user attribution (branch: `feature/audit-user-attribution`)

The "who" is broken today. Everything in Phases 2-3 depends on it. Small, ships alone.

### Task 1.1: Register `IHttpContextAccessor` and wire it into factory-created contexts

**Files:**
- Modify: `CDH_EL/Program.cs` (~line 96)
- Modify: `Lib/DAL/ELContext.cs:37-52`

- [ ] Collapse `ELContext`'s constructors into one with an optional accessor (factory resolves it from root DI; `IHttpContextAccessor` is a singleton backed by `AsyncLocal`, safe in a singleton factory):

```csharp
public ELContext(DbContextOptions<ELContext> options, IHttpContextAccessor? httpContextAccessor = null)
    : base(options)
{
    this.httpContextAccessor = httpContextAccessor;
}
```

Delete the 2-arg ctor that null-sets the accessor and the unused 3-arg ctor. Check for direct `new ELContext(...)` call sites first (tests, design-time factory) and update them.

- [ ] In `Program.cs`, before the factory registration:

```csharp
builder.Services.AddHttpContextAccessor();
```

- [ ] Make `ELContext.Username` a settable property with the accessor read as fallback, so Blazor-circuit code paths (where `HttpContext` can be null/stale after prerender) can stamp explicitly:

```csharp
private string? usernameOverride;

public string Username
{
    get => usernameOverride
        ?? httpContextAccessor?.HttpContext?.User?.Identity?.Name
        ?? "unknown@user";
    set => usernameOverride = value;
}
```

- [ ] Add `Lib.Tests` test: context with fake accessor stamps `createdBy` from identity name; context with `Username` override prefers the override; context with neither stamps `"unknown@user"`.
- [ ] `dotnet build` + run tests.
- [ ] Manual check: run app, log in, save anything (e.g. admin user edit), confirm `updated_by` column now shows real email, not `unknown@user`.
- [ ] Commit: `fix: stamp real username on factory-created ELContext audit columns`

**Verify before starting:** whether `Identity.Name` is populated under Auth0 web-app flow (it maps `name` claim; may be display name, not email). If email wanted, read `ClaimTypes.Email` / `"email"` claim instead of `Identity.Name` — match what `CurrentUserPermissionService.GetCurrentUserIdentityAsync()` (`CurrentUserPermissionService.cs:85-109`) already does, and keep the two consistent.

---

## Phase 2 — Audit.NET entity audit (branch: `feature/audit-net-entity-log`)

### Task 2.1: Package + audit noise reduction

**Files:**
- Modify: `Lib/Lib.csproj`
- Modify: `Lib/Models/BaseRecord.cs:16,24,32,40`

- [ ] `dotnet add Lib package Audit.EntityFramework.Core` (latest v32.x).
- [ ] Uncomment the four `[AuditIgnore]` attributes on `BaseRecord` (add `using Audit.EntityFramework;`). Rationale: `dateUpdatedUtc`/`updatedBy` change on every save — pure diff noise; the audit log row carries its own who/when.
- [ ] Build. Commit: `chore: add Audit.EntityFramework.Core, exclude BaseRecord stamps from diffs`

### Task 2.2: `ELAuditLog` entity + migration

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

- [ ] `ELContext`: add `public DbSet<ELAuditLog> ELAuditLog { get; set; }`; in `OnModelCreating` add composite index `(tableName, primaryKey)` and index on `dateCreatedUtc`.
- [ ] Migration: `dotnet ef migrations add add_table_ELAuditLog --project Lib` then rename file/class to timestamped convention if the generator's stamp differs from repo format (repo format: `{yyyyMMddHHmmss}_add_table_ELAuditLog.cs`, class `add_table_ELAuditLog`).
- [ ] Inspect generated migration: table `ELAuditLog`, int identity `id`, nvarchar(100)/(100)/(100)/MAX, `datetime2`. Apply to dev DB, build, commit: `feat: add_table_ELAuditLog for Audit.NET change log`

### Task 2.3: Interceptor + data provider wiring

**Files:**
- Modify: `CDH_EL/Program.cs` (factory registration ~line 96, plus one-time Audit.NET setup before `builder.Build()`)

- [ ] Add interceptor to the factory options:

```csharp
builder.Services.AddDbContextFactory<ELContext>(item =>
    item.UseSqlServer(connectionString, options => options.CommandTimeout(commandTimeout))
        .AddInterceptors(new Audit.EntityFramework.Interceptors.AuditSaveChangesInterceptor()));
```

- [ ] One-time Audit.NET config (private helper in `Program_Helpers.cs`, called from `Main`):

```csharp
using Audit.Core;
using Audit.EntityFramework;
using Audit.EntityFramework.ConfigurationApi;
using Lib.DAL;
using Lib.Models.Audit;

private static void ConfigureAuditNet()
{
    Audit.Core.Configuration.Setup()
        .UseEntityFramework(ef => ef
            .UseDbContext<ELContext>()
            .AuditTypeMapper(t => typeof(ELAuditLog))
            .AuditEntityAction<ELAuditLog>((ev, entry, audit) =>
            {
                var efEvent = ev.GetEntityFrameworkEvent();
                audit.tableName = entry.Table;
                audit.primaryKey = string.Join(",", entry.PrimaryKey.Select(k => $"{k.Value}"));
                audit.enumAuditAction = entry.Action switch
                {
                    "Insert" => ELAuditAction.Insert,
                    "Delete" => ELAuditAction.Delete,
                    _ => ELAuditAction.Update,
                };
                audit.jsonChanges = entry.ToJson();
                audit.username = (efEvent?.GetDbContext() as ELContext)?.Username ?? "unknown@user";
                audit.dateCreatedUtc = DateTime.UtcNow;
                return true; // false skips saving this row
            })
            .IgnoreMatchedProperties(true));
}
```

- [ ] Exact API names drift between Audit.NET versions — verify `AuditTypeMapper`/`AuditEntityAction`/`GetEntityFrameworkEvent` against the installed package before writing; adjust to the fluent API the package exposes.
- [ ] Build, run. Edit a template or user in the UI; query `SELECT TOP 10 * FROM ELAuditLog ORDER BY id DESC` — expect one row per changed entity with JSON old/new values and real username.
- [ ] Verify dev-auth branch still boots (`DevelopmentAuthenticationHandler` path) and audit rows record the dev identity.
- [ ] Commit: `feat: wire Audit.NET interceptor writing ELAuditLog change log`

### Task 2.4 (optional, same branch): Admin audit viewer stub

Blazor page `Admin/AdminAuditLog.razor` behind `Permissions`/`View` gate — HxGrid over `ELAuditLog` newest-first, filter by table/user/date. HAVIT MCP check before writing markup (per global rule). Defer if sprint-pressed; table is queryable via SQL meanwhile.

---

## Phase 3 — Policy-based authorization (branch: `feature/policy-permission-auth`)

### Task 3.1: Policy names catalog (Lib)

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

- [ ] Lib.Tests: `For(PermissionModule.Templates, PermissionAction.Edit) == PermissionPolicyNames.TemplatesEdit`; loop-test every const matches `For(...)` for its pair (catches typo drift).
- [ ] Commit: `feat: add PermissionPolicyNames catalog`

### Task 3.2: Requirement + handler (web)

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

- [ ] Commit: `feat: add PermissionRequirement and authorization handler`

### Task 3.3: Register policies (Program.cs)

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

- [ ] Build, boot, confirm login flow unchanged (policies additive — nothing references them yet).
- [ ] Commit: `feat: register Permission:{Module}:{Action} policies at startup`

### Task 3.4: Single enforcement path — refactor `AppPermissionGate`

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

- [ ] Verify each gated page manually: Dashboard, Landing, HeaderFooterDesigner, AdminDashboard, AdminUsers, AdminUserEdit, AdminUserPermissions — with a full-access user (UAT default) all render.
- [ ] Temporarily flip own permission doc to test denial path renders the access-denied card (then restore).
- [ ] Commit: `refactor: AppPermissionGate authorizes via policy pipeline`

### Task 3.5: Harden pages + endpoints with policy attributes

**Files:**
- Modify: admin pages (`Admin/*.razor`), `Template/*.razor` as appropriate
- Modify: `CDH_EL/Endpoints/EditorImportEndpoints.cs`

- [ ] Admin pages: `@attribute [Authorize(Policy = PermissionPolicyNames.UserManagementView)]` (page-level hard gate on top of in-page `AppPermissionGate`). Map: AdminDashboard/AdminUsers → `UserManagementView`; AdminUserEdit → `UserManagementEdit`; AdminUserPermissions → `PermissionsEdit`.
- [ ] `/editor/import-docx`: add `.RequireAuthorization(PermissionPolicyNames.TemplatesEdit)` — currently unprotected.
- [ ] Audit remaining mapped endpoints for missing `.RequireAuthorization()`.
- [ ] Verify desktop + mobile widths on touched pages; MVC `HomeController.Index` + one Blazor page render (mixed-surface rule).
- [ ] Commit: `feat: enforce permission policies on admin pages and import endpoint`

### Task 3.6 (optional): Per-request permission caching

`HasPermissionAsync` hits DB per check; a Blazor page render can trigger several. If profiling shows pain: scoped memoization inside the handler (dictionary keyed by email+module+action) or `IMemoryCache` with 30-60s TTL invalidated by `SaveUserPermissionDocumentAsync`. Skip until measured — DB check is one indexed row read.

---

## Phase 4 — Domain audit events (DEFERRED)

Business events ("approved binder v3", "issued document", "inactivated template") are not field diffs — Audit.NET doesn't cover intent. When approval workflow lands (see `ELBinderApproval`/`ELDocumentApproval` entities, currently placeholder-stage): add `ELDomainEvent` table (`add_table_ELDomainEvent`: `enum_event_type`, subject FK columns, `json_payload`, `username`, `date_created_utc`) + `IDomainAuditService` in Lib, called explicitly from workflow services. Design then; entity shapes will be clearer.

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

- Audit.NET fluent API names drift across versions — verify against installed package docs before Task 2.3.
- `Identity.Name` under Auth0 may be display name, not email — resolve in Task 1.1 before anything downstream trusts `Username`.
- Audit row insert = second `SaveChanges`, not same transaction — documented, acceptable v1.
- `ELDocumentRevision.jsonChanges`-style large JSON bodies (TipTap docs) will produce large audit rows on document saves — if `ELAuditLog` bloats, add `[AuditIgnore]` to the heavy JSON columns or exclude `ELDocumentRevision` and rely on the revision table itself as its own history.
- Blazor Server: `IHttpContextAccessor` after prerender can be null/stale — `Username` settable override is the escape hatch; wire a circuit-level stamp only if `unknown@user` rows reappear.
