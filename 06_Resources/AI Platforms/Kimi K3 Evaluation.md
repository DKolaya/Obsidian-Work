---
title: Kimi K3 Evaluation
created: 2026-08-20
type: resource
tags:
  - topic/ai-platforms
  - project/ai-initiative
---

# Kimi K3 Evaluation

Researched W6 (2026-08-03 → 08-07) for [[04_Projects/Active/AI Initiative|AI Initiative]], Track 1 (model landscape) and Track 5 (build-with-AI). Figures verified 2026-08-20.

## Executive take

Kimi K3 is a **Fable 5-tier competitor at roughly 30% of the price** — not an Opus substitute, which is the easy mistake to make. It scores within a few points of Fable 5 on general intelligence and beats it outright on frontend coding, at $3/$15 per million against $10/$50.

The open weights are the more interesting half and the more disappointing one. K3 is the first genuinely frontier-class model CDH could legally run in-house, and the hardware math says we can't afford to. That's a useful negative result: it dates the "can we run this locally" question rather than leaving it open.

## What it is

| | |
|---|---|
| Vendor | Moonshot AI |
| Released | 2026-07-16 (API), 2026-07-27 (weights) |
| Architecture | 2.8T parameter mixture-of-experts — 896 experts, 16 active per token |
| Context | 1,048,576 tokens |
| Max output | ~974,842 tokens |
| License | Modified MIT, training data withheld |

Open-**weight**, not open-source. We can download, run and fine-tune it; we cannot audit what went into it. That distinction matters for any client conversation about provenance.

## Performance

| Benchmark | Kimi K3 | Comparison |
|---|---|---|
| Artificial Analysis Intelligence Index | 57 | Fable 5: 60 |
| GDPval-AA v2 | 1,687 (3rd overall) | Fable 5 Max 1,815 · GPT-5.6 Sol Max 1,747.8 · Opus 4.8 1,600 |
| Frontend Code Arena | **1,679 Elo** | beats Fable 5 |
| GPQA Diamond | 90.2–93.1% | varies by provider |
| TAU-Bench | 70.7–78.0% | partial data |

## Pricing

| | Input /M | Output /M | Cached in /M |
|---|---|---|---|
| **Kimi K3** (Moonshot direct) | $3.00 | $15.00 | $0.30 |
| Fable 5 | $10.00 | $50.00 | $1.00 |
| Grok 4.6 | $2.00 | $6.00 | — |
| Opus 5 | $5.00 | $25.00 | — |

Third-party resellers vary — OpenRouter's cheapest shows $2.60/$13.00, others up to $6.00/$22.50. Moonshot's Mooncake disaggregated inference reports >90% cache-hit on typical coding workloads, so real input traffic lands closer to $0.30 than the $3.00 headline.

## Self-hosting: the math doesn't work

| Configuration | Monthly (24/7) |
|---|---|
| 8×B300 (cheapest) | ~$42,566 |
| 8×B300 (mid) | ~$43,200–45,216 |
| 16×B200 | ~$67,853 |

8×B200 is **not** viable — falls 121 GB short of the 1,561 GB checkpoint. Minimum real config is 8×B300 or a GB300 NVL72. Counterintuitively the newer B300 hardware is cheaper overall than 16×B200.

**Break-even against the API:**
- ~1,095 output tokens/second sustained, measured against the $15/M output rate alone
- ~7,109 output tokens/second sustained against a realistic blended rate with prompt caching

CDH is not within an order of magnitude of either. Below a few thousand output tokens/second, sustained, the API is cheaper and it isn't close — before counting the ops burden.

## CDH read

- **Model choice is now a per-workload decision, not a vendor commitment.** A near-peer to the top tier exists at a third of the cost. Anything running at Fable 5 rates should have a reason it needs Fable 5.
- **Self-hosting is a compliance lever, not a savings lever.** The only case that justifies ~$42.5k/month is a client engagement requiring that prompts and documents never leave our infrastructure. Relevant to the Initiative 5 product offering; irrelevant to internal dev use, where we already accept vendor terms.
- **What's closing is availability, not capability.** Open weights now land within weeks of the API release and within a few points of frontier. The blocker on local is hardware cost. Worth re-checking on every major open-weight drop — the moment that math flips, data residency stops being a cost and becomes a product option.

## Still owed

Benchmarks aren't workloads. K3 has not been run against real CDH code. Route it into a harness and try it on an actual ticket before this becomes a recommendation.

## Related

- [[06_Resources/AI Platforms/AI Platforms Index]]
- [[06_Resources/AI Platforms/Grok 4.6 Evaluation]] — same signal, one week later
- [[04_Projects/Active/AI Initiative]]
