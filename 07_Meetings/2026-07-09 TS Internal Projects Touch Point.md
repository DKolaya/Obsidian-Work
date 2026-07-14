---
title: TS Internal Projects Touch Point
created: 2026-07-09
type: meeting
tags:
  - project/el
  - work
---
# Meeting - 2026-07-09

Time: ~20:01–20:46 UTC. Organizer: Esther Carreno. Source: [[90_Archive/OneNote Raw/Drew @ Work|meeting transcript]] (auto-transcribed).

## Attendees

- Esther Carreno
- Patrick Della Rocca (pdrocca@cdhts.com)
- Shannon Thai (sthai@cdhts.com)
- Nathan Sawyer (nsawyer@cdhts.com)
- Drew Kolaya (dkolaya@cdhts.com)
- Bernie Lietz
- Phillip Lampugnano
- Alisha Ahmed
- Dan Duncan

## Agenda

- EL mapping/tagging follow-up (assurance combos)
- EL review cadence for existing docs (yearly, governed by external bodies)
- Sprint 2 EL app demo + UAT walkthrough (Shannon)
- Sprint 3 preview
- SharePoint export for letters (signature piece)
- FPA app status, catalog survey
- Billing app status
- Reporting app status
- Next steps / scheduling

## Notes

- EL service/template mapping: some assurance combos still need Emily's review; Alisha/Yukako/Bernie already gave feedback. Open design question — tag-and-combo picker vs. process-of-elimination matching.
- ELs are reviewed **yearly**, generally toward calendar year-end; timing tied to governing-body language, not a fixed date.
- **Sprint 2 EL app demo** (Shannon Thai) — deployed to beta server (same host as project reporting/billing apps):
  - Template Finder: search-by-service and search-by-template screens. By-service uses mock FPA data (not yet wired to live FPA app).
  - Template detail screen: version/effective dates, document category, default binder order, linked FPA services, read-only template viewer with merge-field placeholders (blue brackets), PDF preview.
  - New Draft flow: creates version N+1, unlocks full text editor (undo/redo, bold/italic/underline, lists, headings).
  - Compare feature: toggle-in-place or side-by-side tab (max 2 versions selected at once); both sides currently read-only.
  - Submit/approval: all testers currently have full approval access for UAT purposes; approved versions lock and cannot be edited or deleted yet.
  - UAT questionnaire: Microsoft Forms, now requires login (saves progress across sessions). Admin team asked to do the detailed walkthrough; others can pick overview or detailed.
- **Terminology concern (Bernie, Alisha):** "binder" collides with the existing "engagement binder" term and reads as confusing to engagement users. Alternatives raised: EL package, letter package, bundle (Nathan), or reverting to "package" (the original term, per Drew).
- **Workflow open questions (Esther):**
  - Should a reviewer be able to make a quick edit directly instead of bouncing the draft back? Not yet mapped — options include letting the reviewer flip it to draft themselves, or a dedicated reviewer-edit stage. Sprint 3 discussion (Patrick: avoid a laborious back-and-forth).
  - Can an approved/locked version be deleted after the fact if an error is found post-approval? Not currently possible. Options being considered: inactivate (keep history) vs. hard delete if never used in a client EL. Sprint 3 discussion.
- **Doc variables (Drew):** current set is minimal (client name, date). Requesting a complete list of merge fields, ideally down to granular splits (first name / last name / full name). Drew is compiling from the FPA side; Esther will compile any admin-side asks into one list.
- **Sprint 3 scope (Patrick):** FPA↔EL data wiring, approval workflows (templates + letters), continued editor work (track changes, SharePoint export).
- **SharePoint export (Esther/Nathan):** plan to reuse the FPA export framework as-is; Esther sees no needed improvements based on FPA's low failure rate (failures are almost always bad client email addresses, not app errors). Open question: group multiple letters requiring signature into one item vs. individual items.
- UAT turnaround: requested back by **2026-07-17** (Wed) so results can be discussed the following Monday, ahead of the 2026-07-23 call.
- **Billing app bug (Dan Duncan):** client CCI 1984 and Phil's client "Custom Cylinders" (same underlying company, renamed after a sale) both show up with identical values in the Billing app. No billing run against them yet. Shannon to investigate — likely a name/ID matching issue (uses a combination of customer name + ID).
- Billing: inactive-project access opened up for managers doing analysis; no other open items.
- Reporting app: no updates this cycle.
- FPA app: running well, no reported app errors; catalog survey going out (managers+ and admin), ~2-week response window.
- Next touchpoint: **2026-07-23**, same time.

## Decisions

- None finalized — binder naming, reviewer-edit workflow, and delete-vs-inactivate for approved versions are all open, deferred to Sprint 3 discussion.

## Action Items

- [ ] Allow editing directly inside the version-compare/side-by-side view (currently both panes are read-only). — Drew Kolaya
- [ ] Add a double-page/side-by-side view inside the single-version editor itself (not just the dedicated compare tab). — Drew Kolaya
- [ ] Track-changes/diff view for version comparison (avoid manual toggling between full versions) — already slated for a future sprint per Shannon.
- [ ] Decide reviewer-edit workflow (direct edit vs. bounce to draft) — Sprint 3.
- [ ] Decide delete vs. inactivate policy for approved/locked template versions — Sprint 3.
- [ ] Resolve "binder" naming (candidates: EL package / letter package / bundle / package) with Bernie/Nathan/Drew input.
- [ ] Compile complete merge-field/doc-variable list — Drew (FPA-side fields) + Esther (admin asks).
- [ ] Investigate Billing app duplicate-client display for CCI 1984 / Custom Cylinders — Shannon Thai.
- [ ] Return EL UAT feedback by 2026-07-17.
- [ ] Emily to re-review remaining assurance-combo mapping tweaks.

## Links

- [[04_Projects/Active/EL]]
- [[03_Todos/Work TODOs]]
