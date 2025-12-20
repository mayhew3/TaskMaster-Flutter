---
description: Quick finish task (skip tests) for low-risk changes
arguments: none (uses state file)
---

# Quick Finish Task

Finish the current task quickly without running the full test suite. Use for low-risk changes only.

## When to Use

**Appropriate for:**
- Documentation updates
- Config changes
- Typo fixes
- Small, isolated changes

**NOT for:**
- New features
- Bug fixes affecting logic
- Refactoring
- Any code that affects behavior

## Your Task

### Step 1: Verify state file exists

Read the state file:
```bash
cat .claude/state/task_state.json
```

If the file doesn't exist or is empty, inform the user:
> "No active task found. Use `/task-start <issue>` to begin working on a task."

Extract the issue key and summary from the state file.

### Step 2: Confirm this is a low-risk change

Ask the user to confirm this is appropriate for quick finish:

> "Quick finish skips the test suite. This should only be used for low-risk changes.
>
> **Task:** {ISSUE_KEY}: {Summary}
>
> Is this a low-risk change (docs, config, typo fixes)? [Y/n]"

**WAIT for user confirmation before proceeding.**

If the user says no, suggest using `/task-complete` instead.

### Step 3: Commit any uncommitted changes

```bash
git status
```

If there are uncommitted changes:
```bash
git add .
git commit -m "{ISSUE_KEY}: [Summary of changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 4: Add brief comment to Jira

**MCP (Primary) - USE THIS:**
```
mcp__atlassian__addCommentToJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  commentBody: `### Quick Complete

**Changes:**
- [Brief summary of changes]

*Low-risk change - tests will run in CI.*`
})
```

### Step 5: Transition to "Under Review"

**MCP (Primary):**
```
mcp__atlassian__transitionJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  transition: { id: "61" }
})
```

**acli (Fallback):**
```bash
acli jira workitem transition --key {ISSUE_KEY} --status "Under Review"
```

> **Note:** Transition ID 61 = "Under Review" (stable for TM project)

### Step 6: Request push permission

> "Changes committed. Ready to push and create PR.
>
> May I push to the remote branch and create a PR?"

**WAIT for user approval before pushing.**

### Step 7: Push and create PR

After user approves:
```bash
# Push to remote
git push -u origin {branch-name}

# Create PR
gh pr create --title "{ISSUE_KEY}: {Summary}" --body "## Summary
- [Brief description of changes]

*Low-risk change - tests will run in CI.*

**JIRA:** https://mayhew3.atlassian.net/browse/{ISSUE_KEY}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### Step 8: Clean up state file

Reset the state file:
```bash
echo '{}' > .claude/state/task_state.json
```

---

## Output Format

```
## Task Complete (Quick): {ISSUE_KEY}

**Summary:** {Summary}
**Status:** Under Review
**PR:** {PR_URL}

Tests will run in CI. Please review and mark the Jira ticket as Done when merged.
```

---

## Notes

- Quick finish is for low-risk changes only
- Tests will run in CI, not locally
- If CI fails, you'll need to fix and push again
- Use `/task-complete` for any code changes that affect behavior
