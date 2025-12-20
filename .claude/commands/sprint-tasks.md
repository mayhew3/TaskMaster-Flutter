---
description: Query active sprint for available tasks
arguments: project-key (optional - defaults to TM)
---

# Sprint Tasks

Query the active sprint to see available stories and bugs.

## Your Task

**Argument provided:** `$ARGUMENTS`

### Step 1: Determine project key

| Input | Action |
|-------|--------|
| `TM` or empty | Use TM (TaskMaster) |
| `?` or `help` | Show usage and exit |

### Step 2: Query sprint for tasks

**MCP (Primary):**

Query for **Ready to Start** (To Do / Backlog):
```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC",
  maxResults: 10
})
```

Query for **In Progress**:
```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status = 'In Progress' ORDER BY rank ASC",
  maxResults: 10
})
```

Query for **Under Review**:
```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status = 'Under Review' ORDER BY rank ASC",
  maxResults: 10
})
```

**acli (Fallback):**
```bash
# Ready to Start
acli jira workitem search --jql "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC" --limit 10

# In Progress
acli jira workitem search --jql "project = TM AND sprint in openSprints() AND status = 'In Progress' ORDER BY rank ASC" --limit 10

# Under Review
acli jira workitem search --jql "project = TM AND sprint in openSprints() AND status = 'Under Review' ORDER BY rank ASC" --limit 10
```

### Step 3: Present results

Format the results in three sections:

```
## Sprint Tasks - TM (TaskMaster)

### Ready to Start
| Key | Type | Summary |
|-----|------|---------|
| TM-123 | Story | Add new feature |
| TM-124 | Bug | Fix issue |

### In Progress
| Key | Type | Summary |
|-----|------|---------|
| TM-125 | Story | Implement workflow |

### Under Review
| Key | Type | Summary |
|-----|------|---------|
| TM-126 | Task | Update documentation |
```

### Step 4: Suggest next task

If there are tasks in "Ready to Start":

> "**Suggested next task:** TM-123: Add new feature
>
> Would you like to start work on this task? Run `/task-start TM-123`"

If no tasks in "Ready to Start":

> "No tasks ready to start in the current sprint.
> Check the backlog or talk to the team about priorities."

---

## Output Format

Display the sprint tasks organized by status, with a suggestion for the next task to pick up.

---

## Notes

- Tasks are ordered by rank (priority) within each status
- The suggested task is the highest-ranked item in "Ready to Start"
- Use `/task-start <issue>` to begin work on a task
