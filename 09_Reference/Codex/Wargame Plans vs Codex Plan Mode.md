---
title: Wargame Plans vs Codex Plan Mode
created: 2026-07-08
type: reference
tags:
  - topic/codex
  - topic/ai-workflows
  - topic/red-team
---

# Wargame Plans vs Codex Plan Mode

## Short Version

A regular Codex Plan Mode plan answers:

> What should we do, in what order?

A wargame plan answers:

> If we try this plan, how can it fail, who or what pushes back, what surprises could appear, and how should we adapt?

Plan Mode creates an execution path. A wargame plan stress-tests that path against uncertainty, opposition, bad assumptions, weird data, production constraints, reviewers, users, and rollback needs.

## How They Differ

| Dimension | Regular Plan Mode | Wargame Plan |
|---|---|---|
| Main purpose | Build a clean path to the goal | Pressure-test the path before execution |
| AI posture | Planner and implementer | Planner, red team, and scenario controller |
| Main question | What steps should we take? | What breaks if we take these steps? |
| Shape | Ordered checklist | Scenario, moves, countermoves, injects, decision points |
| Risk handling | Identifies risks | Simulates risks becoming real |
| Actors | User, AI, codebase | User, AI, codebase, reviewers, customers, production, bad data, external systems |
| Success condition | Plan is executable | Plan survives pressure and has fallback paths |

## What Codex Plan Mode Does

Plan Mode is best when work is complex, ambiguous, or needs discussion before implementation.

In Plan Mode, Codex tends to:

- Gather context before acting.
- Ask clarifying questions.
- Break work into steps.
- Identify files, commands, tests, and dependencies.
- Avoid implementation until plan is approved or user asks to proceed.
- Optimize for a clean sequence from current state to desired result.

Example:

```text
1. Inspect current editor save path.
2. Update JSON persistence service.
3. Adjust UI binding.
4. Add focused tests.
5. Run build and regression checks.
```

That is useful, but mostly assumes the plan can proceed as designed.

## What A Wargame Plan Does

A wargame plan asks the AI to treat the plan as contested.

The AI should:

- Attack assumptions.
- Identify hidden dependencies.
- Simulate failures after each major move.
- Add surprises, called injects.
- Model opposition or resistance from systems, people, data, process, or environment.
- Define decision points where the team must choose.
- Define detection signals that show the plan is winning or failing.
- Add mitigations, fallback paths, and rollback criteria.

Example:

```text
Objective: migrate editor persistence safely.

Blue move: switch save path to canonical JSON.
Red response: legacy HTML consumers still expect old field.
Inject: one template has invalid historical JSON.
Decision point: block migration, repair data, or fallback render?
Detection: build passes but preview PDF differs.
Mitigation: add compatibility read path and fixture diff test.
Rollback: leave old read path active until parity checks pass.
```

## How The AI Reacts Differently

With a normal plan, Codex tries to organize work.

With a wargame plan, Codex should challenge the work.

Specific behavior changes:

- It should not only list tasks. It should test each task against failure.
- It should not assume happy-path data. It should invent bad-but-plausible data.
- It should not treat tests as final proof. It should ask what tests miss.
- It should not stop at "risk: deployment issue." It should describe the failure mode, signal, decision, mitigation, and owner.
- It should not optimize only for implementation speed. It should optimize for operational survivability.
- It should think in rounds: move, response, surprise, decision, adaptation.

## When To Use Each

Use regular Plan Mode when:

- You need task decomposition.
- Scope is fuzzy.
- You want implementation sequence before code changes.
- You need the AI to inspect a repo and propose next steps.

Use a wargame plan when:

- Work touches production, data, security, permissions, migration, billing, customer experience, or release timing.
- Failure would be expensive.
- Multiple teams or systems are involved.
- Requirements are uncertain.
- You already have a plan and want to know where it breaks.

## Team Prompt Template

```text
Create a wargame plan for this implementation.

Use:
- Objective
- Baseline plan
- Assumptions to attack
- Blue team moves
- Red team responses
- Injects/surprises
- Decision points
- Detection signals
- Mitigations
- Fallback/rollback
- Final go/no-go checklist

Be adversarial. Do not just restate implementation steps.
```

## Compact Team Explanation

A wargame plan is a red-team version of a plan. Plan Mode tells us how to proceed. A wargame plan asks what happens when the plan meets reality: bad data, reviewers, users, production limits, broken assumptions, hidden dependencies, and rollback pressure. It makes the AI behave less like a project manager and more like a scenario tester.

