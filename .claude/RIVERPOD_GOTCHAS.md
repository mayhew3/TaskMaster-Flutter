# Riverpod Migration Gotchas

This document captures common pitfalls and patterns discovered during the Redux to Riverpod migration.

## Table of Contents
1. [Widget Initialization Patterns](#widget-initialization-patterns)
2. [Task Recurrence Population](#task-recurrence-population)
3. [Async Provider Handling](#async-provider-handling)

---

## Widget Initialization Patterns

### Problem: Re-initialization on Every Rebuild

**Symptom**: State gets reset on every rebuild (e.g., form fields clearing, selections being lost)

**Example from TM-299/300**:
```dart
// ❌ BAD - Runs on EVERY build
@override
Widget build(BuildContext context) {
  if (taskItem == null) {
    _initializeTask(null);  // Creates fresh empty blueprint every time!
  }
  // ...
}
```

**Root Cause**:
- `build()` method runs on every rebuild (triggered by `setState()`, parent rebuild, etc.)
- Any initialization logic in `build()` will run repeatedly
- This causes state to reset, wiping out user input or selections

**Solution**: Use proper lifecycle methods

```dart
// ✅ GOOD - Runs once when dependencies available
bool _initialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (!_initialized) {
    final task = widget.taskItemId != null
        ? ref.read(taskProvider(widget.taskItemId!))
        : null;
    _initializeTask(task);
    _initialized = true;
  }
}

@override
Widget build(BuildContext context) {
  // No initialization here - just build the UI
  return Scaffold(...);
}
```

**Why `didChangeDependencies()` over `initState()`**:
- `initState()` runs before `ref` is available (InheritedWidget not yet accessible)
- `didChangeDependencies()` runs after `initState()` and when InheritedWidget changes
- With `_initialized` flag, it only runs once

**Related Issues**: TM-299, TM-300

---

## Task Recurrence Population

### Problem: Recurrence Object Not Populated

**Symptom**: Exception "No recurrence on task item!" when calling `RecurrenceHelper.createNextIteration()`

**Example from TM-304**:
```dart
// ❌ BAD - Assumes recurrence is populated
for (var recurID in recurIDs) {
  TaskItem newest = sortedItems.last;
  if (newest.recurWait == false) {
    // Crashes if newest.recurrence is null!
    addNextIterations(newest, endDate, futureIterations);
  }
}
```

**Root Cause**:
- Tasks store `recurrenceDocId` (reference) but not always the full `recurrence` object
- `tasksProvider` loads tasks from Firestore but doesn't populate recurrence references
- `tasksWithRecurrencesProvider` exists specifically to link tasks with their recurrences
- Code calling `RecurrenceHelper.createNextIteration()` requires the full `recurrence` object

**Solution Pattern 1**: Use the right provider

```dart
// ✅ GOOD - Use tasksWithRecurrencesProvider when you need recurrences
@riverpod
TaskItem? task(TaskRef ref, String taskId) {
  final tasksAsync = ref.watch(tasksWithRecurrencesProvider);  // Not tasksProvider!

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );
}
```

**Solution Pattern 2**: Manually populate before use

```dart
// ✅ GOOD - Fetch and populate recurrence before calling createNextIteration
void createTemporaryIterations() {
  final allTasks = ref.read(tasksProvider).value ?? [];

  // Get all recurrences to populate tasks
  final allRecurrences = ref.read(taskRecurrencesProvider).value ?? [];

  for (var recurID in recurIDs) {
    TaskItem newest = sortedItems.last;

    // Populate recurrence on the task if not already populated
    if (newest.recurrence == null && newest.recurrenceDocId != null) {
      final recurrence = allRecurrences.firstWhereOrNull(
        (r) => r.docId == newest.recurrenceDocId
      );
      if (recurrence != null) {
        newest = newest.rebuild((b) => b..recurrence = recurrence.toBuilder());
      } else {
        // Skip this task if recurrence not found
        print('[TM-304] Skipping task ${newest.docId} - recurrence not found');
        continue;
      }
    }

    if (newest.recurWait == false) {
      addNextIterations(newest, endDate, futureIterations);
    }
  }
}
```

**Provider Comparison**:

| Provider | Populates Recurrence? | Use When |
|----------|----------------------|----------|
| `tasksProvider` | ❌ No | Simple task list display, no recurrence logic needed |
| `tasksWithRecurrencesProvider` | ✅ Yes | Displaying recurrence info, creating next iterations |
| `taskRecurrencesProvider` | N/A | Need to manually populate recurrences |

**Related Issues**: TM-299, TM-304, TM-303

---

## Async Provider Handling

### Problem: Reading Async Provider Before Data Loads

**Symptom**: Empty lists, null values, or "data not found" even though data exists

**Example from TM-303**:
```dart
// ❌ BAD - Tries to initialize in callback before data loads
if (!initialized) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      // tasksProvider might still be loading!
      final allTasks = ref.read(tasksProvider).value ?? [];  // Empty!
      preSelectTasks(allTasks);
      initialized = true;
    });
  });
}
```

**Root Cause**:
- Async providers (Stream/Future) have three states: loading, data, error
- Reading `.value` before provider loads returns `null` or empty
- `addPostFrameCallback` runs after first build, but provider might not be loaded yet

**Solution**: Check loading state before accessing data

```dart
// ✅ GOOD - Wait for data to load, then initialize
@override
Widget build(BuildContext context) {
  // Watch providers
  final allTasksAsync = ref.watch(tasksProvider);
  final allSprintsAsync = ref.watch(sprintsProvider);

  // Handle loading/error states FIRST
  if (allTasksAsync.isLoading || allSprintsAsync.isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Tasks')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  if (allTasksAsync.hasError || allSprintsAsync.hasError) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Tasks')),
      body: const Center(child: Text('Error loading data')),
    );
  }

  // NOW data is available - safe to use .value
  final allTasks = allTasksAsync.value ?? [];
  final allSprints = allSprintsAsync.value ?? [];

  // Initialize on first build with loaded data
  if (!initialized) {
    preSelectTasks(allTasks);
    initialized = true;
  }

  return Scaffold(...);
}
```

**Alternative**: Use `didChangeDependencies()` with hasValue check

```dart
// ✅ ALSO GOOD - Initialize in lifecycle method once data loads
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (!initialized) {
    final tasksAsync = ref.read(tasksProvider);
    final sprintsAsync = ref.read(sprintsProvider);

    // Only initialize if data is loaded
    if (tasksAsync.hasValue && sprintsAsync.hasValue) {
      final allTasks = tasksAsync.value ?? [];
      preSelectTasks(allTasks);
      initialized = true;
    }
  }
}

@override
Widget build(BuildContext context) {
  final tasksAsync = ref.watch(tasksProvider);

  // Show loading until initialized
  if (tasksAsync.isLoading || !initialized) {
    return CircularProgressIndicator();
  }

  return Scaffold(...);
}
```

**Pattern Summary**:

1. **Watch** async providers in `build()`
2. **Check** loading/error states and return early if needed
3. **Extract** `.value` only after confirming data is loaded
4. **Initialize** state with the loaded data

**Related Issues**: TM-303

---

## Quick Reference Checklist

When migrating a widget from Redux to Riverpod, check:

- [ ] **Initialization**: Is it in `didChangeDependencies()` with `_initialized` flag?
- [ ] **Recurrence**: If using `RecurrenceHelper`, is recurrence object populated?
- [ ] **Providers**: Am I using `tasksWithRecurrencesProvider` when I need recurrences?
- [ ] **Async**: Am I checking `isLoading`/`hasError` before accessing `.value`?
- [ ] **Build purity**: Is my `build()` method free of state mutations?

---

## Related Documents

- [MIGRATION_PLAN.md](.claude/MIGRATION_PLAN.md) - Overall migration strategy
- [PATTERNS.md](.claude/PATTERNS.md) - Riverpod patterns and best practices
- [CLAUDE.md](CLAUDE.md) - Project-wide guidance
