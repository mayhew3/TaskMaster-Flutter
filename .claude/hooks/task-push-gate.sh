#!/bin/bash
# PreToolUse hook: Blocks git push if in task mode without verification
# State file: .claude/state/task_state.json
# Usage: Activated when working on stories/bugs, cleared with /task-complete or /task-quick

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check Bash commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

# Only block git push commands
if [[ ! "$COMMAND" =~ ^git[[:space:]]+push ]]; then
    exit 0
fi

# Check state file (relative to repo root)
STATE_FILE=".claude/state/task_state.json"
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0  # No task in progress, allow push
fi

# Check if file is empty or has empty object
CONTENT=$(cat "$STATE_FILE" 2>/dev/null)
if [[ -z "$CONTENT" || "$CONTENT" == "{}" ]]; then
    exit 0  # No active task, allow push
fi

VERIFIED=$(echo "$CONTENT" | jq -r '.verified // false')
ISSUE=$(echo "$CONTENT" | jq -r '.issue // "unknown"')

if [[ "$VERIFIED" == "true" ]]; then
    exit 0  # Task verified, allow push
fi

# Block with helpful message
cat << EOF
{"decision": "block", "reason": "Push blocked: Task $ISSUE not yet verified by user.\n\nWorkflow:\n1. Implement the feature/fix\n2. Transition to 'Under Review'\n3. User verifies the work\n4. Run /task-complete to mark verified and push\n\nOr run /task-quick to skip verification for low-risk changes."}
EOF
exit 0
