---
title: Grant EL Admin Permissions
created: 2026-07-20
type: resource
tags:
  - resource/script
  - project/el
---
# Grant-ELAdminPermissions.sql

## Purpose

One-off unblock for a permission lockout in CDH_EL. `UserPermissionDocument.UatBootstrapDefault()` was flipped from `FullAccess()` to `Empty()` (post-UAT deny-by-default). No `UserRecord` row in the DB ever had an explicit `json_permissions` value saved — every account, including admin accounts, relied on the bootstrap `FullAccess()` fallback. Flipping the default locks every account out of every policy-gated page, including the admin pages needed to grant permissions through the UI, so there's no way to self-recover without touching the DB directly.

This script sets one account's `json_permissions` to full access across all 6 modules x all 4 actions, matching `UserPermissionDocument.FullAccess()`'s exact JSON shape (verified by serializing that method directly, not hand-written).

Related: [[EL Audit and Permissions Warplan]].

## Location

`scripts/Grant-ELAdminPermissions.sql`

## Usage

```powershell
sqlcmd -S "192.168.17.202\CDH_FPA" -d CDH_EL_ST_LIB3 -U sa -P '<password from appsettings.Development.json>' -C -i "scripts\Grant-ELAdminPermissions.sql"
```

Or open in SSMS/Azure Data Studio connected to `192.168.17.202\CDH_FPA` / `CDH_EL_ST_LIB3` and execute.

Edit the `@Email`/`@FirstName`/`@LastName` variables at the top before running for a different account.

## Notes

- Idempotent — updates the row if `username` already exists, inserts a new row if not.
- Targets a shared dev DB (`192.168.17.202\CDH_FPA`), not localdb — be deliberate about who else is affected.
- This is a stopgap, not the long-term fix. The proper fix is an EF seed migration (AGENTS.md convention: `seed_UserRecord_ELAdmins`) that grants at least one real admin account explicit permissions as part of the schema, so a fresh environment doesn't hit this same lockout.
- Once `Permissions:Edit` is usable again (i.e. this script has run for at least one account), grant everyone else through the Admin UI instead of running this script per-account.
