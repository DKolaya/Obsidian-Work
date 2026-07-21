-- Grant-ELAdminPermissions.sql
-- One-off unblock for CDH_EL post-UAT permission lockout (2026-07-20).
--
-- Context: UserPermissionDocument.UatBootstrapDefault() was flipped from FullAccess() to Empty()
-- (Lib/Models/User/Permissions/UserPermissionDocument.cs, commit pending on Drew/Sprint3/Audit).
-- No UserRecord row in this DB has ever had an explicit jsonPermissions value saved - every account,
-- including admin accounts, relied on the bootstrap FullAccess() fallback. Flipping the default to
-- Empty() locks EVERY account out of every policy-gated page (admin pages included), with no way to
-- self-grant through the app UI, since granting permissions itself requires Permissions:Edit.
--
-- This script sets one account's UserRecord.json_permissions to full access across all 6 modules
-- (Workspace/Templates/ServiceMaps/Rules/UserManagement/Permissions) x all 4 actions
-- (View/Create/Edit/Admin), matching UserPermissionDocument.FullAccess()'s exact JSON shape
-- (verified 2026-07-20 by serializing FullAccess().ToJson() directly - do not hand-edit the JSON
-- shape without re-verifying against that method, since property/enum casing is JsonSerializer-driven).
--
-- Run against: 192.168.17.202\CDH_FPA, database CDH_EL_ST_LIB3 (shared dev DB - not localdb).
-- Safe to re-run (idempotent: updates if the row exists, inserts if it doesn't).

DECLARE @Email nvarchar(1000) = 'dkolaya@cdhts.com';
DECLARE @FirstName nvarchar(100) = 'Drew';
DECLARE @LastName nvarchar(100) = 'Kolaya';
DECLARE @FullAccessJson nvarchar(max) = N'{"modules":[{"module":"Workspace","actions":["View","Create","Edit","Admin"]},{"module":"Templates","actions":["View","Create","Edit","Admin"]},{"module":"ServiceMaps","actions":["View","Create","Edit","Admin"]},{"module":"Rules","actions":["View","Create","Edit","Admin"]},{"module":"UserManagement","actions":["View","Create","Edit","Admin"]},{"module":"Permissions","actions":["View","Create","Edit","Admin"]}]}';

IF EXISTS (SELECT 1 FROM dbo.UserRecord WHERE username = @Email)
BEGIN
    UPDATE dbo.UserRecord
    SET json_permissions = @FullAccessJson,
        is_inactive = 0,
        date_updated_utc = GETUTCDATE(),
        updated_by = 'manual-unblock-script'
    WHERE username = @Email;

    PRINT 'Updated existing UserRecord row for ' + @Email;
END
ELSE
BEGIN
    INSERT INTO dbo.UserRecord (username, user_first, user_last, is_inactive, json_permissions, date_created_utc, date_updated_utc, created_by, updated_by)
    VALUES (@Email, @FirstName, @LastName, 0, @FullAccessJson, GETUTCDATE(), GETUTCDATE(), 'manual-unblock-script', 'manual-unblock-script');

    PRINT 'Inserted new UserRecord row for ' + @Email;
END

SELECT id, username, is_inactive, json_permissions FROM dbo.UserRecord WHERE username = @Email;
