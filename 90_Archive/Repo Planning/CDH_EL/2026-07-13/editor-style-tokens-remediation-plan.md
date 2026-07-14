# EL Style Tokens — Remediation Plan (agent reference)

Follow-up to `editor-style-tokens-plan.md`. The first implementation pass landed the GemBox + HTML-preview paths but **missed the editor side and the injectability/parity design**. This plan closes those gaps. Full prose: `editor-style-tokens-remediation-plan.original.md`.

Status 2026-06-30: implemented. Keep this file as historical implementation context; do not treat GAP 1-5 below as active TODOs without re-checking live code.

## Cold-start context
- Branch `feature/June/26/RTE-TipTap` → PR `master`.
- Goal of whole effort: one typed source of truth `Lib/Services/Editor/ElDocumentStyleTokens.cs` so the **browser editor** and the **GemBox PDF** render the same document identically. Background: `editor-gembox-flow-comparison.md`.
- Build caveat: `CDH_EL` won't build via CLI while Visual Studio holds the DLL lock — stop the VS debugger first. `Lib` + `Lib.Tests` build standalone fine.
- UI rule (CLAUDE.md): consult HAVIT Blazor MCP before editing `.razor`.
- Verified current state: `Lib` builds clean (1 pre-existing GemBox `CS0618` warning). `Lib.Tests` = 135/137 pass; the 2 failures are pre-existing `EngagementLetterTemplateServiceTests` (title-sequence + default-order), unrelated to tokens — do not "fix" them here.

## What's already DONE (do not redo)
- `ElDocumentStyleTokens.cs` exists. Records: `ElDocumentStyleTokens` (positional) with `BodyFontName`, `BodyFontFamilyCss`, `BodyFontSizePt`, `BodyLineSpacing`, `ParagraphSpaceAfterPt`, `BlockQuoteLeftIndentPt`, `Headings` dict, `BrandRule`; static `Default`; `GetHeading(level)`. Plus `ElDocumentHeadingStyleTokens`, `ElDocumentBrandRuleTokens` (has `ToCssLinearGradient()` + `HeightIn`), `ElDocumentBrandRuleStop`. Values are canonical (18/14/12pt headings, 18pt blockquote, 4.5pt rule). Brand stops include a `#007bff @0` lead-in so 0–50% is solid blue.
- `ElTiptapGemBoxBodyRenderer` reads tokens (body/heading/font/blockquote) — literals gone.
- `ElDocumentFurnitureGemBoxBuilder.CreateBrandRule` renders a generated **PNG gradient strip** from `tokens.BrandRule` (smooth gradient, better than 4 cells). `CreateBrandRulePng(tokens,w,h)` is `internal` + parameterized.
- `ElDocumentFurnitureRenderer` (HTML preview) emits gradient/heading/body/font from tokens via `ToCssLinearGradient()`.
- `ElDocumentFurnitureViewModel` shared furniture model added + consumed.
- Tokens are currently consumed via a hardcoded `ElDocumentStyleTokens.Default` reference everywhere (static field in body renderer, direct `.Default` in builder/preview). This is the root limitation the tasks below fix.

## Gaps to close (priority order)

### GAP 1 (critical) — Editor CSS is NOT token-driven; live editor still diverges from PDF
`CDH_EL/Components/Shared/ElTiptapEditor.razor.css` was untouched by typography work. Editor still hardcodes:
- `.el-tiptap-editor .tiptap` font-family + `font-size:11pt` (~`:1044-1045`)
- `h1` `1.65rem`/`h2` `1.3rem`/`h3` `1.08rem` + line-heights (~`:1070-1089`)
- `p,li` `line-height:1.5` (~`:1093`)
- furniture brand rule `linear-gradient(...)` (~`:932`) — the 3rd duplicate of the gradient

User decision (locked): consume tokens via **CSS custom-property injection**, matching the existing `--el-editor-zoom` pattern.

Steps:
1. In `ElTiptapEditor.razor`, add a computed style string (mirror `ZoomStageStyle` at `:250-263`) that emits custom props from `ElDocumentStyleTokens.Default`:
   `--el-font-family`, `--el-body-size:11pt`, `--el-body-line:1.5`, `--el-h1-size:18pt`/`--el-h1-line:1.2`, `--el-h2-size`/`--el-h2-line`, `--el-h3-size`/`--el-h3-line`, `--el-brand-rule-gradient` (from `BrandRule.ToCssLinearGradient()`), `--el-brand-rule-height` (from `BrandRule.HeightIn` → `in`). Use `FormattableString.Invariant`.
   Emit it on the root `.el-tiptap-shell` element (the CSS vars are already scoped there) via `style="@StyleTokenVars"`.
2. In `.razor.css`, swap the hardcoded values above to `var(--el-*)`:
   - `.tiptap` → `font-family: var(--el-font-family); font-size: var(--el-body-size);`
   - `h1/h2/h3` `font-size`+`line-height` → the `--el-h{n}-size`/`--el-h{n}-line` vars. Keep existing `font-weight`/`margin` as-is.
   - `p,li` `line-height` → `var(--el-body-line)`.
   - furniture rule `background` (`:932`) → `var(--el-brand-rule-gradient)`; height → `var(--el-brand-rule-height)`.
   - Provide CSS fallbacks in `var(--x, <current literal>)` so the editor still renders if the attribute is absent.
3. `ElEditorFurnitureHtmlFactory.BuildBrandRule()` already emits an inline `ToCssLinearGradient()` gradient (token-driven) — leave it; just confirm it visually matches the `.razor.css` rule var so both editor furniture paths agree.

Outcome: editor headings render 18/14/12pt (slightly smaller than today) = identical to PDF; brand-rule gradient single-sourced.

### GAP 2 — Make tokens injectable (stop hardcoding `.Default`)
Enables future per-template overrides AND the GAP 3 parity test.
- `ElTiptapGemBoxBodyRenderer`: replace `private static readonly ... StyleTokens = Default` with an instance field set via constructor: `public ElTiptapGemBoxBodyRenderer(ElDocumentStyleTokens? styleTokens = null) => _styleTokens = styleTokens ?? ElDocumentStyleTokens.Default;`. Use `_styleTokens` in the (now instance) render helpers. (Helpers are `static` today — make them instance or pass `_styleTokens` through.)
- `ElDocumentFurnitureGemBoxBuilder`: it's a `static` class. Thread `ElDocumentStyleTokens tokens` into `ApplyFurniture(...)` and `CreateBrandRule(document, tokens)` instead of reading `.Default` at `:311`. The `ElDocumentRenderService` overload passes it in.
- `ElDocumentRenderService`: add ctor param `ElDocumentStyleTokens? styleTokens = null` → `_styleTokens = styleTokens ?? ElDocumentStyleTokens.Default`; pass to `bodyRenderer.RenderBlocks(...)` (or construct renderer with it) and `ApplyFurniture(...)`.
- `ElDocumentFurnitureRenderer`: accept `ElDocumentStyleTokens` (ctor, default `Default`) instead of the local `var tokens = ...Default` at `:21`.
- Verify DI registration in `CDH_EL` startup still resolves with the new optional params (they default, so no registration change required — just confirm).

### GAP 3 — Real parity/anti-regression test (currently hollow)
Existing `Lib.Tests/Services/Editor/ElDocumentFurnitureGemBoxBuilderTests.cs` only asserts PNG signature/dims with `Default` tokens — proves nothing about literal removal.
Add tests that render with a **deliberately non-default** `ElDocumentStyleTokens` (e.g. body 99pt, H1 77pt, brand first-stop `#123456`) and assert the output reflects the custom values:
- GemBox body: assert a heading run's `CharacterFormat.Size` == custom H1 pt and a body run == custom body pt (walk the returned `Block`s).
- GemBox brand rule: assert `CreateBrandRulePng(customTokens,...)` produces interpolated pixels matching the custom first-stop color (or unit-test `InterpolateBrandRuleColor` if exposed).
- HTML preview: assert emitted `<style>` contains the custom gradient + heading sizes.
This is the lock: if someone re-hardcodes a literal later, these fail.

### GAP 4 — Bump `RendererVersion`
`ElTiptapGemBoxBodyRenderer.RendererVersion` still `1`. Bump to `2` so `ElDocumentRenderAudit` distinguishes token-era output. Update any test asserting the value.

### GAP 5 — Furniture builder font literal
`ElDocumentFurnitureGemBoxBuilder.Paragraph(...)` helper still hardcodes `run.CharacterFormat.FontName = "Arial"` (~`:510`). Replace with the threaded `tokens.BodyFontName`. (No visual change — value equals default — but completes de-dup and prevents drift.)

## Verification
1. Build: `dotnet build` (stop VS debugger first). Report exact failure if tooling errors.
2. Tests: `dotnet test Lib.Tests`. New non-default-token parity tests green; still 135/137 baseline pass (same 2 pre-existing failures, untouched).
3. PDF path: render a draft template → PDF. Brand rule (gradient), headings 18/14/12pt, body Arial 11pt unchanged.
4. Editor path (only if browser verification explicitly requested per AGENTS.md): open a draft template in the Tiptap editor; headings now 18/14/12pt and brand-rule gradient matches PDF; check console for missing-CSS-var / asset errors; desktop + mobile widths.
5. Cross-check the whole point: temporarily pass a non-default token set into `ElDocumentRenderService` (or change `Default`), rebuild, confirm editor + PDF shift together.
