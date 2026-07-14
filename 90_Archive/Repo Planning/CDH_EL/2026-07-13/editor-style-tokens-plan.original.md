# Engagement-Letter Style Tokens — Implementation Plan (full prose)

This is the human-readable companion to `editor-style-tokens-plan.md`. For architecture background, read `editor-gembox-flow-comparison.original.md` first.

Status as of 2026-06-30: this implementation plan has been completed/superseded by the live style-token implementation and remediation follow-up. Keep it as historical context, not as current TODO guidance.

## Context for an agent picking this up cold

The engagement-letter (EL) feature renders the same authored document through **two independent rendering adapters**:

1. **Browser path** — the live Tiptap rich-text editor (`CDH_EL/Components/Shared/ElTiptapEditor.razor`) plus an HTML preview/designer surface (`Lib/Services/Editor/ElDocumentFurnitureRenderer.cs`). This is what the user sees and edits.
2. **GemBox path** — the final output engine. `Lib/Services/Editor/ElTiptapGemBoxBodyRenderer.cs` turns canonical Tiptap JSON into GemBox body blocks; `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs` builds the header/footer "furniture." Today it produces PDF; DOCX export is planned (reuse `BuildDocument` with `DocxSaveOptions`).

Having two adapters is the correct architecture and **must be preserved** — a browser cannot share a rendering engine with a print/PDF library. The defect is narrower: each adapter hardcodes its own copy of the **style decisions** (font family, body/heading sizes, line spacing, paragraph spacing, the CDH brand accent rule). Because the decisions are duplicated rather than shared, they have already drifted. The clearest example: heading font sizes are `18 / 14 / 12 pt` in both the GemBox body renderer and the HTML preview, but the live editor CSS uses `1.65 / 1.3 / 1.08 rem`, which is roughly `19.8 / 15.6 / 13 pt`. The editor and the PDF therefore show different heading sizes today.

The remedy is a single typed source of truth, `ElDocumentStyleTokens`, that every adapter reads from. We replace the hardcoded literals with token lookups. We do **not** merge the renderers, and we do **not** touch the input services (the schema validator/canonicalizer `ElTiptapSchemaService`, or the DOCX importer `ElGemBoxTiptapBodyImporter`) — those are correctly separated already.

A draft of the token type already exists at `Lib/Services/Editor/ElDocumentStyleTokens.cs`. It defines the records `ElDocumentStyleTokens`, `ElHeadingStyleToken`, `ElBrandRuleToken`, and `ElBrandRuleStop`, plus a static `Default` carrying the current CDH values. It is deliberately pure data with no GemBox or CSS dependencies, and it is not yet wired into anything. The first task is to confirm it compiles in `Lib`, then build the rest of the plan on top of it.

### Why points, and why this kills the conversion problem

The canonical unit is the **typographic point (pt)**, with line heights stored as **unitless multipliers**. This is chosen deliberately:

- GemBox is point-native.
- The browser editor CSS already renders body text in points (`font-size: 11pt` in `ElTiptapEditor.razor.css`). CSS supports `pt` directly, so the browser adapter can consume token point values without any px conversion for typography.
- Line-height multipliers (`1.5`, `1.2`, etc.) mean the identical thing in CSS and in GemBox's `LineSpacing` with `LineSpacingRule.Multiple`, so spacing needs no conversion either.

This is what makes the token layer safe: if we stored values in px or rem we would just be rebuilding the drift one layer down.

### Environment notes

- Active branch is `feature/June/26/RTE-TipTap`; PRs target `master`.
- The `CDH_EL` web project frequently cannot be built from the CLI because Visual Studio holds a lock on the output DLL. Stop the VS debugger first, then run `dotnet build`. `Lib` and `Lib.Tests` build fine independently.
- Project rule (CLAUDE.md): consult the HAVIT Blazor MCP before editing any `.razor` file. The edits in this plan are CSS-variable wiring rather than HAVIT component usage, but the check still applies.

## Locked decisions

These were resolved with the requester and should not be reopened:

- **Heading sizes** are canonically `18 / 14 / 12 pt` — the GemBox print values. The editor headings will shrink slightly to match the PDF, which is intended: the PDF is the client-facing deliverable, so the editor should conform to it.
- **Blockquote indent** is `18 pt` (the current GemBox value), not the editor's `1rem` (12pt).
- **Brand rule height** is `4.5 pt` (equivalent to the CSS `6px`).
- **The browser editor consumes tokens by CSS custom-property injection.** The editor component writes `--el-*` custom properties derived from the tokens, and the static `.razor.css` references them via `var(--el-*)`. This *prevents* drift rather than merely detecting it, and it follows the pattern the editor already uses for `--el-page-paper-width` and related page-geometry variables.

### Scope boundary

Tokens cover **typography and the brand rule only**. Furniture *geometry* — page margins, header and footer heights, body insets, logo cell widths — already lives in `ElDocumentPdfLayoutMetrics` and `ElDocumentPageGeometry`, single-sourced through the `PointsPerCssPixel = 0.75` constant. Leave geometry where it is. (This is a deliberate deviation from the comparison doc's Simplify step 1, which lumped "furniture sizing" into the tokens; on inspection that sizing is already centralized, so pulling it into tokens would add churn for no gain.)

## Where the duplication lives

**Brand-rule gradient stops** appear in three code locations plus the editor stylesheet:

- `CDH_EL/Components/Shared/ElTiptapEditor.razor.css:932` — the editor furniture rule, a CSS `linear-gradient`.
- `Lib/Services/Editor/ElDocumentFurnitureRenderer.cs:119` — the HTML preview's inline `<style>`, also a `linear-gradient`.
- `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs:290-291` — the GemBox version, expressed as four table cells with `colors[]` and percentage `widths[]`. Note the encodings differ: the CSS gradient uses cumulative stop positions `50% / 60% / 90% / 100%`, while the GemBox cells use per-cell delta widths `50 / 10 / 30 / 10`. The token stop list uses positions; the GemBox adapter must convert positions to per-cell deltas.

The canonical stops are `#007bff @ 50%`, `#00b9e7 @ 60%`, `#81c341 @ 90%`, `#f7901e @ 100%`.

Other files also contain `linear-gradient` (`HeaderFooterDesigner.razor.css`, `TemplateDetail.razor.css`, `Editor.razor.css`, `EngagementLetterShell.razor.css`, `TemplateCompare.razor.css`). Audit each; convert only those that are the CDH four-stop brand rule and leave unrelated UI/shadow gradients alone.

**Font family `"Arial"`** is hardcoded at `ElTiptapGemBoxBodyRenderer.cs:302` and `:331`, at `ElDocumentFurnitureGemBoxBuilder.cs:325`, and in the CSS `font-family` chains.

**Body and heading typography** diverge between `ElTiptapGemBoxBodyRenderer.cs:18-22,235-236,242,257-265` and the editor CSS `ElTiptapEditor.razor.css:1044-1094`. The HTML preview renderer at `ElDocumentFurnitureRenderer.cs:124-142` already matches the canonical point values — only confirm it, then route it through tokens so the agreement is enforced rather than coincidental.

## Implementation steps

### Step 0 — Finalize the token type
The draft `Lib/Services/Editor/ElDocumentStyleTokens.cs` already carries the locked values. Confirm it compiles inside `Lib` and that it stays pure (no GemBox or CSS types creep in). Everything downstream depends on this contract.

### Step 1 — GemBox body renderer reads tokens
In `Lib/Services/Editor/ElTiptapGemBoxBodyRenderer.cs`, add an `ElDocumentStyleTokens tokens` parameter to both `RenderBlocks` overloads and thread it through `CreateParagraph`, `CreateHeading`, `CreateRun`, and `AddInlineContent`. Replace each literal with its token equivalent: the static `HeadingSizes` dictionary becomes `tokens.Headings` / `tokens.HeadingFallback`; the body `SpaceAfter = 11`, `LineSpacing = 1.5`, and `fontSize: 11` become `tokens.ParagraphSpaceAfterPt`, `tokens.BodyLineHeight`, and `tokens.BodyFontSizePt`; the per-level heading line-spacing/space-before/space-after ternaries become lookups into `tokens.Headings[level]`; the blockquote `LeftIndentation += 18` becomes `tokens.BlockquoteIndentPt`; and `FontName = "Arial"` becomes `tokens.FontFamily`. Bump `RendererVersion` from `1` to `2` so the change is reflected in the render audit.

### Step 2 — GemBox furniture builder reads tokens
In `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs`, thread `tokens` through `ApplyFurniture(...)` (it is invoked from `ElDocumentRenderService.BuildDocument`). In `CreateBrandRule`, derive the `colors` and per-cell `widths` from `tokens.BrandRule.Stops` (converting cumulative stop positions into per-cell delta widths) and take the row height from `tokens.BrandRule.HeightPt`. Replace the `FontName = "Arial"` in the `Paragraph(...)` helper with `tokens.FontFamily`.

### Step 3 — Render service plumbs tokens
In `Lib/Services/Editor/ElDocumentRenderService.cs`, add a constructor parameter `ElDocumentStyleTokens? styleTokens = null`, resolving to `styleTokens ?? ElDocumentStyleTokens.Default`. Pass it into `bodyRenderer.RenderBlocks(...)` and `ElDocumentFurnitureGemBoxBuilder.ApplyFurniture(...)`. Optionally record the token version in `ElDocumentRenderAudit`. Confirm the DI registration in `Program.cs`/startup still resolves with the new optional parameter.

### Step 4 — HTML preview renderer reads tokens
In `Lib/Services/Editor/ElDocumentFurnitureRenderer.cs`, accept an `ElDocumentStyleTokens` (constructor injection or method parameter) and emit the inline `<style>` gradient (`:119`), heading sizes (`:136-138`), body font-size (`:125`), and font-family (`:59`) from the tokens. These values already match the canonical set; the goal is to make them share one source.

### Step 5 — Editor CSS via injected CSS variables
In `CDH_EL/Components/Shared/ElTiptapEditor.razor` and its `.razor.css`, have the component emit inline custom properties on `.el-tiptap-shell` (or the page root) from `ElDocumentStyleTokens.Default`: `--el-font-family`, `--el-body-size`, `--el-body-line`, `--el-h1-size`/`--el-h1-line` (and h2/h3), `--el-brand-rule-gradient`, and `--el-brand-rule-height`. Mirror the existing injection pattern used for `--el-page-paper-width`. Then switch the hardcoded typography (`:1044-1094`) and the furniture `linear-gradient` (`:932`) in the stylesheet to `var(--el-*)`. This is the change that eliminates the live editor/PDF heading-size drift. The `ElEditorFurnitureHtmlFactory` brand-rule element is styled by the same `.razor.css` rule, so it is covered automatically once the CSS variable is in place.

### Step 6 — Parity guarantee test
Add a test under `Lib.Tests/Services/EngagementLetters/` (or a new `Editor/` test file beside the existing renderer tests). Render through `ElTiptapGemBoxBodyRenderer` and the furniture builder using a deliberately **non-default** `ElDocumentStyleTokens`, and assert the output reflects the custom values (a heading size, the body size, and the brand-rule first-stop color). This proves no hardcoded literal survives. Also assert that the GemBox brand-rule cell colors are derived from `tokens.BrandRule.Stops`. Without this test nothing *enforces* the single source, and a future contributor can silently re-hardcode a value.

## Deferred (explicitly not in this PR)

- `ElDocumentRenderContextBuilder` — a later helper that gathers JSON, furniture, assets, tokens, merge values, and diagnostics into one context. Do this only after the tokens land.
- Per-template or database-driven token overrides. The record shape already supports this; loading overrides from persistence is a separate change.
- DOCX export reusing `BuildDocument` with `DocxSaveOptions` — there is an existing `TODO` at `ElDocumentRenderService.cs:87`.

## Verification

1. **Build** with `dotnet build` after stopping the Visual Studio debugger (it locks the output DLL). If the build tooling itself fails, report the exact command and error rather than guessing.
2. **Tests** with `dotnet test Lib.Tests`: the new parity test should pass and the existing renderer/import/schema tests should stay green. The current baseline is 132 of 134 passing; the two failures are pre-existing and unrelated to this work.
3. **PDF path**: render a draft template to PDF and confirm the headers/footers, the four-color brand rule, the heading sizes, and the body font are unchanged. Because the canonical values already matched the PDF, the PDF output should be visually identical.
4. **Editor path**: open a draft template in the Tiptap editor and confirm the headings now render at 18/14/12 pt (slightly smaller than before) and the brand rule matches the PDF. Check desktop and mobile widths and watch the browser console for CSS-variable or static-asset errors. Per AGENTS.md, only perform browser verification if it is explicitly requested.
5. **Cross-check the whole point**: temporarily change one token value, rebuild, and confirm both the editor and the PDF shift together. That single-source behavior is the entire objective of the change.
