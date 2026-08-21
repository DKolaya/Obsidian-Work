---
title: AI Weekly Update Template
created: 2026-08-20
type: reference
tags:
  - topic/ai-workflows
  - project/ai-initiative
---

# AI Weekly Update Template

Templates and conventions for the weekly [[04_Projects/Active/AI Initiative|AI Initiative]] update on the monday.com AI Weekly Tasks board. Open this on Friday, fill the work-log template, paste, set Done.

Board: https://cdhts-company.monday.com/boards/18420780253

## The weekly close

1. Write the work log (template below) against whichever tracks actually moved.
2. Post it as an update on that week's item.
3. Rename the item to append the topic — `Drew - W8: AI Research & Evaluation - <topic>`.
4. Set Status → **Done**.

That's the whole close. The scope is permanently open; the *time box* is what closes. Done doesn't mean "finished researching AI," it means "W8 logged."

## Title convention

| State | Title |
|---|---|
| Open / future week | `Drew - W8: AI Research & Evaluation` |
| Closed week | `Drew - W8: AI Research & Evaluation - Kimi K3` |

Board-wide convention across all 54 items is `Owner - W#: Title` with plain hyphens. Dates live in the `Week Start` / `Week End` columns — never put them in the title. The topic gets appended only when the week closes, because what a week actually covered isn't known until it happens.

## The 5 standing tracks

Scan this list when writing; no week is expected to hit all five, and partial coverage is the norm.

| # | Track | Covers |
|---|---|---|
| 1 | Model landscape | Releases, benchmark shifts, pricing, deprecations — filtered to CDH relevance |
| 2 | Harnesses & dev tools | Claude Code, Codex, Copilot CLI, Cursor, T3 — hands-on trials, dev-team fit |
| 3 | Agent proficiency | Prompt engineering, skill development, instruction files, context/file-structure organization |
| 4 | Firm tool AI evaluation | AI features inside tools CDH already runs or resells. Per tool: what shipped, is it any good, are we using it right, could we do it better |
| 5 | Build-with-AI | APIs, model selection, tool-calling vs RAG, structured output, guardrails, cost/latency |

## Work-log template

Posted every week. Keep only the tracks that moved — delete the rest. Use the track name plus the subject as the heading.

```html
<b>W8 - Aug 17 to Aug 21</b><br><br>
<b>Harnesses &amp; dev tools - [subject]</b><br>
- [what was done, written as a conclusion]<br>
- [cost or fit read, stated plainly]<br>
- [the recommendation, as a sentence not a label]<br><br>
<b>Model landscape - [subject]</b><br>
- [what shipped, with the number that matters]<br>
- [the catch, if there is one]<br>
- [what CDH should do with it]<br><br>
<b>Carry into next week:</b> [one thing]
```

## Change-log template

Only needed when a task is **renamed or rescoped** — not part of the weekly rhythm. Post this *before* the work log so the work log sits on top of the thread.

```html
<b>Task restructured - YYYY-MM-DD</b><br><br>
<b>Was:</b> [old title]<br>
<b>Now:</b> [new title]<br><br>
<b>Reason:</b> Per the 08-14 AI meeting. Researching one vendor per week goes stale
faster than it can be written. Replaced with a standing weekly research brief across
5 tracks:<br><br>
1. Model landscape<br>
2. Harnesses &amp; dev tools<br>
3. Agent proficiency (prompting, skills, context/file structure)<br>
4. Firm tool AI evaluation<br>
5. Build-with-AI (APIs, implementation patterns)<br><br>
Full track definitions are on the W1 item. Weekly close = work-log update posted.<br><br>
Substance unchanged - the topic tag names this week's focus. Work log follows at week close.
```

If the scope genuinely changed rather than just the title, say so explicitly instead of the last line. A change log that describes a rescope as a rename is a false audit trail.

## House style

Learned the hard way over W6/W7. The update is manager-facing — short and conclusive. The reasoning lives in the vault and gets discussed at the retrospective.

**Do:**
- Write conclusions as plain sentences. "Not worth adopting. The switching cost is a full IDE migration."
- Lead with the number that decides it — price, benchmark, break-even.
- Give each bullet a "so what for CDH" where one exists.
- Keep a release date when it's load-bearing for *is this current*.

**Don't:**
- No `Verdict:` / `Watch out:` / `Secondary concern:` label prefixes. They read badly.
- No vendor revenue figures, customer logos, or acquisition timelines. Nobody's asking.
- No links or citations. Evidence lives in the vault by design.
- Don't pad with tracks that didn't move.

## Gotchas

- `create_update` takes **HTML, not markdown**. Markdown renders as literal asterisks.
- Escape `&` as `&amp;`. Use `<br>` for line breaks, `&rarr;` for the "so what" arrow, `<b>` for headings.
- Threads render **newest first** — post the change log first so the work log lands on top.
- **Monday updates cannot be edited after posting.** Delete and repost is the only fix. Proofread before sending.
- No fabricated Done. A week with no real work gets logged honestly as a partial — W4 was closed as "no Gemini profile, but the deep-research synthesis failure was root-caused," which is a real engineering output and reads better than a silent gap.

## Cadence beyond the week

- **Half-quarter share-out** — evidence gets gathered from the vault and shared. This is where the artifact notes earn their keep; weekly updates carry nothing.
- **Retrospective** — the detailed discussion. The vault note is the prep material.

## Related

- [[04_Projects/Active/AI Initiative]] — standing scope, weekly task list, status log
- [[06_Resources/AI Platforms/AI Platforms Index]] — where model/vendor artifacts land
- [[09_Reference/Codex/Codex Index]] — where harness/tooling artifacts land
