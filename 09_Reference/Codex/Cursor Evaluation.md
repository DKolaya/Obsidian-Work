---
title: Cursor Evaluation
created: 2026-08-20
type: reference
tags:
  - topic/ai-workflows
  - project/ai-initiative
---

# Cursor Evaluation

Researched W7 (2026-08-10 → 08-14) for [[04_Projects/Active/AI Initiative|AI Initiative]], Track 2 (harnesses & dev tools). Verified 2026-08-20.

## Decision: not adopting

Cursor is a good product that doesn't fit our stack. The blocker isn't quality — it's that Cursor is a **VS Code fork and our dev team works in Visual Studio**. Adopting it isn't adding a tool alongside existing ones, it's an IDE migration.

## Why the IDE point is decisive

The CLI harnesses we've trialed — Claude Code, Codex, Copilot CLI — sit *alongside* the editor. Cursor replaces it. That means giving up the Visual Studio tooling our .NET/Blazor work depends on:

- Designer
- Debugger and profiler
- Hot Reload
- Solution/project management

None of that comes across to a VS Code fork in equivalent form. The switching cost is the whole development environment, paid by every developer, and what it buys is AI capability we already have licensed.

## Cost

| Tier | Price |
|---|---|
| Hobby | Free |
| Pro | $20/mo |
| Pro+ | $60/mo |
| Ultra | $200/mo |
| **Teams** | **$40/user/mo** |
| Enterprise | Custom |

Annual billing saves 20%. Teams adds SAML/OIDC SSO, org-wide privacy mode, usage analytics, agentic code review, shared team context, and centralized admin — the tier CDH would actually need.

Billing is **credit-based** (since June 2025): the monthly subscription includes a credit pool that depletes faster on expensive models. Spend tracks model usage rather than staying flat, so the $40 is a floor, not a budget.

This lands on top of M365, ChatGPT and Claude, all of which CDH already pays for.

## The ownership question — the intuitive version is wrong

**Cursor is not locked to Grok.** This is worth stating plainly because the assumption is natural and incorrect. Current model support includes:

- **Anthropic** — Claude 4.7 Opus, Claude 4.6 Sonnet, Claude 4.5 Haiku, Sonnet 5
- **OpenAI** — GPT-5 through GPT-5.6 variants, plus Codex models
- **Google** — Gemini 2.5 Flash through 3.7 Flash, Pro variants
- **Others** — Moonshot Kimi, Z.ai GLM 5.2
- **In-house** — Composer 2.5, Grok 4.5/4.6 (jointly trained with SpaceXAI)

The real exposure is structural, not current. SpaceX — which merged with xAI in February 2026 — closed a $60B all-stock acquisition of Cursor on **2026-08-14**. The acquisition announcement discussed compute access and model economics and made **no commitment to model neutrality**: nothing about third-party availability, nothing about independence, nothing about maintaining current options.

So continued support for Claude and GPT inside Cursor is now a business decision made by a direct competitor of the model vendors we depend on. That's a dependency to price before standardizing on any tool — but it is **secondary** here. The IDE mismatch decides it on its own, and this is the reason not to revisit the decision later purely on capability grounds.

## What would change the answer

- The dev team moving off Visual Studio for other reasons.
- Cursor shipping a Visual Studio extension rather than requiring its fork.
- A capability gap opening that our existing licensed tools can't close.

None of these are in view.

## Related

- [[09_Reference/Codex/Codex Index]]
- [[09_Reference/Codex/AI Agent Workflow Audit Report 2026-07]] — the harness comparison that set our baseline
- [[06_Resources/AI Platforms/Grok 4.6 Evaluation]] — same week, same vendor family
- [[04_Projects/Active/AI Initiative]]
