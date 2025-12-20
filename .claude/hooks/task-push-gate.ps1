# PreToolUse hook: Blocks git push if in task mode without verification
# State file: .claude/state/task_state.json
# Usage: Activated when working on stories/bugs, cleared with /task-complete or /task-quick

try {
    # Read JSON from stdin - use pipeline input for PowerShell compatibility
    $stdinContent = @($input) -join "`n"

    if ([string]::IsNullOrWhiteSpace($stdinContent)) {
        exit 0
    }

    $json = $stdinContent | ConvertFrom-Json
    $toolName = $json.tool_name
    $command = $json.tool_input.command
} catch {
    # If we can't parse input, allow the operation
    exit 0
}

# Only check Bash commands
if ($toolName -ne "Bash") {
    exit 0
}

# Only block git push commands
if ($command -notmatch "^git\s+push") {
    exit 0
}

# Check state file
$stateFile = ".claude/state/task_state.json"
if (-not (Test-Path $stateFile)) {
    exit 0  # No task in progress, allow push
}

$content = Get-Content $stateFile -Raw -ErrorAction SilentlyContinue
if ([string]::IsNullOrWhiteSpace($content) -or $content -eq "{}") {
    exit 0  # No active task, allow push
}

try {
    $state = $content | ConvertFrom-Json
    $verified = $state.verified
    $issue = $state.issue

    if ($verified -eq $true) {
        exit 0  # Task verified, allow push
    }

    # Block with helpful message
    $reason = "Push blocked: Task $issue not yet verified by user.`n`nWorkflow:`n1. Implement the feature/fix`n2. Transition to 'Under Review'`n3. User verifies the work`n4. Run /task-complete to mark verified and push`n`nOr run /task-quick to skip verification for low-risk changes."
    @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress
} catch {
    exit 0  # JSON parse error, allow
}
