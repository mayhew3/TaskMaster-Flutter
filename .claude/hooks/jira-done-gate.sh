#!/bin/bash
# PreToolUse hook: Blocks transitioning Jira issues to "Done" unless task is verified
# State file: .claude/state/task_state.json
# Catches both MCP tool (mcp__atlassian__transitionJiraIssue) and acli CLI commands

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

# Done transition ID for TM project
DONE_TRANSITION_ID="41"

# Check state file helper function
check_verified() {
    local STATE_FILE=".claude/state/task_state.json"

    if [[ ! -f "$STATE_FILE" ]]; then
        return 0  # No task in progress, allow
    fi

    local CONTENT=$(cat "$STATE_FILE" 2>/dev/null)
    if [[ -z "$CONTENT" || "$CONTENT" == "{}" ]]; then
        return 0  # No active task, allow
    fi

    local VERIFIED=$(echo "$CONTENT" | jq -r '.verified // false')
    local ISSUE=$(echo "$CONTENT" | jq -r '.issue // "unknown"')

    if [[ "$VERIFIED" == "true" ]]; then
        return 0  # Task verified, allow
    fi

    # Not verified - output the issue key for the error message
    echo "$ISSUE"
    return 1
}

# Check MCP Atlassian transition tool
if [[ "$TOOL_NAME" == "mcp__atlassian__transitionJiraIssue" ]]; then
    TRANSITION_ID=$(echo "$INPUT" | jq -r '.tool_input.transition.id // empty')

    if [[ "$TRANSITION_ID" == "$DONE_TRANSITION_ID" ]]; then
        ISSUE=$(check_verified)
        if [[ $? -ne 0 ]]; then
            cat << EOF
{"decision": "block", "reason": "Transition to Done blocked: Task $ISSUE not yet verified by user.\n\nOnly the user should mark tasks as Done after reviewing the work.\n\nWorkflow:\n1. Claude transitions to 'Under Review' when work is complete\n2. User verifies the implementation works\n3. User marks the Jira ticket as Done\n\nIf you need to transition, use /task-complete first to mark as verified."}
EOF
            exit 0
        fi
    fi
    exit 0
fi

# Check Bash commands for acli
if [[ "$TOOL_NAME" == "Bash" ]]; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

    # Check for acli transition to Done
    # Patterns: acli jira workitem transition --status "Done"
    #           acli jira workitem transition --status Done
    #           acli jira issue transition ... Done
    if [[ "$COMMAND" =~ acli.*jira.*(transition|move).*[Dd]one ]] || \
       [[ "$COMMAND" =~ acli.*--status[[:space:]]*[\"\']*[Dd]one ]]; then
        ISSUE=$(check_verified)
        if [[ $? -ne 0 ]]; then
            cat << EOF
{"decision": "block", "reason": "Transition to Done blocked: Task $ISSUE not yet verified by user.\n\nOnly the user should mark tasks as Done after reviewing the work.\n\nWorkflow:\n1. Claude transitions to 'Under Review' when work is complete\n2. User verifies the implementation works\n3. User marks the Jira ticket as Done\n\nIf you need to transition, use /task-complete first to mark as verified."}
EOF
            exit 0
        fi
    fi
fi

exit 0
