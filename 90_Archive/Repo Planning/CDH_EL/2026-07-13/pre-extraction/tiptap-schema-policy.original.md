# Tiptap Schema Policy

## Purpose
The engagement-letter editor should use Tiptap's built-in ProseMirror schema mechanics for browser editing, but the application should not rely on Tiptap's built-in schema alone for persistence. The persisted document model needs an engagement-letter-specific schema policy so saved JSON stays predictable, searchable, and safe to manipulate.

The important distinction is:

```text
Installed extension = code available to the browser bundle
Allowed persisted node/mark = content approved by the EL schema policy
```

Those are not the same thing. It is fine to install extra free extensions so future work can use them, but they should not become saved document content until the EL workflow needs them and backend validation has explicit rules for them.

## Architecture
Use three layers:

```text
Tiptap extensions
        ↓
Browser editing behavior and ProseMirror schema mechanics
        ↓
EL schema policy
        ↓
Allowed persisted nodes, marks, attributes, required fields, and URL rules
        ↓
Backend validator
        ↓
Reject invalid JSON, canonicalize valid JSON, index nodes, extract fields, diff revisions, save immutable revision
```

Tiptap should keep doing what it is good at: editing mechanics, selections, commands, marks, lists, keyboard behavior, and ProseMirror-compatible JSON. The EL backend should do what the application needs: decide what JSON is allowed to become a durable engagement-letter document.

## Extension Categories
Some extensions are runtime or UI features. They may be useful in the editor, but they do not mean new saved JSON node types should be allowed:

- `BubbleMenu`
- `FloatingMenu`
- `DragHandle`
- `CharacterCount`
- `Focus`
- `Gapcursor`
- `Dropcursor`
- `Selection`
- `Placeholder`
- `TableOfContents`
- `InvisibleCharacters`

These can be enabled for editing ergonomics without changing the persisted schema.

Core persisted nodes should stay intentionally small and predictable:

- `doc`
- `paragraph`
- `text`
- `heading`
- `bulletList`
- `orderedList`
- `listItem`
- `taskList`
- `taskItem`
- `blockquote`

Formatting marks can be allowed when they support real letter drafting:

- `bold`
- `italic`
- `underline`

V1 intentionally does not persist links, colors, highlights, arbitrary font family, arbitrary font size, strikethrough, subscript, or superscript. The generated PDF path is expected to contain text, lists, locked paragraph/heading styles, EL merge fields, and app-owned furniture, not user-inserted links or other non-text objects.

Inline code and block code are not desired engagement-letter content. V1 rejects `code` marks and `codeBlock` nodes, and the browser wrapper does not expose code commands. Paste/import should reject or convert code formatting so saved engagement-letter JSON does not persist code-style content.

Tables are also out of V1 editor scope. The browser wrapper does not expose table commands, and V1 rejects `table`, `tableRow`, `tableCell`, and `tableHeader` nodes so saved engagement-letter JSON cannot persist table structures.

The important application-specific layer is the EL node set:

- `elSection`
- `elClause`
- `elMergeField`
- `elConditionalBlock`
- `elRequiredClause`
- `elProjectOverride`

These nodes are what make JSON easier than HTML for this app. Instead of scanning HTML for text and class names, backend code can ask for `clauseKey`, `sectionKey`, `fieldKey`, stable `data-el-node-id`, and JSON paths.

Extensions that are installed for future use but not needed now should remain disallowed for persistence:

- `image`
- `audio`
- `youtube`
- `twitch`
- `math`
- `emoji`
- `mention`
- `details`
- `hardBreak`
- `horizontalRule`
- `link`
- `textStyle`
- `highlight`
- `strike`
- `subscript`
- `superscript`
- `table`
- `tableRow`
- `tableCell`
- `tableHeader`

Merge fields now have a v1 code-backed catalog in `ElMergeFieldCatalog`. Known Word `DOCVARIABLE` fields and known legacy `{{ Field }}` tokens normalize to `elMergeField`; unknown DOCVARIABLE fields produce `unknown_docvariable_field` warning findings and keep visible text; unknown legacy tokens remain text and produce legacy field-usage rows. Preview/export resolves structured merge fields through `ElMergeFieldValueSet`; unresolved values stay visible as `{{ Label }}` and produce diagnostics. The editor token/resolved display toggle is deferred, so persisted JSON remains token/source structure rather than substituted text.

Additional planned structures are needed for template fidelity and review workflow, but they should still follow the same explicit-policy rule before persistence:

- page furniture for first/default/even headers and footers
- anchored comments
- Word named-style import/export mapping

If one of these becomes necessary later, add it deliberately: frontend command, backend allowlist, attr validation, renderer behavior, indexing behavior, tests, and migration only if new derived storage is needed.

## Schema Policy Shape
The schema policy should be a first-class application artifact, not scattered knowledge. It should document:

- allowed node names
- allowed mark names
- allowed attributes per node and mark
- required attributes for EL nodes
- allowed URL protocols
- max text length
- max attribute length
- which node types require `data-el-node-id`
- editor schema version
- HTML schema/render version

The backend validator should use this policy directly. The browser editor should mirror it by configuring only the matching Tiptap extensions and commands. A generated `.schema.json` file can be useful for review and tooling, but it should not replace semantic backend validation because Tiptap/ProseMirror content rules are richer than plain JSON Schema.

Current V2 implementation uses `ElTiptapSchemaDefinition.Current` as the typed backend source of truth and `docs/reference/el-tiptap-schema-definition.v2.json` as the readable review/tooling artifact. The V1 artifact remains historical.

## Implementation Guide
1. Define schema metadata in `Lib.Services.Editor`.

   Create records/constants for node definitions, mark definitions, allowed attrs, required attrs, and URL rules. Prefer data-driven metadata over scattered hardcoded `HashSet` and `Dictionary` declarations.

2. Make backend validation consume metadata.

   `IElTiptapSchemaService` should reject unknown nodes, marks, attrs, unsafe URLs, invalid scalar types, missing required attrs, malformed text nodes, and illegal node nesting. Strict mode means rejection, not silent partial save.

3. Keep browser extension config curated.

   `CDH_EL/wwwroot/js/tiptapEditor.js` should register the extension set that matches the persisted policy. Installed packages that are not policy-approved should remain unused or UI-only.

4. Add EL custom nodes when workflow needs them.

   Merge fields now move from known plain `{{ Client Name }}` text into `elMergeField` nodes through schema normalization. Clauses and sections should become `elClause` and `elSection` nodes when the app needs reliable clause-level replacement, comparison, and override behavior.

5. Save only through revision service.

   `IElDocumentRevisionService` should be the save path. It validates raw browser JSON, stores canonical JSON in `ELDocumentRevision.editor_json`, and regenerates node index, field usage, and diff rows. `ELDocumentRevision` should not persist generated HTML or full plain text; search should use `ELDocumentNodeIndex.text_content`.

6. Test policy drift.

   Tests should prove that unsupported installed-extension JSON is rejected, allowed nodes survive canonicalization, unsafe links are rejected, missing EL attrs are rejected, canonical hashes are stable, and node index/diff output remains predictable.

7. Keep code-style content out of the engagement-letter schema.

   Tests should prove that inline `code` marks and `codeBlock` nodes are rejected. If code-style formatting is pasted or imported from Word, the import path should either convert it to normal text or report it as unsupported.

## DOCX Import Rule

GemBox.Bundle is approved for the DOCX import/export layer. GemBox.Document should own loading DOCX files, inspecting Word-specific features, and producing normalized HTML plus import findings. GemBox output does not become the persistence authority and is not expected to produce Tiptap/ProseMirror JSON directly.

The import spike path is:

```text
DOCX
  -> GemBox.Document
  -> normalized HTML + import findings
  -> Tiptap.NET HTML-to-JSON
  -> strict EL schema validation
  -> canonical editor_json
```

Known DOCVARIABLE fields should be converted to catalog merge-field tokens before HTML export, then normalized to `elMergeField` nodes before strict validation. Unknown DOCVARIABLE fields should keep their visible result text and report a warning finding. Code-style Word content should be converted to normal text and reported with a warning finding. Persisted `code` marks and `codeBlock` nodes remain rejected by the strict schema service.

## Save Flow
The intended save flow is:

```text
Browser Tiptap JSON
        ↓
Strict EL schema validation
        ↓
Canonical Tiptap JSON
        ↓
Content hash
        ↓
Node index + merge-field usage + revision diff
        ↓
Immutable ELDocumentRevision
```

The source of truth is always `ELDocumentRevision.editor_json`. HTML is generated output at preview/export time. Plain text for search is stored per node in `ELDocumentNodeIndex.text_content`, not as a full revision column. Node index, field usage, and diff rows are derived data that can be rebuilt from canonical JSON if needed.

## Practical Rule
If a feature helps editing but does not need to become durable document structure, keep it in the browser layer.

If a feature changes saved JSON, add it to the EL schema policy first.

If backend code cannot explain how to validate, render, search, diff, and safely replace that node, do not allow it in persisted JSON yet.
