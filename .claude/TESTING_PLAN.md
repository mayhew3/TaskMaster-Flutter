# Pre-Migration Testing Plan

**Goal:** Increase test coverage from ~30% to ~70%+ before beginning Redux → Riverpod migration to ensure functionality doesn't break during refactoring.

**Current Status:** 101 tests passing (7 seconds)

---

## Test Coverage Analysis

### ✅ Well-Tested Components

- **RecurrenceHelper** - Excellent coverage (~80% of test suite)
  - Date calculations
  - Recurring task creation
  - Snooze functionality
  - Anchor date handling

- **Widget Components** - Good coverage
  - `EditableTaskField` - Comprehensive (input validation, text capitalization, etc.)
  - `EditableTaskItem` - Basic coverage

- **Unit Tests** - Solid foundation
  - Model tests (TaskItem)
  - Date utilities
  - Notification helpers

### ❌ Critical Testing Gaps

#### 1. **ZERO Integration Tests** 🔴 HIGHEST PRIORITY
No end-to-end user flows tested. This is the biggest risk for migration.

#### 2. **Screen-Level Tests** 🔴 HIGH PRIORITY
Most complex screens have NO tests:
- `add_edit_screen.dart` - Main task editing (CRITICAL)
- `details_screen.dart` - Task details view
- `home_screen.dart` - Main navigation
- `planning_home.dart` - Sprint planning
- `new_sprint.dart` - Sprint creation
- `task_item_list.dart` - Main task list
- `sign_in.dart` - Authentication

#### 3. **Redux Layer Tests** 🟡 MEDIUM PRIORITY
- NO middleware tests (business logic layer)
- NO reducer tests (state mutations)
- NO selector tests (derived state)
- NO container/ViewModel tests

#### 4. **Repository & Data Layer** 🟡 MEDIUM PRIORITY
- `TaskRepository` tests mostly commented out
- No Firestore integration tests
- No offline mode tests

#### 5. **Authentication & Loading** 🔴 HIGH PRIORITY
- No auth flow tests
- No data loading tests
- No error handling tests

---

## Testing Strategy

### Phase A: Critical Path Integration Tests (Week 1)
**Goal:** Ensure core user journeys work end-to-end

**Priority:** 🔴 MUST HAVE before migration

### Phase B: Screen Widget Tests (Week 2)
**Goal:** Test all major screens in isolation

**Priority:** 🔴 MUST HAVE before migration

### Phase C: Redux Layer Tests (Week 3)
**Goal:** Test state management logic

**Priority:** 🟡 NICE TO HAVE (can test after migration to Riverpod)

### Phase D: Repository & Edge Cases (Week 4)
**Goal:** Test data layer and error scenarios

**Priority:** 🟢 OPTIONAL (lower risk areas)

---

## Phase A: Critical Path Integration Tests

**Estimated Time:** 3-5 days
**Files to Create:** `test/integration/`

### Test 1: Complete Task Flow
```dart
// test/integration/task_crud_test.dart

testWidgets('User can create, edit, complete, and delete a task', (tester) async {
  // Setup: Mock Firestore, authenticated user
  // 1. Navigate to add task screen
  // 2. Fill in task name, due date, project
  // 3. Save task
  // 4. Verify task appears in list
  // 5. Tap task to open details
  // 6. Edit task name
  // 7. Save changes
  // 8. Verify updated name in list
  // 9. Check task as complete
  // 10. Verify completion date set
  // 11. Delete task
  // 12. Verify task removed from list
});
```

**Why Critical:** This is the most common user flow. If this breaks during migration, app is unusable.

### Test 2: Recurring Task Flow
```dart
// test/integration/recurring_task_test.dart

testWidgets('User can create and complete recurring task', (tester) async {
  // 1. Create task with recurrence (every 7 days)
  // 2. Complete the task
  // 3. Verify next iteration is created
  // 4. Verify next iteration has correct due date (+7 days)
  // 5. Verify both tasks visible when showing completed
});
```

**Why Critical:** Recurrence is a complex core feature. Unit tests exist but no integration test.

### Test 3: Sprint Creation Flow
```dart
// test/integration/sprint_test.dart

testWidgets('User can create sprint with tasks', (tester) async {
  // 1. Navigate to planning screen
  // 2. Create new sprint
  // 3. Add existing tasks to sprint
  // 4. Create new tasks in sprint
  // 5. Verify sprint appears as active
  // 6. Verify all tasks assigned to sprint
});
```

**Why Critical:** Sprint management is unique feature. No tests currently.

### Test 4: Authentication Flow
```dart
// test/integration/auth_test.dart

testWidgets('User can sign in and load data', (tester) async {
  // 1. Start app (not authenticated)
  // 2. See sign in screen
  // 3. Mock Google sign-in success
  // 4. Verify person doc lookup
  // 5. Verify data loading starts
  // 6. Verify home screen appears
  // 7. Verify tasks loaded
});

testWidgets('User without person doc sees error', (tester) async {
  // 1. Sign in with email not in persons collection
  // 2. Verify error screen shown
});
```

**Why Critical:** Can't use app without authentication. No tests currently.

### Test 5: Snooze Task Flow
```dart
// test/integration/snooze_test.dart

testWidgets('User can snooze task', (tester) async {
  // 1. Open task details
  // 2. Tap snooze button
  // 3. Select snooze duration (3 days)
  // 4. Verify due date updated (+3 days)
  // 5. Verify snooze record created
  // 6. For recurring task: verify anchor date handling
});
```

**Why Critical:** Complex date manipulation. Only unit tests exist.

---

## Phase B: Screen Widget Tests

**Estimated Time:** 5-7 days
**Files to Create:** `test/screens/`

### Priority 1: Task Editing Screen 🔴

```dart
// test/screens/add_edit_screen_test.dart

testWidgets('Add/Edit screen displays correctly', (tester) async {
  // Test initial state
  // Test with existing task (edit mode)
  // Test with no task (add mode)
});

testWidgets('Task name field validation', (tester) async {
  // Test required validation
  // Test max length
});

testWidgets('Date picker integration', (tester) async {
  // Test opening date picker
  // Test setting start date
  // Test setting due date
  // Test clearing dates
});

testWidgets('Recurrence configuration', (tester) async {
  // Test enabling recurrence
  // Test setting recurrence interval
  // Test On Complete vs On Schedule
});

testWidgets('Save button creates/updates task', (tester) async {
  // Test save action dispatches correct Redux action
  // Test navigation after save
});

testWidgets('Cancel button discards changes', (tester) async {
  // Test navigation without saving
});
```

**Why Priority 1:** Most complex screen, most likely to break during migration.

### Priority 2: Task List Screen 🔴

```dart
// test/screens/task_list_screen_test.dart

testWidgets('Task list displays tasks', (tester) async {
  // Test empty state
  // Test with tasks
  // Test task ordering
});

testWidgets('Checkbox completes task', (tester) async {
  // Test checking box
  // Test unchecking box
  // Test recurring task creates next iteration
});

testWidgets('Filter button toggles visibility', (tester) async {
  // Test showing/hiding completed
  // Test showing/hiding scheduled
});

testWidgets('Tapping task opens details', (tester) async {
  // Test navigation to detail screen
});

testWidgets('Urgent tasks highlighted', (tester) async {
  // Test urgent indicator visible
  // Test past due indicator visible
});
```

### Priority 3: Task Details Screen 🔴

```dart
// test/screens/details_screen_test.dart

testWidgets('Details screen displays task info', (tester) async {
  // Test all fields displayed
  // Test with minimal task data
  // Test with full task data
});

testWidgets('Edit button navigates to edit screen', (tester) async {
  // Test navigation
  // Test passing task data
});

testWidgets('Delete button removes task', (tester) async {
  // Test confirmation dialog
  // Test delete action
  // Test navigation after delete
});

testWidgets('Snooze button opens snooze dialog', (tester) async {
  // Test dialog displays
  // Test snooze options
});

testWidgets('Sprint assignments displayed', (tester) async {
  // Test task in sprint
  // Test task in multiple sprints
  // Test task not in sprint
});
```

### Priority 4: Sprint Screens 🟡

```dart
// test/screens/planning_home_test.dart
// test/screens/new_sprint_test.dart

testWidgets('Planning screen shows available tasks', (tester) async {});
testWidgets('User can select tasks for new sprint', (tester) async {});
testWidgets('Create sprint button validation', (tester) async {});
testWidgets('Active sprint displayed', (tester) async {});
```

### Priority 5: Home & Navigation 🟡

```dart
// test/screens/home_screen_test.dart

testWidgets('Home screen shows correct tab', (tester) async {});
testWidgets('Tab switching works', (tester) async {});
testWidgets('Loading state displayed', (tester) async {});
testWidgets('Error state displayed', (tester) async {});
```

---

## Phase C: Redux Layer Tests (Optional)

**Estimated Time:** 3-4 days
**Priority:** 🟡 NICE TO HAVE (will be deleted during migration anyway)

**Decision Point:** Skip this if pressed for time. Integration tests cover most of this indirectly.

### If you decide to write these:

```dart
// test/redux/middleware/task_middleware_test.dart
test('CompleteTaskItemAction creates next recurrence', () async {});
test('AddTaskItemAction calls repository', () async {});
test('UpdateTaskItemAction updates Firestore', () async {});

// test/redux/reducers/task_reducer_test.dart
test('TasksAddedAction adds tasks to state', () {});
test('TaskItemCompletedAction updates completion date', () {});

// test/redux/selectors/selectors_test.dart
test('filteredTaskItemsSelector filters completed', () {});
test('activeSprintSelector returns current sprint', () {});
```

---

## Phase D: Repository & Edge Cases (Optional)

**Estimated Time:** 2-3 days
**Priority:** 🟢 NICE TO HAVE

```dart
// test/task_repository_test.dart (uncomment and fix existing tests)
test('addTask creates document in Firestore', () async {});
test('updateTaskAndRecurrence updates both documents', () async {});
test('deleteTask soft deletes with retired field', () async {});
test('createListener handles document added', () async {});
test('createListener handles document modified', () async {});

// test/edge_cases/error_handling_test.dart
testWidgets('Firestore offline error shows message', (tester) async {});
testWidgets('Invalid person doc shows error screen', (tester) async {});
testWidgets('Network timeout retries', (tester) async {});
```

---

## Implementation Guide

### Step 1: Setup Test Infrastructure (Day 1)

Create test helpers and mocks:

```dart
// test/integration/integration_test_helper.dart

class IntegrationTestHelper {
  static Future<void> pumpApp(
    WidgetTester tester, {
    required Store<AppState> store,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      ),
    );
  }

  static Store<AppState> createMockStore({
    List<TaskItem>? tasks,
    Sprint? activeSprint,
    String? personDocId,
  }) {
    // Create store with mocked repository
    final mockFirestore = MockFirebaseFirestore();
    final mockRepo = MockTaskRepository();

    // Setup mock responses
    when(mockRepo.watchTasks(any)).thenAnswer((_) => Stream.value(tasks ?? []));

    return Store<AppState>(
      appReducer,
      initialState: AppState.init()
        ..taskItems = ListBuilder(tasks ?? [])
        ..personDocId = personDocId ?? 'test-person-id',
      middleware: createStoreTaskItemsMiddleware(mockRepo, GlobalKey(), mockMigrator),
    );
  }
}
```

### Step 2: Write One Test Per Day

**Day 1-5:** Critical Path Tests (Phase A)
- Day 1: Task CRUD flow
- Day 2: Recurring task flow
- Day 3: Sprint creation flow
- Day 4: Authentication flow
- Day 5: Snooze flow

**Day 6-12:** Screen Widget Tests (Phase B)
- Day 6-7: Add/Edit screen
- Day 8-9: Task list screen
- Day 10: Details screen
- Day 11: Sprint screens
- Day 12: Home screen

### Step 3: Run Tests Before Migration

```bash
# Record baseline
flutter test > .claude/test_baseline.txt

# Check coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

Target: 70%+ coverage on critical paths

---

## Test Patterns for Redux

### Pattern: Testing Screens with Redux

```dart
testWidgets('Example screen test', (tester) async {
  // 1. Create mock store with initial state
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.init().rebuild((b) => b
      ..taskItems = ListBuilder([mockTask])
      ..personDocId = 'person-123'
      ..isLoading = false
    ),
  );

  // 2. Pump app with StoreProvider
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: TaskListScreen(),
      ),
    ),
  );

  // 3. Wait for async rendering
  await tester.pumpAndSettle();

  // 4. Verify UI
  expect(find.text(mockTask.name), findsOneWidget);

  // 5. Interact
  await tester.tap(find.byType(Checkbox).first);
  await tester.pumpAndSettle();

  // 6. Verify state changed
  expect(store.state.taskItems.first.completionDate, isNotNull);
});
```

### Pattern: Mocking Firestore

```dart
// Use fake_cloud_firestore package for realistic mocking
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

final fakeFirestore = FakeFirebaseFirestore();

// Seed with data
await fakeFirestore.collection('tasks').add({
  'name': 'Test Task',
  'personDocId': 'person-123',
  'completionDate': null,
});

// Use in repository
final repo = TaskRepository(firestore: fakeFirestore);
```

Add to pubspec.yaml:
```yaml
dev_dependencies:
  fake_cloud_firestore: ^3.0.3
```

---

## Testing Checklist

Before starting migration, verify:

### Phase A Checklist (REQUIRED)
- [ ] Task CRUD integration test
- [ ] Recurring task integration test
- [ ] Sprint creation integration test
- [ ] Authentication flow integration test
- [ ] Snooze task integration test
- [ ] All integration tests passing

### Phase B Checklist (REQUIRED)
- [ ] Add/Edit screen tests
- [ ] Task list screen tests
- [ ] Task details screen tests
- [ ] Sprint planning screen tests
- [ ] Home screen tests
- [ ] All widget tests passing

### Phase C Checklist (OPTIONAL)
- [ ] Middleware tests
- [ ] Reducer tests
- [ ] Selector tests

### Phase D Checklist (OPTIONAL)
- [ ] Repository tests
- [ ] Error handling tests
- [ ] Offline mode tests

### Coverage Metrics
- [ ] Overall coverage > 70%
- [ ] Critical path coverage > 90%
- [ ] Screen coverage > 60%
- [ ] Business logic coverage > 80%

---

## Common Testing Pitfalls

### 1. Async State Updates

```dart
// BAD: Doesn't wait for Redux state update
await tester.tap(find.byType(Checkbox));
expect(store.state.taskItems.first.completionDate, isNotNull); // FAILS

// GOOD: Wait for all animations and async operations
await tester.tap(find.byType(Checkbox));
await tester.pumpAndSettle(); // Wait for all async
expect(store.state.taskItems.first.completionDate, isNotNull); // PASSES
```

### 2. Firestore Streams

```dart
// BAD: Stream never emits in test
when(mockRepo.watchTasks(any)).thenReturn(Stream.value([]));
// Test hangs...

// GOOD: Use StreamController for control
final controller = StreamController<List<TaskItem>>();
when(mockRepo.watchTasks(any)).thenAnswer((_) => controller.stream);

// Emit data when needed
controller.add([task1, task2]);
await tester.pumpAndSettle();
```

### 3. Mock Timestamps

```dart
// BAD: Timestamps change between test runs
final task = TaskItem((b) => b..dateAdded = DateTime.now());

// GOOD: Fixed timestamps
final fixedTime = DateTime(2024, 1, 1, 12, 0, 0);
final task = TaskItem((b) => b..dateAdded = fixedTime);
```

---

## Success Criteria

Before proceeding to migration:

1. ✅ All existing 101 tests still passing
2. ✅ 5+ critical path integration tests added and passing
3. ✅ 10+ screen widget tests added and passing
4. ✅ Test execution time < 15 seconds (fast feedback loop)
5. ✅ No flaky tests (tests pass consistently)
6. ✅ Coverage report shows >70% coverage
7. ✅ All critical user flows tested end-to-end

---

## Timeline Summary

| Phase | Tests | Priority | Days | Start After |
|-------|-------|----------|------|-------------|
| A: Integration | 5 tests | 🔴 MUST HAVE | 3-5 | Now |
| B: Screens | 15+ tests | 🔴 MUST HAVE | 5-7 | Phase A |
| C: Redux | 10+ tests | 🟡 OPTIONAL | 3-4 | Phase B |
| D: Repository | 5+ tests | 🟢 NICE TO HAVE | 2-3 | Phase C |

**Minimum before migration:** Phases A + B (8-12 days)
**Ideal:** All phases (13-19 days)

---

## Next Steps

1. **Review this plan** - Adjust priorities based on your timeline
2. **Install dependencies** - Add `fake_cloud_firestore` to dev_dependencies
3. **Create test infrastructure** - Set up helpers and mocks (Day 1)
4. **Start with Phase A** - Write one critical path test per day
5. **Update METRICS.md** - Track test count and coverage as you go

Once Phase A + B complete → Proceed to Redux migration with confidence!

---

## Questions?

Add any testing questions to `.claude/QUESTIONS.md` and we'll address them!
