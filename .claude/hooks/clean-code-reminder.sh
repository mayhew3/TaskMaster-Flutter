#!/usr/bin/env bash
# UserPromptSubmit hook: Injects Clean Code rule reminders when the prompt
# looks code-related. Mirrors clean-code-reminder.ps1 for non-Windows envs.
#
# Adapted for this Flutter/Dart codebase — keyword list and reminder text
# include Dart-specific idioms (widget, provider, dispose, etc.).

set -u

command -v jq >/dev/null 2>&1 || exit 0

input="$(cat)"
[ -z "$input" ] && exit 0

prompt="$(printf '%s' "$input" | jq -r '.prompt // ""' 2>/dev/null)"
[ -z "$prompt" ] && exit 0

if ! printf '%s' "$prompt" | grep -qwiE '(write|add|implement|refactor|fix|create|build|change|update|modify|extract|rename|method|function|class|component|service|endpoint|test|bug|feature|api|module|migration|schema|query|deploy|hook|util|interface|widget|provider|notifier|riverpod|dispose|stream|drift|firestore|blueprint|mixin|extension|reducer|middleware)'; then
    exit 0
fi

reminder='**Clean Code rules apply to any code written this turn:**
1. Prefer small, single-purpose methods. Extract once a function exceeds ~30 lines or does multiple unrelated things. Widget `build()` methods that grow past ~50 lines should split into smaller widgets.
2. Use descriptive names. Avoid `data`, `result`, `tmp`, `process()`, `handle()`, `manager`, `helper` unless genuinely the best fit.
3. Eliminate duplication once you see 3+ near-identical blocks — but not before.
4. Avoid boolean parameters in public APIs — prefer enums or separate methods.
5. Keep nesting shallow (max 2-3 levels). Extract helpers or invert conditions.
6. Match levels of abstraction within a function — don'\''t mix high-level orchestration with low-level details.
7. Comments explain non-obvious *why*. Never restate *what*.
8. Dart specifics: prefer single quotes (project lints `prefer_single_quotes`), use `const` constructors on widget literals where possible, always `dispose()` controllers / streams / focus nodes, and guard `BuildContext` use across `await` with a `mounted` check.'

jq -nc --arg ctx "$reminder" '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
exit 0
