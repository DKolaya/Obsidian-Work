# Editor/GemBox Flow Comparison

## Purpose
- Explain current EL editor architecture, duplication, simplification path.
- Durable bases:
  - Body truth: canonical Tiptap JSON.
  - Output truth: GemBox `DocumentModel`.
  - Furniture truth: `ELDocumentFurnitureLayout` + `ELBrandAsset`.
- Related diagram:
  - `docs/reference/el-editor-gembox-flow.mmd`
  - `docs/reference/el-editor-gembox-flow.svg`
  - `docs/reference/el-editor-gembox-flow.png`

## Current Truths
- Body JSON: `Lib/Services/Editor/ElTiptapSchemaService.cs`, `ElTiptapSchemaDefinition.cs`, `docs/reference/el-tiptap-schema-definition.v2.json`.
- Furniture: `/templates/header-footer`, `ElDocumentFurnitureLayoutService`, `ElBrandAssetService`, `ELDocumentFurnitureLayout`, `ELBrandAsset`.
- Output: `ElTiptapGemBoxBodyRenderer`, `ElDocumentFurnitureGemBoxBuilder`, `ElDocumentPdfPreviewService`, `ElDocumentRenderService`.
- Import: `ElDocxImportService`, `ElGemBoxTiptapBodyImporter`.
- DOCX headers/footers skipped on import; app furniture wraps imported body later.

## Current Flow
```text
DOCX -> GemBox DocumentModel -> ElGemBoxTiptapBodyImporter -> candidate JSON -> schema canonicalization
/editor or template editor -> Tiptap JSON -> schema canonicalization -> persisted canonical JSON
/templates/header-footer -> ELDocumentFurnitureLayout + ELBrandAsset
canonical JSON + furniture/assets -> browser CSS/HTML page chrome for editor/designer preview
canonical JSON -> ElTiptapGemBoxBodyRenderer -> GemBox body blocks
furniture/assets -> ElDocumentFurnitureGemBoxBuilder -> GemBox headers/footers
GemBox DocumentModel -> PDF now, DOCX later
```

## Real Duplication
| Concern | Browser/designer | GemBox/PDF |
|---|---|---|
| Body typography | `ElTiptapEditor.razor.css` | `ElTiptapGemBoxBodyRenderer` hardcoded values |
| Furniture HTML | `ElEditorFurnitureHtmlFactory` / `ElDocumentFurnitureRenderer` | not used |
| Furniture output | not used | `ElDocumentFurnitureGemBoxBuilder` |
| Brand rule | CSS `linear-gradient(...)` | four solid GemBox table cells |
| Preview wrapper | browser/debug HTML | final output uses GemBox object model |

Problem is not separate renderers. Problem is duplicated style/furniture decisions inside separate renderers.

## Keep Separate
- `ElTiptapSchemaService`: JSON validation/canonicalization/index/diff.
- `ElGemBoxTiptapBodyImporter`: DOCX/GemBox -> JSON.
- `ElTiptapGemBoxBodyRenderer`: JSON -> GemBox body blocks.
- `IElDocumentRenderService`: app output boundary.
- `/templates/header-footer`: product furniture editor.

## Simplify
1. Add `ElDocumentStyleTokens`.
   - font family, body size, line height, paragraph spacing, heading sizes/spacing, quote style, brand rule stops/height, furniture sizing.
2. Add shared resolved furniture model.
   - layout snapshot, header logo, footer mark, merge values, findings.
3. Keep separate adapters.
   - Browser adapter: model + tokens -> HTML/CSS chrome.
   - GemBox adapter: model + tokens -> GemBox headers/footers/body formatting.
4. Optional later: `ElDocumentRenderContextBuilder`.
   - gathers JSON, furniture, assets, tokens, merge values, diagnostics.

## Options
- A leave as-is: lowest effort; drift remains.
- B style tokens only: best first step; low/medium effort.
- C style tokens + furniture model: recommended target; medium effort.
- D unified render context builder: best mental model; do after B/C.
- E raw editor CSS into GemBox: not recommended; reintroduces CSS interpretation drift.

## Recommended Plan
Implementation update 2026-06-29:
- Done: stale docs corrected to direct JSON -> GemBox body path.
- Done: `ElDocumentStyleTokens` added.
- Done: browser furniture and GemBox furniture use shared brand rule tokens; GemBox renders generated PNG strip.
- Done: `ElDocumentFurnitureViewModel` added so preview/render paths can share resolved layout/assets/merge values/findings.
- Later: optional render context builder and DOCX export.

1. Fix stale docs: PDF body is direct JSON -> GemBox, not HTML -> GemBox.
2. Add `ElDocumentStyleTokens`.
3. Fix brand rule from shared tokens:
   - browser: CSS gradient.
   - GemBox: generated PNG strip or supported drawing from same stops.
4. Add shared furniture view model.
5. Optionally add render context builder.
6. Future DOCX export saves same GemBox `DocumentModel` with `DocxSaveOptions`.

## Test Focus
- Schema rejects unsupported nodes/marks.
- DOCX import maps headings/paragraphs/lists/marks/alignment/merge fields.
- GemBox body renderer maps JSON to expected blocks/formats.
- Brand rule browser/GemBox share same stops.
- Preview returns page count, furniture warnings, unresolved merge-field findings.
- Render audit includes content hash, renderer version, furniture version, asset checksums, artifact hash.

## Decision
Do not build one monolithic renderer. Keep input services separate. Centralize style/furniture decisions. Keep browser and GemBox as separate adapters. GemBox remains final output engine.

Target truths:
```text
Body: canonical Tiptap JSON
Furniture: ELDocumentFurnitureLayout + ELBrandAsset
Style: ElDocumentStyleTokens
Output: GemBox DocumentModel
```
