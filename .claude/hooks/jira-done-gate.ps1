# PreToolUse hook: Blocks transitioning Jira issues to "Done" unless task is verified
# State file: .claude/state/task_state.json
# Catches both MCP tool (mcp__atlassian__transitionJiraIssue) and acli CLI commands

$input = $input | Out-String
$json = $input | ConvertFrom-Json

$toolName = $json.tool_name

# Done transition ID for TM project
$doneTransitionId = "41"

function Test-TaskVerified {
    $stateFile = ".claude/state/task_state.json"

    if (-not (Test-Path $stateFile)) {
        return @{ verified = $true; issue = $null }  # No task in progress, allow
    }

    $content = Get-Content $stateFile -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($content) -or $content -eq "{}") {
        return @{ verified = $true; issue = $null }  # No active task, allow
    }

    try {
        $state = $content | ConvertFrom-Json
        return @{
            verified = ($state.verified -eq $true)
            issue = $state.issue
        }
    } catch {
        return @{ verified = $true; issue = $null }  # JSON parse error, allow
    }
}

# Check MCP Atlassian transition tool
if ($toolName -eq "mcp__atlassian__transitionJiraIssue") {
    $transitionId = $json.tool_input.transition.id

    if ($transitionId -eq $doneTransitionId) {
        $result = Test-TaskVerified
        if (-not $result.verified) {
            $reason = "Transition to Done blocked: Task $($result.issue) not yet verified by user.`n`nOnly the user should mark tasks as Done after reviewing the work.`n`nWorkflow:`n1. Claude transitions to 'Under Review' when work is complete`n2. User verifies the implementation works`n3. User marks the Jira ticket as Done`n`nIf you need to transition, use /task-complete first to mark as verified."
            @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress
            exit 0
        }
    }
    exit 0
}

# Check Bash commands for acli
if ($toolName -eq "Bash") {
    $command = $json.tool_input.command

    # Check for acli transition to Done
    if ($command -match "acli.*jira.*(transition|move).*[Dd]one" -or
        $command -match "acli.*--status\s*[`"']*[Dd]one") {
        $result = Test-TaskVerified
        if (-not $result.verified) {
            $reason = "Transition to Done blocked: Task $($result.issue) not yet verified by user.`n`nOnly the user should mark tasks as Done after reviewing the work.`n`nWorkflow:`n1. Claude transitions to 'Under Review' when work is complete`n2. User verifies the implementation works`n3. User marks the Jira ticket as Done`n`nIf you need to transition, use /task-complete first to mark as verified."
            @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress
            exit 0
        }
    }
}

exit 0
