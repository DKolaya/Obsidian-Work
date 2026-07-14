# EL Style Tokens — Remediation Plan (full prose)

Human-readable companion to `editor-style-tokens-remediation-plan.md`. Read that for the terse task list; read `editor-gembox-flow-comparison.original.md` for architecture background and `editor-style-tokens-plan.original.md` for the original plan.

Status as of 2026-06-30: the remediation gaps described below have been implemented in the live code. Keep this document as historical context for why the token work was done, not as the current TODO list.

## Why this plan exists

The first implementation pass of the style-tokens work delivered the GemBox/PDF and HTML-preview rendering paths correctly — both now read style decisions from `Lib/Services/Editor/ElDocumentStyleTokens.cs` instead of hardcoded literals, and the GemBox brand rule was implemented as a generated PNG gradient strip that matches the CSS gradient nicely. However, a review against the approved plan found three substantive gaps and two minor ones:

1. **The live editor was never touched.** The Tiptap editor's stylesheet still hardcodes heading sizes (`1.65 / 1.3 / 1.08 rem`, roughly `19.8 / 15.6 / 13 pt`) and the brand-rule gradient. The entire point of the effort was to make the editor and the PDF agree; today they still disagree, because only the PDF side moved to the canonical `18 / 14 / 12 pt`.
2. **Tokens are not injectable.** Every consumer reads `ElDocumentStyleTokens.Default` directly (a static field in the body renderer, a direct `.Default` reference in the furniture builder and HTML preview). The render service never gained a `styleTokens` constructor parameter. This blocks the future per-template override and — more immediately — makes a real parity test impossible.
3. **The parity guarantee is hollow.** The only new GemBox test asserts that a PNG is produced with the default token dimensions. Nothing renders with a *non-default* token set to prove that no hardcoded literal survives, so there is no regression lock: a future contributor can re-hardcode a value and every test stays green.
4. `RendererVersion` was not bumped (still `1`), so the render audit cannot distinguish token-era output.
5. The furniture builder's `Paragraph` helper still hardcodes `FontName = "Arial"`.

This plan closes all five, in priority order.

## Context an agent needs before starting

- The active branch is `feature/June/26/RTE-TipTap`; PRs target `master`.
- The `CDH_EL` web project frequently cannot be built from the CLI because Visual Studio holds a lock on the output DLL. Stop the VS debugger first. `Lib` and `Lib.Tests` build independently without issue.
- Project rule: consult the HAVIT Blazor MCP before editing any `.razor` file, even though the edits here are CSS-variable wiring rather than HAVIT component usage.
- Verified baseline at the time of writing: `Lib` builds clean with one pre-existing GemBox `CS0618` obsolete-API warning. `Lib.Tests` reports 135 of 137 passing; the two failures are pre-existing `EngagementLetterTemplateServiceTests` (a year-sequence test and a default-order test) unrelated to this work — do not attempt to fix them here.

## What is already done (do not redo)

`ElDocumentStyleTokens.cs` exists and is correct. It is a positional record exposing `BodyFontName`, `BodyFontFamilyCss`, `BodyFontSizePt`, `BodyLineSpacing`, `ParagraphSpaceAfterPt`, `BlockQuoteLeftIndentPt`, a `Headings` dictionary, and a `BrandRule`, plus a static `Default`, a `GetHeading(level)` helper, and the supporting records `ElDocumentHeadingStyleTokens`, `ElDocumentBrandRuleTokens` (with `ToCssLinearGradient()` and `HeightIn`), and `ElDocumentBrandRuleStop`. The canonical values are baked in: headings 18/14/12 pt, blockquote indent 18 pt, brand rule height 4.5 pt, and the gradient stops include a `#007bff @ 0%` lead-in so the rule is solid blue from 0–50% (matching the CSS).

The GemBox body renderer (`ElTiptapGemBoxBodyRenderer`) already reads tokens for body and heading typography, font, and the blockquote indent. The GemBox furniture builder (`ElDocumentFurnitureGemBoxBuilder`) renders the brand rule as a generated PNG gradient from `tokens.BrandRule`, via an `internal`, parameterized `CreateBrandRulePng(tokens, width, height)`. The HTML preview renderer (`ElDocumentFurnitureRenderer`) emits the gradient, heading sizes, body size, and font family from tokens. A shared `ElDocumentFurnitureViewModel` was added and is consumed by the render service and both furniture paths.

The one structural limitation underlying gaps 2 and 3 is that all of this reads `ElDocumentStyleTokens.Default` directly rather than receiving the tokens as an argument.

## The work

### Gap 1 — make the editor CSS token-driven (highest priority)

The editor stylesheet `CDH_EL/Components/Shared/ElTiptapEditor.razor.css` still hardcodes the `.tiptap` font family and `font-size: 11pt` (around line 1044), the `h1`/`h2`/`h3` sizes and line-heights (around lines 1070–1089), the `p, li` line-height of `1.5` (around line 1093), and the furniture brand-rule `linear-gradient` (around line 932 — the third copy of the gradient).

The locked approach is CSS custom-property injection, mirroring the existing `ZoomStageStyle` computed property (lines 250–263 of the `.razor`) which already injects `--el-editor-zoom` and friends via a `style="@..."` attribute.

In `ElTiptapEditor.razor`, add a computed style string that emits, from `ElDocumentStyleTokens.Default`: `--el-font-family`; `--el-body-size` (`11pt`); `--el-body-line` (`1.5`); `--el-h1-size`/`--el-h1-line`, `--el-h2-size`/`--el-h2-line`, `--el-h3-size`/`--el-h3-line`; `--el-brand-rule-gradient` (from `BrandRule.ToCssLinearGradient()`); and `--el-brand-rule-height` (from `BrandRule.HeightIn`, suffixed `in`). Build it with `FormattableString.Invariant`. Emit it on the root `.el-tiptap-shell` element, because the editor's CSS variables are already scoped to that selector.

Then in `.razor.css`, replace the hardcoded values with `var(--el-*)` references — `.tiptap` font-family and font-size, the three heading sizes and line-heights (leave font-weight and margins alone), the `p, li` line-height, and the furniture rule background and height. Use `var(--el-x, <existing literal>)` fallbacks so the editor still renders correctly if the attribute is somehow absent.

`ElEditorFurnitureHtmlFactory.BuildBrandRule()` already emits an inline token-driven gradient, so leave it; just confirm it matches the `.razor.css` rule variable so the two editor furniture mechanisms agree.

The visible outcome is that editor headings render at 18/14/12 pt — slightly smaller than today and identical to the PDF — and the brand-rule gradient is single-sourced.

### Gap 2 — make tokens injectable

This unblocks both the future per-template override and the Gap 3 test.

In `ElTiptapGemBoxBodyRenderer`, replace the static `StyleTokens = Default` field with an instance field assigned from a constructor parameter `ElDocumentStyleTokens? styleTokens = null` (defaulting to `Default`). The render helpers are currently static; either make them instance methods or thread the token field through them.

In the static `ElDocumentFurnitureGemBoxBuilder`, thread an `ElDocumentStyleTokens tokens` argument into `ApplyFurniture(...)` and into `CreateBrandRule(document, tokens)` instead of reading `.Default` at line 311.

In `ElDocumentRenderService`, add a constructor parameter `ElDocumentStyleTokens? styleTokens = null` (defaulting to `Default`) and pass it to the body renderer and the furniture builder.

In `ElDocumentFurnitureRenderer`, accept the tokens via constructor (defaulting to `Default`) rather than the local `var tokens = ...Default`.

Because every new parameter defaults, the `CDH_EL` DI registration needs no change — just confirm it still resolves.

### Gap 3 — a real parity test

The current GemBox builder test only checks a PNG is produced with default dimensions. Add tests that render with a deliberately non-default token set — for example body 99 pt, H1 77 pt, brand first stop `#123456` — and assert the output reflects those custom values: walk the GemBox blocks and assert a heading run's `CharacterFormat.Size` equals the custom H1 size and a body run equals the custom body size; assert the brand-rule PNG (or the `InterpolateBrandRuleColor` helper) reflects the custom first-stop color; and assert the HTML preview's emitted `<style>` contains the custom gradient and heading sizes. These tests are the regression lock that the first pass lacked.

### Gap 4 — bump the renderer version

Change `ElTiptapGemBoxBodyRenderer.RendererVersion` from `1` to `2` so `ElDocumentRenderAudit` records token-era output distinctly. Update any test that asserts the old value.

### Gap 5 — remove the last furniture font literal

The `Paragraph(...)` helper in `ElDocumentFurnitureGemBoxBuilder` (around line 510) still hardcodes `FontName = "Arial"`. Replace it with the threaded `tokens.BodyFontName`. There is no visual change because the value equals the default, but it completes the de-duplication.

## Verification

Build with `dotnet build` after stopping the Visual Studio debugger; if the tooling itself fails, report the exact command and error. Run `dotnet test Lib.Tests` and confirm the new non-default-token parity tests pass while the baseline holds at 135/137 (the same two pre-existing failures, untouched). Render a draft template to PDF and confirm the brand rule, 18/14/12 pt headings, and Arial 11 pt body are unchanged. If browser verification is explicitly requested (per AGENTS.md), open a draft template in the editor and confirm the headings now render at 18/14/12 pt and the brand-rule gradient matches the PDF, watching the console for missing-variable or asset errors at desktop and mobile widths. Finally, cross-check the whole objective: pass a non-default token set into `ElDocumentRenderService` (or temporarily change `Default`), rebuild, and confirm the editor and the PDF shift together.
