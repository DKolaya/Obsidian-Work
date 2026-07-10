---
title: AI Agent Workflow Audit Prompt
created: 2026-07-08
type: reference
tags:
  - topic/codex
  - topic/claude-code
  - topic/ai-workflows
  - topic/prompting
---

# AI Agent Workflow Audit Prompt

## Purpose

Use this prompt when you want an AI to review Codex and Claude Code history, find workflow patterns, and recommend better prompting, instructions, verification habits, and handoff practices.

> **Run history:** v2 executed 2026-07-09 over Jun 9 – Jul 9 transcripts (111 Codex + 40 Claude Code sessions, all projects) → results in [[AI Agent Workflow Audit Report 2026-07]].

## Full Prompt

```text
You are auditing my AI coding workflow across Codex and Claude Code.

Goal:
Review all available transcripts, logs, AGENTS.md, CLAUDE.md, prompts, tool outputs, commits, and handoff notes from both Codex and Claude Code. Find patterns that show how I prompt, how agents behave, where work goes well, where work breaks down, and how to improve my agentic workflow.

Scope:
- Codex transcripts/logs
- Claude Code transcripts/logs
- Repo instruction files: AGENTS.md, CLAUDE.md, README/docs if relevant
- Repeated task types, failures, retries, misunderstandings, missing context, bad plans, over/under-implementation
- Successful examples worth copying

Analyze:
1. Prompting patterns
   - What instructions I give clearly
   - What instructions are ambiguous
   - What context I often forget to include
   - Where I over-specify or under-specify
   - Where agents infer wrong scope

2. Agent workflow patterns
   - When agents should ask questions first
   - When agents should implement directly
   - When agents should verify more
   - When agents should stop and report
   - Where tool usage is weak or wasteful

3. Instruction-file quality
   - AGENTS.md / CLAUDE.md conflicts
   - Missing durable rules
   - Rules that are too vague
   - Rules that cause bad behavior
   - Suggested edits, ready to paste

4. Recurring failure modes
   - Bad assumptions
   - Stale memory/context
   - Incomplete verification
   - Too much planning
   - Too much unsolicited refactor
   - Ignored user constraints
   - Poor handoffs

5. Best practices from my own good sessions
   - Extract reusable prompt patterns
   - Extract reusable agent instructions
   - Extract good verification habits

Output format:
- Executive summary: top 5 changes I should make
- Evidence-backed findings with transcript/log references
- Concrete prompt rewrites: before/after examples
- Suggested AGENTS.md changes
- Suggested CLAUDE.md changes
- Recommended workflow for:
  - bug fix
  - UI polish
  - code review
  - planning-only task
  - implementation task
  - handoff near context limit
- Checklist I can paste into future prompts
- "Do not do this anymore" list
- Open questions where logs are insufficient

Rules:
- Cite specific examples from logs/transcripts.
- Separate confirmed patterns from guesses.
- Prefer actionable advice over generic AI tips.
- Do not summarize every transcript. Find cross-session patterns.
- Keep recommendations practical for a hands-on Windows developer using Codex and Claude Code.
- If private/secrets appear in logs, do not repeat them. Mention only that sensitive content exists and where.
```

## Gaps In V1 (found 2026-07-09)

- No log paths — agent won't know where Codex/Claude Code transcripts live on disk. Must locate/state first, not guess.
- No evidence threshold — "pattern" undefined; 1 occurrence ≠ pattern.
- No citation format — "cite examples" too vague to enforce.
- No scope bound — "all transcripts" could be unbounded (date range, repo list).
- No output length cap — risk of bloated report.
- Doesn't address that Codex and Claude Code logs use different schemas — needs handling before cross-comparing.

## Refined Prompt (v2)

```text
You are auditing my AI coding workflow across Codex and Claude Code, to find behavior patterns and fix them via better prompts/instruction files.

STEP 0 — Locate sources (do this before analyzing):
- Find Codex transcript/log storage location (ask me if unknown, don't guess a path).
- Find Claude Code transcript/log storage location.
- Find all AGENTS.md and CLAUDE.md files in [scope: which repos? — specify or say "all repos under X"].
- Report what you found and what's missing before proceeding. If a source is empty/inaccessible, say so — don't skip silently.

SCOPE:
- Time range: [last N weeks / all available — specify]
- Repos/projects: [name them, or "all"]
- Minimum evidence bar: a "pattern" requires ≥3 independent occurrences across sessions. 1-2 occurrences = "anecdote," report separately, don't promote to pattern.

CITATION FORMAT (required for every finding):
- Codex: session file name + line/turn number
- Claude Code: session id (or file path) + timestamp/turn number
- No finding without a citation. If you can't cite it, it's a guess — label it as one.

ANALYZE:
1. Prompting patterns — clear instructions vs ambiguous, forgotten context, over/under-specification, wrong-scope inference by agents.
2. Agent workflow patterns — when agents should've asked vs implemented directly, under-verification, weak/wasteful tool use.
3. Instruction-file quality — AGENTS.md/CLAUDE.md conflicts, missing rules, vague rules, rules causing bad behavior. Give ready-to-paste edits.
4. Recurring failure modes — bad assumptions, stale context, incomplete verification, overplanning, unsolicited refactors, ignored constraints, bad handoffs.
5. Best practices from good sessions — reusable prompt patterns, reusable agent instructions, good verification habits.

OUTPUT (cap: ~2500 words unless findings genuinely require more — say why if you exceed it):
- Executive summary: top 5 changes, ranked by impact, each with 1-line evidence pointer.
- Evidence-backed findings (confirmed pattern / anecdote / guess — label each).
- Prompt rewrites: before/after, tied to a cited example.
- Suggested AGENTS.md diff.
- Suggested CLAUDE.md diff.
- Recommended workflow per task type: bug fix, UI polish, code review, planning-only, implementation, handoff near context limit.
- Paste-ready checklist for future prompts.
- "Do not do this anymore" list.
- Open questions where logs are insufficient to conclude.

RULES:
- Every finding needs a citation (see format above) or is labeled a guess.
- Don't summarize transcripts one by one — cross-session patterns only.
- If secrets/credentials appear in logs, note their existence + location, never repeat contents.
- Practical for a Windows dev using Codex + Claude Code — no generic AI-hygiene tips.
```

Fill scope/time-range brackets before running. Biggest failure risk without Step 0: agent guesses log path, finds nothing, hallucinates patterns anyway.

## Short Prompt

```text
Audit my Codex and Claude Code transcripts/logs for recurring prompting and workflow patterns. Identify what causes good outcomes, failures, retries, wrong scope, stale context, poor verification, and bad handoffs. Give evidence-backed recommendations, ready-to-paste AGENTS.md/CLAUDE.md edits, before/after prompt examples, and checklists for future bug-fix, UI, review, planning, implementation, and handoff prompts. Separate confirmed evidence from guesses. Do not expose secrets.
```

## Suggested Inputs To Attach

- Codex transcript/log export path
- Claude Code transcript/log export path
- Relevant repo root
- Current `AGENTS.md`
- Current `CLAUDE.md`
- Any recent handoff notes
- A few examples of sessions that felt good
- A few examples of sessions that felt bad

## Good Follow-Up Ask

```text
Turn your findings into concrete edits for my AGENTS.md and CLAUDE.md. Keep rules short, durable, and enforceable. Explain each rule with one sentence of rationale and cite the log pattern that supports it.
```

## Related

- [[Codex Index]]
- [[Wargame Plans vs Codex Plan Mode]]
