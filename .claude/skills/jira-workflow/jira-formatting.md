# Jira Comment Formatting Guide

When using the MCP Atlassian tool to add comments, use **Markdown** format. The tool converts Markdown to Atlassian Document Format (ADF) automatically.

## Supported Markdown Syntax

### Headings
```markdown
### Heading 3
#### Heading 4
```

### Text Formatting
```markdown
**bold text**
*italic text*
`inline code`
```

### Lists
```markdown
- Bullet item 1
- Bullet item 2
  - Nested item

1. Numbered item 1
2. Numbered item 2
```

### Code Blocks
````markdown
```dart
void main() {
  print('Hello');
}
```
````

### Links
```markdown
[Link Text](https://example.com)
```

---

## Comment Templates

### Starting Work
```markdown
### Starting Work

**Branch:** `TM-123-description`

**Approach:**
Will analyze the codebase and create an implementation plan.

**Next steps:**
1. Review requirements
2. Explore relevant code
3. Create implementation plan
```

### Progress Update
```markdown
### Progress Update

**Completed:**
- Implemented feature X
- Added tests for Y

**In Progress:**
- Working on Z

**Blockers:**
- None
```

### Implementation Complete
```markdown
### Implementation Complete

**Changes:**
- Added new feature X
- Modified files: `lib/feature.dart`, `test/feature_test.dart`

**Testing:**
- Analysis: Passing
- Unit tests: Passing

Ready for review.
```

### Quick Complete
```markdown
### Quick Complete

**Changes:**
- Updated documentation

*Low-risk change - tests will run in CI.*
```

---

## Notes

- Always use the MCP tool for comments (better formatting)
- If MCP auth expires, ask user to run `/mcp` to re-authenticate
- acli CLI cannot produce properly formatted comments
