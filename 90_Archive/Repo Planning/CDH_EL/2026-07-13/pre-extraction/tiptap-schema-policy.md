# Tiptap Schema Policy

## Rule
- Do not rely on built-in Tiptap schema alone for persisted EL documents.
- Use Tiptap built-ins for editor mechanics.
- Use strict EL schema policy for persistence.
- Installed extension != allowed persisted JSON.
- Backend is final authority before save.

## Layers
```text
Tiptap extensions -> browser editing behavior
EL schema policy -> allowed persisted nodes/marks/attrs
Backend validator -> reject/canonicalize/index/diff/save
```

## Extension Categories
Runtime/UI only; no persisted schema permission:
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

Allowed persisted core:
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

Allowed formatting marks:
- `bold`
- `italic`
- `underline`
- No link, color, highlight, arbitrary font family, arbitrary font size, strike, subscript, or superscript marks in V1 persisted EL JSON.

Disallowed code-style content:
- Inline `code` marks and `codeBlock` nodes are not allowed in V1 persisted EL JSON.
- Paste/import should reject or convert code formatting; engagement-letter JSON should not persist code-style content.

Disallowed table content:
- Table commands are not exposed in the editor.
- `table`, `tableRow`, `tableCell`, and `tableHeader` nodes are not allowed in V1 persisted EL JSON.

EL-specific persisted structure:
- `elSection`
- `elClause`
- `elMergeField`
- `elConditionalBlock`
- `elRequiredClause`
- `elProjectOverride`

Installed but not currently allowed/persisted unless future workflow needs them:
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

Current template merge-field mapping:
- Code-backed catalog lives in `ElMergeFieldCatalog`.
- Known Word `DOCVARIABLE` fields import as `elMergeField`.
- Known legacy `{{ Field }}` tokens normalize to `elMergeField`.
- Unknown DOCVARIABLE fields produce `unknown_docvariable_field` warning findings and keep visible text.
- Unknown legacy `{{ Field }}` tokens remain text and produce legacy field-usage rows.
- Preview/export resolves `elMergeField` values from `ElMergeFieldValueSet`; unresolved values render as `{{ Label }}` and produce diagnostics.
- Editor resolved-value toggle is deferred; persisted JSON remains token/source structure, not substituted text.

Planned template/review structures:
- page furniture for first/default/even headers and footers
- anchored comments
- Word named-style import/export mapping

## Policy Shape
- Keep one explicit schema definition with:
  - allowed nodes
  - allowed marks
  - allowed attrs per node/mark
  - required attrs
  - allowed URL protocols
  - max text/attr lengths
  - schema version
  - HTML renderer version
- Backend validator consumes this policy.
- Browser extension setup mirrors this policy.
- Optional generated `.schema.json` documents policy for tooling/review.
- Current V2 readable artifact: `docs/reference/el-tiptap-schema-definition.v2.json`; V1 remains historical.
- Current V2 typed source: `ElTiptapSchemaDefinition.Current`.

## Implementation Steps
1. Define schema metadata in `Lib.Services.Editor`.
2. Move hardcoded allowlists from validator into metadata records.
3. Add generated static JSON artifact for review/tooling.
4. Configure `CDH_EL/wwwroot/js/tiptapEditor.js` from curated extension set, not all installed packages.
5. Add tests proving unsupported installed-extension JSON is rejected.
6. Add tests proving allowed core/EL nodes survive canonicalization.
7. Save only canonical JSON through `IElDocumentRevisionService`.
8. Regenerate node index, field usage, and diff rows after each save; search uses `ELDocumentNodeIndex.text_content`.
9. Keep tests proving `code` marks and `codeBlock` nodes are rejected.

## DOCX Import Rule
```text
DOCX -> GemBox.Document -> normalized HTML + findings -> Tiptap.NET JSON -> strict EL schema
```

- GemBox may read/preserve Word features and produce normalized HTML.
- Known DOCVARIABLE values become catalog merge-field tokens before HTML export, then normalize to `elMergeField`.
- Unknown DOCVARIABLE values keep their visible result text and emit a warning finding.
- GemBox output is not persistence authority.
- Strict EL schema remains final gate before `editor_json`.
- Code-style Word content converts to normal text with a warning finding; persisted `code` marks and `codeBlock` nodes remain rejected.

## Save Rule
```text
raw browser JSON
  -> strict EL validation
  -> canonical JSON
  -> content hash
  -> node index + field usage + diffs
  -> immutable ELDocumentRevision
```

Never save:
- browser HTML as source of truth
- generated HTML on `ELDocumentRevision`
- generated full plain text on `ELDocumentRevision`; use `ELDocumentNodeIndex.text_content` for search
- unknown nodes
- unknown marks
- unknown attrs
- unsafe URLs
- partial sanitized output after strict rejection

## Why
- Tiptap JSON is easier to inspect/manipulate than TinyMCE HTML only if persisted shape is controlled.
- Clause/section/merge-field work needs semantic nodes, not arbitrary rich-text JSON.
- Strict policy lets backend find, replace, diff, and regenerate text from stable node ids and JSON paths.
