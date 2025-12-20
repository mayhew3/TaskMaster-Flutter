# Claude Code Hooks, Skills & Commands Guide

**Created:** December 19, 2025
**Location:** `.claude/` directory

This guide documents the custom automation added to improve Claude Code workflow consistency.

---

## Quick Start

### Activation

All hooks, skills, and commands activate on **session restart**. After pulling these changes:

1. Exit your current Claude Code session
2. Start a new session
3. Hooks will be active for the new session

---

## Hooks

Hooks run automatically in response to specific events.

### 1. Commit Message Validation (PreToolUse)

**File:** `.claude/hooks/validate-commit-message.sh`

**What it does:**
- Intercepts `git commit` commands before execution
- Validates commit message has JIRA ticket prefix (e.g., `TM-123:`)
- Blocks commits without valid prefix
- Suggests the ticket from branch name when possible

**Example:**
```
✅ git commit -m "TM-123: Add new feature"     → Allowed
✅ git commit -m "TM-281: Fix bug"             → Allowed
❌ git commit -m "Fix the bug"                 → Blocked with suggestion
```

**When blocked, you'll see:**
```
BLOCKED: Commit message missing JIRA ticket prefix.
Current message: Fix the bug
Required format: TM-###: Commit message
Detected ticket from branch 'TM-123-feature': TM-123
Suggested message: TM-123: Fix the bug
```

---

### 2. Task Test Gate (PreToolUse)

**File:** `.claude/hooks/task-test-gate.sh`

**What it does:**
- Blocks `flutter test` commands when in "task mode" (after `/task-start`)
- Requires user verification before tests can run
- Prevents wasting time on tests if implementation approach is wrong

**Blocked commands:**
- `flutter test`

**When blocked, you'll see:**
```
Test suite blocked: Task TM-123 not yet verified by user.

Workflow:
1. Implement the feature/fix
2. Ask user to verify it works
3. Run /task-complete to verify and run tests

Or run /task-quick to skip tests for low-risk changes.
```

**State file:** `.claude/state/task_state.json`

---

## Slash Commands

Slash commands are invoked by typing `/command-name` in Claude Code.

### 1. `/task-start` - Start Working on a Task

**File:** `.claude/commands/task-start.md`

**Usage:**
```
/task-start TM-123        # Start specific issue
/task-start TM            # Query sprint, pick top task
/task-start               # Auto-detect from branch or query sprint
/task-start ?             # Show usage
```

**What it does:**
1. Resolves the issue (directly or via sprint query)
2. Transitions to "In Progress"
3. Creates branch if needed
4. Creates state file (enables test blocking)
5. Adds "Starting Work" comment to Jira
6. Enters plan mode for implementation design

---

### 2. `/task-complete` - Complete Task with Full Verification

**File:** `.claude/commands/task-complete.md`

**Usage:**
```
/task-complete            # Complete current task
```

**What it does:**
1. Prompts user to verify implementation works
2. Runs `dart analyze`
3. Runs `flutter test`
4. Fixes any failures
5. Adds summary comment to Jira
6. Transitions to "Under Review"
7. Prompts for push permission
8. Creates PR
9. Cleans up state file

**When to use:**
- New features
- Bug fixes
- Refactoring
- Any change affecting logic

---

### 3. `/task-quick` - Quick Finish (Skip Tests)

**File:** `.claude/commands/task-quick.md`

**Usage:**
```
/task-quick               # Quick finish current task
```

**What it does:**
1. Confirms this is a low-risk change
2. Commits changes
3. Adds brief comment to Jira
4. Transitions to "Under Review"
5. Prompts for push permission
6. Creates PR
7. Cleans up state file

**When to use:**
- Documentation updates
- Config changes
- Typo fixes
- Small, isolated changes

**Not for:**
- New features
- Bug fixes affecting logic
- Refactoring

---

### 4. `/sprint-tasks` - Query Active Sprint

**File:** `.claude/commands/sprint-tasks.md`

**Usage:**
```
/sprint-tasks             # Query TM sprint
/sprint-tasks ?           # Show usage
```

**What it does:**
- Queries Jira for active sprint stories
- Shows three categories:
  - **Ready to Start** (To Do / Backlog)
  - **In Progress**
  - **Under Review**
- Suggests highest-priority unstarted task
- Offers to start work on selected ticket

---

## Task Workflow Overview

The task commands work together as a workflow:

```
/task-start TM-123
    │
    ├─→ Jira: "In Progress"
    ├─→ Branch created
    ├─→ State file created (tests blocked)
    └─→ Plan mode activated

    ... implement feature/fix ...

/task-complete  OR  /task-quick
    │                   │
    ├─→ User verifies   ├─→ User confirms low-risk
    ├─→ dart analyze    └─→ Commit
    ├─→ flutter test        ├─→ Jira comment
    ├─→ Fix failures        ├─→ "Under Review"
    ├─→ Jira comment        ├─→ Push + PR
    ├─→ "Under Review"      └─→ State cleared
    ├─→ Push + PR
    └─→ State cleared
```

---

## Skills

Skills provide guidance for complex workflows. Claude activates them automatically when relevant topics are discussed.

### Jira Workflow Skill

**Directory:** `.claude/skills/jira-workflow/`

**Files:**
- `SKILL.md` - Main definition and quick reference
- `jira-formatting.md` - Markdown formatting reference
- `jql-templates.md` - Common JQL queries for TM project

**Triggers automatically when you mention:**
- Jira, ticket, story, epic, sprint, backlog
- Starting or completing work
- Creating branches or PRs

**Key Rules Enforced:**

| Action | Allowed? |
|--------|----------|
| Transition to "In Progress" | ✅ Yes |
| Transition to "Under Review" | ✅ Yes |
| Transition to "Done" | ❌ No (user only) |
| Add comments | ✅ Yes |
| Create Epic/Story | ✅ Yes |
| Push to remote | ⚠️ Only after verification |

**Tool Priority:**
- **Primary:** MCP Atlassian tool (better formatting)
- **Fallback:** acli CLI (when MCP auth expires)

---

## Configuration

### Settings File

**Location:** `.claude/settings.json`

The hooks are configured in the `hooks` section:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/validate-commit-message.sh" },
          { "type": "command", "command": ".claude/hooks/task-test-gate.sh" }
        ]
      }
    ]
  }
}
```

### Disabling Hooks

To temporarily disable a hook, remove or comment out its entry in `settings.json`.

---

## File Structure

```
.claude/
├── settings.json                    # Hook configuration
├── settings.local.json              # Local overrides (not committed)
├── HOOKS-AND-COMMANDS-GUIDE.md      # This file
├── hooks/
│   ├── validate-commit-message.sh   # Commit validation hook
│   └── task-test-gate.sh            # Task workflow test blocking
├── commands/
│   ├── task-start.md                # /task-start command
│   ├── task-complete.md             # /task-complete command
│   ├── task-quick.md                # /task-quick command
│   └── sprint-tasks.md              # /sprint-tasks command
├── state/
│   └── task_state.json              # Current task state
└── skills/
    └── jira-workflow/
        ├── SKILL.md                 # Main skill definition
        ├── jira-formatting.md       # Markdown formatting guide
        └── jql-templates.md         # JQL query templates
```

---

## Troubleshooting

### Hooks not activating?
- Restart Claude Code session (hooks are captured at startup)
- Check `.claude/settings.json` has the hooks configured
- Verify hook scripts are executable (`chmod +x`)

### Commit validation too strict?
- Branch must contain JIRA ticket pattern (e.g., `TM-123-feature`)
- Or manually include ticket in commit message

### Jira commands failing?
- Check if MCP Atlassian is authenticated
- Run `/mcp` to re-authenticate if needed
- Use acli as fallback for basic operations

### Task workflow issues?
- **Tests blocked unexpectedly:** Check `.claude/state/task_state.json` - remove it or set `verified: true`
- **State file persisting:** Delete `.claude/state/task_state.json` to clear task mode
- **Hook not blocking tests:** Restart Claude Code session to reload hooks

---

## Related Documentation

- `CLAUDE.md` (root) - Main project instructions
- `.claude/skills/jira-workflow/SKILL.md` - Jira workflow details
- `.claude/MIGRATION_PROGRESS.md` - Redux to Riverpod migration status
