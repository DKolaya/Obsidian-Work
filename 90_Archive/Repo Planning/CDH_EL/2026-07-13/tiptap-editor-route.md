# Tiptap Editor Route

Purpose: Sprint 2 decision draft if Tiptap is chosen as only EL editor.

## Source

- Source of truth: `ELDocumentRevision.editor_json`.
- `html_content` = generated preview/export/cache, not authority.
- No `editor_type`.
- No `source_format`.
- Hash canonical Tiptap JSON, not generated HTML.

## .NET Package Note

`Tiptap.NET` / `ColeViztech/tiptap-dotnet` makes backend path easier:

- .NET 8+ server-side package.
- HTML -> JSON: `SetContent(html).GetJSON()`.
- JSON -> HTML: `SetContent(json).GetHTML()`.
- Text extract: `GetText(...)`.
- Schema sanitize: `Sanitize(...)`.
- Tree walk/mutate: `Descendants(...)`.
- Custom nodes/marks/extensions supported.

Use in `Lib` for canonicalization, HTML export, plain text, validation helpers.

Still needed: Blazor JS interop wrapper for actual browser editor.

Before adopting:

- confirm NuGet/latest tag mismatch (`0.2.0` appears on NuGet; GitHub page shows `0.1.3` latest release).
- prototype EL custom nodes/marks.
- verify JSON/HTML round-trip on real EL samples.

## Revision Shape

`ELDocumentRevision` = immutable snapshot/version.

Columns:

- `id`
- `document_id`
- `revision_number`
- `editor_json nvarchar(MAX) not null`
- `content_hash nvarchar(100) not null`
- `editor_schema_version int not null`
- `html_schema_version int not null`
- `enum_revision_reason int not null`
- `enum_version_state int not null`
- `BaseRecord` audit fields

Generated HTML is render-time output. Search text lives in `ELDocumentNodeIndex.text_content`, not a full revision plain-text column.

## Keep

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

## Add

- `ELValidationFinding`
- `ELMergeFieldDefinition`
- `ELDocumentFieldUsage`
- `ELDocumentNodeIndex`
- `ELDocumentDiff`

Defer:

- `ELDocumentChangeSet`
- `ELDocumentOperation`

## Merge Model

Three-way compare:

- Base = template version used by project doc.
- Left = latest template version.
- Right = current project revision.

Use node IDs/schema nodes for section conflict, field validation, required clause insert, deleted section handling.

## Indexes

- unique active binder per FPA.
- unique document key per binder.
- unique template key/version.
- unique section key per template.
- unique active service map per service.
- unique revision number per document.

Use filtered unique indexes for active rows.

## Fit

Pick Tiptap when semantic diff, template merge, overrides, and Git-like history matter more than fastest MVP.

Cost: JS interop, schema design, EL-specific package validation, more team learning.
