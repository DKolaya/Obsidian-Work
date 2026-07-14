# Tiptap Editor Guide

## Purpose
This guide documents the Tiptap-only editor direction for the engagement letter application. The current live Blazor editor route is `/editor`. It is a product-style RTE workspace, not an editor comparison page.

The current editor UI has a non-persistent PDF Preview wired from the current unsaved Tiptap JSON. Save draft remains disabled, so the page is not a production save surface yet. The backend now has strict schema validation and EF revision storage primitives for the future save path. Browser payloads are treated as untrusted input, and only validated canonical Tiptap JSON can become the source of truth.

## Architecture
The intended architecture is:

```text
Blazor component renders editor host div
        ↓
JavaScript initializes Tiptap in the browser
        ↓
Tiptap sends JSON, HTML, and text back to Blazor through JS interop
        ↓
Backend validates Tiptap JSON against the EL schema
        ↓
Backend canonicalizes JSON, indexes nodes/fields, and diffs revisions
        ↓
Database stores editor_json plus generated index/diff rows
```

The browser needs JavaScript because Tiptap itself is a browser editor. The backend does not need Node.js at runtime. Backend services live in `Lib.Services.Editor` and reject unknown nodes, marks, attributes, malformed structures, unsafe URLs, and missing required EL attributes before persistence.

Persistence rule:

- `editor_json` is authoritative.
- Revision rows do not persist generated `html_content` or full `plain_text_content`.
- `ELDocumentNodeIndex.text_content` is the search source generated from the validated document.
- `content_hash`, schema versions, node index rows, merge-field usage rows, and diff rows are derived from canonical JSON.
- Do not trust browser-generated HTML for final persistence/export. Use browser HTML for instant preview only; server-generated HTML should be canonical.

## Current Files
The current live editor files are:

- `package.json` at repo root owns JavaScript dependencies and `pnpm` scripts.
- `pnpm-lock.yaml` pins JavaScript dependency versions.
- `vite.config.js` bundles the browser wrapper.
- `CDH_EL/wwwroot/js/tiptapEditor.js` is the source JavaScript wrapper.
- `CDH_EL/wwwroot/js/dist/tiptapEditor.bundle.js` is the built browser bundle.
- `CDH_EL/Components/Shared/ElTiptapEditor.razor` is the reusable Blazor RTE wrapper.
- `CDH_EL/Components/Shared/ElTiptapEditor.razor.css` owns component-specific editor styling.
- `CDH_EL/Components/Pages/Editor.razor` hosts the product-style editor workspace.
- `CDH_EL/Components/Pages/Editor.razor.css` owns workspace styling.
- `CDH_EL/Components/Pages/HeaderFooterDesigner.razor` hosts the global header/footer furniture designer.
- `CDH_EL/Components/Pages/HeaderFooterDesigner.razor.css` owns designer page styling.
- `Lib/Services/Editor` owns strict schema validation, canonicalization, DOCX import, revision save/load, node indexing, merge-field usage extraction, and node-level diffing.
- `Lib/Models/EL/ELDocumentNodeIndex.cs`, `ELDocumentFieldUsage.cs`, and `ELDocumentDiff.cs` persist derived JSON search/diff data.

The Blazor component imports the bundle through JS interop using the current app base URI, so subfolder deploys such as `AppBasePath="/EL"` can still resolve `js/dist/tiptapEditor.bundle.js`.

## Current UI
The standalone `/editor` route has:

- A static document header with sample client, period, template, owner, reviewer, and status metadata.
- A `Header & Footer` link to `/templates/header-footer` for global app-owned furniture design. This is navigation only; page furniture is not imported into Tiptap JSON.
- An `Import DOCX` action that opens a HAVIT modal, accepts one `.docx` file up to 25 MB, runs it through `IElDocxImportService`, shows import findings, and can load validated canonical JSON into the live editor.
- Enabled non-persistent PDF Preview and disabled Save draft. Preview sends current unsaved body JSON to the server, validates/canonicalizes it, renders GemBox body blocks with app-owned furniture, stores PDF bytes in a short-lived token cache, and warns when browser page-flow count differs from GemBox PDF page count. Persisted template editing happens on `/engagement-letter/templates/{TemplateId:int}`.
- A Claude design-kit ribbon toolbar with History, Text, Paragraph, Styles, and View groups.
- Real Tiptap command wiring for undo/redo, bold, italic, underline, lists, alignment, blockquote, current locked style presets, formatting marks, and document outline.
- Visual-only View toolbar zoom controls for zoom out, preset percent, zoom in, and fit-width.
- A fixed-height scrollable page-flow viewport, so added visual pages scroll inside the editor canvas instead of increasing the editor component height.
- Default body text is Arial 11. Users cannot change font family, freeform font size, text color, or highlight.
- The Insert group is removed. Links, images, horizontal rules, hard breaks, and other non-text objects are not expected in generated PDFs.
- Strikethrough, subscript, and superscript are not engagement-letter editor capabilities in V1.
- Inline code and block code are not engagement-letter features. V1 rejects `code` marks and `codeBlock` nodes, and the browser wrapper does not expose code commands.
- Tables are not engagement-letter editor capability in V1. Table commands are hidden, table extensions are not registered, and backend schema rejects table JSON.
- Contextual Tiptap UI for text selections, empty blocks, block drag handles, table of contents, and invisible characters.
- A document-page canvas inside a scrollable editing area.
- A right merge-field drawer with catalog-backed fields and search, using demo values on standalone `/editor`; template detail uses the same catalog and keeps template tokens visible in preview.
- Structured `elMergeField` insertion for merge fields, rendered as tokens such as `{{ Client Name }}`.
- PDF preview resolves body merge fields from a render-time `ElMergeFieldValueSet`. Missing values stay visible as `{{ Label }}` and are returned as merge-field diagnostics.
- A collapsed debug panel that can show live JSON, browser HTML, and text payloads. Browser HTML is debug-only and must not become export or review authority.

Known legacy token text such as `{{ Client Name }}` is normalized into the same `elMergeField` schema node during backend validation and DOCX import. Unknown legacy tokens remain editable text and still appear as legacy field-usage rows.
The editor canvas intentionally stays in token/chip mode for this slice. A UI toggle between token and resolved display is deferred until the production document route and real source-data resolver exist.

The DOCX import preview is intentionally non-persistent. It lets the team manually test real Word templates against the body-first import pipeline before introducing document ids, revision save behavior, or production template replacement.

The `/templates/header-footer` route is the current global furniture design surface. It uses `IElBrandAssetService` to upload or replace active transparent PNG assets for `ElDocumentFurnitureAssetKeys.HeaderLogo` and `FooterMark`, saves active global layout settings through `IElDocumentFurnitureLayoutService`, and shows first-page and continuation letter-paper previews with merge-field placeholders. The `/editor` route renders Letter-size visual pages around the body editor, including active first-page furniture and continuation-page furniture after page 1. Furniture and automatic soft page breaks are not inserted into Tiptap JSON; user-inserted forced breaks persist as schema V2 `pageBreak` nodes and render in browser and PDF. Asset crop and final export wiring are deferred.

## Installed Packages
Current root `package.json` includes:

- `@tiptap/core`
- `@tiptap/pm`
- `@tiptap/starter-kit`
- `@tiptap/extension-link`
- `@tiptap/extension-underline`
- `@tiptap/extension-text-align`
- `@tiptap/extension-text-style`
- `@tiptap/extension-color`
- `@tiptap/extension-highlight`
- `@tiptap/extension-font-family`
- `@tiptap/extension-placeholder`
- `@tiptap/extension-character-count`
- `@tiptap/extension-table`
- `@tiptap/extension-table-row`
- `@tiptap/extension-table-cell`
- `@tiptap/extension-table-header`
- `@tiptap/extension-image`
- `@tiptap/extension-file-handler`
- `@tiptap/extension-task-list`
- `@tiptap/extension-task-item`
- `@tiptap/extension-subscript`
- `@tiptap/extension-superscript`
- `@tiptap/extension-typography`
- `@tiptap/extension-gapcursor`
- `@tiptap/extension-dropcursor`
- `@tiptap/extension-focus`
- `@tiptap/extension-unique-id`
- `@tiptap/extension-horizontal-rule`
- `@tiptap/extension-hard-break`
- `@tiptap/extension-bubble-menu`
- `@tiptap/extension-floating-menu`
- `@tiptap/extension-drag-handle`
- `@tiptap/extension-table-of-contents`
- `@tiptap/extension-invisible-characters`
- `vite`

Only the strict text subset is wired into the current live editor. StarterKit provides basic document, paragraph, heading, list, history, and emphasis mechanics, with code, link, strike, hard break, and horizontal rule disabled. Extra registered extensions add underline, alignment, task lists, typography cleanup, placeholders, focus styling, stable node IDs, character count, table of contents, invisible characters, and better cursor behavior.

`UniqueID` is configured with `attributeName: "data-el-node-id"` for supported structural nodes. This is the first browser-side step toward durable EL node identity for merge/diff work.

`Image`, `FileHandler`, link, color, highlight, font-family, subscript, superscript, horizontal-rule, hard-break, and table packages may be installed for future use but are not registered in V1. The toolbar does not expose those capabilities, and strict backend validation rejects persisted JSON for them until that workflow is explicitly added to the EL schema policy.

BubbleMenu, FloatingMenu, DragHandle, TableOfContents, and InvisibleCharacters are now registered as browser/runtime helpers. BubbleMenu uses Blazor-rendered menu DOM for selected text. FloatingMenu uses Blazor-rendered menu DOM for empty blocks. DragHandle creates its own grip element in JavaScript, so the global `.el-drag-handle` CSS lives in `CDH_EL/wwwroot/css/site.css`. TableOfContents sends heading metadata back to Blazor through `OnTableOfContentsUpdated`. InvisibleCharacters is a UI-only view toggle and is not a persisted schema node.

Tiptap React/Vue packages provide framework-specific menu components, but this app is Blazor. Do not add `@tiptap/react` or `@tiptap/vue-*` unless the app intentionally introduces that framework for this editor surface. For Blazor, use vanilla Tiptap extensions plus JS interop.

## Build And Team Setup
There are two separate concerns: running the app and changing the editor JavaScript.

If `CDH_EL/wwwroot/js/dist/tiptapEditor.bundle.js` is committed, teammates do not need Node, pnpm, or Vite just to run the Blazor app. ASP.NET Core serves the built Tiptap bundle from `wwwroot`, and the browser loads it like any other static asset.

Teammates do need Node plus pnpm when they change any JavaScript dependency, `vite.config.js`, or `CDH_EL/wwwroot/js/tiptapEditor.js`.

Recommended setup for editor JavaScript work:

```powershell
corepack enable
pnpm install
pnpm run build:tiptap
```

During active editor-wrapper work:

```powershell
pnpm run watch:tiptap
```

Do not commit `node_modules`. Commit `package.json`, `pnpm-lock.yaml`, `vite.config.js`, source wrapper, built bundle, Razor editor components, and editor page files.

## Current Wrapper Behavior
`CDH_EL/wwwroot/js/tiptapEditor.js` exports browser functions for Blazor:

- `createEditor(elementId, initialContent, dotNetRef, options)`
- `destroyEditor(elementId)`
- `getJson(elementId)`
- `getHtml(elementId)`
- `setContent(elementId, content)`
- `setParagraph(elementId)`
- `insertText(elementId, text)`
- `undo(elementId)`
- `redo(elementId)`
- `toggleBold(elementId)`
- `toggleItalic(elementId)`
- `toggleUnderline(elementId)`
- `toggleHeading(elementId, level)`
- `toggleBulletList(elementId)`
- `toggleOrderedList(elementId)`
- `toggleBlockquote(elementId)`
- `setTextAlign(elementId, alignment)`
- `toggleTaskList(elementId)`
- `toggleInvisibleCharacters(elementId)`
- `scrollToHeading(elementId, headingId)`
- `fitPageToViewport(elementId, minZoom, maxZoom)`

`ElTiptapEditor.razor` exposes `SetContentJsonAsync(string editorJson)` so a validated canonical JSON payload can be loaded into the live Tiptap instance through the existing `setContent` JavaScript wrapper. Page-flow furniture can be refreshed without recreating the editor through `updatePageFlowConfig`.

The wrapper keeps active editors in a JavaScript `Map` keyed by the editor element id. `createEditor` destroys an existing editor with the same id before creating a new one. On create, update, selection update, and toolbar command, it sends this payload back to Blazor:

```json
{
  "json": {},
  "html": "<p>Generated browser HTML</p>",
  "text": "Generated browser text",
  "characters": 0,
  "words": 0,
  "invisibleCharactersVisible": false,
  "pageFlow": {
    "pageCount": 1,
    "signature": "",
    "warningCount": 0,
    "warnings": []
  },
  "activeMarks": {},
  "activeBlocks": {},
  "can": {}
}
```

`ElTiptapEditor.razor` receives that payload as `TiptapUpdatePayload` and raises `OnUpdated`. The `/editor` page uses it only for the collapsed debug panel. The toolbar uses `activeMarks`, `activeBlocks`, `characters`, `words`, `can`, and `invisibleCharactersVisible` for active button state, history controls, and the status row.

## Backend Route
The live workspace does not call real save endpoints yet. Backend primitives for strict revision persistence now exist. Keep this boundary:

The durable persistence policy is documented in `docs/reference/tiptap-schema-policy.md`. The readable current V2 schema metadata artifact is `docs/reference/el-tiptap-schema-definition.v2.json`, V1 remains historical, and the typed backend source of truth is `ElTiptapSchemaDefinition.Current`.

- Blazor component captures editor JSON and sends it to an application service or endpoint.
- `CDH_EL` owns browser/Blazor interop and current-user context.
- `Lib` owns pure document services, validation, canonicalization, DOCX import, and EF persistence.
- Backend Tiptap JSON validation/conversion belongs in reusable services, not `.razor` files.

Expected save flow:

```text
Client sends Tiptap JSON
Backend validates JSON against explicit EL schema
Backend calculates content_hash from canonical JSON
Backend builds node index, merge-field usage, and node diff rows
EF stores immutable revision fields and derived rows
```

The clean Tiptap route saves JSON as the source of truth and treats HTML as generated output for preview/export. Search uses `ELDocumentNodeIndex.text_content`; strict mode rejects unsupported JSON instead of storing partially sanitized content.

## EL-Specific Extensions
The current editor uses general-purpose rich text extensions plus structured merge-field tokens. Next app-specific work should add engagement-letter-specific nodes and marks so the document model carries business meaning directly.

Likely future extensions:

- `elSection`
- `elClause`
- `elMergeField`
- `elConditionalBlock`
- `elRequiredClause`
- `elProjectOverride`

Example target JSON shape for a merge field:

```json
{
  "type": "elMergeField",
  "attrs": {
    "fieldKey": "client.name",
    "label": "Client Name",
    "required": true
  }
}
```

Server-rendered HTML can still use stable markers:

```html
<span data-el-field="client.name" data-el-required="true">
  {{ Client Name }}
</span>
```

The value of Tiptap for this app comes from making EL structure enforceable in the editor schema, not merely from storing rich text as JSON.

## Editor Todo Roadmap
This roadmap captures what is still missing after the current Tiptap shell, toolbar, contextual menus, strict schema foundation, and persisted template-detail editor. The template editor is now the official template save surface; the remaining work is mostly server-backed data, final export artifacts, DOCX fidelity, issued-document/package flow, and review/version UX.

### Confirmed Current Support
Do not list these as missing editor capabilities. They already exist in the current Tiptap editor, though some still need DOCX import/export fidelity:

- Bold, italic, and underline already exist in the toolbar, JavaScript commands, and backend schema.
- Bullet, ordered, and task lists already exist in the toolbar, JavaScript commands, and backend schema.
- Paragraphs and heading levels 1-3 already exist.
- Default editor and preview body text is Arial 11; arbitrary font family, freeform font size, text color, and highlight are not V1 capabilities.
- Alignment already exists through the Tiptap alignment extension.
- Tables are removed from V1 editor creation/persistence. The inspected ASC 740 sample DOCX body does not contain tables.
- Template detail is now the real persisted editor surface. `/engagement-letter/templates/{TemplateId:int}` loads draft template-section `editorJson`, saves through `SaveTemplateSectionEditorJsonAsync`, validates/canonicalizes through `ElTiptapSchemaService`, and can preview the current unsaved editor JSON through the shared PDF preview route.

Partial support:

- Paragraph/heading basics exist, but Word named style preservation is not implemented for styles such as `BodyText`, `NormalText`, `Heading1`, and `Heading2`.
- Word color and highlight import is intentionally out of V1 strict text scope and should be reported or converted to plain text if encountered.
- Lists exist, but DOCX numbering style/import mapping still needs validation.

### P1 - Schema Cleanup And Template Model
- Use GemBox import analysis together with strict Tiptap schema validation for code-style content. Code formatting should be converted to normal text and surfaced as a non-blocking import finding, because engagement-letter JSON should not persist code-style marks or blocks.
- The app-owned document/page furniture model exists for standard CDH first-page and continuation-page headers and footers; keep it as the preview/export furniture source.
- Add a comment model with anchored ranges, author, initials, timestamp, body text, and resolved state.
- Map known Word `DOCVARIABLE` fields and known plain `{{ Field }}` tokens to `elMergeField` nodes. Unknown DOCVARIABLE fields should report a warning finding and keep visible text.
- Unsupported Word features must produce an import/report finding rather than silently disappearing.

### P2 - Template Fidelity And DOCX Feature Coverage
The first implementation spike now exists. GemBox loads DOCX files and exports normalized HTML, Tiptap.NET converts that HTML into JSON, and the existing strict EL schema service validates/canonicalizes the result. The standalone `/editor` surface remains useful as a scratch/import preview surface, while persisted template editing now lives on `/engagement-letter/templates/{TemplateId:int}`.

```text
DOCX
  -> GemBox.Document
  -> normalized HTML + import findings
  -> Tiptap.NET HTML-to-JSON
  -> strict EL schema validation
  -> canonical editor_json
```

Current import quality target is body-first. The preview should block on reliable body text, headings, supported marks, lists, known DOCVARIABLE fields, known legacy tokens, and clear findings when conversion is lossy or unsupported.

- Header and footer import is intentionally skipped. DOCX import should migrate body content only, while app-owned furniture wraps preview and export.
- Standard furniture uses database-stored PNG brand assets, first-page header/footer, continuation-page header/footer, client legal name, letter date, and page number.
- Current `/editor` furniture support is Letter visual page flow. It measures body flow in JS, creates line-level runtime decorations for automatic breaks, exposes page-flow warning state and diagnostics, and renders continuation-page header/footer furniture for pages after page 1. Automatic breaks and furniture stay out of `editor_json`; user-inserted forced breaks persist as `pageBreak` nodes.
- Page-flow hardening now has planner tests for pasted multi-page content, edit/undo boundary signature stability, long list item warning metadata, merge-field boundary atomicity, oversized token warning metadata, and stale measurement rejection.
- Preview now compares browser page-flow page count with generated GemBox PDF page count and surfaces a drift warning when the counts differ. Exact line parity is not required for the first production slice.
- Page-flow TODO: expose richer debug diagnostics from the editor debug area, especially break positions and first break offsets.
- Page-flow TODO: manually verify real large pasted templates in browser to confirm visual selection, scrolling, continuation furniture, and page-flow warning UX beyond planner unit tests.
- PDF final export must use saved canonical body JSON, GemBox body blocks, app-owned furniture/assets/merge values, and export audit metadata. Browser HTML remains debug-only.
- The `test:tiptap` package script exists for `node --test CDH_EL/wwwroot/js/*.test.js`; include it in normal editor verification.
- Keep this roadmap and the schema policy current whenever page-flow internals, page-flow warning payloads, or export-authoritative rules change.
- Preserve or map Word named styles: `BodyText`, `NormalText`, `Heading1`, and `Heading2`.
- Preserve already-supported formatting during import/export: bold, italic, underline, lists, headings, and alignment.
- Handle tab-stop based rows or convert them into stable editor structures for signature lines, materiality rows, and address blocks.
- Add support or an explicit conversion policy for small caps.
- Add a DOCX import analysis report that identifies unsupported or lossy features before content is saved.

### P3 - Production Template And Document Flow
- Template route/load/save is implemented for draft template sections: `/engagement-letter/templates/{TemplateId:int}` loads `ELTemplateSection.editorJson` and saves canonical JSON back to the template section.
- Keep template preview/save using current unsaved JSON, draft-only guards, and user-facing schema validation errors.
- Add real issued-document/package flow separately from template editing when the app needs package-specific revisions or generated engagement letters.
- If a future issued-document editor is added, load the latest `ELDocumentRevision`, save draft revisions through `IElDocumentRevisionService`, and gate Preview/Save by document context and permissions.
- Replace standalone `/editor` sample document facts and demo merge-field values with server-backed template/document/package data.
- Keep browser HTML debug-only; saved output must use canonical backend JSON.

### P4 - Review, Export, And Workflow
- Add comment and note UI with markers, side pane, add/edit/resolve flows, anchored ranges, author/initials/timestamp metadata, and imported Word reviewer-note support.
- Add canonical preview generated from backend JSON instead of browser HTML.
- Add export path for PDF/downstream document generation.
- Include headers, footers, comments, fields, and page furniture in preview/export.
- Replace standalone `/editor` sample metadata/demo merge values with server-backed document/package data where that route remains useful.
- Add edit/review permissions, dirty-state tracking, version history, and node-level diff viewer.

### Recommended Current TODO Order
1. Replace standalone `/editor` sample facts/demo merge values with server-backed document/template/package data. Lift: medium.
2. Add the final export artifact path: saved canonical JSON to `ElTiptapGemBoxBodyRenderer` GemBox body blocks, snapshot furniture/assets/merge values, issued PDF bytes, and audit metadata stored with `ELDocumentFile` or a successor artifact model. Lift: high.
3. Improve DOCX fidelity for named styles, tab-stop rows/signature lines, small caps policy, numbering validation, and a clear lossy-feature report. Lift: medium-high.
4. Polish page-flow diagnostics by exposing break positions/offsets and manually verifying real pasted templates in-browser. Lift: low-medium.
5. Add issued-document/package flow only when needed beyond template editing; use package-specific route/load/save, `ELDocumentRevision`, and permission-gated Preview/Save. Lift: high.
6. Add review comments with anchored ranges, side pane, add/edit/resolve flows, and imported reviewer notes. Lift: high.
7. Add version history and node-level diff viewer from canonical JSON. Lift: high.

### ASC 740 Template Findings
The inspected `EL Template - ASC 740 UTP Analysis & Memo.docx` sample uses features that should shape the editor roadmap:

- One Word section references first/default/even headers and first/default/even footers, but app output uses one standard first-page plus continuation-page furniture model.
- Header/footer parts informed the app-owned furniture design: first-page CDH branding/tagline/contact block and continuation client/date/page header plus website footer.
- Header/body fields include `DATE`, `PAGE`, and Word `DOCVARIABLE` values for client name, address, city/state/zip, year-end date, and binder delivery date.
- The document has anchored comments with reviewer instructions, author, initials, and timestamps.
- The body uses named Word paragraph styles, tab-stop aligned rows/signatures/materiality lines, numbered references, small caps, exact page margins, and printable page layout.
- The inspected body has no tables, hyperlinks, footnote/endnote references, content controls, or tracked changes.

## Verification
After changing Tiptap browser code:

```powershell
pnpm run build:tiptap
dotnet build CDH_EL\CDH_EL.csproj --no-restore -v:minimal -p:OutDir=..\artifacts\verify-build\
```

If `pnpm` fails in a sandbox with `unable to open database file`, rerun it outside the sandbox or from a normal terminal. That failure is a tooling/sandbox problem, not a Tiptap code problem.

For routine repo verification, do not require browser testing unless explicitly requested. For editor interaction changes, browser testing can still be useful when the user asks for it because selection menus, focus behavior, and JS interop are browser-visible behaviors.
