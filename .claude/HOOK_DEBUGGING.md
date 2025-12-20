# Hook Debugging Progress

## Goal
Get the `task-test-gate` hook working to block `flutter test` when a task is in progress but not yet verified.

## Current State
- **State file**: `.claude/state/task_state.json` exists with `verified: false` for TM-315
- **Expected behavior**: Running `flutter test` should be blocked
- **Actual behavior**: Tests run without any blocking

## What We Know
1. The state file is correctly populated:
   ```json
   {
     "issue": "TM-315",
     "verified": false,
     "started_at": "2025-12-20T05:10:00Z",
     "project": "TM",
     "type": "Story",
     "summary": "Improve performance and UI state on task complete"
   }
   ```

2. Hook files exist:
   - `.claude/hooks/task-test-gate.sh` (bash version)
   - `.claude/hooks/task-test-gate.ps1` (PowerShell version)

## Attempts Made

### Attempt 1: Bash hooks (original configuration)
- **Configuration**: `bash "$CLAUDE_PROJECT_DIR"/.claude/hooks/task-test-gate.sh`
- **Result**: Tests ran without blocking
- **Hypothesis**: Bash on Windows may not receive stdin correctly from Claude Code

### Attempt 2: PowerShell hooks
- **Configuration**: `powershell -ExecutionPolicy Bypass -File .claude/hooks/task-test-gate.ps1`
- **Result**: Unknown - user says this was tried before and didn't work
- **Debug log**: `.claude/state/hook_debug.log` appears empty, suggesting hook may not be invoked at all

## Questions to Investigate

1. **Is the hook being invoked at all?**
   - Need to add logging at the very start of the hook to confirm execution

2. **Is stdin being passed correctly?**
   - The PowerShell hook has debug logging but log is empty
   - This suggests the hook might not even be starting

3. **Is the settings.json being read correctly?**
   - Need to verify Claude Code is picking up the hook configuration

4. **Is the matcher working?**
   - The matcher is "Bash" - does this match the `flutter test` command?

## Key Finding: Hooks Are Not Being Invoked At All

**Test performed**:
1. Added `debug-test.ps1` hook that logs to `.claude/state/debug_hook.log`
2. Ran Bash commands (`rm`, `cat`)
3. Checked log file - **NO LOG CREATED**

**Conclusion**: The PreToolUse hooks are not being invoked by Claude Code.

## Root Causes Found (from Claude Code docs)

### 1. **Relative Paths Don't Work**
Hooks run from an **arbitrary working directory**, so relative paths like `.claude/hooks/...` fail silently because the file isn't found.

**Fix**: Use `$CLAUDE_PROJECT_DIR` environment variable:
```json
"command": "powershell -ExecutionPolicy Bypass -File \"$CLAUDE_PROJECT_DIR\\.claude\\hooks\\debug-test.ps1\""
```

### 2. **Session Restart Required**
Claude Code captures a snapshot of hooks at startup. Changes to settings.json don't take effect until you:
1. Exit Claude Code completely
2. Restart the session
3. Or use `/hooks` menu to review and apply changes

### 3. **Hook Input Format**
Hooks receive JSON via stdin with this structure:
```json
{
  "session_id": "abc123",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "flutter test",
    "description": "..."
  }
}
```

To read in PowerShell:
```powershell
$input_json = [Console]::In.ReadToEnd() | ConvertFrom-Json
```

### 4. **Hook Output Format**
- **Exit 0**: Allow tool call
- **Exit 2**: Block tool call (stderr shown to Claude)
- **JSON output**: For advanced control:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "..."
  }
}
```

## Fixes Applied

### 1. settings.json - Fixed hook command paths
Changed from relative paths to `$CLAUDE_PROJECT_DIR`:
```json
"command": "powershell -ExecutionPolicy Bypass -File \"$CLAUDE_PROJECT_DIR\\.claude\\hooks\\task-test-gate.ps1\""
```

### 2. task-test-gate.ps1 - Fixed stdin reading and paths
- Changed `@($input)` to `[Console]::In.ReadToEnd()` for correct stdin reading
- Changed relative paths to use `$env:CLAUDE_PROJECT_DIR`
- Updated blocking output to use correct JSON format:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "..."
  }
}
```

### 3. debug-test.ps1 - Same stdin and path fixes

## Next Steps

1. [x] Fixed settings.json paths to use `$CLAUDE_PROJECT_DIR`
2. [x] Fixed PowerShell stdin reading (`[Console]::In.ReadToEnd()`)
3. [x] Fixed state file paths to use `$env:CLAUDE_PROJECT_DIR`
4. [x] Fixed blocking output JSON format
5. [x] User restarted Claude Code session
6. [ ] After restart, run `flutter test` to verify blocking works
7. [ ] Check `.claude/state/debug_hook.log` to verify hooks are being invoked

---

## Session 2: December 20, 2025 (continued debugging)

### Finding: `$env:CLAUDE_PROJECT_DIR` is null

**Test performed**:
```powershell
echo '{"tool_name":"Bash","tool_input":{"command":"test"}}' | powershell -ExecutionPolicy Bypass -File "C:\Code\TaskMaster\TaskMaster-Flutter\.claude\hooks\debug-test.ps1"
```

**Result**: Script failed with `Join-Path : Cannot bind argument to parameter 'Path' because it is null.`

**Root cause**: `$env:CLAUDE_PROJECT_DIR` is not set when running manually from bash, and the script had no fallback.

### Fix Applied: Fallback path derivation

Updated `debug-test.ps1` to derive project directory from script location:
```powershell
$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) {
    # Fallback: derive from script location
    $projectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName
}
```

Also added directory creation to ensure `.claude/state/` exists.

### Test Result: Manual invocation works

After the fix, manual invocation succeeded:
```
2025-12-20 13:40:22 - Hook invoked (projectDir=C:\Code\TaskMaster\TaskMaster-Flutter)
2025-12-20 13:40:22 - Stdin: {"tool_name":"Bash","tool_input":{"command":"test"}}
```

### Finding: Hooks still not invoked by Claude Code

After running Bash commands through Claude Code, the log file showed only the manual test entry - no entries from Claude Code invocations.

**Hypothesis**: The `$CLAUDE_PROJECT_DIR` variable in settings.json isn't being expanded correctly on Windows.

### Fix Applied: Absolute path in settings.json

Changed from:
```json
"command": "powershell -ExecutionPolicy Bypass -File \"$CLAUDE_PROJECT_DIR\\.claude\\hooks\\debug-test.ps1\""
```

To:
```json
"command": "powershell -ExecutionPolicy Bypass -File \"C:\\Code\\TaskMaster\\TaskMaster-Flutter\\.claude\\hooks\\debug-test.ps1\""
```

Also simplified to just the debug hook for testing.

### Current State

- **settings.json**: Uses absolute path for debug hook only
- **debug-test.ps1**: Has fallback for project directory derivation
- **Status**: Waiting for user to restart Claude Code session

### Next Steps (Session 2)

1. [x] Added fallback path derivation to debug-test.ps1
2. [x] Verified manual hook invocation works
3. [x] Changed settings.json to use absolute path (eliminates variable expansion issues)
4. [x] **USER ACTION REQUIRED**: Restart Claude Code session
5. [x] Run any Bash command to test if hook is invoked
6. [x] Check `.claude/state/debug_hook.log` for new entries

---

## Session 3: December 20, 2025 (hooks working!)

### Result: Hooks ARE Being Invoked

After restart with absolute paths in settings.json, hooks are working:
```
2025-12-20 14:08:01 - Hook invoked (projectDir=C:\Code\TaskMaster\TaskMaster-Flutter)
2025-12-20 14:08:01 - Stdin: {..., "tool_name":"Bash", "tool_input":{"command":"flutter test..."}}
```

### Root Cause Confirmed

The issue was **relative paths in settings.json**. Claude Code hooks run from an arbitrary directory, so:
- ❌ `.claude/hooks/script.ps1` - fails silently
- ✅ `C:\Code\TaskMaster\...\script.ps1` - works

### Changes Made

1. **task-test-gate.ps1** - Added fallback for `$env:CLAUDE_PROJECT_DIR`:
   ```powershell
   $projectDir = $env:CLAUDE_PROJECT_DIR
   if (-not $projectDir) {
       $projectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName
   }
   ```

2. **settings.json** - Switched from debug hook to task-test-gate:
   ```json
   "command": "powershell -ExecutionPolicy Bypass -File \"C:\\Code\\TaskMaster\\TaskMaster-Flutter\\.claude\\hooks\\task-test-gate.ps1\""
   ```

### Next Steps (Session 3)

1. [x] Confirmed hooks are invoked with absolute paths
2. [x] Updated task-test-gate.ps1 with path fallback
3. [x] Updated settings.json to use task-test-gate.ps1
4. [x] User restarted Claude Code session
5. [x] Ran `flutter test` - **BLOCKED SUCCESSFULLY!**
6. [x] Verified block message appears correctly

---

## ✅ RESOLVED: Session 4 - December 20, 2025

### Final Test: Hook Blocking Works!

After Claude Code restart, `flutter test` was blocked with the expected message:

```
Test suite blocked: Task TM-315 not yet verified by user.

Workflow:
1. Implement the feature/fix
2. Ask user to verify it works
3. Run /task-complete to verify and run tests

Or run /task-quick to skip tests for low-risk changes.
```

### Debug Log Confirms Full Flow

```
2025-12-20 14:10:03 - Received: '{"session_id":"...","tool_name":"Bash","tool_input":{"command":"flutter test",...}}'
2025-12-20 14:10:03 - Parsed: tool=Bash, command=flutter test
2025-12-20 14:10:03 - BLOCKING: Test suite blocked: Task TM-315 not yet verified by user...
```

### Summary of Root Causes & Fixes

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| Hooks not invoked | Relative paths in settings.json | Use absolute paths: `C:\Code\...` |
| `$env:CLAUDE_PROJECT_DIR` null | Not set by Claude Code (or not expanded) | Fallback to derive from `$PSScriptRoot` |
| Stdin not read | Using `@($input)` in PowerShell | Use `[Console]::In.ReadToEnd()` |
| Settings not applied | Claude captures hooks at startup | Restart Claude Code after changes |

### Key Learnings for Future Hooks

1. **Use absolute paths in settings.json** - `$CLAUDE_PROJECT_DIR` may not expand correctly on Windows
2. **Add fallback path derivation** - derive project root from `$PSScriptRoot` as backup
3. **Read stdin correctly** - use `[Console]::In.ReadToEnd()` not `$input`
4. **Restart Claude Code** - hooks are captured at session start
5. **Add debug logging** - essential for troubleshooting hook issues

## Debug Commands

```powershell
# Check if hook log exists
cat .claude/state/hook_debug.log

# Check state file
cat .claude/state/task_state.json

# Test hook manually with sample input
echo '{"tool_name":"Bash","tool_input":{"command":"flutter test"}}' | powershell -File .claude/hooks/task-test-gate.ps1
```
