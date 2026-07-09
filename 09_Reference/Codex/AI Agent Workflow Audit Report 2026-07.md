---
title: AI Agent Workflow Audit Report 2026-07
created: 2026-07-09
type: report
tags:
  - codex
  - claude-code
  - ai-workflows
  - audit
---

# AI Agent Workflow Audit — Codex + Claude Code

**Scope:** Jun 9 – Jul 9, 2026, all projects. Produced by the audit prompt in [[AI Agent Workflow Audit Prompt]] (v2). Feeds [[04_Projects/Active/AI Initiative|AI Initiative]] W5 (Codex vs Claude Code research).

**Corpus:** Codex — 111 in-range sessions under `~/.codex/sessions/2026/{06,07}/` (76 human, 26 subagent, 9 daily-automation "1+1=" heartbeats excluded from prompt stats). Claude Code — 40 sessions under `~/.claude/projects/` (35 CDH_EL, 3 Obsidian vault, 1 LESCO_sync, 1 TRANCY). Instruction files: `CDH_EL\AGENTS.md` + `CLAUDE.md` (bare `@AGENTS.md` include), `HAVITMCP\Havit.Blazor-main\AGENTS.md` + `.claude\CLAUDE.md`, global `~/.claude/CLAUDE.md`, global `~/.codex/AGENTS.md`, `~/.codex/config.toml`. Nothing missing or inaccessible. Evidence bar: pattern = ≥3 independent sessions; 1–2 = anecdote; uncited = guess (labeled).

**Citations:** Codex = rollout filename (prefix) : JSONL line. Claude Code = session id (filename) : JSONL line.

---

## Executive summary — top 5 changes, ranked by impact

1. **Kill "build passed = done."** Biggest failure mode (~15 incidents, both tools), and partly instruction-caused: CDH_EL `AGENTS.md` L141 demands UI checks while L143 forbids browser testing. Evidence: footer clipped after "done" (`rollout-2026-06-22T15-59-08:196`); `fitPageToViewport is not a function` at runtime (`rollout-2026-06-24T11-47-06:243`).
2. **Give agents real build/test commands + a verification-handoff protocol.** No audited file contains a working build command; HAVIT's is literally the character `s` (`Havit.Blazor-main\AGENTS.md:71`). Fix = commands in AGENTS.md + explicit "VERIFICATION GAP" handoff when the agent can't render.
3. **Fix the HAVIT MCP rule — ignored by Claude Code (14 of 16 UI sessions skipped) yet over-broad (fires on any `.razor` globally).** Codex, with a one-line rule, complied more (`rollout-2026-06-30T09-48-20:~166`). Narrow the trigger to Hx-component edits.
4. **Stop self-inflicted environment collisions.** Agent-held port 7145 (`rollout-2026-06-22T09-24-14:656`), stale JS bundles twice (`rollout-2026-06-25T09-31-38:343`), recurring DLL-lock build churn (`774a91a6:268`, `ca7d79c8:83`, `f10ec7a5:155`). Add env-hygiene rules.
5. **Add durable cross-session handoffs — Codex memories are silently disabled.** `config.toml` sets `memories = true` but `no_memories_if_mcp_or_web_search = true` with two MCP servers always on → memories never activate. Meanwhile the pagination task restarted across ≥4 sessions and TipTap schema errors recurred in 3.

---

## Confirmed patterns (≥3 independent sessions)

### P1 — "Done" claimed without runtime/visual verification
~15 occurrences, both tools, all repos. Compile/tests pass → agent claims fixed → user finds it broken in the browser or PDF.
- `rollout-2026-06-22T15-47-04:191` — endpoint shipped, runtime `BadHttpRequestException` on `bool download`
- `rollout-2026-06-22T15-59-08:196` — agent's own admission: "tests proved PDF text exists, not that footer visually fits"
- `rollout-2026-06-24T11-47-06:243` / `rollout-2026-06-25T09-31-38:330,343` — "Implemented"; user: JS error / "nothing changed"
- `rollout-2026-06-30T13-56-07:164,199,222` — 3-attempt CSS height loop, each "verified" by `dotnet build`
- `rollout-2026-07-01T10-45-40:7` — grid fix shipped on tests only, no live repro
- `4e03b856:244` — "the pdf still looks like this"; `7e73c4db:148` — DLL-locked build called "compiles clean"; `9d4b0010:233` — bundle-grep as "verification"
- `rollout-2026-06-12T09-18-47:495,526,685` — three consecutive failed "fixed" claims on the same leak

**Root cause is dual:** the L141/L143 instruction contradiction, and genuine inability to render — with no protocol for saying so.

### P2 — HAVIT MCP rule skipped before Hx/UI edits (Claude Code)
Skipped in ~14 of 16 `.razor`-editing Claude Code sessions; complied in 2. Skips: `f10ec7a5`, `5f7af19a`, `39e7d1dd`, `1f09b9b7:27`, `37e65179:72`, `41566fca`, `42a3cd30`, `6909f68c`, `7341693b`, `774a91a6`, `7e73c4db`, `90d91107`, `a3ddc387` (+1). Compliant: `15765a88:506` (found `HxMessageBoxHost` DI answer), `e67980ef:56` (right component API first try). **Cross-tool nuance:** Codex consulted the HAVIT MCP consistently in late-June UI sessions (`rollout-2026-06-30T09-48-20:~166-200` — discovered HxToast is internal → HxMessenger) despite having the weaker one-line rule. The verbose mandatory global rule is being ignored; the habit, not the wording, drives compliance.

### P3 — Self-inflicted environment collisions
- Port 7145 left held by agent's background `dotnet run`; user's own launch then failed (`rollout-2026-06-22T09-24-14:656`); port held again in `bd7d8c49:263`
- Stale JS bundle → "nothing changed" twice in two days (`rollout-2026-06-24T11-47-06:259`; `rollout-2026-06-25T09-31-38:343`) — lesson not carried forward
- Recurring MSB3027 DLL-lock build failures worked around per-session (`774a91a6:268`, `ca7d79c8:83`, `f10ec7a5:155`)
- `MapStaticAssets` MIME block after bundle rebuild (`rollout-2026-06-22T09-24-14:522`); process/port fight loop (`rollout-2026-06-25T15-18-47:337,368,388`); junction/pnpm churn (`rollout-2026-07-06T12-28-02:75`, `rollout-2026-06-29T12-10-44:~178`)
- Agent-convenience dev auto-login later blocked the user's own manual auth testing (`rollout-2026-06-25T14-00-55:7`)

### P4 — Silent stalls / dead turns needing a user nudge
≥5 sessions. Agent pauses or a turn no-ops with no progress signal; user has to poke it.
- "are you stuck?" then "stuck?" in one session — blocking foreground `dotnet run` looked like a hang (`rollout-2026-06-22T09-24-14:202,602`)
- Plan-submission turn completed in ~1s with null message; user re-issued "implement plan" 3.2 h later (`rollout-2026-06-22T11-28-33:169`)
- Agent paused on missing docs; resumed only on "continue" 3.6 h later (`rollout-2026-06-16T10-49-55:61`)
- "are you stuck?" mid-debug (`rollout-2026-06-25T15-18-47:524`); request sat 1.5 h until "now do it" (`rollout-2026-06-30T11-39-09:311,319`)

### P5 — Vague/thin openers force scope-guessing
~20% of human sessions opened with <15 words; misfires recur: "dump" meant *delete*, read as *print* (`39e7d1dd:143,155`); "Implement" with no referent (`rollout-2026-06-29T14-34-49:7`); "df" garbage send (`rollout-2026-06-30T11-18-50:84`); "T" (`9d4b0010:238`); URL-only opener the agent couldn't access (`rollout-2026-06-30T11-39-09:7`); mid-sentence truncated sends (`rollout-2026-06-29T09-41-49:7`, `rollout-2026-07-06T09-34-25:397`); "organize the view section a bit better" → invented design, rejected (`rollout-2026-06-24T13-42-26:7,140`); "not quite there yet... not good enough" with no fidelity spec (`rollout-2026-06-22T15-59-08:7`); paste-with-no-instruction (`29057f1a:9`).

### P6 — Decisive constraint/context supplied only after the agent went wrong
- Editor-vs-PDF distinction after a full-diff hunt found nothing (`39e7d1dd:378`)
- "btw the pr is merging into the UAT branch" mid-draft (`4d5dc35a:27`)
- "JSON IS SOURCE OF TRUTH no html contnet" as ALL-CAPS correction after work started per the pasted plan (`rollout-2026-06-26T09-27-52:84`)
- "I already had this part I am working on the Admin UAT part now" (`rollout-2026-07-06T15-40-20:68`); answer-format requirement after the question set was drafted (`:112`)
- Positioning spec delivered only after first fix landed wrong (`rollout-2026-06-25T09-31-38:224`); template-page-not-editor-page scope correction (`rollout-2026-06-29T09-41-49:188`)

### P7 — Same task restarts across sessions; no durable handoff
- Editor pagination restarted across ≥4 Codex sessions (Jun 9, 11, 12, 15) then continued in Claude Code (`a3ddc387`, `9d4b0010`, `90d91107` continuation chains)
- TipTap schema `unsupported_attr` recurred in 3 separate sessions (`9d4b0010:9`, `aa426b8a:9`, `90d91107`)
- Suggestion-box positioning corrected ≥3× across 2 sessions (`rollout-2026-06-24T14-01-00:336` → `rollout-2026-06-25T09-31-38:35,224,343`)
- Browser/PDF parity bug resurfaced post-"fix" as list-gap drift (`rollout-2026-07-09T08-48-13:774`)
- The one forced handoff doc (usage limit) worked: `docs/reference/docx-import-disconnect-handoff.md` (`rollout-2026-06-25T15-18-47:~700`)
- Aggravator: Codex memories silently disabled (`config.toml:101-107` interaction)

### P8 — Guessing APIs/state from training data instead of grounding
- Intacct `InvoiceUpdate` property names guessed → build fail; recovered via throwaway reflection probes (`92a197ed:261,268-332`)
- "AddHxServices covers IHxMessageBoxService" stated as fact → runtime DI crash (`15765a88:501`)
- `updatedDate` assumed timestamp when it's a state flag — **same misconception in both tools on TRANCY**: Codex (`rollout-2026-06-15T13-40-16:637,679` → broke Home dashboard `:740`) and Claude Code (`3ea817bd:9`, abandoned)
- Custom HxAlert overlay built before checking the library for a toast (`rollout-2026-06-30T09-48-20:165,191`)
- Stale-page-count hypothesis corrected by user (`rollout-2026-07-09T08-48-13:138`)

### P9 (GOOD) — Highest-yield patterns worth keeping
- **Verbatim error paste → one-shot root cause:** AR validation (`rollout-2026-06-16T08-45-32:7`), rebase CS0136 (`rollout-2026-06-16T13-48-14:7`), Auth0 `/el` vs `/EL` casing prod bug from one review prompt (`rollout-2026-07-07T08-59-19:7`), `.eml` + screenshot pixel-read to exact schema error (`rollout-2026-07-08T15-32-32:7`)
- **Plan pipeline:** brainstorm → "make an actual plan" → paste "PLEASE IMPLEMENT THIS PLAN" — first-try successes across ≥10 sessions (e.g. `rollout-2026-06-23T10-17-48:7` six-word prompt worked because the plan file pre-existed; `rollout-2026-07-01T10-34-27:7` "Do phase A1 of ... UAT-PREP-PLAN.md")
- **Read-only constraints honored reliably:** "I don't want you to make any changes" (`rollout-2026-06-16T13-48-14:97`), "don't edit repo" (`rollout-2026-07-01T09-01-05:88`), "don't edit any code yet" (`4e03b856:151`)
- **Cross-AI review:** Claude reviewing Codex output found real gaps + wrote remediation plans (`360bba5f:9`, `39e7d1dd:177,249`, `rollout-2026-06-30T15-13-00:33,211`)
- **Objective proxies when rendering is impossible:** PDF→PNG probe via Poppler (`rollout-2026-06-22T15-59-08:~200`), reflection probe apps (`92a197ed:268`), failing ZLibStream test before the one-line fix (`39e7d1dd:382-400`)
- **`/code-review high`** ran 8 finder angles and dropped 3 refuted candidates (`7341693b:214`)
- **Asking beats guessing:** `request_user_input` on PDF-vs-HTML ambiguity (`rollout-2026-06-11T08-53-30:83`); AskUserQuestion to lock plan scope (`04498b05:94`); invited-questions prompt got one grounded question, clean run (`rollout-2026-07-01T10-58-20:7`)
- **Parallel advisory session** answering a design question, pasted back to validate the implementation plan (`rollout-2026-06-22T09-30-09:7` → `rollout-2026-06-22T09-24-14:113`)

## Anecdotes (1–2 occurrences — not promoted)

- Plan-mode handoff made real repo edits when only a planning doc was wanted; user stashed (`rollout-2026-07-06T09-34-25:374,415`) — 1×, high-annoyance; watch for recurrence
- Stale JS test assertion deleted to go green instead of treated as spec signal (`rollout-2026-06-30T15-13-00:~1220`) — 1×, borderline (prop intentionally removed)
- Agent hand-drew a fake "rendered" SVG when `mmdc` was missing instead of asking (`rollout-2026-06-29T12-10-44:154,178`) — 1×
- Cleanup pass regressed UAT default-permissions (`Empty()` for unknown users), caught days later in testing (`rollout-2026-06-30T15-13-00:1470`); unsolicited cleanup beyond plan scope (`rollout-2026-06-23T10-17-48`) — 2× loosely related
- Plan implemented but an entire second remediation doc missed (`rollout-2026-06-29T14-34-49:393`) — 1×
- Wrong-scope UI change: shared component edited without mode branch, altering edit mode when only view mode was asked (`rollout-2026-06-30T11-39-09:284`) — 1×

**Guess (labeled):** *why* the HAVIT rule is skipped — too broad to feel actionable vs. simply forgotten — is not visible in logs; logs show the skip only.

## Secrets in transcripts (existence + location only; values not reproduced)

- Plaintext DB connection-string passwords echoed from `appsettings` into Codex transcripts: `rollout-2026-06-16T13-48-14:~72`, `rollout-2026-06-22T09-24-14:~542`, `rollout-2026-06-22T11-28-33:~508`
- GemBox license key in Claude Code transcript `15765a88:~670`; SQL `sa` password `608435c6:~164` (source: `CDH_EL\appsettings.Development.json`)
- Internal SQL host `192.168.17.202\WEBSQL` in `92a197ed` (infra detail, not a credential)
- **Mitigation observed:** Claude Code's classifier blocked commands embedding the password / license key on the command line (`608435c6:167`, `15765a88:686`). The leak vector is Read/grep of full appsettings files — not command construction.

---

## Prompt rewrites (before → after)

**1. Vague UI tweak** (`rollout-2026-06-24T13-42-26:7` — "organize the view section a bit better" + screenshot → invention, rejected):
> In `[file]`, restructure the View toolbar section to match the existing Insert/Format sections (same grouping, spacing, no boxed panels). Screenshot shows current state. Don't touch other sections. Describe the rendered result before calling it done.

**2. One-word implement** (`rollout-2026-06-29T14-34-49:7` — "Implement"; a whole second plan doc was missed `:393`):
> Implement `docs/plans/<plan>.md` AND `docs/plans/editor-style-tokens-remediation-plan.md` in full — 5 fixes in the second; list each as done. Build + test. Implementation, not planning.

**3. Bug report missing the decisive axis** (`39e7d1dd:378` — editor-vs-PDF only clarified after a fruitless full-diff hunt):
> The furniture shows in the **editor** but not the **PDF preview**. Start in the GemBox render path, not the editor component.

**4. Planning that became code edits** (`rollout-2026-07-06T09-34-25:374`):
> Planning only — do NOT edit code or repo files. Output a plan doc to `docs/plans/`. Nate is mid-implementation on the FPA data link; don't propose work that touches it.

---

## Suggested AGENTS.md diff — `C:\Users\dkolaya\source\repos\CDH_EL\AGENTS.md`

Claude Code inherits everything via its `@AGENTS.md` include — one edit fixes both agents.

```diff
+ ## Build / Test / Run (authoritative — do not guess)
+ - Build:  dotnet build CDH_EL.sln -warnaserror
+ - Test:   dotnet test Lib.Tests/Lib.Tests.csproj
+ - Run:    dotnet run --project <Web project> --launch-profile https
+ - Routes serve under AppBasePath="/EL"; verify links against that base (case-sensitive).
+ - Build fails on a file lock (MSB3027) = the app is already running. Stop it or rebuild
+   only the changed project; NEVER report a lock-blocked build as "compiles clean".

- For UI changes, verify desktop + mobile widths; check no text overlap, clipped controls...
- Do not include browser testing in routine plans or verification unless explicitly requested.
+ ## Verifying visual / UI / PDF changes (replaces the two contradictory rules above)
+ - You usually cannot render the app. Never claim a visual, layout, or PDF change is
+   "done"/"fixed" from a successful build or unit tests alone.
+ - If you cannot observe the rendered result, end the turn with:
+   "VERIFICATION GAP: build/tests pass but I could not visually confirm <X>.
+    Please check <specific thing> in the running app." Then stop.
+ - Prefer an objective proxy when possible (render PDF→PNG and inspect, DOM/bundle check
+   in a live session) over asserting success blind.

+ ## Environment hygiene
+ - Never leave a background `dotnet run` holding a port; stop any server you start before
+   ending the turn. Dev port is 7145. Never run a blocking foreground server in a turn.
+ - After changing JS/TS/bundled assets: rebuild the bundle AND bump the cache-bust token.
+   A stale bundle is why "nothing changed" — twice.

+ ## Grounding
+ - Do not guess .NET API members, DI registrations, or DB column semantics from memory —
+   read source / NuGet XML docs / appsettings keys first (never echo whole appsettings files;
+   they contain credentials).
+ - `updatedDate` is a STATE FLAG, not an activity timestamp. Do not write it to move dashboards.

+ ## Cross-session handoff
+ - If a bug survives the session or context is near its limit, write
+   docs/handoffs/<task>.md: symptom, evidence, fixes tried, hypotheses, exact next step.

+ ## Scope
+ - Do not modify CDH_FPA/, artifacts/, node_modules/, .claude/worktrees/ — generated or separate app.

+ ## Doc rule (relaxed)
+ - The dual-file <name>.md + <name>.original.md convention is OPTIONAL, only for docs
+   needing long prose rationale. Plans/handoffs are single-file.

- Current Sprint 1 demo state ... docs/sprints/sprint-1/...
+ Current sprint state: latest folder under docs/sprints/ wins — do not hardcode a sprint number here.
```

Also soften L68–73 (full XML docs on private helpers → only where intent isn't obvious from the signature).

## Suggested CLAUDE.md diff — global `C:\Users\dkolaya\.claude\CLAUDE.md`

```diff
  ## HAVIT Blazor MCP — UI/Frontend Rule
- **Always** use the `Havit.Blazor.Mcp` MCP server before writing or modifying any Blazor UI code.
- Triggers: any task involving `.razor` files, ... or UI/UX changes in this project.
+ Query `Havit.Blazor.Mcp` before adding or modifying HAVIT component markup
+ (`Hx*`, `BootstrapIcon.*`, `ThemeColor`, `IconBase`) — REQUIRED for those edits.
+ It was skipped in 14 of 16 UI sessions in Jun–Jul 2026; the 2 compliant sessions found
+ the correct API first try (HxMessenger, HxMessageBoxHost). Do NOT trigger for
+ plain-HTML `.razor` edits or in non-HAVIT repos (MudBlazor projects use mudblazor-mcp).

+ ## MudBlazor MCP
+ In MudBlazor projects use the `mudblazor-mcp` skill for component APIs (mirrors the
+ Codex global). NEVER use MudBlazor MCP in CDH_EL — that repo bans it.

+ ## Verification before "done"
+ Never claim a visual/UI/PDF change works from a build or unit tests alone. If you cannot
+ observe the rendered result, say "VERIFICATION GAP: <what I couldn't check>" and hand it back.

  ## Caveman Mode
  Default mode: **ultra**. ...
+ Exception — deliverables: audit reports, plans, PR/commit text, review write-ups, and
+ anything pasted elsewhere are written in normal prose; compression drops nuance there.
```

## Adjacent config fixes (not CLAUDE.md/AGENTS.md, same priority)

1. `~/.codex/config.toml:101-107` — `memories = true` is nullified by `no_memories_if_mcp_or_web_search = true` while two MCP servers are always enabled (`:111`, `:116`). Set it `false` to actually get cross-session memory (directly attacks P7).
2. `~/.codex/AGENTS.md:3` — says `havit-blazor-mcp`; the server is `havit_blazor_mcp` (`config.toml:113`). Fix the name.
3. `Havit.Blazor-main\AGENTS.md:71` — build command is the literal character `s`. Replace with a real `dotnet build ... -warnaserror` line; also fix `:65` icon-json path (actual: `Havit.Blazor.Components.Web.Bootstrap\Icons\bootstrap-icons.json`) and `:46` (no `.github/` exists).
4. `config.toml:113-116` — HAVIT MCP runs a **published exe**; source edits don't reach it until republish. Document the republish step wherever the MCP is mandated.
5. `config.toml:109-111` — `mudblazor_mcp` hard-pinned `--version 9.0.0`; goes stale silently on upgrades.

---

## Recommended workflow per task type

- **Bug fix:** paste the verbatim error/stack + one-line repro + the decisive axis (editor vs PDF vs view mode; which page). Let the agent reproduce or read the failing path before fixing — every one-shot root-cause in the corpus started from a paste.
- **UI polish:** name the reference ("match the Insert section"), the file, and what NOT to touch; require a rendered description/screenshot or an explicit VERIFICATION GAP. Expect to do the final eyeball yourself.
- **Code review:** Claude Code `/code-review high` (refutes its own false positives), or cross-AI review (Claude over Codex output) — both proven here.
- **Planning-only:** say "planning only, do NOT edit code"; output to `docs/plans/`. Plan mode has made real edits once.
- **Implementation:** point at a reviewed plan file, "implement in full, confirm every item, build + test." Enumerate ALL plan docs if more than one.
- **Handoff near context limit:** don't wait for the wall — order `docs/handoffs/<task>.md` (symptom, evidence, tried, hypotheses, next step). Fix Codex memories so some of this is automatic.

## Paste-ready prompt checklist

```
[ ] Exact target: file/component/route named (not "the editor")
[ ] Bug? verbatim error text + repro + decisive axis (editor vs PDF, edit vs view, which page)
[ ] Scope fence: what to change AND what to leave alone
[ ] Constraints UP FRONT: branch, "no code edits", "no docx export", source-of-truth, teammate's in-flight work
[ ] Verification bar: "build + test" for logic; "rendered result or VERIFICATION GAP" for UI/PDF
[ ] Plan vs implement: say which; name every plan file if implementing
[ ] No secrets pasted; reference the file/key name and let the agent read the single key
```

## Do not do this anymore

- Accept "done" on a visual/PDF change from a green build — ask "did you see it render?"
- Leave the CDH_EL L141/L143 browser-verify contradiction in place
- Send one-word / URL-only / mid-sentence openers ("Implement", "dump", "df", "T", bare links) — each cost a turn or a wrong guess
- Let plan mode touch code when you wanted a plan — say "planning only"
- Let agents grep/cat whole `appsettings*.json` into transcripts — passwords and the GemBox key are already in logs
- Rely on Codex memory (it's off) — require handoff docs for multi-session bugs
- Let agents act on guessed API members / column semantics — require a source read first (the `updatedDate` guess broke Home and burned sessions in BOTH tools)

## Open questions (logs insufficient)

1. Why the HAVIT rule is skipped (too broad vs forgotten) — logs show the skip, not the reason. Ship the narrowed rule, re-measure compliance in a month.
2. Does the published `Havit.Blazor.Documentation.Mcp.exe` serve stale docs after HAVIT source changes? No republish step appears in any session.
3. Is plan-mode-edits-code a mode bug or prompt issue? One clean instance only.
4. Does the `.claude\CLAUDE.md` `@AGENTS.md` include in HAVITMCP resolve from the subdirectory (no root CLAUDE.md there)? Needs a live check.
5. Automation "1+1=" heartbeat sessions burn turns hunting a memory file before answering (`rollout-2026-06-23T08-40-48:9,15` + 2 more) — worth checking what that automation is for.

---

*Method: 9 parallel analysis agents over batched transcripts (5 Codex date batches, 3 Claude Code batches, 1 instruction-file audit); cross-session synthesis on the main thread. Raw incident payloads cited above; no per-session summaries retained.*
