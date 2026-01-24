# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## General Behaviors

This file will live in the project root, but all supplemental helper files should go in the @.claude directory. Scan these files at startup along with this one.
- Naming convention: ALL CAPS

Try not to use language expressing certainty unless you are actually certain.
- When investigating bugs, do not say things like "this fixes the issue," if the fix hasn't actually been verified yet. You can say things like "possibly fix" or "likely fix" if you have more certainty.
- Don't mark an in-progress feature or task as complete until it has been confirmed to work.

## Project Overview

TaskMaster is a Flutter task management application with recurring tasks, sprint planning, and Firebase/Firestore backend integration. The app currently uses Redux for state management and built_value for immutable data models.

**🚧 ACTIVE MIGRATION:** This codebase is being migrated from Redux to Riverpod.

**⚠️ TESTING FIRST:** Before any migration work, complete testing plan in `.claude/TESTING_PLAN.md`.

## Migration Documents

- **`.claude/TESTING_PLAN.md`** - ⚠️ START HERE: Pre-migration testing requirements
- **`.claude/MIGRATION_PLAN.md`** - Complete phase-by-phase migration strategy
- **`.claude/PATTERNS.md`** - Riverpod patterns and best practices for the team
- **`.claude/METRICS.md`** - Track migration progress and performance improvements
- **`.claude/QUICK_START.md`** - Quick start guide for beginning migration
- **`.claude/QUESTIONS.md`** - Common questions and answers

When working on new features, prefer Riverpod patterns (see PATTERNS.md) over Redux.

## Essential Commands

### Development
```bash
# Run the app
flutter run

# Run with local Firestore emulator
flutter run --dart-define=SERVER=local

# Run tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run widget tests specifically
flutter test test/widgets/

# Run with verbose output
flutter test --verbose
```

### Code Generation
```bash
# Generate built_value models (*.g.dart files)
# Run this after modifying models with @built_value annotations
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Analysis & Linting
```bash
# Run static analysis
flutter analyze

# Format code
dart format .
```

### Build
```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

## Git Commit Conventions

**IMPORTANT**: Always follow these commit message rules:

1. **Before commit**:
   - Make sure to update proper feature documentation in .claude root folder with progress make by checkin

2. **JIRA ticket prefix**: Every commit message MUST start with the JIRA ticket number
   - Format: `TM-###: Commit message`
   - Example: `TM-19: Foundation Setup`
   - The current active ticket can be found at the start of the active git branch name, e.g. "TM-19-foundation-setup"

3. **Commit message structure**:
   ```
   TM-###: Brief summary (imperative mood, capitalize first word)

   - Bullet point details of changes
   - What was changed and why
   - Technical details

   Rationale:
   - Why this change was needed
   - Benefits of the approach

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

4. **When to commit**:
   - Feel free to commit on your own after every small piece of work:
   - After tests pass
   - After compilation succeeds

5. **Current active tickets**:
   - `TM-82` - Integration tests

## Architecture

### State Management: Redux Architecture

The app uses Redux for centralized state management with the following structure:

- **AppState** (`lib/redux/app_state.dart`): Root state containing:
  - Core data: `taskItems`, `sprints`, `taskRecurrences`
  - UI state: `activeTab`, filters, loading states
  - Auth state: `personDocId`, `currentUser`, `firebaseUser`
  - Firestore listeners for real-time updates

- **Reducers** (`lib/redux/reducers/`): Pure functions that handle state transitions
  - `app_state_reducer.dart`: Combines all reducers
  - `task_reducer.dart`: Task CRUD operations
  - `sprint_reducer.dart`: Sprint management
  - `auth_reducer.dart`: Authentication state

- **Middleware** (`lib/redux/middleware/`): Side effects and async operations
  - `store_task_items_middleware.dart`: Task persistence to Firestore
  - `store_sprint_middleware.dart`: Sprint persistence to Firestore
  - `auth_middleware.dart`: Google Sign-In and Firebase Auth
  - `notification_helper.dart`: Local notification scheduling

- **Containers** (`lib/redux/containers/`): Connect Redux state to presentation
  - Use `StoreConnector` to map state and dispatch to ViewModels
  - ViewModels define the interface between state and UI

- **Presentation** (`lib/redux/presentation/`): UI components
  - Screens and widgets that receive data via ViewModels
  - Pure widgets that don't directly access Redux store

### Data Models: built_value Pattern

All domain models use built_value for immutability and code generation:

- **TaskItem** (`lib/models/task_item.dart`): Core task entity
  - Dates: `startDate`, `targetDate`, `dueDate`, `urgentDate`, `completionDate`
  - Recurrence: `recurNumber`, `recurUnit`, `recurWait`, `recurrenceDocId`
  - Blueprints: Use `TaskItemBlueprint` for creating/updating tasks

- **Sprint** (`lib/models/sprint.dart`): Time-boxed work periods
  - Contains `sprintAssignments` linking tasks to sprints
  - Tracked by `sprintNumber` for ordering

- **TaskRecurrence** (`lib/models/task_recurrence.dart`): Recurring task rules
  - Separated from TaskItem to enable multiple task instances from one rule

- **Blueprints**: Mutable objects for creating/updating built_value models
  - Pattern: `TaskItem` → `TaskItemBlueprint` → `TaskRepository.updateTask()` → new `TaskItem`

### Firebase Integration

**TaskRepository** (`lib/task_repository.dart`): Firestore data access layer
- Collections: `tasks`, `sprints`, `taskRecurrences`, `snoozes`, `persons`
- Subcollections: `sprintAssignments` (under sprints)
- Real-time listeners via `createListener()` generic method
- Transactions for atomic operations (e.g., `addSprintWithTaskItems()`)

**Key patterns:**
- All writes add `dateAdded` timestamp
- Soft deletes use `retired` field (docId) and `retiredDate`
- Person data scoped by `personDocId` field
- Server environment: Use `--dart-define=SERVER=local` for emulator

### Testing Patterns

**Mock Generation:**
- Uses Mockito for mocking dependencies
- Run `flutter pub run build_runner build` to generate `*.mocks.dart` files
- See `test/test_mock_helper.dart` for common mock setup

**Widget Tests:**
- Located in `test/widgets/`
- Use `StoreProvider` with test store for Redux-connected widgets
- See `test/widgets/editable_task_field_test.dart` for examples

**Unit Tests:**
- Model tests in `test/models/`
- Helper tests: `recurrence_helper_test.dart`, `task_helper_test.dart`
- Repository tests: `task_repository_test.dart`

## Critical Code Patterns

### Creating/Updating Tasks
```dart
// Always use blueprints for mutations
var blueprint = taskItem.createBlueprint();
blueprint.name = 'Updated name';
await taskRepository.updateTaskAndRecurrence(taskItem.docId, blueprint);

// Add new task
var blueprint = TaskItemBlueprint()..name = 'New task'..personDocId = personDocId;
taskRepository.addTask(blueprint);
```

### Redux Dispatch Pattern
```dart
// Dispatch actions through middleware
store.dispatch(AddTaskItemAction(taskItem));
store.dispatch(UpdateTaskItemAction(taskItem));
```

### Recurrence System
- `RecurrenceHelper` (`lib/helpers/recurrence_helper.dart`): Calculates next recurrence dates
- When completing recurring task: Create new instance with `createNextRecurPreview()`
- Anchor dates track original schedule vs actual completion

## Important Notes

- **Code Generation**: Always run `build_runner` after modifying `@built_value` classes or `@GenerateMixin` annotations
- **Firestore Rules**: Queries filter by `personDocId` - ensure all new collections include this field
- **Offline Support**: App supports Firestore persistence with unlimited cache
- **Timezone Handling**: Uses `TimezoneHelper` for local timezone awareness in notifications
- **Date Storage**: All dates stored as UTC in Firestore, converted to local time in UI
- **Linting**: Uses `prefer_single_quotes` - prefer single quotes for strings

## Environment Configuration

**Firebase**: Configured in `lib/firebase_options.dart` (generated by FlutterFire CLI)

**Server Modes:**
- Production (default): Uses Firebase project
- Local: `flutter run --dart-define=SERVER=local` connects to emulator on 127.0.0.1:8085

## Jira Workflow (Atlassian MCP)

**Overview**: We use Jira for high-level planning and progress tracking, combined with detailed markdown documentation in `.claude/` directories.
**Project**: TaskMaster, "TM" prefix

### MCP Tools Available
The Atlassian MCP server provides direct access to Jira and Confluence. Key tools:

**Jira Tools:**
- `mcp__atlassian__getJiraIssue` - Get issue details by key (e.g., "TM-593")
- `mcp__atlassian__createJiraIssue` - Create new issues (Epic, Story, Task, Bug)
- `mcp__atlassian__editJiraIssue` - Update issue fields
- `mcp__atlassian__searchJiraIssuesUsingJql` - Search with JQL queries
- `mcp__atlassian__getTransitionsForJiraIssue` - Get available status transitions
- `mcp__atlassian__transitionJiraIssue` - Change issue status
- `mcp__atlassian__addCommentToJiraIssue` - Add comments to issues
- `mcp__atlassian__getVisibleJiraProjects` - List accessible projects
- `mcp__atlassian__getJiraProjectIssueTypesMetadata` - Get issue types for a project
- `mcp__atlassian__search` - Rovo Search across Jira and Confluence

**Confluence Tools:**
- `mcp__atlassian__getConfluenceSpaces` - List spaces
- `mcp__atlassian__getConfluencePage` - Get page content
- `mcp__atlassian__createConfluencePage` - Create new pages
- `mcp__atlassian__updateConfluencePage` - Update existing pages
- `mcp__atlassian__searchConfluenceUsingCql` - Search with CQL

### Cloud ID
All Atlassian MCP tools require a `cloudId` parameter. You can use:
- The site URL: `mayhew3.atlassian.net`
- Or call `mcp__atlassian__getAccessibleAtlassianResources` to get the UUID

### Common Operations

**Viewing Issues:**
```
# Get a specific issue
mcp__atlassian__getJiraIssue(cloudId: "mayhew3.atlassian.net", issueIdOrKey: "TM-593")

# Search for issues with JQL
mcp__atlassian__searchJiraIssuesUsingJql(
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM ORDER BY created DESC",
  maxResults: 10
)

# View Epic and all child stories
mcp__atlassian__searchJiraIssuesUsingJql(
  cloudId: "mayhew3.atlassian.net",
  jql: "parent = TM-1226 OR key = TM-1226"
)
```

**Creating Issues:**
```
# Create an Epic
mcp__atlassian__createJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  projectKey: "TM",
  issueTypeName: "Epic",
  summary: "Phase X: Feature Name",
  description: "Detailed description"
)

# Create a Story under an Epic (use parent field in additional_fields)
mcp__atlassian__createJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  projectKey: "TM",
  issueTypeName: "Story",
  summary: "Story summary",
  description: "Story details",
  parent: "TM-XXX"
)
```

**Updating Issues:**
```
# First get available transitions
mcp__atlassian__getTransitionsForJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-593"
)

# Then transition to new status (use transition ID from above)
mcp__atlassian__transitionJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-593",
  transition: { id: "21" }  # ID for "In Progress"
)

# Add a comment
mcp__atlassian__addCommentToJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-593",
  commentBody: "Progress update or technical note"
)

# Edit issue fields
mcp__atlassian__editJiraIssue(
  cloudId: "mayhew3.atlassian.net",
  issueIdOrKey: "TM-593",
  fields: { summary: "Updated summary" }
)
```

**Projects:**
```
# List visible projects
mcp__atlassian__getVisibleJiraProjects(cloudId: "mayhew3.atlassian.net")

# Get issue types for a project
mcp__atlassian__getJiraProjectIssueTypesMetadata(
  cloudId: "mayhew3.atlassian.net",
  projectIdOrKey: "TM"
)
```

### Finding Tasks in Active Sprint

When the user asks to start work or find the next task, query the active sprint for available stories:

```
# Find stories in the active sprint for a project (e.g., TaskMaster)
mcp__atlassian__searchJiraIssuesUsingJql(
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status != Done ORDER BY rank ASC",
  maxResults: 20
)

# Find stories assigned to current user in active sprint
mcp__atlassian__searchJiraIssuesUsingJql(
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND assignee = currentUser() ORDER BY rank ASC"
)

# Find unstarted stories (To Do status) in active sprint
mcp__atlassian__searchJiraIssuesUsingJql(
  cloudId: "mayhew3.atlassian.net",
  jql: "project = TM AND sprint in openSprints() AND status = 'To Do' ORDER BY rank ASC"
)
```

**When starting a new task:**
1. Query the active sprint for available stories
2. Present options to the user or pick the highest-ranked unstarted story
3. Transition the story to "In Progress"
4. Create/checkout a branch following naming conventions
5. Begin work

### Workflow Process

**When Starting Work on a Phase/Epic:**

1. **Epic Creation** (Claude can do this):
    - Use `mcp__atlassian__createJiraIssue` with `issueTypeName: "Epic"`
    - Set summary, description, and project key

2. **Story Creation** (Claude can do this):
    - Break Epic into user stories using `mcp__atlassian__createJiraIssue`
    - Link stories to Epic with `parent` parameter
    - Each story represents a major component or deliverable

3. **Branch Creation** (Claude can do this):
    - Create a new branch for the Epic using format: `<epic-jira>-short-description`
    - Examples:
        - `TM-1226-migrate-auth0`
   ```bash
   git checkout -b TM-1226-migrate-auth0
   git push -u origin TM-1226-migrate-auth0
   ```

4. **Draft Pull Request** (Claude can do this):
    - Create a draft PR to run CI tests as work progresses
    - Use GitHub CLI or `mcp__github__create_pull_request` with `draft: true`

5. **Starting Work** (Claude can do this):
    - Use `mcp__atlassian__getTransitionsForJiraIssue` to get transition IDs
    - Use `mcp__atlassian__transitionJiraIssue` to move to "In Progress"
    - Use `mcp__atlassian__addCommentToJiraIssue` for progress updates

6. **During Development** (Claude can do this):
    - Add comments to stories as work progresses
    - Use `mcp__atlassian__editJiraIssue` to update descriptions if scope changes
    - Push commits regularly to run CI tests on draft PR

7. **⚠️ Completing Work** (Claude transitions to "Under Review"):
    - When Story work is complete, transition to "Under Review"
    - Add comment summarizing what was done
    - User reviews and either marks "Done" or provides feedback

8. **Documentation** (Claude does this):
    - Create detailed markdown files in `.claude/<app>/` directory
    - Reference Jira issue in markdown: `**JIRA**: TM-XXXX`
    - Link markdown in Jira comments: "See PHASE_X_FEATURE.md for technical details"

### Hybrid Jira + Markdown Strategy

**Use Jira for:**
- High-level planning (Epics and Stories)
- Progress tracking (status transitions)
- Task assignment
- Quick status updates (comments)
- Linking commits to issues

**Use Markdown files for:**
- Detailed technical documentation
- Code patterns and examples
- Architectural decisions
- Lessons learned

**Example Structure:**
```
Jira:
  Epic TM-1226: "Phase 11: Migrate Auth0 Lock to Modern Auth0 SDK"
    ├─ Story TM-1227: "Install and configure SDK"
    ├─ Story TM-1228: "Migrate AuthService"
    └─ Story TM-1229: "Update components"

.claude/:
  PHASE_11_AUTH0_MIGRATION.md
    - Technical implementation details
    - Code examples and patterns
    - Testing strategy
    - Lessons learned
    - Links to Jira: "**JIRA**: TM-1226"
```

### Status Transition Guidelines

**Claude CAN transition to:**
- ✅ "In Progress" - When starting work on an issue
- ✅ "Under Review" - When work is complete and ready for user review
- ✅ Add comments - Progress updates, blockers, technical notes

**Claude CANNOT transition to:**
- ❌ "Done" - Only user can mark issues complete
- ❌ "Closed" - Only user can close issues

**Typical Workflow:**
1. Claude transitions Story to "In Progress" when starting work
2. Claude adds comments during development with progress updates
3. Claude transitions Story to "Under Review" when work is complete
4. User reviews the work (tests passing, functionality verified, documentation updated)
5. User transitions Story to "Done" if approved, or back to "In Progress" with feedback

**Rationale**: User verification ensures work meets quality standards and acceptance criteria before being marked complete.
