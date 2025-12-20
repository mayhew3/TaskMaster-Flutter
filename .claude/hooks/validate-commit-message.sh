#!/bin/bash
#
# PreToolUse hook: Validate git commit messages have JIRA ticket prefix
#
# Expected format: TM-###: Commit message
# Examples: TM-281: Fix bug, TM-313: Add feature
#
# This hook receives JSON input via stdin with the tool call details.
# Exit codes:
#   0 - Allow the commit (validation passed or not a commit command)
#   2 - Block the commit (validation failed, stderr shown to Claude)

set -e

# Read JSON input from stdin
INPUT=$(cat)

# Extract the command from the tool input
# The input structure is: { "tool_input": { "command": "..." } }
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# If we couldn't parse the command, allow it (not our concern)
if [ -z "$COMMAND" ]; then
    exit 0
fi

# Only validate git commit commands
if [[ ! "$COMMAND" =~ ^git[[:space:]]+commit ]]; then
    exit 0
fi

# Extract commit message from -m flag
# Handles: git commit -m "message", git commit -m 'message', git commit -m message
# Also handles HEREDOC style: git commit -m "$(cat <<'EOF'..."
COMMIT_MSG=""

# Try to extract message from -m flag with various quote styles
if [[ "$COMMAND" =~ -m[[:space:]]+\"([^\"]+)\" ]]; then
    COMMIT_MSG="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ -m[[:space:]]+\'([^\']+)\' ]]; then
    COMMIT_MSG="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ -m[[:space:]]+\"\$\(cat[[:space:]]+\<\<[\'\"]?EOF[\'\"]?$'\n'([^$'\n']+) ]]; then
    # HEREDOC style - get first line after EOF
    COMMIT_MSG="${BASH_REMATCH[1]}"
elif [[ "$COMMAND" =~ -m[[:space:]]+([^[:space:]\"\'][^[:space:]]*) ]]; then
    COMMIT_MSG="${BASH_REMATCH[1]}"
fi

# If no message found (maybe --amend without -m), allow it
if [ -z "$COMMIT_MSG" ]; then
    exit 0
fi

# JIRA ticket pattern: TM-### format (TaskMaster project)
# Also allow 2-3 uppercase letters for flexibility
JIRA_PATTERN='^[A-Z]{2,3}-[0-9]+:'

if [[ "$COMMIT_MSG" =~ $JIRA_PATTERN ]]; then
    # Valid format - allow the commit
    echo "Commit message has valid JIRA prefix"
    exit 0
fi

# Invalid format - try to help by extracting ticket from branch name
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
SUGGESTED_PREFIX=""

if [ -n "$CURRENT_BRANCH" ]; then
    # Branch patterns for TaskMaster:
    # - TM-281-riverpod-refactor
    # - TM-313-description
    if [[ "$CURRENT_BRANCH" =~ ([A-Z]{2,3}-[0-9]+) ]]; then
        SUGGESTED_PREFIX="${BASH_REMATCH[1]}"
    fi
fi

# Block the commit with helpful error message
if [ -n "$SUGGESTED_PREFIX" ]; then
    echo "BLOCKED: Commit message missing JIRA ticket prefix." >&2
    echo "" >&2
    echo "Current message: $COMMIT_MSG" >&2
    echo "Required format: TM-###: Commit message" >&2
    echo "" >&2
    echo "Detected ticket from branch '$CURRENT_BRANCH': $SUGGESTED_PREFIX" >&2
    echo "Suggested message: $SUGGESTED_PREFIX: $COMMIT_MSG" >&2
else
    echo "BLOCKED: Commit message missing JIRA ticket prefix." >&2
    echo "" >&2
    echo "Current message: $COMMIT_MSG" >&2
    echo "Required format: TM-###: Commit message" >&2
    echo "Examples: TM-281: Fix bug, TM-313: Add feature" >&2
    echo "" >&2
    echo "Could not detect ticket from branch name. Please add the JIRA ticket manually." >&2
fi

exit 2
