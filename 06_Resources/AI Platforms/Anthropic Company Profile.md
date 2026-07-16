---
title: Anthropic Company Profile
created: 2026-07-15
type: resource
tags:
  - topic/ai-platforms
  - project/ai-initiative
---

# Anthropic Company Profile

Current as of **2026-07-15**. Company research for [[04_Projects/Active/AI Initiative|AI Initiative]] W1. Companion to [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison|Anthropic vs OpenAI Enterprise Comparison]].

## Executive take

**Anthropic looks like strongest current specialist for coding, long-running agents, and document-heavy knowledge work.** Claude Code is not only a strong model wrapped in a terminal: it has a coherent operating layer for project instructions, permissions, sandboxing, skills, hooks, MCP tools, subagents, plugins, and enterprise policy. That product depth helps explain why it feels more mature than Codex/ChatGPT in hands-on development.

Evidence supports that impression, with limits:

- Independent analysis finds Claude consistently overperforms its general ability on software-engineering benchmarks. Anthropic models held leading independent scores in May/June 2026. [Epoch AI](https://epoch.ai/data-insights/claude-ds-eci), [Artificial Analysis](https://artificialanalysis.ai/articles/claude-opus-4-8-analysis-and-benchmarks/)
- Claude Code reached **$1B run-rate revenue six months after public availability**. Business subscriptions quadrupled in early 2026; enterprise use became more than half of Claude Code revenue. These are vendor-reported, but powerful product-market-fit signals. [Anthropic: Claude Code milestone](https://www.anthropic.com/news/anthropic-acquires-bun-as-claude-code-reaches-usd1b-milestone), [Anthropic: Series G](https://www.anthropic.com/news/anthropic-raises-30-billion-series-g-funding-380-billion-post-money-valuation)
- Ramp spend data shows Anthropic leading OpenAI among Ramp-tracked US businesses: **42.4% vs. 39.5% in June 2026**. Still not total market share; Ramp customers skew toward tech-forward, card-paying businesses. [Ramp AI Index, July 2026](https://ramp.com/data/ai-index-july-2026)
- Not universal winner. Benchmark rankings change with model, harness, effort, and task mix. Claude is especially strong in multi-file software work and agentic knowledge work; rivals can lead terminal, math, cost, speed, or multimodal tasks.
- Business is growing extraordinarily fast, but valuation and capacity commitments assume that growth continues. Anthropic remains private, capital-intensive, dependent on cloud partners, exposed to litigation and government-policy disputes, and not currently profitable according to independent reporting. [AP](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1)

**Firm recommendation:** treat Anthropic as preferred pilot vendor for development and high-context professional work, not an exclusive firm-wide standard. Run a controlled Claude Enterprise/Team pilot beside Microsoft/OpenAI options. Measure quality, review time, total task cost, data handling, and outage impact on CDH-specific work.

## Evidence key

| Label | Meaning |
|---|---|
| **Primary fact** | Current Anthropic documentation, policy, status, or announcement |
| **Vendor claim** | Anthropic performance, customer, revenue, or adoption statement; useful but interested |
| **Independent signal** | Third-party benchmark, spend data, court reporting, or press |
| **Anecdotal signal** | User/community experience; hypothesis, not market fact |

## Company and business snapshot

| Item | Current picture | Evidence / caveat |
|---|---|---|
| Founded | 2021 by former OpenAI leaders; Claude maker | [AP company/funding profile](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1) |
| Positioning | Safety-focused frontier-model company increasingly centered on enterprise agents and coding | Product mix and public policy; positioning ≠ proven safety superiority |
| Reported run-rate revenue | **$47B** in May 2026 | Self-reported annualized pace, not audited completed-year revenue. [Anthropic Series H](https://www.anthropic.com/news/series-h), [AP](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1) |
| Latest financing | **$65B Series H**, **$965B post-money valuation**, May 28, 2026 | Private-round valuation, not public-market price. [Anthropic](https://www.anthropic.com/news/series-h), [AP](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1) |
| Profitability | Still losing money, per AP; February reporting described 2028 break-even target | Forecasts can move. [AP](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1), [Guardian/Reuters](https://www.theguardian.com/technology/2026/feb/12/anthropic-funding-round) |
| Coding business | Claude Code hit **$1B run-rate revenue in six months** by Nov. 2025 | Vendor-reported. [Anthropic](https://www.anthropic.com/news/anthropic-acquires-bun-as-claude-code-reaches-usd1b-milestone) |
| Business adoption | Anthropic used by **42.4%** of Ramp-tracked businesses in June vs. OpenAI **39.5%** | Spend-based US sample; use of both vendors common; not total enterprise share. [Ramp](https://ramp.com/data/ai-index-july-2026), [May crossover analysis](https://ramp.com/leading-indicators/the-ai-race-has-a-new-frontrunner-but-no-clear-winner) |
| Compute | Agreement with Amazon for up to **5 GW**; API also on AWS, Google Cloud, Microsoft Azure | Shows capacity and multi-cloud reach; also huge capital/partner dependence. [Anthropic/Amazon](https://www.anthropic.com/news/anthropic-amazon-compute) |

### Business model

Four reinforcing revenue engines:

1. **Per-seat software:** Claude Free/Pro/Max; Team; Enterprise.
2. **Usage revenue:** Claude API, prompt caching, web search, code execution, Managed Agents, priority tiers.
3. **Developer product:** Claude Code subscriptions, enterprise seats, usage credits, code review/security.
4. **Distribution:** direct sales plus AWS Marketplace, Amazon Bedrock, Google Vertex AI, and Microsoft Azure/Foundry.

Enterprise price structure is increasingly **seat + metered usage**, not traditional flat SaaS. Current self-serve Enterprise starts at **$20/seat plus API-rate usage**; negotiated plans remain contact-sales. Cost control therefore matters as much as license price. [Claude pricing](https://claude.com/pricing)

## Product map

| Product | What it does | Best-fit use |
|---|---|---|
| **Claude Chat** | Research, writing, analysis, files, projects, web search, memory, connectors | Everyday knowledge work and drafting |
| **Claude Code** | Agentic developer tool across terminal, IDE, desktop/web, and CI/review workflows | Repo analysis, implementation, debugging, migration, tests, code review |
| **Claude Cowork** | Delegates long-running background tasks across files and connected apps | Research, document production, repetitive cross-app work |
| **Claude Enterprise** | Chat + Code + Cowork with SSO, SCIM, RBAC, audit logs, spend/retention controls, Compliance API | Governed workforce deployment |
| **Claude Platform/API** | Model APIs, batch, caching, tools, Managed Agents, cloud distribution | Product integration and custom agents |
| **Connectors / MCP / plugins** | Adds internal context, external tools, packaged workflows | Knowledge search and governed action across business systems |
| **Claude for Microsoft 365** | Works in Excel, PowerPoint, Word, and Outlook | Finance, reporting, document and presentation workflows |
| **Claude Security / Code Review** | Reviews code for logic, regression, and security issues; drafts fixes | Engineering QA and security review; still beta/research-preview surfaces |

Product definitions and current enterprise packaging: [Claude Enterprise](https://claude.com/solutions/enterprise), [Claude pricing](https://claude.com/pricing), [Claude Code review docs](https://code.claude.com/docs/en/code-review).

## Where customers use Claude

### Established uses

- **Software development:** codebase discovery, feature work, debugging, migrations, tests, review, security analysis.
- **Document-heavy analysis:** large reports, contracts, policies, research synthesis, structured extraction.
- **Internal knowledge:** search across connected repositories and business systems; answer with relevant context.
- **Office production:** draft/edit Word documents, build/audit spreadsheets, create linked presentations, triage/draft email.
- **Customer support:** synthesize customer history, draft responses, classify and route work.
- **Agents and automation:** programmatic workflows using API tools, MCP, connectors, skills, and subagents.
- **Research and science:** literature review, evidence synthesis, coding/data analysis.
- **Regulated-industry modernization:** legacy-code analysis, insurance/finance/health workflows, governed internal assistants.

Anthropic's own usage data shows why coding dominates: September 2025 research mapped **44% of sampled first-party API traffic** to computer/mathematical work, while **77% of business API use** showed automation patterns. Office/admin work was second. This is Anthropic-measured telemetry, not an independent market census. [Anthropic Economic Index](https://www.anthropic.com/research/anthropic-economic-index-september-2025-report)

June 2026 research over about **400,000 Claude Code sessions** found humans usually decide *what* to do while Claude decides *how* to execute; users with more domain expertise got more work per instruction. Important implication: Claude is leverage for skilled staff, not substitute for judgment. [Anthropic: agentic coding and expertise](https://www.anthropic.com/research/claude-code-expertise)

### CPA / professional-services fit

**Strong pilot candidates**

- Internal application development and modernization.
- First-draft client correspondence, memos, policies, and presentations.
- Approved internal knowledge search with source links.
- Financial-document extraction, reconciliation support, and anomaly triage.
- Spreadsheet formula creation/audit and sensitivity-analysis assistance.
- Research briefs with mandatory citations and source validation.
- Month-end close checklists and workflow coordination.
- KYC/document screening support.

Anthropic now publishes finance-agent templates for work including KYC screening, pitchbooks, and month-end close, plus Microsoft 365 and financial-data connectors. Treat these as vendor-supplied starting points, not proof that workflows meet CDH controls. [Anthropic finance agents](https://www.anthropic.com/news/finance-agents)

**Keep human-owned**

- Tax conclusions and filing positions.
- Audit judgments, materiality, sampling, and sign-off.
- Client-facing financial advice.
- Final numbers in returns, financial statements, or attest reports.
- Autonomous posting, payment, deployment, credential, or production-data actions.
- Any output lacking traceable source/recalculation support.

## Software quality

### Evidence in Claude's favor

- **Software-engineering specialization:** Epoch finds Claude consistently performs better on software-engineering benchmarks than its general capability would predict, while historically underperforming on math. [Epoch AI](https://epoch.ai/data-insights/claude-ds-eci)
- **Frontier model quality:** Opus 4.8 led Artificial Analysis' Intelligence Index at launch, including strong agentic knowledge-work results. Fable 5 then launched at #1. [Opus 4.8 analysis](https://artificialanalysis.ai/articles/claude-opus-4-8-analysis-and-benchmarks/), [Fable 5 analysis](https://artificialanalysis.ai/articles/claude-fable-5-mythos-intelligence-index/)
- **Real engineering tasks:** Epoch's current SWE-bench Verified run listed Claude Opus 4.7 at **83.5% ±1.7%**, ahead of GPT-5.5 at **80.6% ±1.8%** in that scaffold. Scores depend heavily on agent scaffold and can change. [Epoch SWE-bench Verified](https://epoch.ai/benchmarks/swe-bench-verified)
- **Long-running agent design:** current product supports explicit project memory/instructions, reusable skills, MCP, hooks, isolated subagents, agent teams, and packaged plugins. [Claude Code extension overview](https://code.claude.com/docs/en/features-overview)

### Why Claude Code can feel more mature than Codex/ChatGPT

This is partly inference from product architecture plus Drew's own usage—not a proven universal preference.

1. **One coherent developer surface.** `CLAUDE.md`, rules, skills, hooks, MCP, subagents, teams, permissions, and plugins have distinct documented roles.
2. **Strong model/product fit.** Claude models are unusually strong at software work; Claude Code is tuned around repository-scale agent loops rather than generic chat alone.
3. **Visible control model.** Read-only default, explicit command/edit permissions, configurable policies, and sandboxing make autonomy understandable.
4. **Workflow depth.** Terminal, IDE, desktop, web, CI, PR review, and enterprise administration share one product vocabulary.
5. **Context handling.** Claude's long-context strength plus project instructions and tool ecosystem reduce repeated setup on large codebases.
6. **Enterprise path feels connected to individual workflow.** Same developer product scales into premium seats, policy controls, audit data, and usage analytics.

Counterpoint: model quality and harness quality are separable. Codex may beat Claude on some terminal benchmarks, be cheaper under an existing ChatGPT plan, or fit OpenAI/Microsoft-native workflows better. Best internal benchmark is CDH's own repositories, tasks, and review burden.

### Quality concerns

- Anthropic acknowledged **three Claude Code product bugs** that degraded quality over roughly six weeks in March-April 2026: reasoning-effort change, cache bug, and verbosity-prompt change. Core model was not intentionally reduced; fixes were complete by April 20. This validates user reports and shows product-layer changes can materially alter apparent model quality. [Anthropic postmortem](https://www.anthropic.com/engineering/april-23-postmortem)
- Fable 5's top capability comes with high cost, slower-than-average output, and more verbosity. Artificial Analysis observed safety fallback on **9%** of Humanity's Last Exam tasks in its launch evaluation. [Artificial Analysis](https://artificialanalysis.ai/articles/claude-fable-5-mythos-intelligence-index/)
- Benchmarks remain proxies. A model can score well yet over-engineer, miss firm conventions, hallucinate packages, or generate plausible but insecure code.

## Pricing snapshot

Current public US list pricing, before negotiated discounts; recheck before decisions. [Claude pricing](https://claude.com/pricing)

| Model | Input / 1M tokens | Output / 1M tokens | Position |
|---|---:|---:|---|
| Fable 5 | $10 | $50 | Highest-end long-running agents; premium price |
| Opus 4.8 | $5 | $25 | Complex coding and enterprise work |
| Sonnet 5 | $2 | $10 through 2026-08-31; then $3 / $15 | Main performance/cost balance |
| Haiku 4.5 | $1 | $5 | Fast, lower-cost work |

Other cost mechanics:

- Prompt-cache reads cost 10% of base input price; five-minute cache writes cost 125%.
- Batch processing advertises 50% savings.
- US-only inference costs 1.1×.
- Opus 4.8 fast mode costs 2×.
- Managed Agents runtime: $0.08 per active session-hour, plus tokens.
- Web search: $10 per 1,000 searches, plus tokens.
- Enterprise: $20/seat plus API-rate usage; negotiated terms available.

**Cost conclusion:** Claude can be worth premium rates when it finishes high-value work correctly with less review/rework. Token price alone cannot answer this. Measure **total cost per accepted task**:

`license + tokens + staff prompting + review + rework + failed runs + outage delay`

## Security, privacy, and governance

### Strengths

- Commercial-product inputs/outputs are **not used for model training by default**. Explicit feedback or opt-in can be used; feedback may retain related conversation for up to five years. [Anthropic Privacy Center](https://privacy.claude.com/en/articles/7996868-is-my-data-used-for-model-training)
- Enterprise offers SSO/SAML, SCIM, RBAC, audit logs, Compliance API, spend controls, IP allowlisting, network controls, custom retention, and HIPAA-ready option. Anthropic states SOC 2, ISO 27001, GDPR, and CCPA compliance. [Claude Enterprise](https://claude.com/solutions/enterprise)
- API inputs/outputs are normally deleted within 30 days, subject to product, safety, legal, and contractual exceptions. [Retention policy](https://privacy.claude.com/en/articles/7996866-how-long-do-you-store-my-organization-s-data)
- Claude Code uses permission controls and can add OS-level filesystem/network sandboxing. [Security docs](https://code.claude.com/docs/en/security), [sandbox docs](https://code.claude.com/docs/en/sandboxing)

### Details easy to miss

- Enterprise chat/project content is retained by default to provide conversation history. Custom retention must be configured; minimum is currently 30 days. Default can otherwise be indefinite. [Custom retention controls](https://privacy.claude.com/en/articles/10440198-configure-custom-data-retention-controls-for-enterprise-plans)
- Zero-data-retention arrangements apply only to eligible APIs and Claude Code Enterprise/API configurations, subject to approval and exceptions. [ZDR scope](https://privacy.claude.com/en/articles/8956058-i-have-a-zero-data-retention-agreement-with-anthropic-what-products-does-it-apply-to)
- Anthropic requires 30-day retention for designated high-capability “covered models,” including Mythos-class models, even in otherwise ZDR environments. [Covered-model retention](https://privacy.claude.com/en/articles/15425996-data-retention-practices-for-covered-models)
- Sandboxing is supported on macOS, Linux, and WSL2. **Native Windows support is only planned**, relevant to CDH. If sandbox dependencies fail, Claude Code warns and runs commands unsandboxed unless administrators configure fail-closed behavior. [Sandbox docs](https://code.claude.com/docs/en/sandboxing)
- Agent tools process untrusted repo content, web pages, plugins, and MCP output. Prompt injection, malicious dependencies, over-broad permissions, credential exposure, and data exfiltration remain real risks. Human approval is not a full security boundary.

### Minimum firm controls

1. Use Team/Enterprise or approved API—not consumer accounts—for client/confidential data.
2. Confirm contract, training, retention, region, subprocessors, incident notice, and deletion terms in writing.
3. Start with least privilege; deny secrets, production credentials, client-data exports, and destructive commands.
4. Use isolated dev/test environments. Require sandbox fail-closed where feasible.
5. Maintain source control, branch protection, tests, code review, audit logs, and rollback.
6. Treat connectors/MCP/plugins as separate vendors and attack surfaces.
7. Disable feedback submission if entire conversation retention is unacceptable.
8. Do not assume “no training” means “no storage.”

## Reliability and operating risk

Anthropic's status page currently reports 90-day uptime:

| Surface | 90-day uptime on 2026-07-15 |
|---|---:|
| claude.ai | 99.47% |
| Claude API | 99.58% |
| Claude Code | 99.52% |
| Claude Cowork | 99.61% |

July 2-14 history shows repeated elevated-error or degraded-performance incidents across Fable, Opus, Sonnet, Haiku, Claude Code/web, MCP authorization, and container creation. Most were short, but frequency matters for workflows that become operational dependencies. [Claude Status](https://status.claude.com/)

Practical response:

- Keep model/vendor fallback for critical workflows.
- Queue or retry idempotent work.
- Do not make deadline-critical close, filing, or deployment processes depend on one live model endpoint.
- Track task failures separately from model-answer errors; both affect business value.

## Business trends

### Positive

- **Enterprise crossover:** Anthropic passed OpenAI in Ramp's paid-business adoption sample and extended lead through June 2026.
- **Coding wedge became platform:** Claude Code's rapid revenue created a route from individual developer love to enterprise deployment.
- **Product expansion:** Chat → Code → Cowork → security/review → Managed Agents → Microsoft 365 and industry templates.
- **Regulated-industry distribution:** partnerships include PwC, DXC, Infosys, finance data providers, and systems integrators. [PwC](https://www.anthropic.com/news/pwc-expanded-partnership), [DXC](https://www.anthropic.com/news/dxc-anthropic-alliance), [Infosys](https://www.anthropic.com/news/anthropic-infosys)
- **Multi-cloud reach:** API access on AWS, Google Cloud, and Microsoft Azure reduces procurement friction and gives buyers deployment choices.
- **Strong funding/capacity:** enormous capital raise and Amazon capacity deal reduce near-term financing/capacity risk.

### Concerning

- **Run-rate optics:** $47B annualized revenue is a point-in-time extrapolation, not audited annual revenue. Hypergrowth can reverse as prices fall or customers optimize tokens.
- **Valuation risk:** $965B valuation prices in years of frontier leadership and rapid monetization.
- **Capital intensity:** up to 5 GW of Amazon capacity signals massive infrastructure need. Compute supply, power, chips, cloud terms, and unit economics remain strategic dependencies.
- **Customer price pressure:** frontier quality is expensive; open and lower-cost models keep improving. Multi-vendor use and low switching costs weaken moat.
- **Concentration around coding:** coding is excellent wedge but exposes Anthropic to Codex, Gemini, GitHub, Cursor, open models, and rapid benchmark leapfrogging.
- **Government-policy dispute:** Pentagon designated Anthropic a supply-chain risk after disagreement over safeguards. Courts produced conflicting interim outcomes; government revenue and reputation remain exposed. [Reuters, Mar. 26](https://www.investing.com/news/general-news/us-judge-blocks-pentagons-anthropic-blacklisting-for-now-4583980), [Reuters, Apr. 8](https://www.investing.com/news/world-news/us-court-declines-to-block-pentagons-anthropic-blacklisting-for-now-4604301)
- **Copyright liability:** proposed **$1.5B** author settlement remained under judicial review in May 2026. It is major cost plus precedent risk, not final closure yet. [Reuters](https://www.investing.com/news/stock-market-news/us-judge-considers-anthropics-15-billion-settlement-of-authors-lawsuit-4690939)
- **Product trust volatility:** quality regression, changing limits/packaging, high-end model availability, and frequent status incidents can erode professional trust even when core models lead.

## Sentiment read

### Positive signals

- Rapid paid adoption and Claude Code revenue show willingness to pay, stronger evidence than social-media praise.
- Developers commonly praise repository-scale reasoning, instruction following, long-context work, writing quality, and ability to carry multi-step tasks through testing.
- Anthropic publicly acknowledged the 2026 quality regression with concrete causes and remediation, improving credibility relative to denying user reports.
- Drew's direct experience: Claude Code feels better and more mature than Codex/ChatGPT. Local experience matters because CDH's actual stack and workflow are better predictors than a generic benchmark.

### Mixed / negative signals

- Pricing, opaque/variable usage limits, and surprise packaging changes create frustration.
- Some users report “model got worse” after product-layer changes; April postmortem confirmed a real version of that complaint.
- Refusals and safety fallback can interrupt legitimate security/research work.
- Outages and capacity limits are visible during rapid growth.
- Agent permissions create approval fatigue; broad auto-approval creates security risk.
- Claude can be verbose, over-engineer, or consume expensive tokens while exploring.

**Bottom line on sentiment:** developer enthusiasm is strong and commercially validated. Trust is conditional: users like capability, but react sharply to silent quality changes, restrictions, price/limit changes, and outages.

## Competitive moat

Likely durable advantages:

- Strong coding and agentic-model specialization.
- Claude Code product ecosystem and developer habit.
- Enterprise governance plus consumer-grade usability.
- MCP origin/leadership and broad connector/plugin ecosystem.
- Multi-cloud availability and major systems-integrator partnerships.
- Safety/reliability research brand valuable to regulated buyers.

Moat limits:

- Models and benchmarks leapfrog quickly.
- APIs are replaceable when applications use abstraction layers.
- 52% of Ramp customers using Anthropic or OpenAI used both in May 2026—weak vendor loyalty and active portfolio buying. [Ramp](https://ramp.com/leading-indicators/the-ai-race-has-a-new-frontrunner-but-no-clear-winner)
- Hyperscalers own much of compute and enterprise distribution.
- Open-source and cheaper models can capture routine workloads while frontier vendors keep only hardest tasks.

## Pilot design for CDH

### Proposed 6-week evaluation

| Track | Example work | Success measure |
|---|---|---|
| Development | Real bounded CDH issue, refactor, test failure, code review | Accepted change rate; review/rework minutes; escaped defects; total cost |
| Research | Accounting/technology brief with citations | Source accuracy; unsupported claims; staff editing time |
| Documents | Memo, policy, client-letter first draft | Template fidelity; factual corrections; time saved |
| Spreadsheet | Formula audit, reconciliation support, sensitivity model | Recalculation match; flagged defects; false positives |
| Internal knowledge | Approved policy/runbook search | Answer accuracy; source traceability; access-control correctness |

Test at least:

- Claude Team/Enterprise with Sonnet 5 default; Opus only for hard tasks.
- Claude Code against Codex on identical repo tasks and instructions.
- Microsoft/OpenAI option on Microsoft 365-heavy work.
- Normal workload and deliberate failure cases: ambiguous request, stale docs, malicious repo instruction, secret file, outage, and usage-cap event.

### Scorecard

Weight outcomes, not demo appeal:

| Dimension | Suggested weight |
|---|---:|
| Output correctness / accepted work | 30% |
| Human review + rework time | 20% |
| Security, privacy, governance fit | 20% |
| Total cost per accepted task | 15% |
| Reliability / continuity | 10% |
| User preference / adoption friction | 5% |

## Questions for Anthropic sales/security review

1. Exact Team vs. Enterprise seat, usage-credit, overage, and rate-limit terms?
2. Which products share or separate usage pools?
3. Default and configurable retention for Chat, Code, Cowork, files, connectors, logs, and feedback?
4. Can CDH obtain ZDR? Which models/features break ZDR?
5. Data residency, US-only inference, subprocessors, and support for client confidentiality obligations?
6. Does Microsoft 365 connector/add-in content stay within same commercial terms and audit boundary?
7. What telemetry/content enters Compliance API, audit logs, and support diagnostics?
8. Native Windows sandbox timeline and current enterprise-safe Windows deployment pattern?
9. SLA, service credits, support response, incident notice, and capacity guarantees?
10. Model deprecation notice and migration support?
11. Contract indemnity for IP claims and limits on output warranties?
12. Admin controls for MCP, plugins, skills, hooks, local files, network access, and autonomous actions?
13. Ability to export data/configuration and switch providers without workflow loss?

## Watch list

Review monthly until Q1 partner checkpoint:

- Ramp adoption lead: persists or reverses?
- Revenue: run-rate converts into audited/public results?
- IPO filing or financial disclosures.
- Claude Code quality/limit changes.
- 90-day uptime and incident frequency.
- Pentagon litigation and government availability.
- Copyright settlement approval and further cases.
- Native Windows sandbox delivery.
- Fable/Mythos availability, retention, and export-control changes.
- Sonnet standard price after 2026-08-31.
- Competitive coding benchmarks and CDH internal benchmark.

## Source notes

### Primary: Anthropic / Claude

- [Claude plans and API pricing](https://claude.com/pricing)
- [Claude Enterprise](https://claude.com/solutions/enterprise)
- [Series H funding and revenue announcement](https://www.anthropic.com/news/series-h)
- [Claude Code $1B milestone / Bun acquisition](https://www.anthropic.com/news/anthropic-acquires-bun-as-claude-code-reaches-usd1b-milestone)
- [Amazon compute expansion](https://www.anthropic.com/news/anthropic-amazon-compute)
- [Claude Code quality postmortem](https://www.anthropic.com/engineering/april-23-postmortem)
- [Claude Code security](https://code.claude.com/docs/en/security)
- [Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Claude Code extension model](https://code.claude.com/docs/en/features-overview)
- [Commercial data training policy](https://privacy.claude.com/en/articles/7996868-is-my-data-used-for-model-training)
- [Commercial retention policy](https://privacy.claude.com/en/articles/7996866-how-long-do-you-store-my-organization-s-data)
- [Enterprise custom retention](https://privacy.claude.com/en/articles/10440198-configure-custom-data-retention-controls-for-enterprise-plans)
- [Zero-data-retention scope](https://privacy.claude.com/en/articles/8956058-i-have-a-zero-data-retention-agreement-with-anthropic-what-products-does-it-apply-to)
- [Covered-model retention](https://privacy.claude.com/en/articles/15425996-data-retention-practices-for-covered-models)
- [Anthropic Economic Index: enterprise use](https://www.anthropic.com/research/anthropic-economic-index-september-2025-report)
- [Anthropic Economic Index: Claude Code expertise](https://www.anthropic.com/research/claude-code-expertise)
- [Finance-agent templates and Microsoft 365](https://www.anthropic.com/news/finance-agents)
- [Claude service status](https://status.claude.com/)

### Independent / external

- [Ramp AI Index: June 2026 adoption](https://ramp.com/data/ai-index-july-2026)
- [Ramp: Anthropic/OpenAI crossover and dual use](https://ramp.com/leading-indicators/the-ai-race-has-a-new-frontrunner-but-no-clear-winner)
- [Epoch AI: Claude software-engineering strength](https://epoch.ai/data-insights/claude-ds-eci)
- [Epoch AI: SWE-bench Verified](https://epoch.ai/benchmarks/swe-bench-verified)
- [Artificial Analysis: Opus 4.8](https://artificialanalysis.ai/articles/claude-opus-4-8-analysis-and-benchmarks/)
- [Artificial Analysis: Fable 5](https://artificialanalysis.ai/articles/claude-fable-5-mythos-intelligence-index/)
- [AP: funding, revenue, valuation, profitability caveat](https://apnews.com/article/86c432fa375548fd4f111f8164d6ffc1)
- [Reuters: author settlement review](https://www.investing.com/news/stock-market-news/us-judge-considers-anthropics-15-billion-settlement-of-authors-lawsuit-4690939)
- [Reuters: Pentagon designation blocked in California](https://www.investing.com/news/general-news/us-judge-blocks-pentagons-anthropic-blacklisting-for-now-4583980)
- [Reuters: separate D.C. appeal declined interim block](https://www.investing.com/news/world-news/us-court-declines-to-block-pentagons-anthropic-blacklisting-for-now-4604301)

## Related

- [[06_Resources/AI Platforms/AI Platforms Index]]
- [[06_Resources/AI Platforms/Anthropic vs OpenAI Enterprise Comparison]]
- [[09_Reference/Codex/AI Agent Workflow Audit Report 2026-07|Internal Codex + Claude Code workflow audit]]
- [[04_Projects/Active/AI Initiative]]
