---
title: MIDAS GP MPAS Service
created: 2026-07-08
type: project
source: [[90_Archive/OneNote Raw/Drew @ Work]]
tags:
  - project/midas
  - area/database
  - area/development
---

# MIDAS GP MPAS Service

## Source Context

- Original OneNote date: Tuesday, February 17, 2026, 11:33 AM.
- Related area: database + service-layer development.

## EF Scaffold Command

```powershell
Scaffold-DbContext "Server=[DB_SERVER]\PEFMBP;Database=MBP;User Id=sa;Password=[REDACTED];TrustServerCertificate=True" Microsoft.EntityFrameworkCore.SqlServer -Project GP_Data -StartupProject MIDAS_GP_MPAS -Context GpDbContext -OutputDir Models -Tables VW_PEF_CONVERSION_UPDATE_FLDS,PEF_CONVERSION,PEF_CONVERSION_HIST,PEF_LAYOFF_LIST -DataAnnotations -Force
```

## Tasks

- [ ] Create output file/report.
- [ ] Create CSV report with `recid`, `empnum`, `name`, status, date, and description.
- [ ] Change app runtime context to dependency injection.

## Status Log

- 2026-07-10 — repo `MIDAS_GP_MPAS`: no new commits, 1 uncommitted file on `develop`.
- 2026-07-13 — repo `MIDAS_GP_MPAS`: no new commits, still 1 uncommitted file, same branch. Note moved to `04_Projects/Done` despite open tasks above — verify intentional.

## Links

- [[05_Areas/Database/Database Index]]
- [[06_Resources/Scripts/Script Index]]
