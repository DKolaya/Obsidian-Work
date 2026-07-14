# Tiptap Editor Route

This draft assumes the team chooses Tiptap as the only engagement letter editor. The schema does not need `editor_type` or `source_format` columns because the editor choice is permanent for this product path.

## Source Of Truth

`editor_json` is the source of truth for document content.

`html_content` is generated output used for preview, rendered diffs, exports, and downstream document generation. It should be treated as a cache or export artifact, not as the authoritative document source.

This route fits best when the long-term goal is structured template versioning, project-specific overrides, semantic diffs, and Git-like document history.

## .NET Server-Side Support

The `Tiptap.NET` NuGet package from `ColeViztech/tiptap-dotnet` changes the risk profile for this route. It is a .NET 8+ server-side port of `tiptap-php` that can parse, sanitize, and transform Tiptap content without relying on Node.js for those backend operations.

Documented capabilities include:

- Convert HTML to Tiptap/ProseMirror JSON with `Editor.SetContent(html).GetJSON()`.
- Convert Tiptap JSON back to HTML with `Editor.SetContent(json).GetHTML()`.
- Extract plain text with `GetText(...)`.
- Sanitize HTML, JSON, or `ProseMirrorDocument` input against the configured schema.
- Walk and mutate the document tree with `Descendants(...)`.
- Configure extensions through `EditorOptions`.
- Add custom nodes, marks, or extensions by inheriting from `Node`, `Mark`, or `Extension`.

This makes the Tiptap route more practical for the backend because `Lib` can own canonicalization, text extraction, export HTML generation, and validation support in C# instead of shelling out to a Node process.

Important limitation: this package is not the browser editor. The app would still need a Blazor JavaScript interop wrapper around the Tiptap web editor for actual user editing.

Adoption checks before committing:

- Confirm package version and repository tag alignment. NuGet search results show `Tiptap.NET` version `0.2.0` last updated May 12, 2026, while the GitHub repository page still shows release `0.1.3` as latest.
- Prototype EL-specific schema behavior with sections, clauses, merge fields, and required blocks.
- Verify round-trip stability for representative engagement letter HTML and JSON.
- Confirm custom EL nodes/marks can preserve required attributes and render deterministic HTML.
- Confirm package license and dependency fit for the repo. The package targets `net8.0` and lists `AngleSharp` and `System.Text.Json` dependencies.

## Core Revision Shape

`ELDocumentRevision` remains the immutable version table for engagement letter documents. It should store complete snapshots at meaningful points such as initial generation, user save, review submission, approval, regeneration, and finalization.

Recommended columns:

- `id int identity primary key`
- `document_id int not null`
- `revision_number int not null`
- `editor_json nvarchar(MAX) not null`
- `content_hash nvarchar(100) not null`
- `editor_schema_version int not null`
- `html_schema_version int not null`
- `enum_revision_reason int not null`
- `enum_version_state int not null`
- standard audit columns from `BaseRecord`

`content_hash` should be calculated from canonicalized Tiptap JSON, not generated HTML. `html_schema_version` tracks renderer output changes. `editor_schema_version` tracks Tiptap document schema changes. Generated HTML is render-time output. Search text lives in `ELDocumentNodeIndex.text_content`, not a full revision plain-text column.

## Supporting Tables

Keep the current EL foundation:

- `ELBinder`
- `ELDocument`
- `ELTemplate`
- `ELTemplateSection`
- `ELServiceMap`
- `ELSourceSnapshot`
- `ELDocumentRevision`
- `ELDocumentFile`
- `ELBinderApproval`
- `ELDocumentApproval`

Add tables that support structured document behavior:

- `ELValidationFinding` for blockers, warnings, and informational findings.
- `ELMergeFieldDefinition` for the allowed merge field catalog.
- `ELDocumentFieldUsage` for merge fields found in a revision.
- `ELDocumentNodeIndex` for section, clause, paragraph, field, table, and other semantic nodes found in a revision.
- `ELDocumentDiff` for cached rendered or semantic diffs between two revisions.

Defer `ELDocumentChangeSet` and `ELDocumentOperation` until the editor integration proves a need for operation-level persistence. Full immutable revisions are enough for initial versioning, review history, export traceability, and finalization.

## Template And Project Merge Model

Project documents should keep a reference to the template and template version used at generation time. When a template changes after a project document has been edited, compare three versions:

- Base: template version used when the project document was created.
- Left: latest template version.
- Right: current project document revision.

Expected outcomes:

- Template changed a section the project never edited: mark as auto-apply candidate.
- Template changed a section the project also edited: mark as conflict.
- Project deleted a template section: do not automatically restore it.
- Template added a required clause: suggest or require insert.
- Template changed a merge field: validate affected project documents.

Tiptap JSON makes this comparison more reliable because sections, clauses, merge fields, and conditional blocks can be stable schema nodes instead of HTML conventions.

## Indexes

Add or enforce these indexes:

- One active binder per FPA.
- One document key per binder.
- One template key and version label pair.
- One section key per template.
- One active service map per service.
- One revision number per document.

Use filtered unique indexes for active rows, such as active binder and active service map, so historical inactive rows can remain.

## Tradeoffs

Benefits:

- Best fit for Git-like document history.
- Better semantic diffs.
- Better template-to-project merge logic.
- Better conflict detection.
- Stronger model for sections, clauses, merge fields, required clauses, and conditional blocks.

Costs:

- More implementation work than an HTML-first editor.
- Requires a Blazor JavaScript interop wrapper.
- Requires a stable Tiptap schema.
- Requires deterministic JSON-to-HTML rendering for export and comparison, though `Tiptap.NET` may provide this on the server if it passes EL-specific validation.
- Team must understand and maintain the ProseMirror/Tiptap document model.

## Decision Fit

Choose this route if tomorrow's decision prioritizes long-term structured document control over shortest-path editor delivery.

Do not choose this route only to store JSON while using a different editor. The main value comes from the editor enforcing the same schema that the database stores.
