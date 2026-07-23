---
title: ORDA Positive Pay
created: 2026-07-22
type: project
source: [[07_Meetings/2026-07-22 Positive Pay review]]
tags:
  - project/orda-positive-pay
  - area/development
---

# ORDA Positive Pay

## Background

- Toolkit apps: single application, multiple modules, each doing an import (or in this case, export) for a customer. Core logic generally shared across customers; variation is per-customer business logic/validation and file format.
- Manual imports = multi-step UI (upload file → validate → push to Intacct). Positive Pay is the odd one out: it's an **export**, not import.
- Positive Pay (bank process): checks deposited via desktop/remote scanner (not at a bank branch) need a secondary verification file sent to the bank — list of check numbers/info confirming which checks were completed. Separate channel from the funds deposit itself.
- Our part: look for checks in Intacct and build the export file the bank expects.
- Customer: ORDA (contact rgraham@orda.org). Prep material: "FW: ORDA - Positive Pay" email forwarded by Patrick, 2026-07-21.
- Reference project: CSAC (existing toolkit implementation) — to review alongside for comparison/pattern while building this one.

## Scope framing

- Not built from scratch — reusing existing toolkit system, doing "the last 10-20%" of customization for ORDA.
- No hard deadline. Patrick confirmed there's time; earlier "one week" mention was a casual ballpark, not a real target.

## Tasks

- [ ] Digest the core toolkit codebase.
- [ ] Review CSAC project alongside core (reference implementation) while ramping up.
- [ ] Create ORDA repository.
- [ ] Get bank file spec from Nathan once he's trimmed the 30-page doc down to what's actually needed.
- [ ] Review any Positive Pay page changes Nathan makes to align with core before building on them.

## Status Log

- 2026-07-22 — Kickoff/handoff meeting with Nathan Sawyer. Drew out on vacation next week; real start after return. Nathan to: set up Monday board + repo shell, distill bank file documentation, possibly get a head start aligning Positive Pay pages with core (will share for review if so).

## Links

- [[07_Meetings/2026-07-22 Positive Pay review]]
