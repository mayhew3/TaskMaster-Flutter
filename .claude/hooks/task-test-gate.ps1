# PreToolUse hook: Blocks test suite if in task mode without verification
# State file: .claude/state/task_state.json
# Usage: Activated when working on stories/bugs, cleared with /task-complete or /task-quick

$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) {
    # Fallback: derive from script location (.claude/hooks -> project root)
    $projectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName
}

# Ensure state directory exists
$stateDir = Join-Path $projectDir ".claude\state"
if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

$debugLog = Join-Path $projectDir ".claude\state\hook_debug.log"

try {
    # Read JSON from stdin using Console.In (correct method for piped input)
    $stdinContent = [Console]::In.ReadToEnd()

    # Debug: log what we received
    Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Received: '$stdinContent'"

    if ([string]::IsNullOrWhiteSpace($stdinContent)) {
        Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Empty input, exiting"
        exit 0
    }

    $json = $stdinContent | ConvertFrom-Json
    $toolName = $json.tool_name
    $command = $json.tool_input.command

    Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Parsed: tool=$toolName, command=$command"
} catch {
    Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: $_"
    exit 0
}

# Only check Bash commands
if ($toolName -ne "Bash") {
    exit 0
}

# Only block FULL test suite (flutter test with no specific file)
if ($command -notmatch "^flutter\s+test") {
    exit 0
}

# Extract everything after "flutter test"
$afterTest = $command -replace "^flutter\s+test\s*", ""

# Allow if there's a path argument (contains .dart or test/)
if ($afterTest -match "\.dart" -or $afterTest -match "test/") {
    exit 0
}

# Check state file (use absolute path via CLAUDE_PROJECT_DIR)
$stateFile = Join-Path $projectDir ".claude\state\task_state.json"
if (-not (Test-Path $stateFile)) {
    exit 0  # No task in progress
}

$content = Get-Content $stateFile -Raw -ErrorAction SilentlyContinue
if ([string]::IsNullOrWhiteSpace($content) -or $content -eq "{}") {
    exit 0  # No active task
}

try {
    $state = $content | ConvertFrom-Json
    $verified = $state.verified
    $issue = $state.issue

    if ($verified -eq $true) {
        exit 0  # Task verified, allow tests
    }

    # Block with helpful message using correct Claude Code hook output format
    $reason = "Test suite blocked: Task $issue not yet verified by user.`n`nWorkflow:`n1. Implement the feature/fix`n2. Ask user to verify it works`n3. Run /task-complete to verify and run tests`n`nOr run /task-quick to skip tests for low-risk changes."

    Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - BLOCKING: $reason"

    $output = @{
        hookSpecificOutput = @{
            hookEventName = "PreToolUse"
            permissionDecision = "deny"
            permissionDecisionReason = $reason
        }
    }
    $output | ConvertTo-Json -Depth 3 -Compress
} catch {
    Add-Content -Path $debugLog -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Catch error: $_"
    exit 0  # JSON parse error, allow
}
