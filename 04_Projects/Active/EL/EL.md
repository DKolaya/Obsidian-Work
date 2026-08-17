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

- Engagement Letter work is active.
- Reusable editor component (how it works, how to embed it on a new page): [[06_Resources/Architecture/EL TipTap Editor Component|EL TipTap Editor Component]].
- Audit trail + permissions implementation plan: archived, [[90_Archive/Repo Planning/CDH_EL/2026-08-06/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]] (2026-07-13 — Audit.NET entity log + policy-based auth bridging the existing enum permission model; Phases 1-3 done, only optional/deferred items remain).
- Dynamic per-module permission actions plan: [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] (2026-08-04 — dev-declared action sets per module with label overrides, grant-time dependency auto-assignment, All/None editor QOL; supersedes the docs-only design note `0bb2d74`).
- Deferred editor/template work includes production export, DOCX fidelity, review/comment workflow, version/diff UX, and package-specific document flow.
- SharePoint export plan set (2026-08-12) — four plans, one branch/PR each, all `Drew/Sprint4/*` off `develop`; ordering and dependencies in [[04_Projects/Active/EL/EL Index|EL Index]]:
    - [[04_Projects/Active/EL/EL Document Approval Workflow Warplan|EL Document Approval Workflow Warplan]] (P0, prerequisite — `DocumentState` + `ELDocumentApproval` exist but nothing transitions a document, so the export's all-letters-approved gate is unsatisfiable without it).
    - [[04_Projects/Active/EL/EL SharePoint Client Warplan|EL SharePoint Client Warplan]] (P1, no dependencies — Graph client in `Lib`, generic `[GraphField]` mapper, `ELPackageSpListItem` mirror table + migration, SharePoint config).
    - [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|EL SharePoint Export Job Warplan]] (P2, needs P1 — export orchestration + Hangfire infra/job; closes the "Set up Hangfire Jobs for EL" item below).
    - [[04_Projects/Active/EL/EL SharePoint Export UI Warplan|EL SharePoint Export UI Warplan]] (P3, needs P0 + P2 — appends `PackageState.SentToSharePoint`, rewires package approval rules, gated Send button + export status).
- Every note in this folder is catalogued in [[04_Projects/Active/EL/EL Index|EL Index]].
- Day-to-day SharePoint export tasks stay in [[03_Todos/Work TODOs]].

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
- [ ] Check edit without save and then try to preview.
- [ ] switching between versions to fast causes the loading to lock up either disable buttons while loading or maybe async cancellation token being mishandled when async loading is happening

#### Export And Artifacts

- [ ] Wire final PDF export from saved canonical JSON through `ElTiptapGemBoxBodyRenderer`, GemBox body blocks, snapshot furniture/assets/merge values, PDF bytes, and audit metadata.
- [ ] Persist issued export artifacts in `ELDocumentFile` or successor model. — covered by [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]].
- [ ] Add render/audit snapshot persistence for content hash, renderer version, furniture version, asset checksums, artifact hash, and artifact bytes. — partially covered by [[04_Projects/Active/EL/EL SharePoint Export Job Warplan|P2]] (persists `ElDocumentRenderAudit` values onto the exported `ELDocumentFile` rows).
- [ ] Add DOCX export from the shared GemBox `DocumentModel` with `DocxSaveOptions`. — **not** in the SharePoint plan set; export ships PDF-only by decision 2026-08-12.
- [ ] Export issued/final letters to SharePoint. — planned as P0-P3, see [[04_Projects/Active/EL/EL Index|EL Index]].

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

- 2026-08-17 — Repo `CDH_EL`: 1 new commit since last run ("Fixed package approval to track in ELPackageApproval table", `75c66cf`, 08-13), currently on `Drew/Sprint4/SharePoint-Client` with 18 dirty/untracked files (active session work). Both P0 ([[04_Projects/Active/EL/EL Document Approval Workflow Warplan|Document Approval Workflow]]) and P1 ([[04_Projects/Active/EL/EL SharePoint Client Warplan|SharePoint Client]]) warplans now read "functionally done" per their own status lines, but each still has open verification-only checkboxes (manual DB smoke test, browser/console check, one unchecked business-logic question on P0 Task 4) — not a clean 100%-done task list, so left in Active per the vault's fold-and-archive rule rather than auto-archived. Worth a quick confirm-and-archive pass with Drew. Monday EL Tasks: "Export letter to SharePoint" (Drew, In Progress) is the only item changed since 08-13, matching this repo work; audit trail/permissions/notes unchanged.
- 2026-08-13 — Patrick's revised sprint timeline (email to Esther/team, CC Drew, 2026-08-12 18:28): Sprint 3 finishes 08-14, Sprint 4 shortened to 3 weeks (08-17→09-04), October 1 go-live held. **Notifications and SharePoint upload pulled out of Sprint 4 scope** — SharePoint work now targeted for the go-live date itself, starting 09-08 alongside beta testing (letters exported to PDF and saved manually in the interim); notifications deferred to post-go-live entirely. Weekly internal touchpoints proposed 09-10 through go-live. Repo `CDH_EL`: 12 new commits on `develop`/`Nate/Sprint3/Audit-Presentation` since last run, largest theme "WIP Document and Package approval workflow" plus request-changes flow, approval permissions, and workflow UI placement fixes — this is P0 ([[04_Projects/Active/EL/EL Document Approval Workflow Warplan|Document Approval Workflow Warplan]]) work already underway, not yet reflected as such in that plan's own tracking. Worth reconciling P0's plan doc against actual repo state next pass.
- 2026-08-12 — **SharePoint export planned as a four-plan set** (P0-P3, see [[04_Projects/Active/EL/EL Index|EL Index]]), goal being FPA parity: a Send to SharePoint button on an approved package uploads every letter PDF into a per-package SharePoint folder with one list item, mirrored back into SQL. Decisions locked with Drew: **PDF only** (no DOCX path — GemBox is the only final layout engine); package-level **Send to SharePoint** button → new `Sent to SharePoint` state → **Complete Package**, with the existing `ReviewerRequestsChange` trigger for send-back; gate on **all letters approved**; **Hangfire** background job (FPA parity); **new EL list + drive**, names config-driven; **one list item per package** with a **folder per package**, per-letter links on `ELDocumentFile`; reviewer/signer/Intacct values pulled from the FPA record over CDH.Bridge. Recon findings that shaped the split: (a) document approval states exist (`DocumentState`, `ELDocumentApproval`, DbSet) but **nothing transitions them** and `ElPackageDetailService` hard-codes `Draft` at two sites, so P0 is a hard prerequisite; (b) `ELDocumentFile` was already built for this — `sp_id`/`web_url`/`file_path`/`bytes`/`checksum` columns with zero writers — so no attachment table is needed; (c) merge-field values are assembled inside `ElPackageWorkspace.razor:401` and populate only `client.name` + `service.line`, which is both unreachable from a background job and insufficient for a client-facing artifact — P2 moves it into `Lib` and opens a fail-vs-warn decision gate; (d) `FpaDetailDto` on `CDH_Bridge_SDK` **`origin/develop`** (its `master` is README-only) exposes `CustomerId`, `CustomerName`, `Contact.ContactName`/`.Email`, `RelationshipManager.Email`, `Partner.Email` — every value the list item needs. Non-code prerequisites now blocking the enabled path: the EL list + library must be created and their internal column names captured; a Graph app registration granted `Sites.Selected` (+ site grant) or `Sites.ReadWrite.All` with admin consent; the client secret placed in `appsettings.Development.local.json` (**not** the git-tracked `appsettings.Development.json`); `CdhBridgeApis:Fpa` BaseUrl/ApiKey configured; SQL rights for Hangfire's `Job` schema; and a spot-check that Intacct employee emails match the SharePoint site's User Information List (FPA feeds it an app `username`, Bridge hands us Intacct `Email`). Separately flagged: CDH_FPA's committed `appsettings.json` carries its Graph client secret in cleartext — worth rotating with whoever owns that registration. Also created [[04_Projects/Active/EL/EL Index|EL Index]], which this folder required from the moment it held two notes.
- 2026-08-11 — PR [CDH_EL#10](https://github.com/CDHTS/CDH_EL/pull/10) ("Audit and permission system") **MERGED** 2026-08-10 — the CONFLICTING/needs-rebase status tracked across the last several syncs is resolved. Repo `CDH_EL`: 10 commits landed 2026-08-10, but only one is Drew's — a merge of `Drew/Sprint4/PermissionCatalogDesignNote` into `Drew/Sprint3/Audit` (`5d8c64b`); the other 9 are Shannon Thai's separate EL-list/KPI-card/package-tab UI work, unrelated to the audit/permissions line. Currently on `Drew/Sprint3/Audit`, tree clean. [[04_Projects/Active/EL Dynamic Permission Actions Warplan]] (the follow-on plan) is still all-unchecked/not-started — no implementation activity yet, not stale enough to flag (authored 2026-08-04, within the 10-day window). [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan]] moved into `04_Projects/Active/EL/` subfolder 2026-08-11 (kept flat-file placement was fine per rule, but moved for clarity — no rule violation, just tidiness). Monday.com EL Tasks: no item changes since 08-06 (Drew's three open items — audit trail, permissions, notes — unchanged).
- 2026-08-06 — Archived [[90_Archive/Repo Planning/CDH_EL/2026-08-06/EL Audit and Permissions Warplan|EL Audit and Permissions Warplan]] — Phases 1-3 done and committed (confirmed 2026-08-04 entry below); only Task 3.6 (optional caching) and Phase 4-5 (deferred, gated on future work) remain, neither blocking. Folded out of Active per vault rule (one main note + only genuinely in-progress sub-plans) — [[04_Projects/Active/EL/EL Dynamic Permission Actions Warplan|EL Dynamic Permission Actions Warplan]] stays the only other active EL sub-note.
- 2026-08-06 — repo `CDH_EL`: 3 new commits since yesterday — "Fixed editor header on EL revision comparison to align with draft editor" (`57b0158`), "Permission redesign" (`318ba91`), and a merge of `Drew/Sprint4/PermissionCatalogDesignNote` into `Drew/Sprint3/Audit` (`3f2a438`). Tree now clean (the `PermissionMatrixEditor.razor` WIP from yesterday landed). PR [CDH_EL#10](https://github.com/CDHTS/CDH_EL/pull/10) got a new comment from Drew today summarizing the shipped work (user creation from frontend, combined user-edit/permissions screen, non-matrix per-module permission catalog, audit-log permission access) — still CONFLICTING, needs rebase. Monday.com EL Tasks: two of Shannon's items ("Create screens for generating ELs from FPAs", "Set up Service maintenance screen to allow users to mark eligible for combo") moved to Waiting for review 08-05; Drew's own three open items (audit trail, permissions, notes) unchanged, added to [[03_Todos/Work TODOs]] Monday.com section (were missing from the tracked list).
- 2026-08-05 — repo `CDH_EL`: rest of yesterday's work landed after the last sync — Add User admin page (with permission assignment), User Maintenance name-edit screen combined into one, and the dynamic per-module permission-action catalog itself (`5f3da45`), plus audit-log nav-gating fix, test coverage, and an EF-model-snapshot cleanup (`a126012`), all still 2026-08-04 timestamps. Currently on `Drew/Sprint4/PermissionCatalogDesignNote` (HEAD `a126012`), 1 dirty file (`PermissionMatrixEditor.razor` — likely the All/None + per-module-card UI work from [[04_Projects/Active/EL Dynamic Permission Actions Warplan]]). No commits since. Monday.com EL Tasks: no item changes since 08-04. PR [CDH_EL#10](https://github.com/CDHTS/CDH_EL/pull/10) unchanged, still CONFLICTING (this branch isn't part of that PR).
- 2026-08-04 — repo `CDH_EL`: heavy activity — 7 commits since yesterday on `Drew/Sprint3/Audit` and three new sub-branches (`Drew/Sprint4/AddUser`, `Drew/Sprint4/EditUser`, `Drew/Sprint4/AuditLogPermission`, `Drew/Sprint4/PermissionCatalogDesignNote`), merged back into `Drew/Sprint3/Audit`. Covers: Add User admin page, editable first/last name on User Maintenance, Audit Log page gated behind its own permission module (+ migration granting existing ELAdmins that module), a permission-catalog design note (docs only), and a Down-migration JSON-rebuild fix. Currently checked out on `Drew/Sprint4/AddUser`, tree clean. Full detail in [[04_Projects/Active/EL Audit and Permissions Warplan]]. Monday.com EL Tasks board: no item changes since 08-03. PR [CDH_EL#10](https://github.com/CDHTS/CDH_EL/pull/10) got a new commit today but is still CONFLICTING — needs a rebase.
- 2026-08-03 — Monday EL Tasks: "Implement audit trail" moved In Progress → Waiting for review, matching PR [CDH_EL#10](https://github.com/CDHTS/CDH_EL/pull/10) being opened; "Implement notes" and "Implement application permissions" unchanged, still In Progress. Repo `CDH_EL`: no new commits since 2026-07-22, tree clean. PR #10 still CONFLICTING, needs rebase.
- 2026-07-21 — Archived [[90_Archive/Repo Planning/CDH_EL/2026-07-13/EL Editor Feedback Hardening Spec|EL Editor Feedback Hardening Spec]] and its companion [[90_Archive/Repo Planning/CDH_EL/2026-07-13/EL Editor Wargames 2026-07-13|EL Editor Wargames 2026-07-13]] — both fully done (all T1-T3 tasks closed 2026-07-13: spacing parity, forced page break, draft-only compare editing all shipped and wargamed). Folded out of Active to cut down EL note sprawl; Warplan stays the only other active EL sub-note since Phase 3 is still uncommitted. (Warplan link paths above updated 2026-08-11 after its move to `04_Projects/Active/EL/`.)
- 2026-07-09 — Sprint 2 EL app demo + UAT walkthrough given to admin/stakeholder group; feedback captured in [[07_Meetings/2026-07-09 TS Internal Projects Touch Point|meeting note]] and folded into backlog above. UAT feedback due back 2026-07-17.
- 2026-07-10 — repo `CDH_EL`: 1 commit ("TipTap and Gembox line spacing fix") on `Sprint2/deployment-prep`, 16 uncommitted files. UAT round 1 questionnaire sent by Shannon Thai. [[07_Meetings/2026-07-10 EL Repo-Branching Review|EL Repo/Branching Review]] meeting today.
- 2026-07-13 — repo `CDH_EL`: now on `develop` branch (switched from cleanup branch), working tree clean, but a "Pre-develop fix stash" exists — verify no work was lost in the branch switch.
- 2026-07-14 — repo `CDH_EL`: back on `feature/June/30/RTE-TipTap-cleanup`, 41 uncommitted files, WIP commit `37a1927` "Pre-develop fix WIP" (2026-07-13) on the branch — working tree not clean, worth checking nothing's stuck mid-edit.

## Links

- [[04_Projects/Active/EL/EL Index|EL Index]]
- [[03_Todos/Work TODOs]]
- [[05_Areas/Development/Development Index]]
