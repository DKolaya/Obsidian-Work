# Tiptap Editor Guide

## Purpose
- App editor direction is Tiptap only.
- Live RTE workspace route is `/editor`.
- Current pass adds strict backend schema + EF revision storage. `/editor` has non-persistent PDF Preview wired, while Save draft remains disabled.
- Browser editor captures JSON/HTML/text; backend persists validated canonical JSON plus derived node-index/search rows.

## Architecture
- Browser: vanilla Tiptap JS editor.
- Blazor: renders editor shell, imports bundled ES module, receives JSON/HTML/text via JS interop.
- Backend: `Lib.Services.Editor` validates/canonicalizes JSON, renders HTML/text when needed, hashes content, indexes nodes/fields, and diffs revisions.
- DB: `ELDocumentRevision.editor_json` authoritative; `ELDocumentNodeIndex.text_content` is search source; revision rows do not persist generated HTML/plain text.
- Do not trust browser HTML for final persistence/export; server generates canonical HTML from validated JSON.

Save/export authority:
```text
Browser Tiptap JSON -> strict backend validation -> canonical JSON -> ElTiptapGemBoxBodyRenderer -> GemBox body blocks + app furniture/assets -> PDF/export
```

## Current Files
- `package.json`: JS deps + `build:tiptap` / `watch:tiptap`.
- `pnpm-lock.yaml`: pinned JS deps.
- `vite.config.js`: bundle config.
- `CDH_EL/wwwroot/js/tiptapEditor.js`: source wrapper.
- `CDH_EL/wwwroot/js/dist/tiptapEditor.bundle.js`: built bundle served by app.
- `CDH_EL/Components/Shared/ElTiptapEditor.razor`: reusable Blazor RTE wrapper.
- `CDH_EL/Components/Shared/ElTiptapEditor.razor.css`: editor CSS.
- `CDH_EL/Components/Pages/Editor.razor`: product-style editor workspace.
- `CDH_EL/Components/Pages/Editor.razor.css`: page CSS.
- `CDH_EL/Components/Pages/HeaderFooterDesigner.razor`: global header/footer furniture designer.
- `CDH_EL/Components/Pages/HeaderFooterDesigner.razor.css`: designer page CSS.
- `Lib/Services/Editor/*`: strict schema, revision, DOCX import, index, field usage, and diff services.
- `Lib/Models/EL/ELDocumentNodeIndex.cs`: per-node searchable JSON index.
- `Lib/Models/EL/ELDocumentFieldUsage.cs`: structured + legacy merge-field usage.
- `Lib/Models/EL/ELDocumentDiff.cs`: node-level revision diff rows.

## Current UI
- Standalone `/editor` shows static sample document metadata, DOCX import preview, enabled non-persistent PDF Preview, and disabled Save draft. Persisted template editing happens on `/engagement-letter/templates/{TemplateId:int}`.
- `/editor` links to `/templates/header-footer` and renders active first-page furniture as visual chrome around the body editor; it does not import page furniture into editor JSON.
- `Import DOCX` opens a HAVIT modal, accepts one `.docx` up to 25 MB, converts through `IElDocxImportService`, shows findings, and can load canonical JSON into the editor without saving.
- `/templates/header-footer` is a global designer for app-owned first-page and continuation-page furniture, DB-backed transparent PNG assets, persisted global layout settings, merge placeholders, page-number options, contact/disclaimer text, and letter-paper preview.
- Main editor uses Claude design-kit ribbon toolbar: History, Text, Paragraph, Styles, and View groups.
- Ribbon controls wire real Tiptap commands for undo/redo, bold/italic/underline, lists/alignment/blockquote, forced page break (`Ctrl+Enter` / `Cmd+Enter`), current locked style presets, formatting marks, and document outline.
- View toolbar includes visual-only editor zoom controls: zoom out, preset percent, zoom in, and fit-width.
- Page-flow editor uses a fixed-height scrollable viewport; added pages scroll inside the editor canvas instead of expanding the whole page layout.
- Default body text is Arial 11. Users cannot change font family, freeform font size, text color, or highlight.
- Insert menu is removed. Links, images, horizontal rules, hard breaks, and other non-text objects are not expected in generated PDFs.
- Strikethrough, subscript, and superscript are not engagement-letter editor capabilities in V1.
- Inline code and block code are not engagement-letter features. V1 rejects `code` marks and `codeBlock` nodes, and the browser wrapper does not expose code commands.
- Tables are not engagement-letter editor capability in V1. Table commands are hidden, table extensions are not registered, and backend schema rejects table JSON.
- Contextual UI is wired with BubbleMenu, FloatingMenu, DragHandle, TableOfContents, and InvisibleCharacters.
- Standalone `/editor` right drawer shows catalog-backed searchable merge fields with demo values; template detail uses the same catalog and keeps template tokens visible in preview.
- Merge-field insert creates structured `elMergeField` nodes that render as protected token text like `{{ Client Name }}`.
- Debug JSON/HTML/text previews are hidden by default behind `Show debug payloads`; browser HTML remains debug-only.
- `/editor` Preview uses current unsaved body JSON, validates/canonicalizes it server-side, resolves body merge fields from a render-time value dictionary, renders GemBox body blocks with app-owned furniture, stores PDF bytes in a short-lived token cache, and warns when browser page-flow page count differs from GemBox PDF page count.
- `/editor` Save draft still does not call a real persistence endpoint.

## Packages
Installed:
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

`UniqueID` is configured with `attributeName: "data-el-node-id"` for durable EL node identity on supported node types.

`Image`, `FileHandler`, link, color, highlight, font-family, subscript, superscript, horizontal-rule, hard-break, and table packages may be installed for future use but are not registered in V1. Persisted JSON for those capabilities is rejected by the strict EL schema, so the toolbar intentionally does not expose them.

BubbleMenu, FloatingMenu, DragHandle, TableOfContents, and InvisibleCharacters are registered as runtime helpers. They do not introduce persisted document nodes by themselves, except user-triggered invisible-character visibility is UI state only.

Do not add `@tiptap/react` / `@tiptap/vue-*` for Blazor wrapper unless team intentionally adds that framework. Use vanilla Tiptap + JS interop.

## Team Setup
- If `CDH_EL/wwwroot/js/dist/tiptapEditor.bundle.js` is committed, teammates do not need Node/pnpm/Vite to run app.
- To change Tiptap JS/build config/deps, teammates need Node + pnpm.

Commands:
```powershell
corepack enable
pnpm install
pnpm run build:tiptap
```

Watch:
```powershell
pnpm run watch:tiptap
```

Do not commit `node_modules`.

## Wrapper API
`CDH_EL/wwwroot/js/tiptapEditor.js` exports:
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
- `updatePageFlowConfig(elementId, config)`

`ElTiptapEditor.razor` exposes `SetContentJsonAsync(string editorJson)` for loading validated canonical JSON into the live browser editor.

JS sends Blazor:
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

## Backend Rules
- `CDH_EL` owns browser interop/current user/page UI.
- `Lib` owns reusable document validation/canonicalization/EF persistence.
- Persistence policy details live in `docs/reference/tiptap-schema-policy.md`.
- Readable current V2 schema metadata lives in `docs/reference/el-tiptap-schema-definition.v2.json`; V1 remains historical.
- `ElTiptapSchemaDefinition.Current` is the typed backend source of truth for persisted JSON.
- `IElTiptapSchemaService` rejects unsupported nodes, marks, attrs, unsafe URLs, missing required attrs, malformed text, and invalid scalar types.
- `IElDocxImportService` converts DOCX streams to normalized HTML, candidate Tiptap JSON, strict validated canonical JSON, plain text, and findings.
- Strict mode rejects invalid payloads; it does not save partially sanitized content.
- Backend service validates JSON, assigns missing `data-el-node-id` during controlled canonicalization, hashes canonical JSON, then saves immutable revision plus derived rows.
- `IElDocumentRevisionService` loads latest revision and saves validated revisions with node index, field usage, and node diff rows.
- Search queries `ELDocumentNodeIndex.text_content`; find/replace/diff work from canonical JSON/index, not browser HTML.
- Do not put backend conversion or EF logic in `.razor`.
- Clean route = Tiptap JSON source of truth.

## EL Extensions
Current merge-field drawer inserts structured `elMergeField` nodes from the code-backed catalog.
Known legacy `{{ Field }}` text converts to the same node during backend validation/import.
Unknown legacy tokens remain text and still produce legacy field-usage rows.
Preview/export resolves structured merge fields from `ElMergeFieldValueSet`; missing values stay visible as `{{ Label }}` tokens and produce merge-field diagnostics.
Editor token/resolved display toggle is deferred; the editor canvas stays token/chip mode for V1.

Current app-specific nodes/marks:
- `elSection`
- `elClause`
- `elMergeField`
- `elConditionalBlock`
- `elRequiredClause`
- `elProjectOverride`

Target merge field JSON:
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

Generated HTML marker:
```html
<span data-el-field="client.name" data-el-required="true">
  {{ Client Name }}
</span>
```

Main value: editor schema carries EL business meaning, not just rich text JSON.

## Editor Todo Roadmap

### Confirmed Current Support
- Bold, italic, and underline exist in toolbar, JS commands, and backend schema.
- Bullet, ordered, and task lists already exist in toolbar, JS commands, and backend schema.
- Paragraph plus heading levels 1-3 already exist.
- Persisted `pageBreak` exists in schema V2; toolbar icon and `Ctrl+Enter` / `Cmd+Enter` insert it; browser page flow and GemBox PDF honor it.
- Default editor and preview body text is Arial 11; arbitrary font family, freeform font size, text color, and highlight are not V1 capabilities.
- Alignment exists through the Tiptap alignment extension.
- Tables are removed from V1 editor creation/persistence. The ASC 740 sample DOCX body has no tables.
- Template detail is now the real persisted editor surface: `/engagement-letter/templates/{TemplateId:int}` loads draft template-section `editorJson`, saves through `SaveTemplateSectionEditorJsonAsync`, validates/canonicalizes with `ElTiptapSchemaService`, and previews unsaved editor JSON through the shared PDF preview route.

Partial fidelity gaps:
- Paragraph/heading basics exist, but Word named style preservation is not implemented for styles like `BodyText`, `NormalText`, `Heading1`, and `Heading2`.
- Word color/highlight import is intentionally out of V1 strict text scope and should be reported or converted to plain text if encountered.
- Lists exist, but DOCX numbering style/import mapping still needs validation.

### P1 - Template Model
- Use GemBox import analysis plus strict Tiptap schema validation for code-style content; convert code formatting to normal text and report a non-blocking import finding.
- Map known Word `DOCVARIABLE` fields and known `{{ Field }}` tokens to `elMergeField`; unknown DOCVARIABLE fields produce warning findings and keep visible text.
- App-owned document/page furniture model exists for standard CDH first-page and continuation-page headers/footers; keep it as the preview/export furniture source.
- Add planned comment model with anchored ranges, author, initials, timestamp, body, and resolved state.
- Unsupported Word features must be reported during import, not silently dropped.

### P2 - Template Fidelity And DOCX Feature Coverage
- Current spike exists: GemBox DOCX import service with findings plus `/editor` preview modal. Template editing persistence now lives on `/engagement-letter/templates/{TemplateId:int}`; standalone `/editor` remains a scratch/import preview surface unless a future document/package route is explicitly added.
- Import pipeline: `DOCX -> GemBox.Document -> normalized HTML + findings -> Tiptap.NET HTML-to-JSON -> strict EL schema -> canonical editor_json`.
- Body-first import fidelity blocks current preview quality: headings, paragraphs, supported marks, lists, known DOCVARIABLE fields, known legacy tokens, and clear warnings for lossy conversion.
- Header/footer import is intentionally skipped. DOCX import migrates body content only; app-owned furniture wraps preview/export.
- Standard furniture uses DB-stored PNG brand assets, first-page header/footer, continuation-page header/footer, client legal name, letter date, and page number.
- The current designer can upload/replace global `ELBrandAsset` PNG rows and save active global `ELDocumentFurnitureLayout` settings. `/editor` renders Letter (`816px x 1056px`) visual pages with active first-page and continuation furniture; crop workflow and final export wiring are deferred.
- Page-flow support: `/editor` uses JS-only line-level decorations to measure body flow, render visual pages, expose page-flow warnings/diagnostics, and keep saved `editor_json` body-only.
- Page-flow hardened: multi-page paste, edit/undo boundary signatures, long list item warnings, merge-field boundary atomicity, oversized token warnings, stale measurement rejection, and browser-vs-PDF page-count drift warning are covered by tests.
- Page-flow TODO: expose richer debug diagnostics in the editor debug area, especially break positions and first break offsets.
- Page-flow TODO: run browser/manual verification on real large pasted templates to confirm visual selection, scrolling, and continuation furniture behavior beyond planner unit tests.
- Export TODO: final PDF export path must use saved canonical JSON, GemBox body blocks, snapshot furniture/layout/assets/merge values, issued artifact bytes, and audit metadata.
- Preserve or map Word named styles: `BodyText`, `NormalText`, `Heading1`, `Heading2`.
- Preserve already-supported formatting during import/export: bold, italic, underline, lists, headings, and alignment.
- Handle tab-stop based rows or convert them into stable editor structures.
- Add support or explicit conversion policy for small caps.
- Add DOCX import analysis report for unsupported or lossy features.

### P3 - Production Template And Document Flow
- Template route/load/save is implemented for draft template sections: `/engagement-letter/templates/{TemplateId:int}` -> `ELTemplateSection.editorJson` -> canonical JSON save.
- Keep template preview/save using current unsaved JSON, draft-only guards, and schema validation errors.
- Add real issued-document/package flow separately from template editing when the app needs package-specific revisions or generated letters.
- If a future issued-document editor is added, load latest `ELDocumentRevision`, save draft revisions through `IElDocumentRevisionService`, and gate Preview/Save by document context and permissions.
- Replace standalone `/editor` sample document facts and demo merge-field values with server-backed template/document/package data.
- Keep browser HTML debug-only; saved output must use canonical backend JSON.

### P4 - Review, Export, And Workflow
- Add comment/note UI: markers, side pane, add/edit/resolve flows, anchored ranges, author/initials/timestamp metadata, and imported Word reviewer-note support.
- Add canonical preview generated from backend JSON.
- Add export path for PDF/downstream generation.
- Include headers, footers, comments, fields, and page furniture in preview/export.
- Replace standalone `/editor` sample metadata/demo merge values with server-backed document/package data where that route remains useful.
- Add edit/review permissions, dirty state, version history, and diff viewer.

### Recommended Current TODO Order
1. Server-backed metadata/fields: replace standalone `/editor` sample facts/demo merge values with document/template/package data. Lift: medium.
2. Final export artifact: saved canonical JSON -> `ElTiptapGemBoxBodyRenderer` -> GemBox body blocks + snapshot furniture/assets/merge values -> PDF bytes + audit metadata in `ELDocumentFile` or successor model. Lift: high.
3. DOCX fidelity: named styles, tab-stop rows, small caps policy, numbering validation, lossy-feature report. Lift: medium-high.
4. Page-flow diagnostics polish: expose break positions/offsets and manually verify real pasted templates in browser. Lift: low-medium.
5. Issued-document/package flow: add package-specific route/load/save only when needed beyond template editing; use `ELDocumentRevision` and permission-gated Preview/Save. Lift: high.
6. Review workflow: comments, anchored ranges, side pane, resolve flow, imported reviewer notes. Lift: high.
7. Version/diff UX: version history and node-level diff viewer from canonical JSON. Lift: high.

### ASC 740 Template Findings
- Sample DOCX has first/default/even headers and first/default/even footers, but app output uses one standard first-page plus continuation-page furniture model.
- Header/footer parts informed app-owned furniture design: first-page CDH branding/tagline/contact block and continuation client/date/page header plus website footer.
- Header/body fields include `DATE`, `PAGE`, and Word `DOCVARIABLE` values such as client name, address, city/state/zip, year-end date, and binder delivery date.
- Document has anchored comments with reviewer instructions, author, initials, and timestamps.
- Body uses named Word styles, tab-stop aligned rows/signatures/materiality lines, numbered refs, small caps, exact page margins, and printable page layout.
- Body has no tables, hyperlinks, footnote/endnote references, content controls, or tracked changes in the inspected sample.

## Verify
```powershell
pnpm run build:tiptap
dotnet build CDH_EL\CDH_EL.csproj --no-restore -v:minimal -p:OutDir=..\artifacts\verify-build\
```

If sandbox `pnpm` says `unable to open database file`, rerun outside sandbox/normal terminal.

Routine repo verification does not require browser testing unless requested.
