---
title: Deferred Transactions
created: 2026-07-08
type: project
source: [[90_Archive/OneNote Raw/Drew @ Work]]
tags:
  - project/deferred-transactions
  - area/development
  - area/intacct
---

# Deferred Transactions

## Implementation TODO

- [ ] Implement new discarded transaction stage.
- [ ] Map business lines.
- [ ] Build frontend support to add business lines for import/export department.

## Progress Steps

1. Receive: use created date.
2. Validate.
3. Intacct processing: use completed date.
4. Complete: use one-to-one API acknowledge date.

## Date Rules

- When transaction date does not match post date, compare CargoWise transaction date and post date.
- Consider filtering when dates are more than one month apart.
- For deferred transactions, check whether month is open in Intacct.
- If month is open, use invoice date and posting date.
- If month is closed, use first day of next month.
- Use location entity to find fiscal periods.

## Status Log

- 2026-07-10 — repo `TRANCY_CargoWise_Integration`: open PR [#2](https://github.com/CDHTS/TRANCY_CargoWise_Integration/pull/2) "Trancy Discarded, Intacct improvements, and department mapping" on `feature/Intacct-Improvements-WIP`, no new commits. [[07_Meetings/2026-07-10 Trancy CargoWise Integration Checkpoint|Trancy CargoWise Integration Checkpoint]] meeting today.
- 2026-07-13 — repo `TRANCY_CargoWise_Integration`: PR #2 still open, no new commits, working tree clean, no CI checks configured on this branch.

## Links

- [[06_Resources/Intacct/Intacct Hints]]
- [[04_Projects/Active/FPA]]
