# Editor, Furniture, and GemBox Flow Comparison

## Purpose

This document explains the current engagement-letter editor architecture, why some components look duplicated, and how the system can be simplified without losing important separation of concerns.

The intended long-term model has two durable bases:

- **Canonical Tiptap JSON** for body text storage, structured manipulation, merge-field tracking, indexing, and comparison.
- **GemBox DocumentModel** for DOCX import, PDF export, future DOCX export, pagination, and issued-document rendering.

Header/footer furniture is a separate durable input. It is not part of body JSON. It comes from app-owned layout settings and brand assets.

Related diagram files:

- Mermaid source: `docs/reference/el-editor-gembox-flow.mmd`
- SVG image: `docs/reference/el-editor-gembox-flow.svg`
- PNG image: `docs/reference/el-editor-gembox-flow.png`

## Current Durable Truths

### Body Truth

Body content is canonical Tiptap JSON. The schema service validates and canonicalizes submitted editor JSON before persistence or rendering.

Important files:

- `Lib/Services/Editor/ElTiptapSchemaService.cs`
- `Lib/Services/Editor/ElTiptapSchemaDefinition.cs`
- `docs/reference/el-tiptap-schema-definition.v2.json` (current; V1 historical)

The schema intentionally allows a narrow engagement-letter body vocabulary: paragraphs, headings, lists, task items, block quotes, bold, italic, underline, structured merge fields, and EL structural wrappers.

### Furniture Truth

Header/footer furniture is app-owned and separate from body JSON.

Important files:

- `CDH_EL/Components/Pages/HeaderFooterDesigner.razor`
- `Lib/Services/Editor/ElDocumentFurnitureLayoutService.cs`
- `Lib/Services/Editor/ElBrandAssetService.cs`
- `Lib/Models/EL/ELDocumentFurnitureLayout.cs`
- `Lib/Models/EL/ELBrandAsset.cs`

The `/templates/header-footer` page edits furniture layout settings and active brand assets. The editor consumes those settings as non-editable page chrome. PDF export consumes those same settings through GemBox furniture rendering.

### Output Truth

GemBox owns final document output. The current preview and render paths already avoid the old HTML bridge for the body. They validate JSON, map body JSON directly to GemBox blocks, add furniture, then save PDF bytes.

Important files:

- `Lib/Services/Editor/ElTiptapGemBoxBodyRenderer.cs`
- `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs`
- `Lib/Services/Editor/ElDocumentPdfPreviewService.cs`
- `Lib/Services/Editor/ElDocumentRenderService.cs`

### Import Truth

DOCX import uses GemBox to load Word documents, then maps the loaded body model into candidate Tiptap JSON. The schema service remains the final persistence gate.

Important files:

- `Lib/Services/Editor/ElDocxImportService.cs`
- `Lib/Services/Editor/ElGemBoxTiptapBodyImporter.cs`

Word headers and footers are intentionally skipped on import. App furniture wraps imported body content later.

## Current Flow

```text
DOCX import:
DOCX -> GemBox DocumentModel -> ElGemBoxTiptapBodyImporter -> candidate Tiptap JSON -> schema canonicalization

Browser body editing:
/editor or template editor -> Tiptap JSON -> schema canonicalization -> persisted canonical JSON

Header/footer editing:
/templates/header-footer -> ELDocumentFurnitureLayout + ELBrandAsset

Browser preview:
canonical JSON + furniture layout/assets -> editor body CSS + browser furniture HTML/page-flow chrome

PDF output:
canonical JSON -> ElTiptapGemBoxBodyRenderer -> GemBox body blocks
furniture layout/assets -> ElDocumentFurnitureGemBoxBuilder -> GemBox headers/footers
GemBox DocumentModel -> PDF bytes
```

## Why Components Feel Duplicated

The code currently has multiple components that describe similar document-looking surfaces:

| Concern | Browser editor | Header/footer designer preview | PDF/GemBox output |
|---|---|---|---|
| Body text display | Tiptap + `ElTiptapEditor.razor.css` | Not primary | `ElTiptapGemBoxBodyRenderer` |
| Header/footer HTML | `ElEditorFurnitureHtmlFactory` | `ElEditorFurnitureHtmlFactory` | Not used |
| Header/footer final output | Not used | Not used | `ElDocumentFurnitureGemBoxBuilder` |
| Furniture preview HTML wrapper | Debug/preview support | `ElDocumentFurnitureRenderer` | Not used for final body render |
| Brand rule | CSS `linear-gradient(...)` | CSS `linear-gradient(...)` | Four solid GemBox table cells |
| Typography | CSS values | CSS values | hardcoded GemBox paragraph/heading values |

Some duplication is legitimate because browser layout and GemBox layout are different output engines. The problematic duplication is not the existence of separate renderers. The problematic duplication is that style and furniture rules are hardcoded independently inside those renderers.

## Known Drift Examples

### Brand Rule Gradient

The editor and designer render the multi-color brand rule as a CSS gradient. GemBox currently renders the same rule as four solid table cells. This preserves color order but loses gradient transitions in PDF.

This is not a Tiptap JSON issue. It is a furniture rendering drift between browser CSS and GemBox object model.

### Body Typography

The editor CSS and GemBox body renderer both target Arial 11pt body text, but headings, paragraph spacing, and margins are expressed separately. Browser CSS uses CSS units and margins; GemBox uses point sizes, line spacing, and `SpaceBefore` / `SpaceAfter`.

The values can be aligned, but raw CSS should not be the final output truth.

### Furniture Preview Paths

The app has browser furniture HTML for `/editor` and `/templates/header-footer`, and GemBox furniture building for PDF. This is reasonable. But both should consume the same furniture model and style tokens so the only difference is the rendering adapter.

### Documentation Drift

Some docs still describe the older `generated HTML -> GemBox HTML load -> PDF` body path. Current code uses direct JSON-to-GemBox body rendering for PDF preview and render service.

## What Should Stay Separate

Do not merge these concerns into one large class:

- `ElTiptapSchemaService`: owns canonical JSON validation, generated HTML/text cache output, node indexing, field usage, and diffing.
- `ElGemBoxTiptapBodyImporter`: maps GemBox-loaded DOCX body into Tiptap JSON. This is the import direction.
- `ElTiptapGemBoxBodyRenderer`: maps canonical JSON into GemBox body blocks. This is the output direction.
- `IElDocumentRenderService`: application-facing service boundary for output artifacts.
- `/templates/header-footer`: product surface for app-owned furniture design.

Keeping these separate preserves testability and protects the JSON contract from output-specific concerns.

## What Can Be Combined or Simplified

### 1. Centralize Document Style Tokens

Create a shared style token source, for example `ElDocumentStyleTokens`.

It should hold document-level values such as:

- font family
- body font size
- body line height
- paragraph spacing
- heading sizes and spacing
- block quote inset/border style
- brand rule colors, stops, and height
- furniture header/footer text sizing
- page geometry references

Browser CSS and GemBox formatting should both consume this token source.

This does not mean GemBox should parse raw CSS. It means both renderers should use the same named values.

### 2. Centralize Furniture View Model

Create a small furniture render model that resolves layout settings and assets once.

Possible shape:

```csharp
public sealed record ElDocumentFurnitureViewModel(
    ElDocumentFurnitureLayoutSnapshot Layout,
    ElBrandAssetSnapshot? HeaderLogo,
    ElBrandAssetSnapshot? FooterMark,
    ElDocumentFurnitureMergeValues MergeValues,
    IReadOnlyList<ElDocumentFurnitureRenderFinding> Findings);
```

Then both browser furniture rendering and GemBox furniture rendering consume the same resolved model.

### 3. Keep Separate Render Adapters

Use separate adapters for separate output engines:

- Browser adapter: furniture model + style tokens -> HTML/CSS page chrome.
- GemBox adapter: furniture model + style tokens -> GemBox headers/footers/body formatting.

This keeps modularity while removing duplicated business/style decisions.

### 4. Optionally Add an Orchestration Builder

A higher-level builder can gather body JSON, furniture, assets, merge values, and tokens into a single logical render request.

Possible name:

- `ElDocumentRenderContextBuilder`
- `ElDocumentModelBuilder`
- `ElDocumentCompositionService`

This builder should not replace the schema service or GemBox importer. It should coordinate inputs for preview/export.

## Simplified Target Flow

```text
Durable inputs:
canonical Tiptap JSON
ELDocumentFurnitureLayout
ELBrandAsset
ElDocumentStyleTokens
merge values

Composition:
ElDocumentRenderContextBuilder gathers durable inputs and diagnostics.

Browser output:
Render context -> browser adapter -> /editor chrome + /templates/header-footer preview

GemBox output:
Render context -> GemBox adapter -> DocumentModel -> PDF now, DOCX later

Import:
DOCX -> GemBox DocumentModel -> importer -> canonical Tiptap JSON
```

## Evaluation Options

### Option A: Leave Current Structure Alone

This is lowest effort but keeps drift risk.

Pros:

- Minimal code churn.
- Existing tests remain stable.
- Current preview/export path already uses direct JSON-to-GemBox body rendering.

Cons:

- Brand rule gradient and typography drift remain likely.
- Future changes to furniture or document styling must touch multiple places.
- Agents may keep confusing debug HTML, editor HTML, and GemBox output.

Use only if the editor/furniture work is paused.

### Option B: Tokenize Style Only

This centralizes font sizes, spacing, page geometry references, and brand rule stops without changing major service boundaries.

Pros:

- Best first step.
- Fixes biggest reason browser and PDF drift.
- Keeps current modular services.
- Easy to test with focused renderer tests.

Cons:

- Still has separate browser and GemBox furniture renderers.
- Does not fully simplify mental model.

Recommended first implementation step.

### Option C: Tokenize Style and Furniture Model

This adds both `ElDocumentStyleTokens` and a shared resolved furniture model.

Pros:

- Reduces real duplication.
- Makes `/editor`, `/templates/header-footer`, and PDF furniture consume the same furniture inputs.
- Preserves separate browser/GemBox adapters.
- Clean fit for future DOCX export.

Cons:

- Medium refactor.
- Requires careful parity tests for existing furniture output.

Recommended target shape.

### Option D: One Unified Document Model Builder

This adds a higher-level builder that composes body JSON, furniture, assets, style tokens, merge values, and diagnostics before handing off to browser or GemBox adapters.

Pros:

- Best mental model for humans and agents.
- One place to understand what a document render needs.
- Strong foundation for issued-document audit snapshots.

Cons:

- Larger refactor.
- Easy to overbuild if done before style/furniture tokenization.

Use after Option B or C proves stable.

### Option E: Feed Raw Editor CSS Into GemBox

This attempts to make GemBox consume editor CSS directly.

Pros:

- Appears conceptually simple.
- Single visible styling language.

Cons:

- Reintroduces CSS interpretation drift.
- GemBox and browsers do not support identical layout/CSS semantics.
- Harder to test exact output.
- PDF output may silently lose features such as gradients, advanced layout, or browser-specific CSS.

Not recommended for final output.

## Recommended Plan

Implementation update, 2026-06-29:

- Stale documentation was corrected to describe direct canonical JSON to GemBox body rendering instead of generated HTML loaded by GemBox.
- `ElDocumentStyleTokens` was added as the shared source for document typography and brand-rule style decisions.
- Browser furniture and GemBox furniture now consume shared brand-rule tokens. GemBox renders the brand rule as a generated PNG strip from the same stops instead of four independently hardcoded table cells.
- `ElDocumentFurnitureViewModel` was added so preview/render paths can share resolved layout, assets, merge values, and findings.
- `ElDocumentRenderContextBuilder` and DOCX export remain later optional work.

### Phase 1: Correct Documentation

Update docs to reflect current reality:

```text
canonical JSON -> GemBox body blocks -> GemBox DocumentModel -> PDF
```

Remove stale wording that says body PDF still depends on generated HTML loaded by GemBox.

### Phase 2: Add Style Tokens

Add a shared token source for:

- Arial body font
- 11pt body size
- paragraph spacing
- heading sizes
- body line height
- brand rule stops
- brand rule height
- furniture spacing values

Wire GemBox renderers to use those tokens first. Then update browser CSS to mirror the same named values.

### Phase 3: Fix Brand Rule Rendering

Use shared brand-rule tokens for both browser and PDF.

Recommended PDF implementation:

- Browser: CSS `linear-gradient(...)`.
- GemBox: generated PNG strip or GemBox-supported drawing equivalent from the same stops.

Generated PNG is the safer first choice because it avoids uncertain gradient support in PDF conversion.

### Phase 4: Shared Furniture View Model

Resolve furniture layout and assets once per render/preview request.

Both browser and GemBox renderers should receive the same resolved model and findings.

### Phase 5: Optional Composition Builder

Introduce `ElDocumentRenderContextBuilder` or similar only after tokens and furniture view model are stable.

This builder should make the system easier to reason about without collapsing all responsibilities into one class.

### Phase 6: Future DOCX Export

Reuse the same GemBox `DocumentModel` path and save with `DocxSaveOptions`.

This should not require a new body model if JSON-to-GemBox rendering is already authoritative.

## Suggested Test Coverage

Add or keep tests in these areas:

- JSON schema canonicalization rejects unsupported nodes/marks.
- DOCX import maps headings, paragraphs, lists, marks, alignment, and known merge fields into canonical JSON.
- GemBox body renderer maps canonical JSON into expected GemBox blocks and paragraph formats.
- Furniture GemBox builder uses same brand rule stops as browser style tokens.
- PDF preview returns page count, warnings, and unresolved merge-field findings.
- Render service returns audit metadata with content hash, renderer version, furniture version, asset checksums, and artifact hash.
- Browser furniture renderer and GemBox furniture builder consume same resolved furniture model.

## Decision Summary

The system does not need one monolithic renderer. It needs one set of durable truths and one set of style/furniture decisions.

Recommended durable truths:

```text
Body: canonical Tiptap JSON
Furniture: ELDocumentFurnitureLayout + ELBrandAsset
Style: ElDocumentStyleTokens
Output: GemBox DocumentModel
```

Recommended architecture:

```text
Input services stay separate.
Style/furniture decisions become shared.
Browser and GemBox remain separate adapters.
GemBox remains final output engine.
```

This keeps the important modularity while removing the duplication that creates visual drift.
