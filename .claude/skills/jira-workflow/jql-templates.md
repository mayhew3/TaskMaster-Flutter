# JQL Query Templates for TaskMaster

Common JQL queries for the TM (TaskMaster) project.

## Sprint Queries

### Ready to Start (To Do / Backlog)
```jql
project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC
```

### In Progress
```jql
project = TM AND sprint in openSprints() AND status = 'In Progress' ORDER BY rank ASC
```

### Under Review
```jql
project = TM AND sprint in openSprints() AND status = 'Under Review' ORDER BY rank ASC
```

### All Open in Sprint
```jql
project = TM AND sprint in openSprints() AND status != Done ORDER BY rank ASC
```

### Completed in Sprint
```jql
project = TM AND sprint in openSprints() AND status = Done ORDER BY updated DESC
```

---

## Backlog Queries

### All Backlog Items
```jql
project = TM AND sprint is EMPTY AND status IN ('To Do', 'Backlog') ORDER BY rank ASC
```

### Bugs in Backlog
```jql
project = TM AND sprint is EMPTY AND issuetype = Bug ORDER BY priority DESC
```

### Stories in Backlog
```jql
project = TM AND sprint is EMPTY AND issuetype = Story ORDER BY rank ASC
```

---

## Issue Type Queries

### All Bugs (Open)
```jql
project = TM AND issuetype = Bug AND status != Done ORDER BY priority DESC
```

### All Stories (Open)
```jql
project = TM AND issuetype = Story AND status != Done ORDER BY rank ASC
```

### All Epics
```jql
project = TM AND issuetype = Epic ORDER BY created DESC
```

### Stories Under Epic
```jql
project = TM AND parent = TM-100 ORDER BY rank ASC
```

---

## User Queries

### Assigned to Me
```jql
project = TM AND assignee = currentUser() AND status != Done ORDER BY rank ASC
```

### Created by Me
```jql
project = TM AND reporter = currentUser() ORDER BY created DESC
```

---

## Recent Activity

### Recently Updated
```jql
project = TM AND updated >= -7d ORDER BY updated DESC
```

### Recently Created
```jql
project = TM AND created >= -7d ORDER BY created DESC
```

### Recently Completed
```jql
project = TM AND status = Done AND resolved >= -7d ORDER BY resolved DESC
```

---

## Using with MCP Tool

```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "{JQL_QUERY_HERE}",
  maxResults: 10
})
```

## Using with acli (Fallback)

```bash
acli jira workitem search --jql "{JQL_QUERY_HERE}" --limit 10
```
