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

## Links

- [[06_Resources/Intacct/Intacct Hints]]
- [[04_Projects/Active/FPA]]
