---
description: Run a parallel multi-perspective review of the current branch (correctness, security, simplicity, clean-code)
arguments: Optional diff scope. Omit for branch-vs-main. Or pass "staged", a range like "main..HEAD", or a single commit-ish.
---

# Parallel Multi-Perspective Review

Run four review agents concurrently against the same diff, each with a different focus. The point is **breadth in one shot** — independent perspectives that don't anchor on each other — rather than serial re-runs of a generic reviewer.

Adapted for this Flutter / Dart / Riverpod / Firestore codebase. Dart-specific notes are folded into the per-agent prompts below.

## Your Task

**Argument provided:** `$ARGUMENTS`

### Step 1: Determine diff scope

| Argument                        | Action                                                   |
|---------------------------------|----------------------------------------------------------|
| *(empty)*                       | `git diff $(git merge-base HEAD main)..HEAD`             |
| `staged`                        | `git diff --staged`                                      |
| `main..HEAD`, `abc..def`, etc.  | `git diff <range>`                                       |
| Single commit-ish (e.g. `HEAD`) | `git show <commit-ish>`                                  |

Capture the diff once. If it's empty, stop and tell the user there's nothing to review.

If the diff is large (>1000 lines), warn the user and ask whether to proceed — subagent context windows are not infinite and a 5000-line diff produces shallow reviews. Offer to scope down (single commit, single directory, etc.).

**Exclude generated files from the captured diff** to keep signal-to-noise high. The build pipeline regenerates these on every change and reviewers should not flag them:
- `*.g.dart` (built_value, json_serializable, Riverpod codegen, Drift)
- `*.freezed.dart`
- `*.mocks.dart` (Mockito)
- `pubspec.lock`

If your `git diff` invocation picks them up, append pathspec excludes:
`':!**/*.g.dart' ':!**/*.freezed.dart' ':!**/*.mocks.dart' ':!pubspec.lock'`

### Step 2: Spawn four subagents in parallel

**All four `Agent` calls must go in a single message.** Sequential calls defeat the purpose.

Use `subagent_type: "general-purpose"` for each. Pass the captured diff inline in the prompt (don't ask the subagents to re-run git — they may not have the same working tree).

**Common framing for all four** (include in each prompt):
- The diff is the entire scope. Do not read unrelated files unless a finding requires confirming surrounding context.
- Report findings as a punch list with severity tags: `[CRITICAL]` (will break something or ship a real bug), `[IMPORTANT]` (real bug, risk, or smell worth fixing now), `[NIT]` (genuinely trivial — phrasing, single-character formatting).
- For each finding, give: file path + line number, one-sentence description, and a concrete suggested fix.
- **Default scope posture: assume every finding belongs in *this* PR.** Only suggest deferring to a follow-up PR if the fix is substantial (roughly: a separate concern requiring its own design decision, or >50 lines of unrelated change). For everything else, just report the issue — let the user decide what to defer.
- **Do not hedge.** Avoid phrases like "not blocking," "consider for a future PR," "minor concern but...", "if you have time," "optional improvement." State the issue and the fix directly. The user decides what's blocking; your job is to surface what's wrong.
- If no findings in your category, say so explicitly. Do not pad.
- Under 400 words total.

**Agent 1 — Correctness & edge cases:**
> Review the diff below for correctness bugs only. Look for: off-by-one errors, null/late-init failures, race conditions, error-handling gaps, broken invariants, incorrect API usage, async/await mistakes, type-coercion bugs.
>
> Dart/Flutter-specific things to watch for: BuildContext used across an `await` boundary, missing `mounted` checks before setState/Navigator after async work, missing `dispose()` for controllers / streams / focus nodes, StreamSubscription/Timer leaks, `Future.future` deadlocks on Riverpod providers (use `container.read()` + pumpAndSettle in tests), provider autoDispose vs keepAlive mismatches, Firestore listener leakage, built_value blueprints mutated after `.build()`, timezone slip-ups (UTC stored vs local rendered), recurrence math edge cases at DST boundaries.
>
> Ignore style, naming, architecture — those are other reviewers' jobs.
>
> Diff: `<paste diff>`

**Agent 2 — Security & data integrity:**
> Review the diff below for security and data-integrity issues only. Look for: secrets / API keys / tokens committed in source, missing `personDocId` scoping on Firestore reads or writes (queries must be scoped per-user), Firestore rules bypass via client-trusted fields, soft-delete bypass (`retired` / `retiredDate` ignored), unsanitized user input flowing into search/query terms, sensitive data in `debugPrint` / log output, insecure platform-channel calls, unsafe deserialization of remote JSON. Ignore style and design.
>
> Diff: `<paste diff>`

**Agent 3 — Simplicity & over-engineering:**
> Review the diff below for over-engineering only. Look for: premature abstractions (single-caller helpers, "manager" / "helper" classes with one method, unused config knobs), defensive code for impossible states, feature-flag scaffolding without a flag, dead code, comments that just restate the code, error handling for cases the language already guarantees, wrapping Riverpod providers in another provider for no reason, redundant null-aware operators where the type is already non-nullable, half-finished TODOs without a tracked ticket. The goal is deletion, not refactoring.
>
> Diff: `<paste diff>`

**Agent 4 — Clean Code smells:**
> Review the diff below for Clean Code smells only. Look for: widget `build()` methods >50 lines that should be broken into smaller widgets, methods >30 lines or doing multiple things, duplicated logic across 3+ blocks, generic names (`data`, `result`, `tmp`, `process`, `handle`, `manager`), boolean parameters in public APIs (prefer enums), nesting deeper than 2-3 levels, mixed levels of abstraction in one function, comments explaining *what* instead of *why*, double quotes where this project lints `prefer_single_quotes`, missing `const` constructors on widget literals. Do NOT propose new abstractions or DRY-for-its-own-sake; that's the Simplicity reviewer's anti-pattern.
>
> Diff: `<paste diff>`

### Step 3: Consolidate findings

When all four return, do NOT just concatenate. Synthesize:

1. **Dedupe** — if two reviewers flagged the same line for the same reason, merge into one entry and note which reviewers raised it.
2. **Group by severity** — all CRITICAL first, then IMPORTANT, then NIT. Within each group, order by file.
3. **Flag conflicts explicitly** — if Simplicity says "delete this abstraction" and Clean Code says "extract a helper here," surface the disagreement rather than picking a side. The user decides.
4. **Note category gaps** — if a reviewer returned "no findings," include a one-line note (e.g., "Security: no findings"). Silence is information.

### Step 4: Present and stop

Output the consolidated punch list. Do NOT start fixing anything — that's a separate decision.

When presenting, hold the same posture as the agents: assume findings are in-scope for this PR, do not soften with "consider later" or "non-blocking" framing, do not editorialize about priority beyond the severity tag. If a subagent's finding came back hedged, restate it directly when consolidating.

End with:

> Next steps: pick which findings to act on. To address them, reply with the items to fix. To run an adversarial follow-up pass (looking for what these reviewers missed), say so.

## Adversarial follow-up (when requested)

If the user asks for a second pass:
- Spawn one Agent (general-purpose) with the full diff AND the list of issues already raised.
- Brief: "Assume the previous reviewers found everything in this list. What did they miss? Look for subtle bugs, surprising interactions, missing test coverage, latent regressions. Be honest if there's nothing left."
- This is *much* higher signal density than re-running the four-agent pass blindly.

## Notes

- The agent count is not sacred. If you add a new lens (performance, accessibility, golden-test coverage, Firestore-rules audit, etc.), wire it in as a fifth parallel call.
- This command does NOT push, comment on a PR, or modify files. Pure read + report.
- For PRs already on GitHub, this is complementary to (not a replacement for) Copilot review — run this locally before pushing so Copilot's findings are more likely to be genuinely new.
