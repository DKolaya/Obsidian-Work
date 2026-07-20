---
title: OpenAI Company Profile
created: 2026-07-16
type: resource
tags:
  - topic/ai-platforms
  - project/ai-initiative
---

# OpenAI Company Profile

Current as of **2026-07-16**. Company research for [[04_Projects/Active/AI Initiative|AI Initiative]] W1. Companion to [[06_Resources/AI Platforms/Anthropic Company Profile|Anthropic Company Profile]] and [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison|Anthropic vs OpenAI Enterprise Comparison]].

## Executive take

**OpenAI is the broadest-reach AI vendor — largest consumer base, deepest Microsoft/Azure enterprise distribution, and the only frontier lab shipping voice, image, and (until recently) video generation alongside text — but it carries more corporate-structure, legal, and product-churn risk than Anthropic right now.** It remains the default choice for Microsoft-native shops and all-modality consumer-facing work; it is a weaker fit than Anthropic for CDH's highest-value use case (governed, long-running coding/document agents), based on current independent benchmarks.

Evidence supports that framing, with limits:

- OpenAI just completed a **$122B funding round at an $852B post-money valuation** (announced Mar 31, 2026), backed by Amazon, Nvidia, Microsoft, and SoftBank — one of the largest private rounds ever, and a signal the company can still finance its compute needs. [Forbes](https://www.forbes.com/sites/antoniopequenoiv/2026/03/31/openai-valuation-reaches-852-billion-after-massive-funding-round/)
- OpenAI is **still unprofitable**: ~$2B/month revenue (~$25B annualized by March 2026) against reported annual losses in the $10B+ range. Enterprise now exceeds 40% of revenue and is targeted to reach parity with consumer revenue by end-2026. [Forbes](https://www.forbes.com/sites/antoniopequenoiv/2026/03/31/openai-valuation-reaches-852-billion-after-massive-funding-round/), [Sacra/multiple aggregators — treat as vendor-adjacent, not audited]
- Ramp's most recent published edition (data through June 2026, released June 26, 2026) shows **Anthropic leading business adoption at 41% vs. OpenAI at 39.5%** — OpenAI has been in second place on this metric since April/May 2026. [Ramp AI Index, June 2026 edition](https://ramp.com/data/ai-index-june-2026)
- OpenAI finished its **for-profit conversion** (OpenAI Group PBC) in Oct 2025, survived an Elon Musk lawsuit challenging that conversion on a technicality (May 18, 2026 jury verdict), and filed a confidential S-1 in May 2026 targeting a September 2026 IPO at $852B–$1T. This is a company mid-restructuring with real litigation exposure, not a settled corporate entity. [Multiple corroborating outlets — see source notes]
- OpenAI shut down its Sora video app in Apr 2026 (API following Sep 2026) after deepfake/celebrity-likeness controversy (Bryan Cranston/SAG-AFTRA) and a collapsed Disney licensing deal — the app cost ~$1M/day to run against ~$2.1M lifetime revenue. Apple separately sued OpenAI in July 2026 alleging trade-secret theft tied to a consumer hardware effort. Neither is fatal, but both show product/legal turbulence beyond what Anthropic is currently managing. [See source notes]
- OpenAI still has real strengths CDH should weigh: broadest modality coverage (voice, image, formerly video), the cheapest credible model tier on the market (GPT-4.1 nano, $0.10/$0.40 per 1M tokens), and the deepest native path into Microsoft 365/Copilot for firms already standardized on that stack.

**Firm recommendation:** treat OpenAI as the natural second pilot vendor, especially for Microsoft-native and multimodal workloads, but not as the primary agentic-coding/document-agent vendor given current benchmark and product-maturity gaps versus Anthropic. Pilot GPT-5.6 Terra/Sol against Claude on identical CDH tasks; do not commit to Assistants API for anything new — it hard-sunsets Aug 26, 2026 with no migration tool.

## Evidence key

| Label | Meaning |
|---|---|
| **Primary fact** | Current OpenAI documentation, policy, status, or announcement |
| **Vendor claim** | OpenAI performance, customer, revenue, or adoption statement; useful but interested |
| **Independent signal** | Third-party benchmark, spend data, court reporting, or press |
| **Anecdotal signal** | User/community experience; hypothesis, not market fact |

## Company and business snapshot

| Item | Current picture | Evidence / caveat |
|---|---|---|
| Founded | 2015 as nonprofit; ChatGPT maker; completed conversion to for-profit **OpenAI Group PBC** in Oct 2025 | Former nonprofit (now "OpenAI Foundation") retains ~26% equity stake; Microsoft holds ~27% diluted. [Multiple corroborating outlets] |
| Positioning | Broadest-reach consumer + enterprise AI company; frontier models, agents, and now hardware ambitions | ChatGPT ~900M weekly active users (Mar 2026, vendor-reported) |
| Reported revenue/run-rate | **~$25B annualized** by March 2026, ~**$2B/month**; enterprise >40% of revenue, targeting parity with consumer by end-2026 | Vendor/press estimates, not audited. [Forbes](https://www.forbes.com/sites/antoniopequenoiv/2026/03/31/openai-valuation-reaches-852-billion-after-massive-funding-round/) |
| Profitability | **Not yet profitable**; reported multi-billion-dollar annual losses continue | Independent/press estimate — treat cautiously, figures vary by source |
| Latest financing | **$122B round**, **$852B post-money valuation**, announced Mar 31, 2026 | Backed by Amazon, Nvidia, Microsoft, SoftBank; individual investors >$3B. [Forbes](https://www.forbes.com/sites/antoniopequenoiv/2026/03/31/openai-valuation-reaches-852-billion-after-massive-funding-round/) |
| IPO status | Confidential S-1 filed **May 22, 2026**; targeting **September 2026** listing at $852B–$1T | Independent press reporting; a filing is not a guaranteed IPO date |
| Business adoption | **39.5%** of Ramp-tracked businesses (June 2026), vs. Anthropic's 41% — OpenAI in **second place** | Spend-based US sample; skews tech-forward, card-paying businesses; both vendors commonly used together. [Ramp AI Index, June 2026](https://ramp.com/data/ai-index-june-2026) |
| Compute/infra | Multi-cloud/multi-chip strategy following the Oct 2025 Microsoft agreement; Microsoft's prior right-of-first-refusal on compute was removed | Microsoft's exclusive IP-license access extended through 2032, but Microsoft no longer gatekeeps OpenAI's compute sourcing |
| Legal exposure | For-profit-conversion suit (Musk, resolved on technicality May 2026); Microsoft shareholder securities suit alleging "circular" AI investment (filed 2026, lead-plaintiff deadline Aug 11, 2026); Apple trade-secret suit (filed Jul 10, 2026) | Multiple live cases; none yet finally adjudicated on the merits |

### Business model

Diversifying but still consumer-heavy:

1. **Consumer subscriptions:** ChatGPT Free, Plus, Pro ($200/mo — 500K+ subscribers, ~$1.2B ARR alone), Go, Business, Enterprise, Edu. ~$17B of the ~$25B annualized run-rate is ChatGPT subscriptions (independent estimate).
2. **API/developer usage:** ~$6.5B of run-rate (independent estimate) — token usage, Codex, embeddings, fine-tuning.
3. **Video/licensing:** ~$1.5B (independent estimate) prior to the Sora shutdown; this line is now shrinking following the Apr/Sep 2026 wind-down.
4. **Emerging: advertising.** A ChatGPT ads pilot reportedly reached $100M+ ARR within six weeks — new, unproven at scale, and a notable departure from Anthropic's ad-free positioning.
5. **Distribution:** direct + deep Microsoft/Azure integration (Copilot, Azure AI Foundry), plus growing multi-cloud presence.

**CDH-relevant flag:** OpenAI's revenue mix is reported as far more consumer-subscription-weighted than Anthropic's (which self-reports ~77% of business API traffic showing automation patterns). If accurate, OpenAI's product roadmap incentives may skew toward consumer engagement/ads rather than governed enterprise workflows — worth probing directly in vendor discussions. Treat this comparison as directional (secondary-source estimate), not confirmed accounting.

## Product map

| Product | What it does | Best-fit use |
|---|---|---|
| **ChatGPT** (Free/Go/Plus/Pro/Business/Enterprise/Edu) | Consumer + business chat, files, projects, memory, voice (GPT-Live-1, replaced Advanced Voice Mode Jul 2026), image gen | Everyday knowledge work, drafting, broad consumer use |
| **ChatGPT Work** | Desktop workspace (launched Jul 9, 2026) for hours-long professional tasks — documents, decks, websites | Long-running document/report production |
| **Codex** | Agentic coding tool/CLI, now on the GPT-5.6 Sol/Terra/Luna model family | Repo-scale coding tasks; weaker independent benchmark standing than Claude Code on SWE-bench Pro as of Jul 2026 |
| **API platform** | Responses API + Conversations API (agentic/stateful), Embeddings, image gen (gpt-image-1), Whisper | Custom integrations and agents |
| **Assistants API** | **Deprecated** — hard sunset **Aug 26, 2026**, no grace period, **no automated migration tool** for Threads→Conversations | Any CDH team still on this needs a migration ticket now |
| **Sora / Sora API** | Text-to-video — **app discontinued Apr 26, 2026; API sunsets Sep 24, 2026** following deepfake/celebrity-likeness controversy and collapsed Disney deal | N/A going forward — do not build on this |
| **Operator** | Browser/agentic-action tool | Automated web tasks |
| **ChatGPT Enterprise/Business** | Admin console, SSO/SCIM, RBAC, IP allowlisting, multi-region data residency (US/EU/UK/JP/CA/KR/SG/IN/AU/UAE), Compliance API | Governed workforce deployment |
| **Microsoft 365 Copilot** | GPT-5.6 tiers now roll into Copilot per the Jul 9, 2026 model rollout | Firms standardized on Microsoft 365 |

Product definitions and current packaging: [ChatGPT pricing](https://chatgpt.com/pricing/), [OpenAI product releases](https://openai.com/news/product-releases/).

## Where customers use OpenAI

### Established uses (per OpenAI's own research)

OpenAI + Harvard economist David Deming analyzed 1.5M ChatGPT conversations (~700M weekly active users at time of study):

- **~30% of consumer ChatGPT usage is work-related; ~70% is non-work** — both categories growing over time. This is a materially different usage profile than Anthropic, whose own economic-index work focuses on API/business traffic (44% computer/mathematical work; 77% of business API traffic showing automation patterns).
- **Three-quarters of conversations focus on practical guidance, information-seeking, and writing** — writing is the single most common *work* task; coding and self-expression remain niche activities on the consumer product. [OpenAI: How People Are Using ChatGPT](https://openai.com/index/how-people-are-using-chatgpt/)
- **Business scale:** OpenAI reports 9M+ paying business users and crossed 1M business customers in Nov 2025.

**Caveat for CDH:** OpenAI has not published an API/enterprise-specific usage breakdown comparable to Anthropic's Economic Index reports (which explicitly quantify automation vs. augmentation patterns in business API traffic). The 30/70 work-split figure describes *consumer ChatGPT*, not necessarily what a firm would see from Enterprise/API deployment — don't over-extend it to a professional-services context without a pilot.

### CPA / professional-services fit

**Strong pilot candidates**

- Microsoft 365-native document/deck/report drafting (ChatGPT Work, Copilot integration).
- General research, writing, and information-seeking tasks — OpenAI's own data shows this is where consumer usage concentrates.
- Multimodal work: voice transcription/notes, image-based document handling.
- Cost-sensitive, high-volume, low-complexity tasks on GPT-4.1 nano ($0.10/$0.40 per 1M tokens) — the cheapest credible tier in the market.

**Keep human-owned** (same standard as Anthropic profile)

- Tax conclusions and filing positions.
- Audit judgments, materiality, sampling, sign-off.
- Client-facing financial advice.
- Final numbers in returns, financial statements, attest reports.
- Autonomous posting, payment, deployment, credential, or production-data actions.
- Anything relying on the now-shut-down Sora product or the sunsetting Assistants API.

## Software quality

### Evidence in OpenAI's favor

- **GPT-5.6 family** (Sol/Terra/Luna) launched Jul 9, 2026 — a new naming convention where the number marks generation and Sol/Terra/Luna mark durable capability tiers (flagship/balanced/fast) that can each advance independently. [OpenAI](https://openai.com/index/previewing-gpt-5-6-sol/)
- Sol claims **54% more token efficiency** for coding tasks vs. predecessors (OpenAI/Sam Altman claim), and independently, **Artificial Analysis has Sol (max) leading its Coding Agent Index at 80 points** — ahead of Anthropic's Fable 5 on that specific index, while using roughly a third of the cost and under half the output tokens. [TechCrunch](https://techcrunch.com/2026/07/09/openai-launches-its-new-family-of-models-with-gpt-5-6/), [Artificial Analysis](https://artificialanalysis.ai/articles/gpt-5-6-has-landed)
- Cheapest credible low tier in the market remains **GPT-4.1 nano** at $0.10/$0.40 per 1M tokens.

### Evidence against / mixed picture

- On **Artificial Analysis's broader Intelligence Index**, Sol (max) scores **59, one point behind Claude Fable 5 (max)**. On **SWE-bench Pro**, independent tracking has **Fable 5 at 80% vs. Sol at 64.6%** — a materially larger gap on pure software-engineering work than the Coding Agent Index suggests. [Artificial Analysis](https://artificialanalysis.ai/articles/gpt-5-6-has-landed), [industry benchmark trackers]
- OpenAI's own headline number for Sol (Terminal-Bench 2.1: 88.8%) is **self-reported, not independently audited** — flagged as a verification concern by benchmark-tracking sites.
- Net read: **OpenAI leads on cost-efficiency and one agentic-coding index; Anthropic still leads on general intelligence and pure SWE-bench performance.** This mirrors the Anthropic profile's own caution that benchmark rankings shift with model, harness, and task mix — verify against CDH's own repos before deciding.

## Pricing snapshot

Current public list pricing, before negotiated discounts; recheck before decisions. [ChatGPT pricing](https://chatgpt.com/pricing/), [OpenAI: previewing GPT-5.6 Sol](https://openai.com/index/previewing-gpt-5-6-sol/)

| Model | Input / 1M tokens | Output / 1M tokens | Position |
|---|---:|---:|---|
| GPT-5.6 Sol | $5 | $30 | Flagship — 2x/1.5x surcharge above 272K tokens |
| GPT-5.6 Terra | $2.50 | $15 | Balanced mid-tier |
| GPT-5.6 Luna | $1 | $6 | Fast/cheap tier |
| GPT-4.1 | $2 | $8 | Legacy flagship, no long-context surcharge |
| GPT-4.1 mini | $0.40 | $1.60 | Budget |
| GPT-4.1 nano | $0.10 | $0.40 | Cheapest credible tier in market |

Other cost mechanics:

- Prompt-cache reads: ~90% discount; **cache writes are free** (a real advantage vs. Anthropic's 125%/200% write surcharge by TTL).
- Long-context surcharge: 2x input / 1.5x output above 272K tokens on Sol/Terra (GPT-4.1 family exempt).
- ChatGPT Business: starts at **2-seat minimum**, billed per user/month.
- ChatGPT Enterprise: **no published self-serve price** — contact-sales only, same pattern as Anthropic's negotiated tier.

**Cost conclusion:** same standard as Anthropic profile — measure total cost per accepted task (license + tokens + prompting + review + rework + failed runs + outage delay), not sticker price. OpenAI's free cache writes and cheap nano tier favor high-volume/low-complexity workloads; Anthropic's flat long-context pricing favors document-heavy pipelines.

## Security, privacy, and governance

### Strengths

- **No-training-by-default** for ChatGPT Enterprise, Business, Edu, Healthcare, Teachers, and the API platform — inputs/outputs are not used to train or improve models by default. [OpenAI enterprise privacy]
- **Zero Data Retention (ZDR)** available for eligible API endpoints — prompts/outputs processed in memory and not retained post-request. **Not self-serve**: requires account-team enablement and is limited to supported endpoints — a real gap vs. assuming it's available everywhere.
- Enterprise governance: SAML SSO, SCIM provisioning, RBAC, admin console, IP allowlisting, multi-region data residency (US/EU/UK/JP/CA/KR/SG/IN/AU/UAE), Compliance API with audit-log export.
- Certifications: **SOC 2 Type II** (period Jan 1–Jun 30, 2025) and **ISO/IEC 27001:2022** covering API, ChatGPT Enterprise, and ChatGPT Edu; ISO 27017/27018/27701 also claimed on the pricing page. **Caveat:** SOC 2 attestation window (Jan–Jun 2025) is now over a year stale as of this writing — ask OpenAI for the current attestation period before relying on it.

### Details easy to miss

- Default API retention **without ZDR** is short-term (up to ~30 days) for abuse monitoring, then deleted absent legal hold — same shape as Anthropic's default, but confirm this in writing per engagement.
- "No training" and "zero retention" are **separate commitments** — having one does not guarantee the other. Confirm both explicitly for any CDH-bound data flow.
- Compliance/audit logs from the Compliance Platform are retained ~30 days on OpenAI's side by default; customers must export for longer retention (per third-party analysis — verify directly with OpenAI, not independently confirmed from a primary source in this pass).
- Assistants API sunset (Aug 26, 2026) means any current data/session structure built on it must be re-architected — this is a compliance/continuity risk in its own right if left unaddressed.

### Minimum firm controls

Same eight controls as the Anthropic profile apply here without modification — Team/Enterprise-only for client data, contract terms in writing, least privilege, isolated dev/test, source control + audit + rollback, treat connectors as separate vendors, disable optional data-sharing features, don't assume "no training" means "no storage."

## Reliability and operating risk

OpenAI's status page currently reports uptime (Apr–Jul 2026 window):

| Surface | Uptime |
|---|---:|
| ChatGPT (15 components) | 99.85–99.86% |
| API (12 components) | 99.97% |
| Codex (4 components) | 99.98% |
| FedRAMP (1 component) | 100% |

No open incidents at time of this check (2026-07-16), but the surrounding window (Jul 14–16) reportedly included SSO login errors, a voice-mode outage, and elevated ChatGPT error rates — comparable incident frequency to Anthropic's own recent status history. [OpenAI Status](https://status.openai.com/)

Practical response: identical to the Anthropic profile — keep model/vendor fallback, queue/retry idempotent work, don't make deadline-critical processes depend on one live endpoint.

## Business trends

### Positive

- **Financing strength:** $122B round, $852B valuation, backing from Amazon/Nvidia/Microsoft/SoftBank reduces near-term capital risk.
- **Enterprise growing fast off a small base:** enterprise revenue share crossed 40% and is targeted for parity with consumer by end-2026 — if it holds, this addresses the "too consumer-heavy" critique.
- **Cheapest credible tier in market** (GPT-4.1 nano) plus free cache writes give real cost advantages for high-volume workloads.
- **Microsoft relationship restructured, not severed:** Microsoft's IP-license access extended through 2032; Microsoft no longer gatekeeps OpenAI's compute sourcing, giving OpenAI more infrastructure flexibility while Microsoft still competes to serve OpenAI's workloads.

### Concerning

- **Still unprofitable** at a run-rate/loss scale that dwarfs most enterprise software companies; profitability timeline is less clearly public than Anthropic's stated 2028 target.
- **Corporate structure mid-transition:** for-profit conversion completed Oct 2025 only after surviving a Musk-led legal challenge (won on a technicality, not the merits) — residual reputational and legal overhang remains.
- **Active litigation on multiple fronts:** Microsoft shareholder securities suit (alleging circular AI investment inflating reported Azure growth — Microsoft invested $13B+ in OpenAI and up to $5B in Anthropic while both committed to Azure purchases); Apple trade-secret suit (Jul 2026, alleging IP theft for OpenAI's hardware ambitions).
- **Sora shutdown** shows OpenAI will ship products that create real reputational/legal exposure (deepfakes, unauthorized likenesses) before pulling them — a governance signal worth weighing for any CDH-adjacent brand risk.
- **Falling behind on business-adoption share:** second place to Anthropic on Ramp's metric since spring 2026, and the gap widened slightly in the June 2026 edition (Anthropic +2.5pp to 41%, OpenAI roughly flat at 39.5%).
- **Assistants API hard sunset** (Aug 26, 2026, no migration tool) is a concrete, dated cost for any team still on it.

## Sentiment read

### Positive signals

- Largest consumer user base of any AI product (~900M weekly actives, vendor-reported) — enormous distribution and brand recognition.
- Cheapest credible pricing tier in market draws cost-sensitive developers and high-volume use cases.
- Deep, improving Microsoft/Azure integration is a genuine draw for Microsoft-native enterprises.
- GPT-5.6 Sol's efficiency/cost claims (54% more token-efficient, ~1/3 the cost of Fable 5 on the Coding Agent Index) are resonating with cost-conscious technical buyers.

### Mixed / negative signals

- Sora's deepfake controversy and abrupt shutdown, plus the collapsed Disney deal, generated real public and industry-partner trust damage.
- Multiple concurrent lawsuits (Musk, Microsoft shareholders, Apple) create headline risk and management distraction independent of model quality.
- Independent benchmarks show OpenAI trailing Anthropic on general intelligence and pure SWE-bench work even where it leads on a specific coding-agent cost/efficiency index — a nuance easy to lose in vendor marketing.
- Falling (relative) enterprise-adoption share versus Anthropic on the one adoption metric both profiles rely on.

**Bottom line on sentiment:** OpenAI retains unmatched consumer scale and Microsoft-channel strength, but 2026 has been a rockier year on the corporate-governance, litigation, and enterprise-momentum fronts than Anthropic's.

## Competitive moat

Likely durable advantages:

- Largest consumer distribution and brand recognition in the category.
- Deepest Microsoft 365/Azure/Copilot integration — hard for CDH to replicate access to without a Microsoft-native vendor.
- Broadest historical modality range (voice, image; video only until Apr/Sep 2026 shutdown).
- Cheapest credible low-cost tier, useful for cost-sensitive high-volume work.

Moat limits:

- APIs are replaceable when applications use abstraction layers — same dynamic as Anthropic.
- Consumer-heavy revenue mix means product incentives (e.g., the new ads pilot) may drift from what a governed enterprise buyer wants.
- Falling behind on the one third-party business-adoption metric both vendors are measured against.
- Litigation and product-shutdown pattern (Sora) signal execution risk beyond pure model competition.
- Assistants API sunset shows OpenAI will deprecate infrastructure customers depend on with a hard date and no migration tooling — a real switching-cost/trust cost for anyone building on its APIs.

## Pilot design for CDH

### Proposed 6-week evaluation (mirrors Anthropic profile's structure)

| Track | Example work | Success measure |
|---|---|---|
| Development | Same bounded CDH issue/refactor/review task run on Claude Code, using Codex on GPT-5.6 Terra/Sol | Accepted change rate; review/rework minutes; escaped defects; total cost |
| Microsoft-native document work | Word/Excel/PowerPoint drafting via Copilot + GPT-5.6 | Template fidelity; factual corrections; time saved vs. Claude for Microsoft 365 |
| Research | Accounting/technology brief with citations | Source accuracy; unsupported claims; staff editing time |
| Voice/multimodal | Meeting transcription, voice-driven drafting (GPT-Live-1) | Transcription accuracy; time saved; a capability Anthropic doesn't natively match |
| Cost-sensitive bulk work | High-volume, low-complexity tasks on GPT-4.1 nano/Luna | Cost per task vs. Haiku 4.5; quality floor maintained |

Test at least:

- ChatGPT Business/Enterprise with GPT-5.6 Terra default; Sol only for hard tasks.
- Codex against Claude Code on identical repo tasks and instructions.
- Confirm no dependency, current or planned, on Assistants API or Sora.
- Same deliberate failure cases as the Anthropic pilot: ambiguous request, stale docs, malicious repo instruction, secret file, outage, usage-cap event.

### Scorecard

Same weighting as the Anthropic profile, applied identically for a fair comparison:

| Dimension | Suggested weight |
|---|---:|
| Output correctness / accepted work | 30% |
| Human review + rework time | 20% |
| Security, privacy, governance fit | 20% |
| Total cost per accepted task | 15% |
| Reliability / continuity | 10% |
| User preference / adoption friction | 5% |

## Questions for OpenAI sales/security review

1. Current SOC 2 Type II attestation period (the publicly cited one, Jan–Jun 2025, is now stale) — what's the latest report date?
2. Exact ZDR eligibility: which endpoints, which plan tiers, what's the enablement process and timeline?
3. Business vs. Enterprise seat minimums, usage-credit/overage terms, and rate limits?
4. Data residency options and whether CDH client data can be pinned to a specific region contractually?
5. What happens to any pilot data/config built on the Assistants API before Aug 26, 2026 — is there a supported manual migration path CDH can follow?
6. Does the Microsoft 365 Copilot integration share the same commercial/audit terms as direct ChatGPT Enterprise, or is it a separate contract?
7. Admin controls for Codex, connectors, and any autonomous/agentic actions — approval gates, logging, revocation?
8. Contract indemnity for IP claims (relevant given the active Apple suit) and limits on output warranties?
9. Any planned pricing changes to GPT-5.6 family or GPT-4.1 family, and deprecation notice policy?
10. SLA, incident notice process, and support response commitments?
11. Status of the corporate restructuring (OpenAI Group PBC) as it affects contract counterparty, IP ownership, and long-term vendor stability?
12. Ability to export data/configuration and switch providers without workflow loss?

## Watch list

Review monthly until Q1 partner checkpoint:

- Ramp adoption gap: does OpenAI recover share, or does Anthropic's lead widen?
- IPO progress: does the Sep 2026 target hold, and at what valuation?
- Resolution of the Microsoft shareholder securities suit (lead-plaintiff deadline Aug 11, 2026) and the Apple trade-secret suit.
- Whether enterprise revenue actually reaches parity with consumer revenue by end-2026 as targeted.
- GPT-5.6 tier performance on CDH's own benchmark tasks vs. Claude.
- Any concrete Assistants API migration deadline slippage (currently firm at Aug 26, 2026).
- New product launches following the Sora shutdown pattern — watch for repeat governance/reputational risk.
- SOC 2/ISO attestation renewal dates.

## Source notes

### Primary: OpenAI / ChatGPT

- [ChatGPT plans and pricing](https://chatgpt.com/pricing/)
- [Previewing GPT-5.6 Sol](https://openai.com/index/previewing-gpt-5-6-sol/)
- [How people are using ChatGPT](https://openai.com/index/how-people-are-using-chatgpt/)
- [OpenAI product releases](https://openai.com/news/product-releases/)
- [OpenAI Status](https://status.openai.com/)
- [What to know about the Sora discontinuation](https://help.openai.com/en/articles/20001152-what-to-know-about-the-sora-discontinuation)
- [Assistants API deprecation announcement](https://community.openai.com/t/assistants-api-beta-deprecation-august-26-2026-sunset/1354666)
- [Enterprise privacy at OpenAI](https://openai.com/enterprise-privacy/) *(fetch blocked at research time — content per secondary sources; verify directly)*

### Independent / external

- [Forbes: $852B valuation, $122B round](https://www.forbes.com/sites/antoniopequenoiv/2026/03/31/openai-valuation-reaches-852-billion-after-massive-funding-round/)
- [Ramp AI Index, June 2026 edition](https://ramp.com/data/ai-index-june-2026)
- [TechCrunch: GPT-5.6 launch](https://techcrunch.com/2026/07/09/openai-launches-its-new-family-of-models-with-gpt-5-6/)
- [Artificial Analysis: GPT-5.6 benchmarks](https://artificialanalysis.ai/articles/gpt-5-6-has-landed)
- [SaaSDossier: OpenAI security evidence ledger](https://saasdossier.com/vendors/openai/security-evidence-ledger)
- [The Decoder: Sora two-stage shutdown](https://the-decoder.com/openai-sets-two-stage-sora-shutdown-with-app-closing-april-2026-and-api-following-in-september/)
- [TechCrunch: Apple sues OpenAI over trade secrets](https://techcrunch.com/2026/07/10/apple-sues-openai-over-alleged-trade-secret-theft/)
- [The D&O Diary: Microsoft AI-related securities suit](https://www.dandodiary.com/2026/06/articles/artificial-intelligence/microsoft-hit-with-ai-related-securities-suit/)
- [PDPSpectra: OpenAI/Microsoft 2026 relationship](https://pdpspectra.com/blog/openai-microsoft-tension-2026/)

**Note on source quality:** several claims in this profile (revenue split, compliance-log retention detail, some litigation specifics) come from secondary aggregators rather than primary OpenAI documentation, because several openai.com trust/privacy pages returned HTTP 403 or blocked-content responses during this research pass. Flagged inline above — re-verify directly with OpenAI sales/security contacts before using in a partner presentation, per the same standard applied to the Anthropic profile.

## Related

- [[06_Resources/AI Platforms/AI Platforms Index]]
- [[06_Resources/AI Platforms/Anthropic Company Profile]]
- [[06_Resources/AI Platforms/Microsoft Copilot Company Profile]]
- [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison]]
- [[04_Projects/Active/AI Initiative]]
