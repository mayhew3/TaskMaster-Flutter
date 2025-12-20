# PreToolUse hook: Validate git commit messages have JIRA ticket prefix
#
# Expected format: TM-###: Commit message
# Examples: TM-281: Fix bug, TM-313: Add feature

try {
    # Read JSON from stdin - use pipeline input for PowerShell compatibility
    $stdinContent = @($input) -join "`n"

    if ([string]::IsNullOrWhiteSpace($stdinContent)) {
        exit 0
    }

    $json = $stdinContent | ConvertFrom-Json
    $command = $json.tool_input.command

    # If we couldn't parse the command, allow it
    if ([string]::IsNullOrWhiteSpace($command)) {
        exit 0
    }
} catch {
    # If we can't parse input, allow the operation
    exit 0
}

# Only validate git commit commands
if ($command -notmatch "^git\s+commit") {
    exit 0
}

# Extract commit message from -m flag
# Handles: git commit -m "message", git commit -m 'message'
$commitMsg = ""

if ($command -match '-m\s+"([^"]+)"') {
    $commitMsg = $matches[1]
} elseif ($command -match "-m\s+'([^']+)'") {
    $commitMsg = $matches[1]
} elseif ($command -match '-m\s+"\$\(cat\s+<<') {
    # HEREDOC style - try to get first line of message
    if ($command -match 'EOF[''"]?\)"\s*\r?\n\s*([^\r\n]+)') {
        $commitMsg = $matches[1]
    } elseif ($command -match "Commit message here") {
        # Template - extract actual message
        $lines = $command -split "`n"
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -and $trimmed -notmatch "^(git|EOF|\$\(|cat|<<)" -and $trimmed -ne ")\"") {
                $commitMsg = $trimmed
                break
            }
        }
    }
} elseif ($command -match '-m\s+([^\s"'']+)') {
    $commitMsg = $matches[1]
}

# If no message found (maybe --amend without -m), allow it
if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    exit 0
}

# JIRA ticket pattern: TM-### format (TaskMaster project)
$jiraPattern = "^[A-Z]{2,3}-[0-9]+:"

if ($commitMsg -match $jiraPattern) {
    # Valid format - allow the commit
    Write-Output "Commit message has valid JIRA prefix"
    exit 0
}

# Invalid format - try to help by extracting ticket from branch name
$currentBranch = ""
try {
    $currentBranch = git branch --show-current 2>$null
} catch {}

$suggestedPrefix = ""
if ($currentBranch -match "([A-Z]{2,3}-[0-9]+)") {
    $suggestedPrefix = $matches[1]
}

# Block the commit with helpful error message
if ($suggestedPrefix) {
    Write-Error "BLOCKED: Commit message missing JIRA ticket prefix.`n`nCurrent message: $commitMsg`nRequired format: TM-###: Commit message`n`nDetected ticket from branch '$currentBranch': $suggestedPrefix`nSuggested message: ${suggestedPrefix}: $commitMsg"
} else {
    Write-Error "BLOCKED: Commit message missing JIRA ticket prefix.`n`nCurrent message: $commitMsg`nRequired format: TM-###: Commit message`nExamples: TM-281: Fix bug, TM-313: Add feature`n`nCould not detect ticket from branch name. Please add the JIRA ticket manually."
}

exit 2
