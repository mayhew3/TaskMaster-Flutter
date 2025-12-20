#!/bin/bash
# PreToolUse hook: Blocks test suite if in task mode without verification
# State file: .claude/state/task_state.json
# Usage: Activated when working on stories/bugs, cleared with /task-complete or /task-quick

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check Bash commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

# Only block test suite commands (Flutter-specific)
# Match: flutter test
if [[ ! "$COMMAND" =~ flutter[[:space:]]+test ]]; then
    exit 0
fi

# Check state file (relative to repo root)
STATE_FILE=".claude/state/task_state.json"
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0  # No task in progress
fi

# Check if file is empty or has empty object
CONTENT=$(cat "$STATE_FILE" 2>/dev/null)
if [[ -z "$CONTENT" || "$CONTENT" == "{}" ]]; then
    exit 0  # No active task
fi

VERIFIED=$(echo "$CONTENT" | jq -r '.verified // false')
ISSUE=$(echo "$CONTENT" | jq -r '.issue // "unknown"')

if [[ "$VERIFIED" == "true" ]]; then
    exit 0  # Task verified, allow tests
fi

# Block with helpful message
cat << EOF
{"decision": "block", "reason": "Test suite blocked: Task $ISSUE not yet verified by user.\n\nWorkflow:\n1. Implement the feature/fix\n2. Ask user to verify it works\n3. Run /task-complete to verify and run tests\n\nOr run /task-quick to skip tests for low-risk changes."}
EOF
exit 0
