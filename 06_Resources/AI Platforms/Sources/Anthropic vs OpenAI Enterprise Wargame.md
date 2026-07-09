> **SUPERSEDED** — this is the original Claude.ai draft, written with no web access. Its "likely fabricated" call on Mythos/Fable 5/Glasswing was wrong; live verification confirmed it real. See [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison|the corrected comparison]]. Kept here for provenance only.

# Anthropic vs. OpenAI — Enterprise Wargame & Multi-Agent Audit (as of July 9, 2026)

## ⚠️ Critical verification-capability disclosure (read first)
The bottom line on your core ask — *replacing unverified numbers with confirmed, live-sourced figures* — is that **this environment could not perform live web verification.** The only tools available to me, to the delegated research subagent, and to the enrichment pass were Microsoft 365 connectors (SharePoint, Outlook, Teams, Calendar). None can reach the public internet or vendor documentation, and the internal M365 corpus contains **zero** relevant material on any of these AI-vendor claims.

Therefore I have **not** re-checked any figure against a live July 2026 source. Everything below is assessed against my model knowledge, whose training cutoff predates July 2026, and is labeled by confidence:
- **CONFIRMED (training)** = matches well-established facts as of my knowledge cutoff, but *not* re-validated against a live mid-2026 source.
- **UNVERIFIABLE** = falls after my cutoff or I have no reliable knowledge; must be checked live.
- **LIKELY FABRICATED** = conflicts with known vendor naming/pricing conventions and could not be corroborated.

**Action required before any procurement decision:** re-validate every price, model name, version, date, and adoption statistic against the live vendor pricing/announcement pages (openai.com/api/pricing, platform.openai.com/docs, anthropic.com/pricing, docs.anthropic.com, anthropic.com/news) and reputable news (Reuters, Bloomberg, TechCrunch). These specifics change monthly.

---

## TL;DR
- **The "exotic" Anthropic items carried over from the earlier reports — the "Mythos" tier, "Claude Fable 5," "Claude Mythos 5," and "Project Glasswing," plus the June-9-release / June-12-export-control-suspension / July-1-restoration narrative — are assessed as LIKELY FABRICATED. They conflict with Anthropic's established Opus/Sonnet/Haiku naming and cannot be corroborated. By contrast, most of the mundane pricing claims match real vendor pricing as of my cutoff:** GPT-4.1 nano at $0.10/$0.40 (launched April 2025), Haiku 4.5 at $1/$5, Sonnet at $3/$15, and Opus at ~$5/$25 are all consistent with known figures. The specific *version numbers* GPT-5.5, GPT-5.4, Opus 4.8, Sonnet 4.6, and "Sonnet 5" fall after my cutoff and are UNVERIFIABLE here.
- **On enterprise substance the vendors are close and complementary: OpenAI leads on multimodal breadth (voice, image, Sora video), ecosystem size, and Azure-native procurement; Anthropic leads on coding/agentic reliability, safety governance, and — per Ramp's corporate-spend index — recently overtook OpenAI in *tracked paid business adoption* (~34% vs ~32%). That Ramp metric measures card/bill-pay adoption among Ramp customers, NOT total enterprise market share or revenue.**
- **OpenAI's Assistants API is genuinely being retired in favor of the Responses API; MCP is a *capability within* the Responses API, not the successor itself. This is a real migration enterprises on the Assistants API must plan now. The exact Aug 26, 2026 sunset date is plausible but UNVERIFIABLE here.**

---

## Key Findings — fact-check verdicts on the five priority claims

### 1. OpenAI model lineup & pricing
- **GPT-4.1 Nano — CONFIRMED (training).** The GPT-4.1 family (GPT-4.1, 4.1 mini, 4.1 nano) launched **April 14, 2025**, API-only. GPT-4.1 nano was priced **$0.10 input / $0.40 output per million tokens**. Both the price *and* the "launched April 2025, not 2026" claim match my knowledge. ✅
- **GPT-5.5 and GPT-5.4 (+ mini/nano) — UNVERIFIABLE.** GPT-5 launched **August 7, 2025** at roughly **$1.25 input / $10 output per million** (272K input context, 400K total). I have no knowledge of a "GPT-5.5" or "GPT-5.4." The claimed GPT-5.5 flagship price of **~$5/$30** does **not** match GPT-5's known pricing (it is ~4x/3x higher), so either a genuinely new higher-tier model was released after my cutoff or the figure is wrong. **Must be checked live.**
- **272K long-context surcharge — QUESTIONABLE.** 272K is GPT-5's maximum *input* window. Historically OpenAI has **not** used tiered/long-context surcharge pricing (that is a Google Gemini practice). This claim is inconsistent with known OpenAI practice; treat as unverified pending the live pricing page.

### 2. Anthropic model lineup & pricing
- **Haiku 4.5 at $1/$5 — CONFIRMED (training).** Claude Haiku 4.5 (released ~October 2025) was priced **$1 input / $5 output**. ✅
- **Sonnet at $3/$15 — CONFIRMED pricing; version UNVERIFIABLE.** Claude Sonnet 4.5 (~September 2025) was priced **$3/$15**. A "Sonnet 4.6," and especially a **"Sonnet 5" as current flagship**, fall after my cutoff — I can neither confirm they exist nor confirm which is the current flagship. The **$3/$15 price point is consistent** with the Sonnet tier.
- **Opus at ~$5/$25 — CONFIRMED pricing; version UNVERIFIABLE.** Claude **Opus 4.5** (~November 2025) cut Opus pricing to **$5 input / $25 output** (down sharply from Opus 4.1's $15/$75). The **$5/$25 figure is accurate** for the Opus tier as of late 2025; an **"Opus 4.8"** specifically is beyond my knowledge.
- **1M-token context with NO surcharge — QUESTIONABLE.** Anthropic's 1M-token context (introduced on Sonnet 4 in beta) historically carried a **~2x premium above 200K tokens** (roughly $6 input / $22.50 output in the long-context band). The "flat/standard pricing, no premium surcharge" claim **contradicts** that established structure. If Anthropic removed the surcharge in 2026 that would be a notable change — **verify live.**

### 3. "Mythos" tier / "Claude Fable 5" / "Claude Mythos 5" / "Project Glasswing"
- **LIKELY FABRICATED.** Anthropic's public model tiers are **Opus / Sonnet / Haiku**. "Mythos," "Fable," and "Glasswing" match **no known Anthropic product line**. The detailed narrative — Fable 5 and Mythos 5 releasing **June 9, 2026**, access suspended **~June 12, 2026** under **U.S. Department of Commerce export controls**, restored **~July 1, 2026** — is uncorroborated and internally characteristic of hallucinated "lore" (a named clandestine project, a precise suspension-and-restoration timeline, a shared underlying model). **Do not include these in any decision document without a primary Anthropic announcement URL.** If a source exists it would be at anthropic.com/news; absent that, strike them.

### 4. Ramp AI Index (Anthropic 34.4% vs OpenAI 32.3%)
- **METHODOLOGY CLAIM CORRECT; EXACT FIGURES/DATE UNVERIFIABLE.** Ramp does publish an **AI Index** derived from **corporate-card and bill-pay transactions among Ramp-tracked businesses** — a *paid-adoption* signal, **not** total enterprise market share and **not** revenue. Your framing of what it measures is right and important. An "Anthropic overtakes OpenAI" reading is **plausible and directionally consistent** with independent enterprise data (e.g., Menlo Ventures' 2025 enterprise-LLM research already showed Anthropic ahead of OpenAI in enterprise API share). However, the **precise 34.4% vs 32.3% split and the May 13, 2026 update / April 2026 data window are after my cutoff and UNVERIFIABLE here.** Verify at ramp.com/ai-index. Also note the selection bias: Ramp's customer base skews toward startups and mid-market tech-forward firms, so it is not representative of the whole enterprise market.

### 5. OpenAI Assistants API deprecation
- **SUCCESSOR CLARIFICATION CORRECT; DATE UNVERIFIABLE.** The **Responses API is the successor** to the Assistants API. OpenAI introduced the Responses API in March 2025 and stated it would deprecate the Assistants API once feature parity was reached, targeting a **2026** sunset. **MCP (Model Context Protocol) is a supported *capability within* the Responses API, not the successor itself** — your correction is right and worth stating explicitly, because conflating the two is a common error. The specific **August 26, 2026** shutdown date is plausible but falls after my cutoff; **confirm on platform.openai.com/docs (Assistants API migration guide).**

---

## Details — secondary six-pillar assessment (all "training" confidence unless noted)

- **Coding (SWE-bench Verified):** Anthropic's Claude Sonnet/Opus line has led SWE-bench Verified (roughly **77–82%** on the strongest configs); OpenAI's GPT-5 was competitive (~**74–75%**). Figures are approximate and pre-cutoff; re-check current leaderboards.
- **Multimodal:** OpenAI leads — native real-time **voice** (Realtime API/Advanced Voice), **image** generation, and **video** (Sora). Anthropic focuses on **text + vision + coding** and does not offer first-party video or voice generation. This is OpenAI's clearest capability moat.
- **Prompt caching (the "~90%" claim):** **Accurate for Anthropic** — cache *reads* are roughly **90% cheaper** than base input tokens (cache *writes* cost ~25% more than base input, and there is a TTL). OpenAI offers **automatic cached-input discounts** (historically ~50%, deepening toward ~75–90% on newer models). Real-world savings depend heavily on prompt-reuse patterns; treat "~90%" as a best-case cache-read figure, not a blended rate.
- **Enterprise security & compliance:** Both provide **SOC 2 Type II, ISO 27001, HIPAA (via BAA), zero-data-retention (ZDR) options for API/enterprise, and SSO/SCIM.** OpenAI adds VPC-style isolation via **Azure OpenAI Service**; Anthropic offers private connectivity via **AWS Bedrock (PrivateLink)** and **GCP Vertex AI**. Both are broadly enterprise-ready; parity is high here.
- **Infrastructure & cloud backing:** **OpenAI ↔ Microsoft Azure** as primary (with 2025 compute diversification via Oracle/CoreWeave and other deals). **Anthropic ↔ AWS** (primary; Trainium chips, Bedrock) **+ Google Cloud** (TPUs, Vertex). **Claude on Microsoft Azure AI Foundry** was reported as added in **late 2025** — meaning Azure customers can access *both* families; **verify current availability live.**
- **Governance & leadership stability:** **OpenAI** experienced the **November 2023 board crisis** (Sam Altman removed then reinstated within days) and notable 2024 senior departures (Ilya Sutskever, Jan Leike, Mira Murati). **Anthropic** (founded by Dario and Daniela Amodei and other ex-OpenAI staff) has had comparatively **stable** leadership and centers **Constitutional AI** and its **Responsible Scaling Policy**. For enterprises weighting vendor-governance risk, this favors Anthropic; for weighting commercial momentum and product breadth, OpenAI.

---

## Phase 1 — The Core Arguments

**The Case for OpenAI (steel-manned).** OpenAI offers the broadest capability surface in the market — text, native real-time voice, image generation, and video (Sora) — under one roof, backed by the largest developer ecosystem and mindshare and by deep **Microsoft/Azure** enterprise integration and co-selling. Its low end is aggressively priced (GPT-4.1 nano at **$0.10/$0.40**), and its agentic stack is consolidating cleanly onto the **Responses API** with built-in tool use and MCP support. For an enterprise that wants a single vendor covering every modality, Microsoft-native procurement, and the deepest third-party tooling, OpenAI is the low-friction default.

**The Case for Anthropic (steel-manned).** Anthropic offers best-in-class **coding and agentic reliability** (top SWE-bench Verified scores), a **safety-first governance posture** (Constitutional AI, Responsible Scaling Policy) that lowers enterprise reputational and compliance risk, and **competitive-to-leading token pricing** after the Opus cut to **$5/$25**. It provides very large context windows, **dual-cloud** availability (AWS + GCP, plus Azure AI Foundry), and **rising paid enterprise adoption** (Ramp shows it overtaking OpenAI in tracked business spend). For regulated industries and code-heavy, agentic workloads, Anthropic is the increasingly cost-effective and governance-safer bet.

## Phase 2 — The Red Team Audit (cynical auditor persona)

- **Marketing lore lacking data:** The **"Mythos/Fable/Glasswing"** cluster and the **export-control suspension saga** read as invented — a suspiciously cinematic project name, a shared "underlying model," and a tidy suspend/restore timeline, none traceable to a primary Anthropic source. **Reject on sight** for any board material until a URL is produced.
- **Claims that shift monthly and need a timestamp check:** Every **version number** (GPT-5.5, GPT-5.4, Opus 4.8, Sonnet 4.6, "Sonnet 5"), every **price**, the **Ramp percentages**, and the **Assistants API sunset date** must be re-pulled from the live source the day of decision. A report like this decays within weeks.
- **Anthropic's hidden risks:** Heavy dependence on **AWS and Google capital and compute** (concentration and strategic-partner risk); **export-control exposure** for frontier models (a real regulatory vector even if the specific June 2026 episode is unverified); and a **narrower multimodal range** (no video/voice generation) that limits it as a single-vendor solution.
- **OpenAI's hidden risks:** A documented history of **governance/leadership volatility** (2023 board crisis, 2024 executive churn); **Azure lock-in** plus increasingly complex, capital-intensive compute-financing arrangements; and a **forced migration** off the Assistants API that imposes real engineering cost on existing users.

## Phase 3 — Cross-Examination Matrix

*(All values are training-cutoff assessments; ✅ = matches known facts, ⚠️ = unverifiable/after cutoff, ❓ = conflicts with known practice. Re-verify live before use.)*

| Pillar / Metric | OpenAI (assessed) | Anthropic (assessed) |
|---|---|---|
| **Current flagship & price /1M tokens** | GPT-5 ~$1.25 in / $10 out ✅ · "GPT-5.5" ~$5/$30 ⚠️ (after cutoff; price inconsistent w/ GPT-5) | Opus 4.5 $5 in / $25 out ✅ · "Opus 4.8" ⚠️ |
| **Lightweight model /1M** | GPT-4.1 nano $0.10 / $0.40, launched Apr 14 2025 ✅ | Haiku 4.5 $1 / $5 ✅ |
| **Mid-tier model /1M** | GPT-4.1 $2 / $8 ✅ (mini $0.40/$1.60) | Sonnet 4.5 $3 / $15 ✅ · "Sonnet 4.6/5" ⚠️ |
| **Max context window** | ~400K total / 272K input (GPT-5); 1M on GPT-4.1 | Up to 1M; historically ~2x premium >200K ❓ (flat-price claim unverified) |
| **Long-context surcharge** | None known ❓ (272K surcharge claim inconsistent) | Yes, historically 2x >200K band |
| **Coding — SWE-bench Verified** | ~74–75% | ~77–82% (leads) |
| **Multimodal** | Voice + image + video (Sora) — broadest | Text + vision only (no video/voice-gen) |
| **Prompt caching** | Auto cached-input discount (~50–90%) | Cache reads ~90% cheaper ✅; writes +25% |
| **Security/compliance** | SOC 2 II, ISO 27001, HIPAA, ZDR, SSO/SCIM; Azure isolation | SOC 2 II, ISO 27001, HIPAA, ZDR, SSO/SCIM; Bedrock PrivateLink |
| **Cloud backing** | Azure primary (+ Oracle/CoreWeave) | AWS primary + GCP + Azure AI Foundry |
| **Agentic API** | **Responses API** (Assistants API sunsetting, ~Aug 26 2026 ⚠️); MCP = feature within it ✅ | Messages API + **MCP originator** |
| **Enterprise adoption (Ramp, spend-based)** | ~32.3% ⚠️ | ~34.4% ⚠️ (Anthropic overtakes; card/bill-pay adoption metric, not market share) |
| **Governance/leadership** | AGI-oriented, commercial; 2023 board crisis + 2024 exec churn | Constitutional AI / RSP; stable Amodei leadership |

---

## Recommendations (staged, with thresholds that change them)

1. **Immediately (data hygiene):** Before circulating any successor to the two prior AI-generated reports, **re-pull every price and model name from the live vendor pages** the day of publication, and **delete the "Mythos / Claude Fable 5 / Claude Mythos 5 / Project Glasswing" material and the export-control suspension narrative** unless a primary Anthropic URL is produced. Flag them in the changelog as removed-fabrications.
2. **Vendor selection (run a dual-vendor bake-off):** Pilot **Anthropic (Opus/Sonnet)** for code-generation, agentic, and regulated/compliance-sensitive workloads; pilot **OpenAI (GPT-5 + Responses API)** for multimodal, voice, and Microsoft-native/Azure-integrated workloads. Do not sole-source: the two are complementary and both are now available through Azure, lowering switching friction.
3. **Migration action:** If any team is on the **OpenAI Assistants API, start migrating to the Responses API now** and confirm the exact sunset date directly in OpenAI's migration guide; treat MCP as one included capability, not a drop-in replacement.
4. **Cost engineering:** Model real (not headline) costs using **prompt caching** — validate the ~90% cache-read savings against *your* prompt-reuse ratio, and separately price the long-context band for Anthropic (assume a possible 2x premium above 200K until confirmed otherwise).
5. **Thresholds that should change the recommendation:** a **>10-point SWE-bench Verified swing** between flagships; a **>2x change** in flagship token pricing; the **confirmed launch of a new flagship** (GPT-5.5 / "Sonnet 5" / "Opus 4.8") that alters the price-performance frontier; or a **material governance event** (leadership change, funding/compute disruption, or a real export-control action) at either vendor.

## Caveats
- **No figure in this report was verified against a live July 2026 source.** The environment provided only Microsoft 365 connectors; the research subagent and the enrichment pass likewise had no web access, and the internal corpus was empty. All values are model-knowledge assessments with a training cutoff predating July 2026.
- **Version numbers after late 2025 are unconfirmed:** GPT-5.5, GPT-5.4 (+ mini/nano), Claude Opus 4.8, Claude Sonnet 4.6, and "Claude Sonnet 5." The exact Ramp percentages/date and the Assistants API sunset date are likewise unconfirmed.
- **"Mythos," "Claude Fable 5," "Claude Mythos 5," and "Project Glasswing" are assessed as LIKELY FABRICATED** and should be treated as such absent a primary Anthropic source.
- Where I marked a claim ✅ CONFIRMED (training), that means it matched known facts as of my cutoff — it is a strong lead, not a live-verified fact. Treat this entire document as a **verification worklist**, not a substitute for checking the vendor pages before you commit budget.