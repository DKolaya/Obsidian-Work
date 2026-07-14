# Sprint 1 Repo Eval

Purpose: partial end-of-sprint repo eval. Not full audit. Shows done vs placeholder vs refine/missing.

## Done

- Blazor/HAVIT demo shell exists.
- Landing routes: `/`, `/landing`.
- Workspace route: `/dashboard`.
- Shared top nav: FPA Search, Engagement Letters, Administration.
- Landing has `Your queue`, `By Status`, `Needs Attention`, `Activity`.
- Workspace has KPI cards, status tabs, search, filters, saved views UI, grid.
- Landing status links deep-link to dashboard query filters.
- Dashboard search/filter works against seeded rows.
- Greeting resolves display name through user admin service.
- Landing/dashboard use permission gates.
- EL schema foundation exists: binders, docs, templates, service maps, snapshots, revisions, files, approvals.

## Placeholder

- Landing lists are hardcoded: `MyQueue`, `LandingRows`, `AttentionItems`, `ActivityItems`.
- Dashboard rows hardcoded in `Rows`.
- Many buttons disabled/no-op: queue actions, resolve/open attention, full activity, export, browse templates, new package, save view, open, row menu, sync FPA, generate drafts, assign owner.
- Search/filter only query seeded data.
- Saved views not persisted.
- Activity feed static, not audit/notification-backed.
- Needs Attention static, not validation/rules-backed.
- Counts/KPIs from seeded rows.
- `FPA-26-xxxxx` still demo identifier unless later confirmed.

## Needs Refinement

- Pick real data source for landing/workspace/attention/activity.
- Align UI states with `BinderState` / `DocumentState`.
- Persist and apply queue preferences.
- Implement validation blockers: missing templates, unmapped services, FPA/EL desync.
- Implement package creation rules and required-letter determination.
- Wire dashboard actions to real pages/services.
- Build template browse/admin flow.
- Persist saved views per user.
- Define activity feed source and audit semantics.
- Decide landing default-home behavior.

## Missing

- FPA completed/closed trigger for EL creation.
- SharePoint/FPA sync or ingestion workflow.
- Nightly import/system sync service.
- Rules engine for unmapped/out-of-sync conditions.
- EL package detail/editor page.
- Template browse/admin page.
- Full activity page.
- Client finder workflow.
- Saved-view persistence.
- Services for draft generation, sync FPA, owner assignment, package open, blocker resolution.

## Next Slice

Make one real vertical path: create/read real `ELBinder` records from completed FPA data, show them in workspace, derive counts from DB, wire `Open` to package detail. Then add template validation and real `Needs Attention` blockers.
