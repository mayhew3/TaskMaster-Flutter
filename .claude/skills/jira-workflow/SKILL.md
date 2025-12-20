---
name: jira-workflow
description: |
  Guide for Jira workflow in TaskMaster-Flutter. Use when:
  - User mentions Jira, ticket, story, epic, sprint, or backlog
  - Starting work on a new feature or bug
  - Asking what to work on next or checking task status
  - Creating branches for tickets
  - Completing work and preparing for review/PR
  - Adding comments or updating Jira issues
---

# Jira Workflow Skill

This skill provides guidance for consistent Jira workflow execution in the TaskMaster-Flutter project.

## Tool Priority

**Primary:** MCP Atlassian tool (better formatting, proper ADF conversion)
**Fallback:** acli CLI (when MCP authentication expires)

### MCP Authentication Issues

The MCP Atlassian tool can lose authentication. If you get auth errors:
1. Ask user to run `/mcp` to re-authenticate
2. Use acli as fallback for commands that support it
3. For **comments**: MCP only (acli can't do proper formatting) - must re-authenticate

## Quick Reference

### Key Rules
1. **Claude CAN** transition to: "In Progress", "Under Review"
2. **Claude CANNOT** transition to: "Done", "Closed" (user verification required)
3. **Comments** must use Markdown with MCP tool - see jira-formatting.md
4. **Push** only after: user verification + analysis passes + tests pass

### Project Info
| Key | Project | Directory |
|-----|---------|-----------|
| TM | TaskMaster | TaskMaster-Flutter/ |

---

## Common Commands

### View Issue

**MCP (Primary):**
```
mcp__atlassian__getJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-123"
})
```

**acli (Fallback):**
```bash
acli jira workitem view TM-123
```

---

### Add Comment

**MCP (Primary) - USE THIS:**
```
mcp__atlassian__addCommentToJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-123",
  commentBody: `### Progress Update

**Completed:**
- Item one
- Item two

**Next steps:**
- Item three`
})
```

**acli (NOT AVAILABLE for proper formatting):**
acli cannot produce properly formatted comments. Wiki markup is stored as plain text.
If MCP is not authenticated, ask user to re-authenticate with `/mcp` before adding comments.

---

### Transition Status

**MCP (Primary):**
```
# First get available transitions
mcp__atlassian__getTransitionsForJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-123"
})

# Then transition
mcp__atlassian__transitionJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-123",
  transition: { id: "{transition_id}" }
})
```

**acli (Fallback):**
```bash
acli jira workitem transition --key TM-123 --status "In Progress"
acli jira workitem transition --key TM-123 --status "Under Review"
```

---

### Search Issues (JQL)

**MCP (Primary):**
```
mcp__atlassian__searchJiraIssuesUsingJql({
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC",
  maxResults: 10
})
```

**acli (Fallback):**
```bash
acli jira workitem search --jql "project = TM AND sprint in openSprints() AND status IN ('To Do', 'Backlog') ORDER BY rank ASC" --limit 10
```

---

### Create Issue

**MCP (Primary):**
```
mcp__atlassian__createJiraIssue({
  cloudId: "mayhew3.atlassian.net",
  projectKey: "TM",
  issueTypeName: "Story",
  summary: "Implement feature X",
  description: `### Description

Details of the story.

### Acceptance Criteria
- Criterion one
- Criterion two`,
  parent: "TM-100"  // Optional: for stories under epic
})
```

**acli (Fallback - plain text description only):**
```bash
acli jira workitem create --project "TM" --type "Story" \
  --summary "Implement feature X" \
  --description "Description of the story (plain text only)" \
  --parent "TM-100" \
  --assignee "@me"
```
Note: acli descriptions won't have formatted headers/bullets.

---

## Supporting Documentation

- **jira-formatting.md** - Markdown formatting reference (for MCP tool)
- **jql-templates.md** - JQL query templates for TM project

## Workflow Overview

### Starting Work
1. Query sprint for unstarted stories
2. Transition to "In Progress"
3. Create branch: `TM-###-description`
4. Add comment with plan

### Completing Work
1. **Ask user to verify** the feature/fix works
2. **Wait for confirmation** before proceeding
3. Run `dart analyze`
4. Run `flutter test`, fix failures
5. Transition to "Under Review"
6. **Request permission to push** (only at this point!)
7. Create PR after push

See `/task-start` and `/task-complete` commands for detailed procedures.
