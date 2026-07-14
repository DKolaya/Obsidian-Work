# End Of Sprint 1 Repo Evaluation

This note summarizes the current Engagement Letter repo state at the end of Sprint 1. It is not a full system audit. Its purpose is to separate what has been accomplished from what is still placeholder/demo-only work and what needs more refinement before the app can be treated as production workflow.

The evaluation is based on the Sprint 1 transcript goals, the presentation screenshots, and the current repo implementation in `CDH_EL/Components/Pages/Landing.razor`, `CDH_EL/Components/Pages/Dashboard.razor`, `CDH_EL/Components/Layout/AppShell.razor`, and the current EL model/migration layer under `Lib/Models/EL` and `Lib/DAL/ELContext.cs`.

## Accomplished

- The Sprint 1 demo shell exists in Blazor/HAVIT.
- The landing page is implemented at `/` and `/landing`.
- The engagement letter workspace is implemented at `/dashboard`.
- The shared top navigation visually connects FPA Search, Engagement Letters, and Administration.
- The landing page includes the four transcript sections: `Your queue`, `By Status`, `Needs Attention`, and `Activity`.
- The workspace includes KPI/status cards, status tabs, search, filter chips, saved-view controls, and a grid matching the screenshot direction.
- The landing `By Status` rows link into the workspace with dashboard query parameters, so clicking status labels can preselect the related dashboard view.
- Dashboard search and filters work against the seeded demo rows.
- The landing greeting resolves the current user's display name through the user administration service instead of only using the raw claim.
- Permission gating is present around the landing and dashboard surfaces.
- Core database entities and migrations exist for EL binders, documents, templates, service maps, source snapshots, revisions, generated files, and approvals.

## Placeholder Or Demo-Only Work

- Landing data is hardcoded in component lists such as `MyQueue`, `LandingRows`, `AttentionItems`, and `ActivityItems`.
- Dashboard data is hardcoded in the component-level `Rows` list.
- Many visible actions are disabled or no-op placeholders, including queue row actions, attention actions, full activity, export, browse templates, new EL package, save view, open package, row menu, sync FPA, generate drafts, and assign owner.
- The search and filters are useful for the demo, but they do not query real EL, FPA, client, partner, project manager, or owner records yet.
- Saved views are present visually, but they are not persisted.
- The Activity panel is a static feed, not an audit log, notification feed, or FPA notification integration.
- Needs Attention shows useful examples, but it is not backed by validation or rules services.
- Status counts and KPI cards are derived from seeded rows, not database state.
- The current `FPA-26-xxxxx` numbering is still demo/sample text unless the production identifier convention is later confirmed.

## Needs More Refinement

- Define and implement the production source of truth for landing queue items, dashboard rows, status counts, attention items, and activity feed entries.
- Align UI workflow states with `BinderState` and `DocumentState`. The demo uses labels such as `Ready to Draft`, `In Review`, `Changes Requested`, `Blockers`, and `Finalized`, while the current enums are more foundational and do not fully express the screenshot taxonomy.
- Decide how user queue preferences should be stored and applied. `UserPreference` exists, but queue personalization is not wired to persisted settings.
- Build real validation/blocker logic for missing templates, unmapped services, FPA/EL desync, and other conditions that should appear under `Needs Attention`.
- Build the EL package creation workflow, including who can create a package, when creation is allowed, and how required letters are determined.
- Wire dashboard actions to real pages and services. The UI already communicates expected workflows, but the commands need implementation.
- Define the final template management experience behind `Browse Templates`, including template storage, versioning, effective dates, and assignment to service maps.
- Decide how saved views should persist per user and which settings they should include, such as tab, filters, search text, sort, and ownership scope.
- Clarify how activity should relate to FPA notifications, system sync events, user actions, approvals, and audit history.
- Clarify whether the landing page should remain a presentation dashboard, become the user's default home page, or be selected from a user preference.

## Not Yet Done

- No production FPA completion/closed trigger was found that creates or exposes EL work.
- No production SharePoint or FPA ingestion/sync workflow was found.
- No nightly import job or system sync service was found.
- No rules engine implementation was found for conditions shown in the demo, such as unmapped services or out-of-sync billing schedules.
- No real EL detail/editor page was found for opening packages.
- No template browse/admin page was found for the dashboard action.
- No full activity page was found for the landing activity button.
- No client finder workflow was found for the landing `Find a client` button.
- No persisted saved-view workflow was found.
- No production workflow service was found for draft generation, FPA sync, owner assignment, package opening, or blocker resolution.

## Suggested Next Focus

The repo is in a good Sprint 1 state for demonstrating direction and collecting feedback. The next sprint should separate presentation UI from production workflow by adding service-backed data providers and choosing one thin vertical slice to make real end-to-end.

A practical next slice would be: create/read real EL binder records from completed FPA data, show them in the workspace, calculate the same status counts from real data, and wire `Open` to a package detail page. After that, add template validation and show real missing-template blockers in `Needs Attention`.
