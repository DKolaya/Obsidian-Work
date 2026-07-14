# EL Style Tokens — Implementation Plan (agent reference)

Compressed plan. Full prose: `editor-style-tokens-plan.original.md`. Architecture background: `editor-gembox-flow-comparison.md`.

Status 2026-06-30: implemented/superseded by the live style-token code and remediation follow-up. Keep as historical plan context, not current work queue.

## Cold-start context (read first)
- Branch: `feature/June/26/RTE-TipTap`. PR target: `master`.
- EL editor renders doc twice: **browser** path (live Tiptap editor + HTML preview/designer) and **GemBox** path (PDF now, DOCX later). Two adapters = intended design. Keep separate.
- Problem: style decisions (typography, spacing, brand accent rule) hardcoded **independently** in each adapter → drift. Already-shipped drift: heading sizes `18/14/12pt` in GemBox + HTML preview, but `1.65/1.3/1.08rem` (~19.8/15.6/13pt) in live editor CSS.
- Fix: one typed source of truth `ElDocumentStyleTokens`. Every adapter reads from it. Replace literals. Do NOT merge renderers. Do NOT touch input services (schema, importer).
- **Draft already written**: `Lib/Services/Editor/ElDocumentStyleTokens.cs` (records `ElDocumentStyleTokens`, `ElHeadingStyleToken`, `ElBrandRuleToken`, `ElBrandRuleStop`, static `Default`). Pure data, no GemBox/CSS types. Not yet wired to anything. Verify it compiles, then build on it.
- Canonical unit = **points (pt)**. Line-heights = **unitless multipliers** (identical in CSS + GemBox). CSS already uses `pt` for body (`font-size:11pt`), so browser consumes pt directly — no px conversion needed for typography.
- Build caveat: CDH_EL won't build via CLI while Visual Studio holds the DLL lock. Stop VS debugger first, then `dotnet build`.
- UI rule (CLAUDE.md): run HAVIT Blazor MCP before editing `.razor`. Brand-rule/typography edits here are CSS-var wiring, not Hx components, but check anyway.

## Locked decisions (do not re-litigate)
- Heading sizes canonical = **18/14/12 pt** (GemBox print values; editor shrinks to match PDF).
- Blockquote indent = **18 pt** (GemBox value).
- Brand rule height = **4.5 pt** (= 6px).
- Browser consumes tokens via **CSS custom-property injection** (drift prevented, not just detected). Matches existing `--el-page-*` var pattern.
- Scope = **typography + brand rule only**. Furniture geometry (margins, header/footer heights, body insets) stays in `ElDocumentPdfLayoutMetrics` + `ElDocumentPageGeometry` (already single-sourced via `PointsPerCssPixel`). Leave it.

## Duplication map (targets to replace)
Brand-rule gradient stops — 3 code locations + CSS:
- `CDH_EL/Components/Shared/ElTiptapEditor.razor.css:932` — editor furniture `linear-gradient`
- `Lib/Services/Editor/ElDocumentFurnitureRenderer.cs:119` — preview HTML `<style>` `linear-gradient`
- `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs:290-291` — GemBox `colors[]`+`widths[]`. NOTE: cell widths `50/10/30/10` = *deltas* of gradient stops `50/60/90/100`. Convert stop positions → per-cell delta widths.
- Other `linear-gradient` hits (`HeaderFooterDesigner.razor.css`, `TemplateDetail.razor.css`, etc.): audit each; convert ONLY the CDH 4-stop brand rule, leave unrelated shadow/UI gradients.

Font family `"Arial"`: `ElTiptapGemBoxBodyRenderer.cs:302,331`, `ElDocumentFurnitureGemBoxBuilder.cs:325`, plus CSS `font-family` chains.

Body/heading typography: `ElTiptapGemBoxBodyRenderer.cs:18-22,235-236,242,257-265` vs editor CSS `ElTiptapEditor.razor.css:1044-1094`. HTML preview `ElDocumentFurnitureRenderer.cs:124-142` already matches canonical pt — confirm only.

Brand-rule stops (canonical): `#007bff @50%`, `#00b9e7 @60%`, `#81c341 @90%`, `#f7901e @100%`.

## Steps

**0. Finalize token type.** `ElDocumentStyleTokens.cs` drafted. Confirm compiles in `Lib`, stays pure (no GemBox/CSS types). Contract for all later steps.

**1. GemBox body renderer reads tokens** — `Lib/Services/Editor/ElTiptapGemBoxBodyRenderer.cs`
- Add `ElDocumentStyleTokens tokens` param to both `RenderBlocks` overloads; thread to `CreateParagraph`/`CreateHeading`/`CreateRun`/`AddInlineContent`.
- Replace literals: `HeadingSizes` dict→`tokens.Headings`/`HeadingFallback`; `SpaceAfter=11`/`LineSpacing=1.5`/`fontSize:11`→`tokens.ParagraphSpaceAfterPt`/`BodyLineHeight`/`BodyFontSizePt`; heading line-spacing/space-before/after ternaries→`tokens.Headings[level]`; blockquote `+=18`→`tokens.BlockquoteIndentPt`; `FontName="Arial"`→`tokens.FontFamily`.
- Bump `RendererVersion`→`2` (flows into audit).

**2. GemBox furniture builder reads tokens** — `Lib/Services/Editor/ElDocumentFurnitureGemBoxBuilder.cs`
- Thread `tokens` through `ApplyFurniture(...)` (called from `ElDocumentRenderService.BuildDocument`).
- `CreateBrandRule`: derive `colors`/`widths` from `tokens.BrandRule.Stops` (positions→delta widths); row height from `tokens.BrandRule.HeightPt`.
- `Paragraph(...)` helper `FontName="Arial"`→`tokens.FontFamily`.

**3. Render service plumbs tokens** — `Lib/Services/Editor/ElDocumentRenderService.cs`
- Ctor param `ElDocumentStyleTokens? styleTokens = null` → `styleTokens ?? ElDocumentStyleTokens.Default`.
- Pass into `bodyRenderer.RenderBlocks(...)` + `ApplyFurniture(...)`.
- Optional: add token version to `ElDocumentRenderAudit`.
- Verify DI/startup still resolves (`Program.cs`).

**4. HTML preview renderer reads tokens** — `Lib/Services/Editor/ElDocumentFurnitureRenderer.cs`
- Accept `ElDocumentStyleTokens` (ctor or method param).
- Emit `<style>` gradient (`:119`), heading sizes (`:136-138`), body font-size (`:125`), font-family (`:59`) from tokens. Values already match — now single-sourced.

**5. Editor CSS via injected CSS vars** — `CDH_EL/Components/Shared/ElTiptapEditor.razor` (+`.razor.css`)
- Component emits inline custom props on `.el-tiptap-shell` from `ElDocumentStyleTokens.Default`: `--el-font-family`, `--el-body-size`, `--el-body-line`, `--el-h{1,2,3}-size`/`--el-h{1,2,3}-line`, `--el-brand-rule-gradient`, `--el-brand-rule-height`. Follow existing `--el-page-paper-width` injection pattern.
- `.razor.css`: swap hardcoded typography (`:1044-1094`) + furniture `linear-gradient` (`:932`) to `var(--el-*)`. Eliminates live 18/14/12 drift.
- `ElEditorFurnitureHtmlFactory` brand-rule div styled by `.razor.css` rule → auto-covered by CSS var.

**6. Parity test (anti-regression lock)** — `Lib.Tests/Services/EngagementLetters/` (or new `Editor/` file)
- Render via `ElTiptapGemBoxBodyRenderer` + furniture builder with **non-default** tokens; assert output reflects custom values (heading size, body size, brand-rule first-stop color) → proves no literal remains.
- Assert GemBox brand-rule cell colors derive from `tokens.BrandRule.Stops`.

## Deferred (not this PR)
- `ElDocumentRenderContextBuilder` (gather JSON+furniture+assets+tokens). After tokens land.
- Per-template/DB token overrides. Record shape already supports.
- DOCX export reusing `BuildDocument`+`DocxSaveOptions` (TODO at `ElDocumentRenderService.cs:87`).

## Verification
1. Build: `dotnet build` (stop VS debugger first — DLL lock). Report exact failure if tooling errors.
2. Tests: `dotnet test Lib.Tests`. New parity test green; existing pass (baseline 132/134; 2 pre-existing failures unrelated to this work).
3. PDF: render draft template→PDF. Headers/footers, 4-color brand rule, heading sizes, body font unchanged (canonical already matched PDF → visually identical).
4. Editor: open draft template in Tiptap editor. Headings now 18/14/12pt (slightly smaller than before); brand rule matches PDF. Desktop+mobile; check console for CSS-var/asset errors. (Only if browser verification explicitly requested per AGENTS.md.)
5. Cross-check: change one token value, rebuild → editor AND PDF shift together. The point of the whole change.
