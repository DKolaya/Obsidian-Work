---
title: EL Editor Wargames 2026-07-13
created: 2026-07-13
type: project
tags:
  - project/el
---

# EL Editor Wargames — 2026-07-13

## Draft Compare Editing

Goal: pane editable only when own template has persisted `Draft` state and is not inactive. Approved, submitted, inactive versions remain read-only; display labels never control editability.

| Threat | Defense |
| --- | --- |
| Status-text spoof | Persisted enum + inactive guard |
| Both panes editable | Pane-local state and editor reference |
| Selection race | Key by template and section IDs; child owns save target |
| Client tamper | Service reloads section and rejects non-draft saves |
| Canonicalization error | Pane-local error; retain content |
| Stale post-save state | Apply returned canonical JSON |
| Read-only save leak | `IsReadOnly`; no Save or mutation toolbar |
| Missing draft content | Preserve empty/error state; no unusable Save |
| Narrow overflow | Existing responsive grid and compact HAVIT action |

Gates: draft/non-draft service tests; Razor compile; browser test only when explicitly requested.

## Editor Forced Page Break

Goal: `Ctrl+Enter` (`Cmd+Enter` macOS) and toolbar icon create same persisted `pageBreak`; browser page flow and GemBox PDF force next page.

| Threat | Defense |
| --- | --- |
| Hard-break confusion | Custom `pageBreak` block; hard break disabled |
| Toolbar/key mismatch | One `insertPageBreak` command |
| Save rejection | Typed schema + readable V2 artifact + canonicalization test |
| Browser ignores break | Forced pagination fragment and planner advance |
| Auto/forced collision | Deterministic signatures and de-duplication |
| PDF drops break | GemBox `SpecialCharacterType.PageBreak`; model/PDF page-count test |
| Marker prints | Zero-height editor marker; GemBox emits special character only |
| Read-only mutation | Toolbar hidden; editor non-editable |
| Undocumented schema | Increment schema version; V1 stays historical |

Gates: `pnpm test:tiptap`; focused schema/renderer/PDF tests; `pnpm run build:tiptap`; app build.

## Editor Spacing Parity

Goal: Tiptap and GemBox PDF share vertical rhythm and wrapping geometry for every persisted block type.

| Threat | Signal | Defense |
| --- | --- | --- |
| Paragraph cumulative drift | Dense fixture page delta | Exact `fontSizePt * lineHeight` |
| Bullet/ordered mismatch | Marker/text offset or page delta | Shared list tokens + both fixtures |
| Nested list drift | Wrong level increment | Assert nested GemBox positions |
| Task wrap drift | Text under marker | Shared marker width/gap |
| Blockquote wrap drift | Quote page delta | Shared border/padding/after-space |
| Heading drift | Heading-heavy page delta | Shared exact line + before/after |
| Custom container bypass | Nested content differs | Transparent-container regression |

Implementation: geometry remains in `ElDocumentStyleTokens`; extend renderer/PDF coverage for paragraphs, headings, bullet/ordered/nested/task lists, blockquotes, custom containers; no unsupported-node spacing.

Gates:

- `dotnet test Lib.Tests\Lib.Tests.csproj --no-restore --filter FullyQualifiedName~ElTiptapGemBoxBodyRendererTests`
- `dotnet test Lib.Tests\Lib.Tests.csproj --no-restore --filter FullyQualifiedName~ElDocumentPdfPreviewServiceTests`
- `git diff --check`
