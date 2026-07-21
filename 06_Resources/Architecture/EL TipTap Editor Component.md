---
title: EL TipTap Editor Component
created: 2026-07-21
type: reference
tags:
  - project/el
  - topic/blazor
  - topic/tiptap-editor
---

# EL TipTap Editor Component

How the reusable rich-text editor component works and how to drop it into a new Blazor page. Written for explaining the integration to teammates who haven't touched this component before.

Repo: `CDH_EL`, branch `Drew/Sprint3/Audit` (component itself unchanged on this branch — audit/permissions work only).

## Component identity

- **File:** `CDH_EL/Components/Shared/ElTiptapEditor.razor`
- **Scoped styles:** `CDH_EL/Components/Shared/ElTiptapEditor.razor.css`
- **Current consumers:** `Components/Pages/Template/TemplateDetail.razor`, `TemplateCompare.razor`, `TemplateComparePane.razor`, and the standalone `/editor` route (`Components/Pages/Editor.razor`).
- **Deeper architecture/schema doc (repo):** `docs/reference/tiptap-editor-guide.md` (compressed) / `tiptap-editor-guide.original.md` (full prose). This vault note focuses on *using* the component; that repo doc covers schema policy, persistence rules, and installed Tiptap extensions in depth.

## Why it's a "drop-in" component

Two things that normally require host-page setup are handled internally:

1. **JavaScript loading.** The component imports its own JS module inside `OnAfterRenderAsync`:
   ```csharp
   module = await JS.InvokeAsync<IJSObjectReference>(
       "import",
       new Uri(new Uri(Navigation.BaseUri), $"js/dist/tiptapEditor.bundle.js?v={TiptapBundleVersion}").ToString());
   ```
   It resolves the bundle URL off `NavigationManager.BaseUri`, so it works whether the app is hosted at `/` or under a subfolder (`AppBasePath="/EL"`). No `<script>` tag needed anywhere in `App.razor` / `_Host`.

2. **Styling.** `ElTiptapEditor.razor.css` is a Blazor CSS-isolation file — the compiler auto-scopes it to the component and injects the `<link>` at build time. Nothing to import on the consuming page.

Net effect: a page that wants the editor just references the `<ElTiptapEditor />` tag. No wiring beyond that for the basic case.

## Data flow (high level)

```text
Blazor page renders <ElTiptapEditor />
        ↓
Component's OnAfterRenderAsync dynamically imports tiptapEditor.bundle.js
        ↓
JS creates a Tiptap instance bound to a generated element id (createEditor)
        ↓
Every keystroke/selection change → JS pushes a payload back via [JSInvokable] OnTiptapUpdated
        ↓
Component stores it as CurrentValue, raises OnUpdated to the host page
        ↓
Host page reads CurrentValue / payload.Json (or calls GetCurrentJsonAsync()) to persist
```

The component itself never saves anything — persistence is entirely the host page's job (see "Saving" below). The full validation/canonicalization/EF-storage pipeline that happens once JSON reaches the server lives in `Lib.Services.Editor` and is documented in the repo's `tiptap-schema-policy.md` — out of scope for this note.

## Parameters

| Parameter                                           | Type                                  | Purpose                                                                                                                        |
| --------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `InitialHtml`                                       | `string?`                             | Seed content as HTML (used when no JSON exists yet).                                                                           |
| `InitialEditorJson`                                 | `string?`                             | Seed content as canonical Tiptap JSON — preferred over HTML once a document has been through the schema pipeline.              |
| `IsReadOnly`                                        | `bool`                                | Collapses the toolbar to view-only controls (TOC, zoom, formatting marks). No edit commands.                                   |
| `PageFlowEnabled`                                   | `bool`                                | Turns on paginated "letter page" rendering with header/footer furniture and page-break tracking. Off = plain scrolling editor. |
| `FirstPageHeaderHtml` / `FirstPageFooterHtml`       | `string?`                             | Furniture HTML for page 1. Only meaningful with `PageFlowEnabled`.                                                             |
| `ContinuationHeaderHtml` / `ContinuationFooterHtml` | `string?`                             | Furniture HTML for page 2+.                                                                                                    |
| `MergeFields`                                       | `IReadOnlyList<TiptapMergeFieldItem>` | Catalog of insertable `{{ field }}` tokens. Optional — defaults empty.                                                         |
| `OnUpdated`                                         | `EventCallback<TiptapUpdatePayload>`  | Fires on every editor change (typing, formatting, undo/redo).                                                                  |
| `ToolbarStartContent` / `ToolbarEndContent`         | `RenderFragment?`                     | Slots to inject extra buttons (e.g. a page-specific Save button) into the toolbar without touching the component.              |

## Public methods (require `@ref`)

| Method | Purpose |
|---|---|
| `GetCurrentJsonAsync()` | Pulls the live document as a JSON string — call this on Save. |
| `SetContentJsonAsync(string editorJson)` | Replaces editor content with server-validated canonical JSON (e.g. after DOCX import). |
| `UpdatePaginationConfigAsync(...)` | Swaps header/footer furniture HTML without recreating the editor instance. |
| `InsertMergeFieldAsync(fieldKey, label, required)` | Programmatically inserts a merge-field token at the cursor. |

## Minimum integration example

```razor
<ElTiptapEditor @ref="editorRef"
                 InitialEditorJson="@myTiptapJson"
                 OnUpdated="HandleEditorUpdatedAsync" />

@code {
    private ElTiptapEditor? editorRef;

    private Task HandleEditorUpdatedAsync(ElTiptapEditor.TiptapUpdatePayload payload)
    {
        // payload.Html / payload.Json / payload.Text — updates on every edit
        return Task.CompletedTask;
    }

    private async Task SaveAsync()
    {
        var json = await editorRef!.GetCurrentJsonAsync();
        // send json to a Lib service for validation + persistence
    }
}
```

Three steps: place the tag, seed content, read content back out (via `OnUpdated` for live state or `GetCurrentJsonAsync()` on demand, e.g. a Save click).

## Gotchas

- **`@key` when swapping documents.** If the same page reuses the editor for a different document/section (e.g. switching template versions), set `@key="someIdentifier"`. Without it, Blazor reuses the existing editor DOM/instance and shows stale content. Real example: `TemplateDetail.razor` uses `@key="PrimarySection.id"` / `@key="readOnlyEditorKey"`.
- **Saving is manual.** Nothing auto-persists. Wire a save button (often via `ToolbarEndContent`) that calls `GetCurrentJsonAsync()` and hands the JSON to a `Lib` service.
- **Browser HTML is not authoritative.** `payload.Html` is fine for instant preview but must never be treated as the thing that gets persisted or exported — canonical JSON is the source of truth, validated server-side. (This rule is repo-wide, from `tiptap-editor-guide.md`.)
- **Merge fields need a DI'd catalog.** Only wire `MergeFields` if the page needs token insertion — inject `Lib.Services.Editor.ElMergeFieldCatalog` and project with `ElTiptapMergeFieldUi.ProjectItems(catalog.GetAll())`.
- **Page-flow furniture params travel together.** Setting `PageFlowEnabled="true"` without the four header/footer HTML params still works, just with blank furniture — not an error, but usually not what you want for a real letter document.
- **Changing the JS bundle requires the Node/pnpm toolchain.** The committed `wwwroot/js/dist/tiptapEditor.bundle.js` means most teammates never need Node just to run the app — only editor *behavior* changes (new Tiptap extension, new toolbar command) require `pnpm run build:tiptap`. See repo doc for the full build/watch setup.

## Where to go deeper

- Full schema, extension list, DOCX import behavior, persistence pipeline: `docs/reference/tiptap-editor-guide.md` (repo).
- Schema validation/versioning rules: `docs/reference/tiptap-schema-policy.md` (repo).
- Editor backlog / open work items: [[04_Projects/Active/EL|EL project note]].
