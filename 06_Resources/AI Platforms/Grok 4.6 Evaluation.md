---
title: Grok 4.6 Evaluation
created: 2026-08-20
type: resource
tags:
  - topic/ai-platforms
  - project/ai-initiative
---

# Grok 4.6 Evaluation

Researched W7 (2026-08-10 → 08-14) for [[04_Projects/Active/AI Initiative|AI Initiative]], Track 1 (model landscape). Figures verified 2026-08-20.

## Executive take

Grok 4.6 is **the cheapest model currently at the frontier** — $2/$6 per million at an intelligence score level with GPT-5.6 Sol. It undercuts [[06_Resources/AI Platforms/Kimi K3 Evaluation|Kimi K3]] on price while scoring higher, which is the second consecutive week pointing at the same conclusion.

One real catch: the headline price is not the price on long agentic sessions. Past 200K tokens xAI rebills the entire request at a higher rate, and agentic workloads accumulate context by design.

## What it is

| | |
|---|---|
| Vendor | xAI |
| Released | 2026-08-12 |
| Context | 500,000 tokens |
| Focus | Long-running agents, agentic coding, interactive/visual work |
| Availability | xAI API, Cursor, Grok Build, OpenRouter, Vercel, Cloudflare |

Launch promotion included 2× included usage in Grok Build and Cursor for the first week.

## Performance

| Benchmark | Grok 4.5 | Grok 4.6 |
|---|---|---|
| Artificial Analysis Intelligence Index | — | **61** |
| DeepSWE | 54 | **65.9** |
| APEX-Agents | 47.1 | **57.5** |

61 puts it level with GPT-5.6 Sol and at the frontier tier. The agentic-coding jumps over 4.5 are the substantive change — this is a release aimed at exactly the long-horizon agent work our harnesses do.

> **Unreconciled:** the source placing Grok 4.6 at 61 describes it as one point behind Fable 5, implying 62. [[06_Resources/AI Platforms/Kimi K3 Evaluation|W6's research]] recorded Fable 5 at 60. Settle before either figure goes in the comparison brief.

## Pricing

| | Input /M | Output /M |
|---|---|---|
| **Grok 4.6** | $2.00 | $6.00 |
| Kimi K3 | $3.00 | $15.00 |
| GPT-5.6 | $2.00 | $8.00 |
| Opus 5 | $5.00 | $25.00 |
| Fable 5 | $10.00 | $50.00 |

A faster variant costs 2×.

### The 200K billing cliff

Once a prompt crosses **200K tokens**, xAI rebills the **entire request** at:

| | Rate /M |
|---|---|
| Input | $4.00 |
| Cached input | $1.00 |
| Output | $12.00 |

This is not a marginal rate on the overage — it reprices the whole call. Agentic sessions accumulate context as they run, so a long session silently doubles its input rate and its output rate. Anyone budgeting against $2/$6 for agent work will be wrong.

## CDH read

- **Worth having available through the API for cost-sensitive work.** Not a default. The frontier-tier score at that price is real, but it hasn't been tried on our code.
- **Budget against the post-200K rates, not the headline**, for anything agentic.
- **Vendor concentration is a live consideration.** xAI merged with SpaceX in Feb 2026 and now owns [[09_Reference/Codex/Cursor Evaluation|Cursor]]. Adopting both the model and the harness from the same owner concentrates dependency in one Musk-controlled entity — worth weighing separately from the technical merits, particularly for anything client-facing.

## The cross-week signal

Three consecutive weeks, same direction: **frontier capability is commoditizing on price.** K3 landed 70% under Fable 5; Grok 4.6 undercut K3 and scored higher. The strategic conclusion for CDH is that model choice should stay a per-workload decision we can change cheaply — which argues for model-agnostic harnesses and against standardizing on any tool whose owner has a horse in the race.

## Still owed

Trial on real CDH code. Same carry as W6, still outstanding.

## Related

- [[06_Resources/AI Platforms/AI Platforms Index]]
- [[06_Resources/AI Platforms/Kimi K3 Evaluation]]
- [[09_Reference/Codex/Cursor Evaluation]] — same week, same vendor family
- [[04_Projects/Active/AI Initiative]]
