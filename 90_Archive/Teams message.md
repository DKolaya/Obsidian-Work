---
title: Teams message (archived paste)
created: 2026-07-09
type: import
tags:
  - imported/teams
---
 Here is the audit prompt that I used. Please make sure to fill in the [ text ] it'll probably ask you a question and handle it if you don't though. I recommend using a time range of last 4 weeks to best show your current prompting skills.

```
​You are auditing my AI coding workflow across Codex and Claude Code, to find behavior patterns and fix them via better prompts/instruction files.STEP 0 — Locate sources (do this before analyzing):- Find Codex transcript/log storage location (ask me if unknown, don't guess a path).- Find Claude Code transcript/log storage location.- Find all AGENTS.md and CLAUDE.md files in [scope: which repos? — specify or say "all repos under X"].- Report what you found and what's missing before proceeding. If a source is empty/inaccessible, say so — don't skip silently.SCOPE:- Time range: [last N weeks / all available — specify]- Repos/projects: [name them, or "all"]- Minimum evidence bar: a "pattern" requires ≥3 independent occurrences across sessions. 1-2 occurrences = "anecdote," report separately, don't promote to pattern.CITATION FORMAT (required for every finding):- Codex: session file name + line/turn number- Claude Code: session id (or file path) + timestamp/turn number- No finding without a citation. If you can't cite it, it's a guess — label it as one.ANALYZE:1. Prompting patterns — clear instructions vs ambiguous, forgotten context, over/under-specification, wrong-scope inference by agents.2. Agent workflow patterns — when agents should've asked vs implemented directly, under-verification, weak/wasteful tool use.3. Instruction-file quality — AGENTS.md/CLAUDE.md conflicts, missing rules, vague rules, rules causing bad behavior. Give ready-to-paste edits.4. Recurring failure modes — bad assumptions, stale context, incomplete verification, overplanning, unsolicited refactors, ignored constraints, bad handoffs.5. Best practices from good sessions — reusable prompt patterns, reusable agent instructions, good verification habits.OUTPUT (cap: ~2500 words unless findings genuinely require more — say why if you exceed it):- Executive summary: top 5 changes, ranked by impact, each with 1-line evidence pointer.- Evidence-backed findings (confirmed pattern / anecdote / guess — label each).- Prompt rewrites: before/after, tied to a cited example.- Suggested AGENTS.md diff.- Suggested CLAUDE.md diff.- Recommended workflow per task type: bug fix, UI polish, code review, planning-only, implementation, handoff near context limit.- Paste-ready checklist for future prompts.- "Do not do this anymore" list.- Open questions where logs are insufficient to conclude.RULES:- Every finding needs a citation (see format above) or is labeled a guess.- Don't summarize transcripts one by one — cross-session patterns only.- If secrets/credentials appear in logs, note their existence + location, never repeat contents.- Practical for a Windows dev using Codex + Claude Code — no generic AI-hygiene tips.
```

Here are some inputs that could help attach but fable will be able to find most of these without problem.

Finally maybe ask it to turn findings into concrete edits for your general/global AGENTS/CLAUDE.md or share them with the group so we can all learn from them. Here is the follow up prompt I used. 

```
Turn your findings into concrete edits for my AGENTS.md and CLAUDE.md. Keep rules short, durable, and enforceable. Explain each rule with one sentence of rationale and cite the log pattern that supports it.
```