---
title: EL Dynamic Permission Actions Warplan
created: 2026-08-04
type: project
source: C:\Users\dkolaya\source\repos\CDH_EL
tags:
  - project/el
  - area/development
---

# EL Dynamic Permission Actions Warplan

**Status (2026-08-04):** Planned, not started. Supersedes the docs-only design note committed as `0bb2d74` on `Drew/Sprint4/PermissionCatalogDesignNote` (`docs/reference/permission-catalog-dynamic-actions.md`), which this plan corrects on three points. Follow-on to [[04_Projects/Active/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]].

> **For agentic workers:** Execute task-by-task. Steps use checkbox syntax for tracking. Tasks 1-6 must land as **one commit** — see § Commit Atomicity. When implementation starts, copy this into the repo at `docs/reference/plans/` per repo doc conventions (`.original.md` + compressed `.md` pair) so it travels with the branch.

**Goal:** Make the permission model dynamic and dev-extensible. Each module declares its own action set and its own action labels; the permission editor renders whatever is declared with no markup changes; adding an action to a new module becomes a catalog edit. Plus two editor QOL features: All/None toggles, and grant-time dependency assignment (checking `Create` auto-grants `View`).

**Architecture:** `PermissionCatalog` gains a per-module `AllowedActions` list of `ModulePermissionAction(Action, LabelOverride?)`, while the global `Actions` registry keeps canonical names plus per-action `Requires` dependency edges. A new pure `PermissionActionRules` in `Lib` owns closure/cascade/normalize logic, consumed by both the editor UI and the save path. `UserModulePermission.HasAction` stays a dumb set-membership test — implication happens at grant time only. The fixed 4-column matrix is replaced by per-module cards, because per-module action names are incompatible with shared column headers.

## Why this supersedes the design note

Wargaming the note surfaced five defects, three in the note itself:

1. **Stale target.** The note names `CDH_EL/Components/Pages/Admin/AdminUserPermissions.razor` as its main rework target 3× (`.md:11,17,26`; `.original.md:22,50,81`). That file was deleted in `688222a` ("Combined User Management edit screen") — and the note was committed *after* that merge. The markup now lives in `CDH_EL/Components/Shared/PermissionMatrixEditor.razor` + `PermissionEditRow.cs`.
2. **Note step 4 rewrites applied migration history.** It prescribes regenerating the `FullAccessJson` literal inside `Lib/Migrations/20260721192437_seed_UserRecord_ELAdmins.cs`. That migration has already run everywhere; editing it changes fresh-DB behavior only → environment drift. Worse, its literal deliberately holds 6 modules (no `AuditLog`), and `20260803100000_seed_UserRecord_AuditLogAccess.cs` appends `AuditLog` guarded by `NOT EXISTS ... module='AuditLog'` — regenerating the older literal would make that guard skip on fresh DBs. Historical migrations stay immutable.
3. **A rename is a fleet-wide lockout — unmentioned by the note.** `UserPermissionDocument.FromJson` catches `JsonException` → returns `Empty()`. With `JsonStringEnumConverter`, renaming a `PermissionAction`/`PermissionModule` enum value makes every stored document containing the old string unparseable, so affected users lose **every permission on every module**, not just the renamed one. This repo already ate one full-fleet lockout from a permissions default flip (2026-07-20, see parent warplan). **Therefore: renames are display-label-only; new concepts get new appended enum values; never rename or remove one.**
4. **Red test, pre-existing.** `Lib.Tests/Models/User/Permissions/UserModulePermissionTests.cs:41` asserts `HasAction(Edit) == true` for `Actions = [Admin]`. `UserModulePermission.cs:10` is `Actions.Contains(action)` → `false`. It encodes implication logic deliberately stripped in `0e8276f`, and contradicts its own sibling at `:17` (Admin does *not* allow View).
5. **Audit Log nav gated on the wrong module.** `AppShell.razor:166` gates the link on `PermissionModule.Permissions`, not `AuditLog`. A user with `AuditLog:View` sees a disabled link but can reach `/admin/audit-log` by URL; a user with `Permissions:View` sees a live link landing on Access Denied.

## Design decisions

### Implication at grant time, not check time

`UserModulePermission.HasAction` was once `Actions.Contains(Admin) || Actions.Contains(action)`; `0e8276f` reduced it to plain `Contains`, and the Codex audit logged in the parent warplan confirmed "Admin/Create/Edit do NOT imply View." Dependency auto-assignment must **not** reintroduce that.

- **Grant time (UI + save):** checking `Create` adds `View` to the stored set. Both persist.
- **Check time (runtime):** `HasAction` unchanged.

Stored documents stay self-describing (what you read is what was granted) and authorization stays trivially auditable. This is also why defect 4's test gets deleted rather than revived.

### Per-module cards, not a matrix

A shared column header cannot read "Approve & Delete" for Templates and "Manage" for Workspace simultaneously — per-module action names break the grid's premise. `PermissionMatrixEditor` becomes a stack of per-module blocks, each rendering only its own actions with its own labels.

Side benefit: this deletes the mobile problem instead of solving it. The current table forces `16rem + 4×5.5rem ≈ 38rem` min-width inside `.table-responsive` with no sticky first column, so at 375px the module name scrolls out of view and nothing ties a checkbox to its row. Cards are single-column at every width.

### Do NOT narrow the policy registration loop

`CDH_EL/Program.cs:141-151` registers all `Enum.GetValues<PermissionModule>() × Enum.GetValues<PermissionAction>()` policies. **Leave it.** Narrowing to `AllowedActions` would make any surviving `[Authorize(Policy = ...)]` reference to a now-unregistered name throw `InvalidOperationException` — a **500, not a 403**. `AppPermissionGate.razor:61-66` fails closed, but the attribute path does not. Registering an unsatisfiable policy is inert; failing to register one is an outage. The note's claim that this layer needs no changes is correct — but for this reason, which it doesn't state.

### Verified HAVIT component constraints

Queried via `Havit.Blazor.Mcp` before any markup design:

- `HxCheckbox` has **no tri-state** — `Value` is `bool`, not `bool?`. A "partially selected" header checkbox needs JS interop poking `.indeterminate`. Rejected; All/None are buttons instead.
- `HxCheckbox.Inline="true"` is valid only with no `Label`/`Hint`/validation message — our case qualifies. Use `Text="@label"`.
- `@bind-Value` alone can't run the dependency logic. Use explicit `Value` + `ValueChanged`, or the `@bind-Value:after` idiom already used at `AdminAuditLog.razor:58`.
- `HxButton` auto-spins on async handlers → keep All/None handlers **synchronous** or an instant local toggle flickers a spinner.

## Declared catalog (v1)

| Module | Actions | Evidence / notes |
|---|---|---|
| Workspace | View, Edit | `Workspace:Edit` at `ElPackageWorkspace.razor:422` |
| Templates | View, Create, Edit, Admin | `Admin` labeled **"Approve & Delete"** — first label override, per `TemplateDetail.razor:1078` |
| ServiceMaps | View | no routed page yet |
| Rules | View | no routed page yet |
| UserManagement | View, Create, Edit | `Admin` never checked anywhere |
| Permissions | View, Edit | only `PermissionsView`/`PermissionsEdit` consts exist |
| AuditLog | View | append-only, interceptor-written |

Every module keeps `View` — `AppShell.razor:264` builds nav visibility from `HasPermission(module, View)`, and every other action depends on it.

> **Drew to author:** this table is domain knowledge, not inferable from grep hits. The task below prepares the record shapes and leaves the `Modules` list as the one spot to fill — including any action to rename or add that today's usage doesn't reveal. ~10 lines.

## Commit Atomicity

Tasks 1-6 land as **one commit** on a new branch off `Drew/Sprint4/PermissionCatalogDesignNote`. An intermediate state where `AllowedActions` exists but `FullAccess()` still cross-products would grant unenforceable actions to any fresh seed.

## Task 1 — Catalog shape

- [ ] `Lib/Models/User/Permissions/PermissionCatalog.cs` — add the three record shapes:
  ```csharp
  public sealed record PermissionActionDefinition(
      PermissionAction Action, string Name, IReadOnlyList<PermissionAction> Requires);

  public sealed record ModulePermissionAction(
      PermissionAction Action, string? LabelOverride = null);

  public sealed record PermissionModuleDefinition(
      PermissionModule Module, string Name, string Description,
      IReadOnlyList<ModulePermissionAction> AllowedActions);
  ```
- [ ] Keep `Actions` as the global registry (canonical name + dependency edges). Seed `Requires`: `View` → none; `Create`/`Edit`/`Admin` → `[View]`.
- [ ] Fill the `Modules` list per § Declared catalog (Drew authors).
- [ ] Add `GetAllowedActions(module)` and `GetActionLabel(module, action)` — override, falling back to the existing `GetActionName`, which is currently dead code and becomes live as the label source.
- [ ] Action **order** comes from iterating the global `Actions` registry, not module declaration order, so ordering stays stable across modules.
- Commit: (part of the single atomic commit)

## Task 2 — Dependency rules in Lib

- [ ] New `Lib/Models/User/Permissions/PermissionActionRules.cs`, pure static, no DI — business logic must not live in `.razor` per repo AGENTS.md.
- [ ] `ExpandRequirements(action)` — transitive closure of `Requires`.
- [ ] `ApplyToggle(HashSet<PermissionAction> granted, PermissionAction toggled, bool isOn, IReadOnlyList<PermissionAction> allowed)` — on: add requirement closure; off: also remove everything depending on it (cascade down, else `Create` without `View` can persist).
- [ ] `Normalize(HashSet<PermissionAction> granted, PermissionModule module)` — drop not-allowed, add missing requirements. Idempotent.

## Task 3 — Permission document

- [ ] `UserPermissionDocument.FullAccess()` → per-module `AllowedActions` instead of the `Modules × Actions` cartesian product (`:22`, `:26` are the only production consumers of the flat `Actions` list).
- [ ] Add `Normalize()` applying `PermissionActionRules.Normalize` across all module entries.
- [ ] `HasPermission` / `FromJson` / `ToJson` / `UatBootstrapDefault` — **unchanged.**
- [ ] Call `Normalize()` in `CDH_EL/Services/Admin/CurrentUserPermissionService.SaveUserPermissionDocumentAsync` (guard already at `:74`) so the invariant holds for callers bypassing the UI.

## Task 4 — Policy layer

- [ ] **No change.** Confirm `Program.cs:141-151` still registers the full enum cross-product and that `PermissionPolicyNames` is untouched. See § Do NOT narrow the policy registration loop.

## Task 5 — Editor UI

- [ ] `CDH_EL/Components/Shared/PermissionEditRow.cs` — replace the four fixed bools (`CanView`/`CanCreate`/`CanEdit`/`CanAdmin`) with `IReadOnlyList<ModulePermissionAction> Actions` (from catalog) + `HashSet<PermissionAction> Granted`. Expose `IsGranted(action)`, `Toggle(action, bool)` (delegating to `PermissionActionRules.ApplyToggle`), `SelectAll()`, `Clear()`, `ToPermission()`. `From(definition, document)` normalizes on load.
- [ ] Fix its stale XML doc at `:6-7`, which still describes the deleted page.
- [ ] `PermissionMatrixEditor.razor` — rewrite as per-module `HxCard` blocks with inline `HxCheckbox` per declared action, honoring label overrides. Per-module All/None as `HxButton Size="ButtonSize.Small"`, plus one global pair in a toolbar above the stack (style guide L102: filters/toolbar above grids).
- [ ] Rewrite `PermissionMatrixEditor.razor.css` — the three min-width table rules die with the table.
- [ ] Verify both consumers still compile and round-trip: `AdminUserEdit.razor:56` and `AdminUserCreate.razor:41`.

## Task 6 — Migration

- [ ] `Lib/Migrations/{yyyyMMddHHmmss}_update_UserRecord_trim_disallowed_permission_actions.cs` (repo naming convention `update_<Entity>_<change>`).
- [ ] Filter each row's `json_permissions` module entries down to the catalog-allowed set via `OPENJSON` + `STRING_AGG` + `JSON_MODIFY` — the rebuild pattern already proven in `20260803100000_seed_UserRecord_AuditLogAccess.cs:38-59`. Note its comment on why `FOR JSON PATH` was rejected: it wraps each value in `{"value": ...}`. **A filter, not a blind overwrite** — anything still valid is preserved, including hand-edited users.
- [ ] Destructive for the 7 seeded admins (~15 orphan action entries each: `Workspace:Create/Admin`, `ServiceMaps:Create/Edit/Admin`, `Rules:Create/Edit/Admin`, `UserManagement:Admin`, `Permissions:Create/Admin`, `AuditLog:Create/Edit/Admin`). `Down()` non-reversible — document it, matching the precedent at `20260721192437:42-45`.
- [ ] State in the migration's XML doc: raw-SQL migrations do **not** fire `AuditSaveChangesInterceptor`, so this permission change produces no `ELAuditLog` row (unlike every UI-driven permission edit) — `__EFMigrationsHistory` is the only record. And `Normalize()` (Task 3) is the backstop for any row this misses.

## Task 7 — Adjacent fixes (confirmed in scope)

- [ ] Delete `UserModulePermissionTests.HasAction_WithOnlyAdmin_AllowsEdit` (`:32-42`) — asserts removed check-time implication, contradicts `:9`.
- [ ] `AppShell.razor:166` — `PermissionModule.Permissions` → `PermissionModule.AuditLog`.
- [ ] `AdminUserCreate.razor:41` — wrap the editor in a `canEditPermissions` check mirroring `AdminUserEdit.razor:50,:90`. Today it renders unconditionally, so a `UserManagement:Create`-only user fills in permissions, submits, and gets the "User created, but status/permissions could not be saved" warning from `:122` after the server-side guard at `CurrentUserPermissionService.cs:74` rejects it.

## Task 8 — Tests

- [ ] New `Lib.Tests/Models/User/Permissions/PermissionCatalogTests.cs` — invariants with zero coverage today:
  - [ ] Every `PermissionModule` enum value has exactly one catalog entry (enum/catalog parity untested today).
  - [ ] Every module declares ≥1 action, and includes `View`.
  - [ ] **Every allowed action's `Requires` closure ⊆ that module's `AllowedActions`** — the real failure mode: declaring an action whose dependency the module doesn't expose makes it ungrantable.
  - [ ] No cycles in `Requires`.
  - [ ] **Enum-name stability:** assert `nameof` for every `PermissionAction`/`PermissionModule` value, so a rename fails a test instead of locking out prod (defect 3).
- [ ] New `PermissionActionRulesTests` — toggle-on adds closure; toggle-off cascades to dependents; `Normalize` drops disallowed + adds missing; idempotent.
- [ ] Rewrite `UserPermissionDocumentTests.FullAccess_AllowsEveryCatalogModuleAction` (`:9`) — tautological today (loops the same two lists `FullAccess()` is built from) and will fail once AuditLog narrows. Replace with exact per-module set assertions plus an explicit `Assert.False(FullAccess().HasPermission(AuditLog, Admin))`.
- [ ] Add a `ToJson()` round-trip assertion against an expected literal — nothing currently guards the serialized shape the migration literals depend on.
- [ ] New `PermissionEditRowTests` — `From` → `Toggle` → `ToPermission` round-trip.

## Task 9 — Docs

- [ ] Rewrite `docs/reference/permission-catalog-dynamic-actions.md` **and** `.original.md` to this design: fix the three stale `AdminUserPermissions.razor` references, drop the migration-history-rewrite step, add the enum-append-only invariant, the grant-time-vs-check-time decision, and the "don't narrow the policy loop" rationale. Flip `Status:` once implemented.

## Verification

- [ ] `dotnet build` — expect 0 errors.
- [ ] `dotnet test`. Note 3 pre-existing unrelated failures in `EngagementLetterTemplateServiceTests` (title-uniqueness, effective-date, default-order) — confirm they still fail identically via `git stash` before attributing anything to this change.
- [ ] Apply the migration against the **local Docker container `cdhel-sql` (sqlcmd → localhost)**, not the shared `192.168.17.202\CDH_FPA` box: `dotnet ef database update --project Lib --startup-project CDH_EL`.
- [ ] Query-verify: (a) each seeded admin retains all still-allowed actions, (b) no module entry contains a disallowed action, (c) no row became unparseable or empty, (d) re-running the migration SQL is a no-op.
- [ ] Manual smoke on `/admin/users/{id}`: each module block shows only its declared actions with correct labels; checking `Create` auto-checks `View`; unchecking `View` clears the module; All/None work per module and globally; save → reload round-trips.
- [ ] Confirm `/admin/audit-log` still authorizes for an `AuditLog:View` user and that the nav link is now enabled for them (Task 7 fix).

## Status Log

- 2026-08-04 — Plan authored. Recon confirmed nothing in the superseded design note is implemented: `PermissionModuleDefinition` has no `AllowedActions`, `FullAccess()` still cartesian, matrix still fixed-4-column. Five defects identified (3 in the note, 2 in code) — see § Why this supersedes the design note. Scope decisions settled with Drew: narrow every module to actual usage including ServiceMaps/Rules → `[View]`; per-action `Requires` declared in catalog with View as universal baseline; All/None buttons rather than tri-state checkboxes (HAVIT `HxCheckbox` has no `bool?` value); per-module cards replacing the matrix because per-module renames break shared column headers. `PermissionAction.Export` considered and **dropped** — no export feature exists on `AdminAuditLog`, so adding it now would reproduce the exact "grantable but gates nothing" disease this plan cures; the design makes adding it later a catalog one-liner.

## Links

- [[04_Projects/Active/EL|EL]]
- [[04_Projects/Active/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]]
- [[04_Projects/Project Index|Project Index]]
