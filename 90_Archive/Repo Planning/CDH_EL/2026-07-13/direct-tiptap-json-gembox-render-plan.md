# Plan: Direct Tiptap JSON → GemBox DocumentModel rendering

## Status

Implemented. Current PDF preview/render path is:

```text
Tiptap JSON -> strict schema -> ElTiptapGemBoxBodyRenderer -> GemBox body blocks -> furniture -> GemBox DocumentModel -> PDF
```

`ElTiptapValidatedDocument.Html` remains useful for browser/debug preview surfaces, but it is not
the body input for GemBox PDF output. Style and furniture decisions now start moving through
`ElDocumentStyleTokens` and `ElDocumentFurnitureViewModel` so browser adapters and GemBox adapters
share named document decisions while staying separate renderers.

## Context

Before this migration, the issued-document path was:

```
Tiptap JSON → strict schema → generated HTML → GemBox HTML load → GemBox PDF
```

This was the old weak joint. Browser, CSS, and GemBox each
paginate differently, so the code carries page-count drift warnings
([ElDocumentPdfPreviewService.cs:95](Lib/Services/Editor/ElDocumentPdfPreviewService.cs:95),
[ElTiptapSchemaResults.cs:115](Lib/Services/Editor/ElTiptapSchemaResults.cs:115)) to surface the
gap rather than close it. That HTML round-trip is fine for a fast editor preview but is a poor
foundation for legally issued documents.

**Key finding from exploration:** the migration is narrower than it first appears. The PDF
service *already* builds furniture (headers, footers, brand rules, logos, page setup, license,
page count) directly in the GemBox object model
([ElDocumentPdfPreviewService.cs:152-384](Lib/Services/Editor/ElDocumentPdfPreviewService.cs:152)).
The body bridge has been replaced. `RenderPdf` now validates canonical JSON, asks
`ElTiptapGemBoxBodyRenderer` for GemBox blocks, and adds those blocks directly to the output
section.

So the production fix = **one new component** that maps canonical Tiptap JSON nodes straight to
GemBox `Block`s, replacing the HTML→`DocumentModel` round-trip. Everything else (furniture, page
geometry, merge values, license) is reused as-is.

**Outcome:** GemBox becomes the single final-layout engine. No CSS interpretation gap. Browser
page-flow demoted to editor aid / debug only. Audit metadata (JSON hash, furniture version, asset
hashes, renderer version) computed per render for future issued-document provenance.

**Scope decisions (confirmed with user):**
- New `ElDocumentRenderService` built **in parallel** with the existing preview service. HTML
  preview stays as debug-only bridge until the direct output is verified.
- Targets **preview PDF + final PDF** from one `DocumentModel`.
- **Page count + audit metadata** computed and returned in the result.
- Audit-snapshot **persistence is design-only** this round (table/columns specced, no migration).
- **DOCX export deferred** — the design keeps the `DocumentModel` reusable so DOCX is a later
  `RenderDocxAsync` addition, but it is not built here.

---

## Architecture

New target pipeline:

```
Canonical Tiptap JSON (ELDocumentRevision.editor_json)
  → IElTiptapSchemaService.ValidateAndCanonicalize   (reuse, existing)
  → ElTiptapGemBoxBodyRenderer: canonical JSON → GemBox Block[]   (NEW)
  → furniture + page setup in GemBox object model   (reuse, existing)
  → GemBox DocumentModel
  → PdfSaveOptions → PDF bytes + page count + audit metadata
```

The HTML the schema service already produces (`ElTiptapValidatedDocument.Html`) stays in use for
the **editor preview pane** and diagnostics only — it is no longer the input to GemBox for the
issued/production path.

---

## Files to create

### 1. `Lib/Services/Editor/ElTiptapGemBoxBodyRenderer.cs` (the core new component)

Maps canonical Tiptap JSON → GemBox `Block[]`. This is the replacement for the HTML bridge.

- Input: `ElTiptapValidatedDocument` (so it consumes the already-canonicalized JSON, not raw).
  Parse `validated.CanonicalJson` with `System.Text.Json.Nodes.JsonNode`.
- Output: `IReadOnlyList<Block>` ready to add to a GemBox `Section`.
- Walk the canonical tree mirroring the node set in
  [ElTiptapSchemaDefinition.cs:67-113](Lib/Services/Editor/ElTiptapSchemaDefinition.cs:67). The
  schema is the contract — map exactly the persisted node/mark types, nothing speculative:

  | Tiptap node | GemBox mapping |
  |---|---|
  | `doc` | iterate children |
  | `paragraph` | `Paragraph`; `textAlign` attr → `ParagraphFormat.Alignment` |
  | `heading` | `Paragraph` with heading run sizing (mirror the h1/h2/h3 pt sizes inlined at [ElDocumentPdfPreviewService.cs:63-65](Lib/Services/Editor/ElDocumentPdfPreviewService.cs:63)); clamp level 1-6 |
  | `text` + marks | `Run`; `bold`→`Bold`, `italic`→`Italic`, `underline`→`UnderlineStyle.Single` |
  | `bulletList` / `orderedList` / `listItem` | GemBox `ListFormat` (`ListType.Bulleted` / `ListType.Numbered`); honor `orderedList.start`; nesting via list level |
  | `taskList` / `taskItem` | bulleted list; prefix run `☑ ` / `☐ ` from `checked` attr (GemBox has no native checkbox) |
  | `blockquote` | indented paragraphs (left indentation) |
  | `elMergeField` | `Run` with the resolved/token text — `{{ Label }}` when no merge value, else substituted value. Reuse the token format from [ElMergeFieldCatalog.cs](Lib/Services/Editor/ElMergeFieldCatalog.cs) |
  | `elSection` / `elClause` / `elConditionalBlock` / `elRequiredClause` / `elProjectOverride` | structural wrappers → render children as blocks (no visual box in PDF unless layout calls for it) |

- Apply body inset/width exactly as `ApplyBodyInset` does today
  ([line 120-134](Lib/Services/Editor/ElDocumentPdfPreviewService.cs:120)) — left/right indentation
  `ElDocumentPdfLayoutMetrics.BodyInsetPt`, table width `BodyWidthPt`. Factor this into the new
  renderer so spacing matches the current output and drift goes to zero by construction.
- Centralize a `RendererVersion` const here (e.g. `1`) for audit metadata.

**Why a separate class:** keeps EF/HTTP/business rules out, single responsibility, directly unit
testable against canonical JSON without GemBox PDF round-trips (assert the `Block` tree).

### 2. `Lib/Services/Editor/ElDocumentRenderService.cs` + interface

Orchestrator that owns the final `DocumentModel`. Mirrors the existing preview service's
constructor deps so DI is a copy-paste.

- `IElDocumentRenderService` with:
  - `Task<ElDocumentRenderResult> RenderPdfAsync(string editorJson, ElDocumentFurnitureMergeValues mergeValues, ElDocumentRenderOptions options, CancellationToken)`
  - (designed-for, **not implemented now**) `RenderDocxAsync(...)` — leave an `// TODO: DOCX`
    seam; the `DocumentModel` it builds is format-agnostic.
- Flow inside `RenderPdfAsync`:
  1. `EnsureGemBoxLicense` — extract the license helper
     ([line 460-483](Lib/Services/Editor/ElDocumentPdfPreviewService.cs:460)) into a shared
     internal static (e.g. `ElGemBoxLicense.Ensure(key)`) so preview, render, and DOCX import all
     share one initializer instead of three copies.
  2. `schemaService.ValidateAndCanonicalize(editorJson)` → validated doc.
  3. Load active furniture layout + brand assets (`layoutService.GetActiveAsync`,
     `brandAssetService.GetActiveAssetAsync`) — same as preview.
  4. Build `DocumentModel` + `Section`, `ApplyLetterPageSetup`, `ApplyFurniture` — **reuse the
     existing furniture methods**. Extract them from the preview service into a shared internal
     `ElDocumentFurnitureGemBoxBuilder` (move methods 152-384) so both services call one
     implementation. No behavior change, pure relocation.
  5. `section.Blocks` ← `ElTiptapGemBoxBodyRenderer` output (the new path; no HTML, no
     `DocumentModel.Load`).
  6. `pageCount = document.GetPaginator().Pages.Count`.
  7. `document.Save(PdfSaveOptions)` → bytes.
  8. Build audit metadata (see below) and return.

### 3. `ElDocumentRenderResult` + `ElDocumentRenderOptions` records

Add to a new file or `ElTiptapSchemaResults.cs` (matches existing record-grouping style):

```csharp
public sealed record ElDocumentRenderResult(
    byte[] Bytes,
    string FileName,
    string ContentType,            // "application/pdf"
    int PageCount,
    ElDocumentRenderAudit Audit,
    IReadOnlyList<ElDocumentFurnitureRenderFinding> Findings);

public sealed record ElDocumentRenderAudit(
    string ContentHash,            // validated.ContentHash (SHA256 of canonical JSON)
    int EditorSchemaVersion,
    int RendererVersion,           // ElTiptapGemBoxBodyRenderer.RendererVersion
    int FurnitureVersion,          // from layout snapshot / furniture marker
    string? HeaderLogoChecksum,    // ElBrandAssetSnapshot.Checksum
    string? FooterMarkChecksum,
    string ArtifactSha256);        // SHA256 of produced PDF bytes
```

`ElDocumentRenderOptions` carries flags like `FileName` and (future) target format.

### 4. Tests: `Lib.Tests/Services/Editor/ElTiptapGemBoxBodyRendererTests.cs` and `ElDocumentRenderServiceTests.cs`

Follow the established pattern in
[ElDocumentPdfPreviewServiceTests.cs](Lib.Tests/Services/Editor/ElDocumentPdfPreviewServiceTests.cs)
(Fake `IElBrandAssetService` / `IElDocumentFurnitureLayoutService` / `IElTiptapSchemaService`,
assert on extracted PDF text + MediaBox).

- Body renderer unit tests (no PDF): each node/mark type produces the expected `Block`/`Run`
  shape; merge field token vs substituted value; list numbering/start; body inset applied.
- Render service tests: returns PDF bytes, Letter MediaBox, furniture text present, audit hash =
  validated content hash, `ArtifactSha256` stable for identical input, invalid JSON throws
  `ElTiptapSchemaValidationException`.

---

## Files to modify

- **`Lib/Services/Editor/ElDocumentPdfPreviewService.cs`** — validates current JSON, renders GemBox
  body blocks directly, applies shared furniture/page setup, and keeps browser furniture HTML only
  as companion preview/debug output.
- **`CDH_EL/Program.cs`** — register the new service next to the preview registration
  ([Program.cs:57-62](CDH_EL/Program.cs:57)):
  ```csharp
  builder.Services.AddScoped<ElTiptapGemBoxBodyRenderer>();
  builder.Services.AddScoped<IElDocumentRenderService>(sp => new ElDocumentRenderService(
      sp.GetRequiredService<IElTiptapSchemaService>(),
      sp.GetRequiredService<ElTiptapGemBoxBodyRenderer>(),
      sp.GetRequiredService<IElDocumentFurnitureLayoutService>(),
      sp.GetRequiredService<IElBrandAssetService>(),
      builder.Configuration["GemBox:LicenseKey"]));
  ```
- **No caller switch yet.** `Editor.razor` preview button keeps calling the preview service. A
  later, separately-approved step points the *issued/final* export at `IElDocumentRenderService`.

---

## Designed, not built this round

- **Audit-snapshot persistence.** Spec only: a future `ELDocumentRenderSnapshot` table
  (`document_revision_id` FK, `content_hash`, `renderer_version`, `furniture_version`,
  `artifact_sha256`, `artifact_bytes varbinary(MAX)`, asset checksums, `date_created_utc`).
  Migration name per AGENTS.md: `add_table_ELDocumentRenderSnapshot`. The `ElDocumentRenderAudit`
  record above is shaped to map onto it 1:1 when built.
- **DOCX export.** `RenderDocxAsync` over the same `DocumentModel` + `Save(stream, new
  DocxSaveOptions())`. Seam left in the interface; not implemented.
- **Final-export caller switch + MVC route retirement.** Separate approval per AGENTS.md route
  rules.

---

## Verification

1. **Build:** `dotnet build` from repo root. Report exact failure if tooling errors.
2. **Unit tests:** `dotnet test Lib.Tests` — new renderer + render-service tests green, existing
   preview tests still green (proves furniture/license extraction was behavior-preserving).
3. **Output parity (manual, on request):** for a representative engagement-letter revision,
   generate both the old HTML-bridge PDF and the new direct PDF; compare page count and visual
   layout. Goal: page-count drift = 0 because the body renderer applies the same inset/width/sizing
   metrics. Capture any divergence as renderer follow-ups.
4. **Audit sanity:** assert `Audit.ContentHash == ValidatedDocument.ContentHash` and that
   `ArtifactSha256` is deterministic across two renders of identical input + assets.
