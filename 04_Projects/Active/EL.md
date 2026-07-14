---
title: EL
created: 2026-07-08
type: project
source: [[90_Archive/OneNote Raw/Drew @ Work]]
tags:
  - project/el
  - area/development
---

# EL

## Notes

- Active editor wargames: [[04_Projects/Active/EL Editor Wargames 2026-07-13|EL Editor Wargames 2026-07-13]].
- Engagement Letter work is active.
- Audit trail + permissions implementation plan: [[04_Projects/Active/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]] (2026-07-13 — Audit.NET entity log + policy-based auth bridging the existing enum permission model).
- Deferred editor/template work includes production export, DOCX fidelity, review/comment workflow, version/diff UX, and package-specific document flow.
- SharePoint export is tracked in [[03_Todos/Work TODOs]].

## Tasks

### Editor Backlog From Repo Docs

Source repo docs checked 2026-07-09:
- `docs/reference/tiptap-editor-guide.md`
- `docs/reference/docx-import-disconnect-handoff.md`
- `docs/reference/direct-tiptap-json-gembox-render-plan.md`
- `docs/reference/plans/CLEANUP-TODO.md`
- `docs/reference/plans/UAT-PREP-PLAN.md`
- `Lib/Models/EL/ELBinder.cs`

#### Near-Term

- [ ] Replace standalone `/editor` sample document metadata and demo merge values with server-backed template/document/package data.
- [ ] Add forced page break support to the editor.
- [ ] Expose richer page-flow diagnostics in the editor debug area, especially break positions and first break offsets.
- [ ] Manually verify real large pasted templates in browser for visual selection, scrolling, page breaks, and continuation furniture behavior.
- [ ] Retest latest DOCX import preflight build with the failing DOCX.
- [ ] If DOCX import still kills the process, capture server-side logs around upload endpoint, preflight, and `DocumentModel.Load`.
- [ ] Add `pnpm test:tiptap` coverage for keyboard shortcuts, floating-menu positioning, and list-toggle behavior.

#### Export And Artifacts

- [ ] Wire final PDF export from saved canonical JSON through `ElTiptapGemBoxBodyRenderer`, GemBox body blocks, snapshot furniture/assets/merge values, PDF bytes, and audit metadata.
- [ ] Persist issued export artifacts in `ELDocumentFile` or successor model.
- [ ] Add render/audit snapshot persistence for content hash, renderer version, furniture version, asset checksums, artifact hash, and artifact bytes.
- [ ] Add DOCX export from the shared GemBox `DocumentModel` with `DocxSaveOptions`.
- [ ] Export issued/final letters to SharePoint.

#### DOCX Import Fidelity

- [ ] Preserve or map Word named styles: `BodyText`, `NormalText`, `Heading1`, and `Heading2`.
- [ ] Validate DOCX numbering style/import mapping for supported lists.
- [ ] Handle tab-stop based rows or convert them into stable editor structures.
- [ ] Add support or explicit conversion policy for small caps.
- [ ] Add DOCX import analysis report for unsupported or lossy features.
- [ ] Map known Word `DOCVARIABLE` fields and known `{{ Field }}` tokens to `elMergeField`; warn on unknown DOCVARIABLE fields.
- [ ] Convert code-style content to normal text and report non-blocking import finding.
- [ ] If GemBox import remains unstable, implement minimal pure OpenXML body importer and keep GemBox for PDF/export only.

#### Template And Document Flow

- [ ] Add real issued-document/package editor route/load/save when package-specific revisions are needed beyond template editing.
- [ ] For future issued-document editor, load latest `ELDocumentRevision`, save draft revisions through `IElDocumentRevisionService`, and gate Preview/Save by document context and permissions.
- [ ] Decide merge-token UI follow-up scope, including token/resolved display toggle.
- [ ] Keep standalone `/editor` as scratch/import preview unless a document/package route is explicitly added.

#### Review And History

- [ ] Add comment/note model with anchored ranges, author, initials, timestamp, body, and resolved state.
- [ ] Add comment/note UI with markers, side pane, add/edit/resolve flows, and imported Word reviewer-note support.
- [ ] Add edit/review permissions and dirty state.
- [ ] Add version history and node-level diff viewer from canonical JSON.

#### Cleanup And UAT Branch Work

- [ ] Finish remaining cleanup branch pass only after re-grepping symbols against current code.
- [ ] Add draft-editor unsaved-change confirmation before leaving a modified draft template section.
- [ ] Decide whether the UAT branch should use a new branch name or the existing `Sprint2/UAT` branch.
- [ ] If cutting a lean UAT branch, keep Template pages, Admin user-management pages, permission model/services, embedded editor, and template PDF preview.
- [ ] If cutting a lean UAT branch, remove or disable non-UAT pages/routes only on that UAT branch.
- [ ] Disable deleted-route nav entries in place so menu shape stays familiar for testers.
- [ ] Before any big-file split, review each candidate file separately with responsibilities, proposed split, files created/moved, and regression risk.
- [ ] Post-UAT: decide whether unknown-user full-access bootstrap remains or changes to explicit admin invite/empty permissions.
- [ ] Post-UAT: decide whether auto-provision-on-login remains as permanent onboarding.
- [ ] Decide final brand-asset storage/cache approach: DB blob plus cache vs filesystem.

#### Data Model Follow-Ups

- [ ] Review `ELBinder.sourceHash` storage policy: source identity meaning, max length, hash algorithm, and whether `nvarchar(100)` remains correct.

#### Sprint 3 Touchpoint Feedback (from 2026-07-09 meeting)

Source: [[07_Meetings/2026-07-09 TS Internal Projects Touch Point|TS Internal Projects Touch Point]] — admin/stakeholder demo + feedback. Tracked in Monday under Sprint 3's feedback bucket ("Implement suggested changes based on user feedback"), not Sprint 2's — Sprint 2 was already deployed/closed by the time this feedback came in.

- [ ] Allow editing directly inside the version-compare/side-by-side view (both panes are currently read-only). — Drew
- [ ] Add a double-page/side-by-side view inside the single-version editor itself, not just the dedicated compare tab. — Drew
- [ ] Track-changes/diff view for version comparison, so testers don't have to manually toggle full versions to spot edits.
- [ ] Resolve "binder" naming collision with "engagement binder" — candidates: EL package, letter package, bundle, or reverting to "package."
- [ ] Reviewer-edit workflow decision: let reviewer edit draft directly vs. bounce back to draft stage.
- [ ] Delete-vs-inactivate policy for approved/locked template versions.
- [ ] Compile full merge-field/doc-variable list (down to first/last/full name granularity) — Drew has FPA-side fields, Esther compiling admin asks.

## Status Log

- 2026-07-09 — Sprint 2 EL app demo + UAT walkthrough given to admin/stakeholder group; feedback captured in [[07_Meetings/2026-07-09 TS Internal Projects Touch Point|meeting note]] and folded into backlog above. UAT feedback due back 2026-07-17.
- 2026-07-10 — repo `CDH_EL`: 1 commit ("TipTap and Gembox line spacing fix") on `Sprint2/deployment-prep`, 16 uncommitted files. UAT round 1 questionnaire sent by Shannon Thai. [[07_Meetings/2026-07-10 EL Repo-Branching Review|EL Repo/Branching Review]] meeting today.
- 2026-07-13 — repo `CDH_EL`: now on `develop` branch (switched from cleanup branch), working tree clean, but a "Pre-develop fix stash" exists — verify no work was lost in the branch switch.
- 2026-07-14 — repo `CDH_EL`: back on `feature/June/30/RTE-TipTap-cleanup`, 41 uncommitted files, WIP commit `37a1927` "Pre-develop fix WIP" (2026-07-13) on the branch — working tree not clean, worth checking nothing's stuck mid-edit.

## Links

- [[03_Todos/Work TODOs]]
- [[05_Areas/Development/Development Index]]
