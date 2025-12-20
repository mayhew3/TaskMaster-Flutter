---
description: Start working on a Jira story or bug with full automation
arguments: issue-key (optional - auto-detects from branch or queries sprint if omitted)
---

# Start Task

Begin work on a Jira story or bug with full Jira automation and plan mode.

## Your Task

**Argument provided:** `$ARGUMENTS`

### Step 1: Resolve the issue

**Parse the argument to determine the issue:**

| Input Pattern | Example | Action |
|---------------|---------|--------|
| Issue key (has hyphen + number) | `TM-123` | Use directly |
| Project key only | `TM` | Query sprint for top-ranked issue |
| Empty/none | | Auto-detect from branch, or query TM sprint |
| `?` or `help` | | Show usage and exit |

**If querying sprint** (no issue key provided):

**MCP (Primary):**
```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC",
  maxResults: 5
})
```

**acli (Fallback):**
```bash
acli jira workitem search --jql "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC" --limit 5
```

Present the top result and ask for confirmation:
> "Found: **TM-123: Add new feature** (Story)
> Start work on this task? [Y/n]"

Wait for user confirmation before proceeding.

### Step 2: Fetch issue details

**MCP (Primary):**
```
mcp__atlassian__getJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}"
})
```

**acli (Fallback):**
```bash
acli jira workitem view {ISSUE_KEY}
```

Note the issue type (Story, Bug, Task) and summary for later use.

### Step 3: Transition to "In Progress"

Check current status. If not already "In Progress":

**MCP (Primary):**
```
mcp__atlassian__getTransitionsForJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}"
})

mcp__atlassian__transitionJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  transition: { id: "{transition_id_for_in_progress}" }
})
```

**acli (Fallback):**
```bash
acli jira workitem transition --key {ISSUE_KEY} --status "In Progress"
```

### Step 4: Create or verify branch

Check current branch. If not already on a branch for this issue:

**Branch naming convention:** `{ISSUE_KEY}-short-description`

Examples:
- `TM-313-task-workflows`
- `TM-281-riverpod-refactor`

```bash
# Check current branch
git branch --show-current

# Create new branch if needed
git checkout -b {ISSUE_KEY}-{short-description}
```

### Step 5: Create state file

Write the task state to `.claude/state/task_state.json`:

```json
{
  "issue": "TM-123",
  "verified": false,
  "started_at": "2025-12-19T10:30:00Z",
  "project": "TM",
  "type": "Story",
  "summary": "Short description from Jira"
}
```

Use bash to write this file:
```bash
echo '{"issue": "{ISSUE_KEY}", "verified": false, "started_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "project": "TM", "type": "{TYPE}", "summary": "{SUMMARY}"}' > .claude/state/task_state.json
```

### Step 6: Add "Starting Work" comment to Jira

**MCP (Primary) - USE THIS:**
```
mcp__atlassian__addCommentToJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  commentBody: `### Starting Work

**Branch:** \`{ISSUE_KEY}-description\`

**Approach:**
Will analyze the codebase and create an implementation plan.

**Next steps:**
1. Review requirements
2. Explore relevant code
3. Create implementation plan`
})
```

### Step 7: Enter Plan Mode

After completing all setup steps, use the **EnterPlanMode** tool to begin planning the implementation.

This will:
1. Allow exploration of the codebase
2. Create a detailed implementation plan
3. Get user approval before making changes

---

## Output Format

```
## Task Started: {ISSUE_KEY}

**Issue:** {ISSUE_KEY}: {Summary}
**Type:** {Story/Bug/Task}
**Branch:** {branch-name}
**Status:** Transitioned to In Progress

State file created. Test suite is now blocked until verification.

Entering plan mode to design the implementation...
```

Then call the EnterPlanMode tool.

---

## Notes

- The test suite is now blocked until you run `/task-complete` or `/task-quick`
- Use `/task-complete` after implementation for full verification workflow
- Use `/task-quick` for low-risk changes (docs, config) that can rely on CI
