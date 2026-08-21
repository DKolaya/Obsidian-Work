---
title: AI Initiative
created: 2026-07-09
type: project
tags:
  - project/ai-initiative
  - area/development
---

# AI Initiative — FY2026-27 AI Roadmap

Firm-wide AI roadmap tasked by the partners. Tracked live on monday.com (workspace "CDH TS Dev"); this note is the Obsidian mirror/working doc for my (Drew's) slice of it.

- Board — weekly tasks: https://cdhts-company.monday.com/boards/18420780253
- Board — initiatives: https://cdhts-company.monday.com/boards/18420780234
- Board — roadmap quarters: https://cdhts-company.monday.com/boards/18420780240

## Outcome

3 partner deliverables by end of FY2026-27:
1. AI-augmented internal application proof-of-concept (Initiative 4)
2. AI-powered internal tool (Initiative 2)
3. Product offering list for clients (Initiative 5)

Personal tie-in: supports my goal to research + deliver 2-3 practical AI improvements over 12 months (cost-efficiency, prompting, workflow time-savings) — see [[03_Todos/Work TODOs]].

## Status

- Current quarter: **Q1 – Baseline & Candidate Selection** (2026-07-01 → 2026-09-30), In Progress
- My role: steward of **Initiative 1: Platform Literacy**; contributor on Initiative 2 (Accounting Task Augmentation)

## The 5 Initiatives

| # | Initiative | Steward(s) | Deliverable |
|---|---|---|---|
| 1 | Platform Literacy | **Drew** | Platform/cost comparison brief — supports all 3 deliverables |
| 2 | Accounting Task Augmentation | Patrick, Nate, Shannon, Drew | Deliverable 2 — AI-powered internal tool |
| 3 | AI Development Integration | Nate | Platform-agnostic AI dev playbook v1; dev-time/code-quality impact report |
| 4 | Application Augmentation | Patrick, Nate, Shannon, Drew | Deliverable 1 — AI-augmented internal app POC |
| 5 | Productization | Patrick | Deliverable 3 — product offering list |

## Roadmap Quarters

| Quarter | Dates | Goal | Checkpoint |
|---|---|---|---|
| **Q1 – Baseline & Candidate Selection** | 2026-07-01 → 2026-09-30 | Baseline dev-time/code-quality, draft AI dev playbook v1, pick internal app + AI feature for POC, finish platform/market research | Partner update: baseline, playbook v1, shortlisted app+feature, platform/cost brief |
| Q2 – Expand & Prototype | 2026-10-01 → 2026-12-31 | Roll playbook out on real projects, start the AI-augmentation build | Early dev-time/quality numbers, build progress vs. baseline estimate |
| Q3 – Measure & Validate | 2027-01-01 → 2027-03-31 | Turn quarter's work into evidence | Impact report, feature test results, tool pilot feedback |
| Q4 – Finalize & Deliver | 2027-04-01 → 2027-06-30 | Close out all 3 deliverables | Final partner presentation + sign-off |

## Standing research scope (from 2026-08-20)

All of Q1 (W1–W13) was restructured from one-vendor-per-week research into a standing weekly research brief. Each week is an instance of the same task; the weekly close is a work-log update posted to the board. Findings are gathered and shared every half-quarter.

| # | Track | Covers |
|---|---|---|
| 1 | Model landscape | Releases, benchmark shifts, pricing, deprecations — filtered to CDH relevance |
| 2 | Harnesses & dev tools | Claude Code, Codex, Copilot CLI, Cursor, T3 — hands-on trials, dev-team fit |
| 3 | Agent proficiency | Prompt engineering, skill development, instruction files, context/file-structure organization |
| 4 | Firm tool AI evaluation | AI features inside tools CDH already runs — M365/SharePoint, GitHub Copilot, DocuSign, Azure DevOps. Per tool: what shipped, is it any good, are we using it right, could we do it better. **Sage Intacct is Patrick's, not mine** |
| 5 | Build-with-AI | APIs, model selection, tool-calling vs RAG, structured output, guardrails, cost/latency |

No week is expected to hit all five. Track 4 replaced an earlier "what AI can do for accounting work" framing — evaluating the tools is the engineering question; the accounting judgement isn't ours to make. As of 2026-08-20 Track 4 covers the tools the dev team runs day to day; **Sage Intacct AI — including the collision-risk question of not building what Sage ships free — moved to Patrick** and is out of scope here.

## My Weekly Tasks (Q1)

- [x] W1: AI Research & Evaluation — Anthropic ✅ 2026-08-20 — profile + the evidence-labeling schema every later writeup reuses
- [x] W2: AI Research & Evaluation — OpenAI ✅ 2026-08-20
- [x] W3: AI Research & Evaluation — M365 Copilot ✅ 2026-08-20 — usage-to-value gap finding
- [x] W4: AI Research & Evaluation — Google Gemini ✅ 2026-08-20 — no profile produced; root-caused and documented the deep-research synthesis failure instead. Closed as-is, not carried forward
- [x] W5: AI Research & Evaluation — Codex vs Claude Code ✅ 2026-08-20 — [[09_Reference/Codex/AI Agent Workflow Audit Report 2026-07|workflow audit report]] over 150 real sessions, reusable audit prompt, [[AGENTS]] multi-agent standard
Open weeks carry the general task name only. A topic tag gets added when that week's work log is written and the item closes — the intended focus for the remaining weeks is noted below, but nothing is committed until the week happens.

- [x] W6: AI Research & Evaluation — Kimi K3 ✅ 2026-08-20 — Fable 5 competitor at ~30% of the price; open weights don't yet make local viable
- [x] W7: AI Research & Evaluation — Cursor & Grok 4.6 ✅ 2026-08-20 — Cursor ruled out on IDE fit; Grok 4.6 cheapest at the frontier
- [ ] W8: AI Research & Evaluation (current week, due 2026-08-21) — intended: Monday board restructure & T3 Code trial
- [ ] W9: AI Research & Evaluation — intended: firm tool evaluation roll-up
- [ ] W10: AI Research & Evaluation — intended: dev playbook usage examples (with Nate)
- [ ] W11: AI Research & Evaluation — intended: dev playbook sections (with Nate)
- [ ] W12: AI Research & Evaluation — intended: platform comparison brief v2
- [ ] W13: AI Research & Evaluation — intended: Q1 partner checkpoint (fixed date)

## Deliverable in progress: Platform Comparison Brief

The Anthropic vs. OpenAI enterprise comparison (W1/W2/W6/W12 work) lives in:
- [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison|Anthropic vs OpenAI Enterprise Comparison]]

Company-by-company research lives in [[06_Resources/AI Platforms/AI Platforms Index|AI Platforms]]:
- [[06_Resources/AI Platforms/Anthropic Company Profile|Anthropic Company Profile]] — products, uses, quality, adoption, business trends, sentiment, risks, and pilot guidance (verified 2026-07-15)
- [[06_Resources/AI Platforms/OpenAI Company Profile|OpenAI Company Profile]] — products, uses, quality, adoption, business trends, sentiment, risks, and pilot guidance (verified 2026-07-16)
- [[06_Resources/AI Platforms/Microsoft Copilot Company Profile|Microsoft Copilot Company Profile]] — products, uses, quality, adoption, business trends, sentiment, risks, and pilot guidance (verified 2026-07-17)

Codex vs Claude Code shipped in W5 — see the [[09_Reference/Codex/AI Agent Workflow Audit Report 2026-07|workflow audit report]]. Nothing further is owed here: per-vendor profiles were retired in the 2026-08-20 restructure, and Gemini closed without one. Research now lands as per-topic evaluation notes instead — see [[06_Resources/AI Platforms/Kimi K3 Evaluation|Kimi K3]], [[06_Resources/AI Platforms/Grok 4.6 Evaluation|Grok 4.6]], [[09_Reference/Codex/Cursor Evaluation|Cursor]].

The v1/v2 comparison brief is **deprioritized** as of 2026-08-20 — it was an artifact of the retired per-vendor shape. W12 and W13 keep their slots; what goes into the Q1 checkpoint gets decided closer to the date.

## Status Log

- 2026-08-20 — **Sage Intacct AI handed to Patrick; W6/W7 research written up.** Sage Intacct AI evaluation — and with it the VAR collision-risk question of not building what Sage ships free — is Patrick's now, removed from the Track 4 scope table above. Not a current concern on this side. **Not posted to Monday:** the W7 and W9 change logs already on the board still name Sage Intacct as mine, and Monday updates can't be edited after posting; deliberate call to leave them rather than delete-and-repost. Also created the three artifacts the weekly updates deliberately don't carry — [[06_Resources/AI Platforms/Kimi K3 Evaluation|Kimi K3]], [[06_Resources/AI Platforms/Grok 4.6 Evaluation|Grok 4.6]] and [[09_Reference/Codex/Cursor Evaluation|Cursor]] — so the half-quarter share-out and retrospective have something to pull from instead of board comments. Weekly update formats are now recorded in [[09_Reference/Vault/AI Weekly Update Template|AI Weekly Update Template]].
- 2026-08-20 — **W7 closed: Cursor and xAI Grok 4.6.**
  - **Cursor — not adopting.** It's a VS Code fork, and the dev team works in Visual Studio, so this is an IDE migration rather than a tool addition; the .NET tooling we depend on (designer, debugger, profiler, Hot Reload, solution management) doesn't come across. $40/user/month on top of M365, ChatGPT and Claude, all of which we already pay for, and credit-based billing means spend tracks model usage rather than staying flat. The AI capability doesn't clear what we already license, so the switching cost has nothing to buy.
  - **Ownership note.** SpaceX (merged with xAI in Feb 2026) closed its $60B acquisition of Cursor on 2026-08-14. Worth correcting a common assumption: Cursor is **not** locked to Grok — its current model list still includes Claude 4.7 Opus, Sonnet 5, GPT-5.6, Gemini 3.7, Kimi and GLM 5.2. The real exposure is that the acquisition announcement made no commitment to model neutrality, so continued third-party support is now a decision made by a direct competitor of the model vendors we rely on. Secondary to the IDE problem, but it's the reason not to revisit this later on capability grounds alone.
  - **Grok 4.6** (released 2026-08-12): 500K context, 61 on the Artificial Analysis Intelligence Index — frontier tier, effectively level with GPT-5.6 Sol. Big agentic-coding gains over 4.5 (DeepSWE 54 → 65.9, APEX-Agents 47.1 → 57.5). Priced $2/$6 per million, the cheapest model at that tier; Fable 5 is $10/$50, Kimi K3 $3/$15. **Billing trap:** once a prompt crosses 200K tokens, xAI rebills the *entire* request at $4/M input, $1/M cached, $12/M output — so long agentic sessions cost well above the headline rate. Worth having available via API for cost-sensitive work; not a default.
  - **Third consecutive week on the same signal:** frontier capability is commoditizing on price (K3 70% under Fable 5, Grok 4.6 cheaper still and scoring higher). Argues for keeping model choice a per-workload decision and favouring model-agnostic harnesses.
  - *Open discrepancy:* the W6 update records Fable 5 at 60 on the AA index; this week's source implies 62. Unreconciled — worth settling before either figure goes in the brief.
- 2026-08-20 — **W6 closed: Kimi K3 evaluation.** First week logged under the new shape. K3 (Moonshot, released 2026-07-16) is a Fable 5-tier competitor, not an Opus substitute — 57 on the Artificial Analysis Intelligence Index against Fable 5's 60, and it beats Fable 5 on the Frontend Code Arena at 1,679 Elo. Priced $3/$15 per million in/out against Fable 5's $10/$50, cached input $0.30 vs $1.00: roughly **70% cheaper for about 95% of the intelligence**. Read for CDH — the top tier is now contested on price, so anything running at Fable-5 rates should have a reason it needs Fable 5. Second finding, on running models locally: weights shipped 2026-07-27 under a Modified MIT license (training data withheld, so open-weight not open-source), but self-hosting needs an 8×B300 node at ~$42.5k/month and break-even against the API sits above ~1,000 output tokens/second sustained — we're not within an order of magnitude. What's closing is availability, not capability; the blocker on local is hardware cost, so this is worth re-checking on every major open-weight drop. **Note W6's original topic was the v1 comparison brief — that didn't happen this week, and W12 (brief v2) still assumes a v1 exists.** Evidence for this week currently lives only in the Monday update; no vault artifact yet.
- 2026-08-20 — **Q1 board restructure, pass 2 — W6–W13 renamed.** Same shape as pass 1, but **first part only**: rename plus a change-log update on each item. No work logs, no status changes — all eight stay Not Started, so W6 and W7 remain honestly overdue rather than falsely closed. Titles were first written with topic tags, then stripped back the same day to the general task name alone — `Drew - W#: AI Research & Evaluation` — because the topics aren't settled until each week actually happens. Drew fills them in as the work logs get written. W1–W5 keep their topic tags; those weeks are closed and the topics are earned. Side effect worth knowing: each change-log update's `Now:` line still quotes the intermediate title with its topic tag, and Monday updates can't be edited after posting. **W7, W8 and W9 were scope changes, not retitles** — the accounting AI add-on research (Sage Intacct, QuickBooks, CCH Axcess, CoCounsel, Karbon) is dropped under the Track 4 pivot; judging whether an AI feature improves accounting work isn't ours to make. Sage Intacct survives into W7 because CDH is the VAR, which makes it the collision-risk item too. W9 becomes a firm-tool roll-up instead of folding dead findings. W8 was named from what the week actually holds (Track 3 board/context restructure + Track 2 T3 Code trial), not from a placeholder. Accepted cost: W13 is a fixed partner presentation and now reads as research at a glance — the topic tag carries the deliverable signal. Also fixed a pass-1 miss: [[03_Todos/Work TODOs]] still showed W1/W2/W4/W5 as In Progress after they closed Done on the board.
- 2026-08-20 — **Q1 board restructure, W1–W5.** Per the 08-14 AI meeting: one-vendor-per-week research goes stale faster than it can be written, and the shape left most of the real work invisible — continuous model tracking, harness trials for the dev team, and prompt/skill/context-engineering practice had no slot on the board, so they showed as nothing. Bigger problem underneath: continuous work modelled as one-shot projects can never be marked Done, so it sat In Progress and read as stalled. Board credited 0 Done against 9 shipped vault artifacts plus a 6-entry weekly sync cadence. Fix: W1–W5 renamed to `Drew - W#: AI Research & Evaluation - <topic>`, each given a change-log update (audit trail of the rename) and a work-log update (what actually got done), then set Done. Work logs anchored to each item's **original topic**, not file `created:` dates — note-creation ≠ when the research happened. Updates deliberately carry no links; they're a manager-facing "what I did," with evidence assembled at the half-quarter share-out. W4 logged honestly as a partial: no Gemini profile, but the deep-research synthesis failure was root-caused and documented, which is what made W5 land cleanly. **W6–W13 deliberately untouched** pending Drew's call.
- 2026-08-18 — Monday sync: **W8 (CCH Axcess/CoCounsel/Karbon) now overdue** too — was due 08-17, still Not Started. W6/W7 unchanged, still overdue. All three (W6, W7, W8) now sitting overdue and Not Started with no board movement.
- 2026-08-17 — Monday sync: **W7 (Sage Intacct/QuickBooks) now overdue** — was due 08-14, still Not Started, no board movement since 08-10. **W8 (CCH Axcess/CoCounsel/Karbon) due today**, Not Started. W6 (draft v1 brief) still overdue from 08-07, unchanged. Three consecutive weekly research tasks now sitting Not Started — Platform Literacy brief work is stalling, worth raising directly rather than waiting on the board to move.
- 2026-08-11 — Monday sync: W4 (Gemini) and W5 (Codex vs Claude Code) both moved from stalled to **In Progress** on the board (2026-08-10), after 2+ weeks sitting overdue/Not Started per the 08-03 entry below. W6 (draft v1 brief) remains Not Started and overdue (was due 08-07) — still blocked on W4/W5 output landing in [[06_Resources/AI Platforms/AI Platforms Index|AI Platforms]]. W7 (accounting AI add-ons — Sage Intacct/QuickBooks) is now the current week's task (due 08-14), Not Started.
- 2026-08-03 — Monday sync (using 2026-07-23 as lookback cutoff — last sync gap): W1/W2 still In Progress, no board movement in 3+ weeks. **W4 (Gemini) and W5 (Codex vs Claude Code) are both overdue** (due 07-24 and 07-31, still Not Started) — a prior-session deep-research attempt at the Gemini profile did not produce a saved note in [[06_Resources/AI Platforms/AI Platforms Index|AI Platforms]], so W4 needs a proper re-run. W6 (draft v1 comparison brief) is now due this week (08-03–08-07) and depends on W4/W5 landing first.
- 2026-07-10 — Monday sync: W1/W2 platform research still In Progress; W3-W13 Not Started. No new board updates since 2026-07-09.
- 2026-07-17 — W3 done: Microsoft Copilot Company Profile written and linked. Deep-research workflow hit session limit mid-run (synthesis step failed, same as W2); finished manually from 16 verified claims plus targeted follow-up searches (Copilot Studio/Security Copilot pricing, Italy AGCM antitrust probe, GitHub Copilot benchmark standing). Key finding: Microsoft's own Work Trend Index data shows a real usage-to-value gap (88% usage vs. 39% attributed EBIT impact per third-party read) and 35.8% Copilot seat utilization — worth flagging to partners before assuming seat purchase equals adoption.

## Links

- [[06_Resources/AI Platforms/AI Platforms Index]]
- [[03_Todos/Work TODOs]]
- [[05_Areas/Development/Development Index]]
- [[09_Reference/Codex/Codex Index|Codex / Claude Code Index]] — audit prompt for W5
- [[09_Reference/Codex/AI Agent Workflow Audit Report 2026-07|AI Agent Workflow Audit Report 2026-07]] — audit results (patterns, instruction-file fixes, prompt checklist)
