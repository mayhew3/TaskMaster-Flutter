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
