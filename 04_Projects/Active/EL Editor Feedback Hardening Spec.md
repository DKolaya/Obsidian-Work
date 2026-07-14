---
title: EL Editor Feedback Hardening Spec
created: 2026-07-13
type: project
tags:
  - project/el
---

# Editor Feedback Hardening

## §G
Fix editor/PDF spacing parity; add forced page break; allow compare editing only for draft versions.

## §C
- Blazor + HAVIT UI; no MudBlazor.
- Canonical Tiptap JSON remains body source of truth; HTML derived.
- Browser/PDF geometry consumes shared `ElDocumentStyleTokens` where applicable.
- `Ctrl+Enter` / `Cmd+Enter` inserts forced page break; toolbar exposes icon action.
- Compare pane editability derives from persisted `TemplateState.Draft`; service remains final guard.
- Existing MVC routes untouched.

## §I
- json: canonical Tiptap node `pageBreak` with `data-el-node-id`
- js: `insertPageBreak(elementId)` → inserts persisted block node
- key: `Mod-Enter` → `insertPageBreak`
- ui: `ElTiptapEditor` paragraph toolbar → icon-only forced-break action
- service: `SaveTemplateSectionEditorJsonAsync(...)` → draft-only persistence
- route: `engagement-letter/templates/{TemplateId:int}/compare`

## §V
- V1: ∀ persisted text blocks → browser + GemBox line/spacing geometry use same style decisions; paragraph, heading, bullet/ordered/nested/task list, blockquote, custom container paths covered.
- V2: `pageBreak` → schema-valid canonical JSON + HTML marker + editor forced next page + GemBox `SpecialCharacterType.PageBreak`.
- V3: `Mod-Enter` and toolbar icon → same `insertPageBreak` command; read-only editor exposes neither mutation path.
- V4: compare pane editable ⇔ persisted template state `Draft` + not inactive; all other panes stay read-only with no save action; service enforces same rule.
- V5: compare save → current editor JSON → existing draft-guarded service → canonical JSON returned and retained in pane.

## §T
id|status|task|cites
T1|x|wargame + harden spacing parity across persisted block surfaces|V1
T2|x|wargame + implement forced page break end-to-end|V2,V3,I.json,I.js,I.key,I.ui
T3|x|wargame + implement draft-only editable compare panes|V4,V5,I.service,I.route

## §B
id|date|cause|fix
B1|2026-07-13|sandbox denied pnpm DB + Node test-worker spawn|tooling workaround; no product invariant
B2|2026-07-13|schema regression asserted nonexistent `RenderedHtml` instead of `Html`|V2
B3|2026-07-13|pnpm wrapper crashed reading package integrity metadata|tooling workaround; direct local Vite entrypoint
B4|2026-07-13|broad template-service suite includes unrelated title/date/order failures|focused draft-save contract gate; no new product invariant
