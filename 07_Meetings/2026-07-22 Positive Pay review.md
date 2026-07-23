---
title: Positive Pay review
created: 2026-07-22
type: meeting
tags:
  - work
---
# Meeting - 2026-07-22

13:00–14:30 UTC, Microsoft Teams. Organizer: Nathan Sawyer.

## Attendees

- Nathan Sawyer (nsawyer@cdhts.com)
- Drew Kolaya (dkolaya@cdhts.com)

## Agenda

- Handoff/kickoff for ORDA Positive Pay project: what toolkit apps are, what Positive Pay is, next steps.

## Notes

- Prep: Patrick forwarded "FW: ORDA - Positive Pay" (from rgraham@orda.org, 2026-07-21) — likely relevant background for this review.
- Toolkit apps: one application, many modules, each an import (or export) job per customer. Core logic shared, variations are per-customer file format/validation/business logic. Manual imports = multi-step UI (upload → validate → push to Intacct).
- Positive Pay is the exception: it's an export, not an import. Bank process — checks deposited via desktop scanner (not at a branch) need a secondary confirmation file sent to the bank listing check numbers/info as completed. Our side of it: pull checks from Intacct, build that export file.
- Customer is ORDA. Reference implementation to work alongside: CSAC project.
- Framed as reusing an existing system, not building from scratch — "last 10-20%" of customization for ORDA. No fixed timeline; Patrick confirmed there's plenty of time. Nathan's earlier "one week" comment was a casual ballpark, not a real deadline.
- Drew is out on vacation starting this week (~1 week); recorded the meeting to review on return rather than try to retain everything now.
- Full detail captured in project note: [[04_Projects/Active/ORDA Positive Pay]].

## Decisions

- Drew and Nathan can split off — Drew starts digesting the core + CSAC in parallel, can start his own repo now if he wants.
- Nathan will set up a Monday board (repo, basic structure) for ORDA, same pattern as other customer boards.
- Nathan will review the bank's file documentation (~30 pages) and try to distill it down for Drew instead of making him read the whole thing.
- Nathan may get a head start on Positive Pay page changes to bring them more in line with core while Drew is out — will share/review with Drew if he does.

## Action Items

- [ ] Drew: digest core toolkit codebase + CSAC project reference (after vacation).
- [ ] Drew: create ORDA repository.
- [ ] Nathan: set up Monday board for ORDA.
- [ ] Nathan: distill bank file documentation for Drew.
- [ ] Nathan: (maybe) start aligning Positive Pay pages with core, share with Drew if done.
