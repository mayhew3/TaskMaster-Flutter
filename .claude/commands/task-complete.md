---
description: Complete task workflow with full verification, tests, and PR
arguments: none (uses state file)
---

# Complete Task

Finish the current task with full verification, test suite, and PR creation.

## Your Task

### Step 1: Verify state file exists

Read the state file:
```bash
cat .claude/state/task_state.json
```

If the file doesn't exist or is empty, inform the user:
> "No active task found. Use `/task-start <issue>` to begin working on a task."

Extract the issue key, project, and summary from the state file.

### Step 2: Prompt for user verification

Ask the user to verify the implementation works:

> "Before running the full test suite, please verify the feature/fix works as expected.
>
> **Task:** {ISSUE_KEY}: {Summary}
>
> Can you confirm the implementation is working correctly?"

**WAIT for user confirmation before proceeding.** Do not continue until the user explicitly confirms.

### Step 3: Update state file

After user confirms, update the state file to mark as verified:
```bash
# Read current state and update verified flag
STATE=$(cat .claude/state/task_state.json)
echo "$STATE" | jq '.verified = true' > .claude/state/task_state.json
```

### Step 4: Run Dart analysis

**Important:** Check for static analysis issues before running tests.

```bash
dart analyze
```

Fix any analysis errors before proceeding.

### Step 5: Run full test suite

```bash
flutter test
```

Fix any test failures before proceeding.

### Step 6: Add summary comment to Jira

**MCP (Primary) - USE THIS:**
```
mcp__atlassian__addCommentToJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  commentBody: `### Implementation Complete

**Changes:**
- [Summary of changes made]
- [Key files modified]

**Testing:**
- Analysis: Passing
- Unit tests: Passing

Ready for review.`
})
```

### Step 7: Transition to "Under Review"

**MCP (Primary):**
```
mcp__atlassian__getTransitionsForJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}"
})

mcp__atlassian__transitionJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "{ISSUE_KEY}",
  transition: { id: "{transition_id_for_under_review}" }
})
```

**acli (Fallback):**
```bash
acli jira workitem transition --key {ISSUE_KEY} --status "Under Review"
```

### Step 8: Commit any uncommitted changes

```bash
git status
```

If there are uncommitted changes:
```bash
git add .
git commit -m "{ISSUE_KEY}: [Summary of final changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 9: Request push permission

> "Work is complete and verified. Analysis and tests pass.
>
> May I push to the remote branch and create a PR?"

**WAIT for user approval before pushing.**

### Step 10: Push and create PR

After user approves:
```bash
# Push to remote
git push -u origin {branch-name}

# Create PR
gh pr create --title "{ISSUE_KEY}: {Summary}" --body "## Summary
- [Key changes]

## Test Plan
- [ ] Verify feature works as expected
- [ ] Check for regressions

**JIRA:** https://mayhew3.atlassian.net/browse/{ISSUE_KEY}

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### Step 11: Clean up state file

Remove or reset the state file:
```bash
echo '{}' > .claude/state/task_state.json
```

---

## Output Format

```
## Task Complete: {ISSUE_KEY}

**Summary:** {Summary}
**Status:** Under Review
**PR:** {PR_URL}

Please review and mark the Jira ticket as Done when merged.
```

---

## Notes

- This workflow ensures thorough verification before completion
- Tests must pass before PR creation
- User must explicitly verify the implementation works
- Claude transitions to "Under Review" but only the user can mark "Done"
