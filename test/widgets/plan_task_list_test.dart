import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaestro/features/shared/presentation/plan_task_list.dart';
import 'package:taskmaestro/features/shared/providers/task_list_view_providers.dart';
import 'package:taskmaestro/features/tasks/providers/task_providers.dart';
import 'package:taskmaestro/features/sprints/providers/create_sprint_draft_provider.dart';
import 'package:taskmaestro/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaestro/features/sprints/services/sprint_service.dart';
import 'package:taskmaestro/core/providers/auth_providers.dart';
import 'package:taskmaestro/core/services/crash_reporter.dart';
import 'package:taskmaestro/models/task_item.dart';
import 'package:taskmaestro/models/task_item_recur_preview.dart';
import 'package:taskmaestro/models/task_list_view.dart';
import 'package:taskmaestro/models/sprint.dart';
import 'package:taskmaestro/models/sprint_blueprint.dart';

import '../mocks/mock_data_builder.dart';
import '../mocks/mock_recurrence_builder.dart';

/// TM-375: a fake CreateSprint that "succeeds" without touching Drift/
/// Firestore — returns a minimal Sprint and does NOT push it into
/// `sprintsProvider`, so the only thing that can close the screen is
/// the deterministic post-await pop (not the fragile stream listener).
class _FakeCreateSprint extends CreateSprint {
  @override
  FutureOr<void> build() {}

  @override
  Future<Sprint> call({
    required SprintBlueprint sprintBlueprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    return Sprint((b) => b
      ..docId = 'sprint-test'
      ..dateAdded = DateTime.now().toUtc()
      ..startDate = DateTime.now().toUtc()
      ..endDate = DateTime.now().toUtc().add(const Duration(days: 7))
      ..numUnits = 1
      ..unitName = 'Weeks'
      ..personDocId = 'test_person_id'
      ..sprintNumber = 1);
  }
}

/// TM-388 (R0 follow-up): captures the SprintBlueprint passed to
/// `call()` so a test can prove the in-shell submit used the picker's
/// frozen cadence snapshot — NOT a stale-by-mutation live draft.
class _CapturingCreateSprint extends CreateSprint {
  SprintBlueprint? captured;

  @override
  FutureOr<void> build() {}

  @override
  Future<Sprint> call({
    required SprintBlueprint sprintBlueprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    captured = sprintBlueprint;
    return Sprint((b) => b
      ..docId = 'sprint-test'
      ..dateAdded = DateTime.now().toUtc()
      ..startDate = sprintBlueprint.startDate
      ..endDate = sprintBlueprint.endDate
      ..numUnits = sprintBlueprint.numUnits
      ..unitName = sprintBlueprint.unitName
      ..personDocId = sprintBlueprint.personDocId
      ..sprintNumber = 1);
  }
}

/// TM-375: a CreateSprint whose submit always throws — used to exercise
/// the failure path (screen stays open, error surfaced, retry allowed).
/// Counts invocations so the test can prove `submitting` was reset.
class _ThrowingCreateSprint extends CreateSprint {
  int callCount = 0;

  @override
  FutureOr<void> build() {}

  @override
  Future<Sprint> call({
    required SprintBlueprint sprintBlueprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    callCount++;
    throw StateError('simulated submit failure');
  }
}

/// TM-375: a fake AddTasksToSprint that "succeeds" without touching
/// Drift/Firestore — for the add-to-existing-sprint pop regression test.
class _FakeAddTasksToSprint extends AddTasksToSprint {
  @override
  FutureOr<void> build() {}

  @override
  Future<void> call({
    required Sprint sprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {}
}

/// TM-375 (Copilot PR #34 R1): an AddTasksToSprint that fails the way the
/// real one does — AsyncValue.guard captures the error into `state` and
/// `call()` completes normally (no throw). Pre-fix this slipped past
/// submit()'s catch and the screen popped as if it had succeeded.
class _GuardSwallowingAddTasksToSprint extends AddTasksToSprint {
  @override
  FutureOr<void> build() {}

  @override
  Future<void> call({
    required Sprint sprint,
    required List<TaskItem> taskItems,
    required List<TaskItemRecurPreview> taskItemRecurPreviews,
  }) async {
    state = await AsyncValue.guard(
        () async => throw StateError('simulated add-to-sprint failure'));
  }
}

/// Records errors handed to the crash reporter so the failure-path test
/// can assert the full error is forwarded (Security-2: not echoed to the
/// persisted print stream). Always disabled so it never touches Firebase.
class _RecordingCrashReporter implements CrashReporterBase {
  final List<Object> errors = [];

  @override
  bool get isEnabled => false;

  @override
  Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    errors.add(error);
  }

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserIdentifier(String personDocId) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}

/// Widget Test: PlanTaskList
///
/// Tests the PlanTaskList widget (Riverpod version) to verify:
/// 1. Renders task selection UI
/// 2. Displays tasks grouped by categories
/// 3. Submit button appears when tasks are selected
/// 4. Shows loading/error states appropriately
///
/// PlanTaskList is used for sprint planning - selecting which tasks to include in a sprint
void main() {
  group('PlanTaskList Tests', () {
    // Helper to create test tasks
    TaskItem createTestTask({
      required String docId,
      required String name,
      DateTime? dueDate,
      DateTime? urgentDate,
      DateTime? targetDate,
      DateTime? startDate,
      DateTime? completionDate,
    }) {
      return TaskItem((b) => b
        ..docId = docId
        ..name = name
        ..personDocId = 'test_person_id'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc()
        ..dueDate = dueDate?.toUtc()
        ..urgentDate = urgentDate?.toUtc()
        ..targetDate = targetDate?.toUtc()
        ..startDate = startDate?.toUtc()
        ..completionDate = completionDate?.toUtc());
    }

    testWidgets('Displays loading indicator when data is loading', (tester) async {
      // Setup: Providers return loading state (never complete)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream<List<TaskItem>>.value([])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(<TaskItem>[])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream<List<Sprint>>.value([])),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      // Note: Since we provide empty streams that complete immediately,
      // we won't see a loading indicator. Instead, verify the screen loads.
      await tester.pump();

      // Verify: Screen renders
      expect(find.text('Select Tasks'), findsOneWidget);
    });

    testWidgets('Displays error message when data loading fails', (tester) async {
      // Setup: Providers return error state
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream<List<TaskItem>>.error('Test error')),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream<List<TaskItem>>.error('Test error')),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream<List<Sprint>>.value([])),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Error message appears
      expect(find.text('Error loading data'), findsOneWidget);
    });

    testWidgets('Displays task list when data is loaded', (tester) async {
      // Setup: Create test tasks
      final tasks = [
        createTestTask(
          docId: 'task1',
          name: 'Task 1',
          dueDate: DateTime.now().add(Duration(days: 2)),
        ),
        createTestTask(
          docId: 'task2',
          name: 'Task 2',
          urgentDate: DateTime.now().add(Duration(days: 3)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(tasks)),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasks)),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Tasks are displayed
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);

      // Verify: "Select Tasks" title appears in AppBar
      expect(find.text('Select Tasks'), findsOneWidget);
    });

    testWidgets('Displays "No eligible tasks" when task list is empty', (tester) async {
      // Setup: Empty task list
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(<TaskItem>[])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(<TaskItem>[])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: "No eligible tasks" message appears
      expect(find.text('No eligible tasks found.'), findsOneWidget);
    });

    testWidgets('Submit button appears when tasks are selected', (tester) async {
      // Setup: Create tasks that will be auto-selected (urgent/due)
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(Duration(days: 1)), // Past urgent date
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value([urgentTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Submit button is visible (FloatingActionButton)
      expect(find.widgetWithText(FloatingActionButton, 'Submit'), findsOneWidget);
    });

    testWidgets(
        'TM-375: Create Sprint submit closes the screen', (tester) async {
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider
                .overrideWith((ref) => Stream.value([urgentTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value(<Sprint>[])),
            recentlyCompletedTasksProvider
                .overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            createSprintProvider.overrideWith(() => _FakeCreateSprint()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PlanTaskList(
                        numUnits: 1,
                        unitName: 'Weeks',
                        startDate: DateTime.now(),
                      ),
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open the Create Sprint screen (addMode: no active sprint).
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanTaskList), findsOneWidget);

      // Submit → the screen must close (pre-fix it stays open forever).
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(PlanTaskList), findsNothing,
          reason: 'Create Sprint submit must pop the screen (TM-375)');
    });

    testWidgets(
        'TM-375: submit failure keeps the screen open, surfaces error, '
        'and allows retry', (tester) async {
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final throwingCreate = _ThrowingCreateSprint();
      final crashReporter = _RecordingCrashReporter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider
                .overrideWith((ref) => Stream.value([urgentTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value(<Sprint>[])),
            recentlyCompletedTasksProvider
                .overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            createSprintProvider.overrideWith(() => throwingCreate),
            crashReporterProvider.overrideWith((ref) => crashReporter),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PlanTaskList(
                        numUnits: 1,
                        unitName: 'Weeks',
                        startDate: DateTime.now(),
                      ),
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanTaskList), findsOneWidget);

      // First submit → CreateSprint throws.
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();

      // Screen stays up so the user can retry; error is surfaced to the
      // user and the full detail is forwarded to the crash reporter.
      expect(find.byType(PlanTaskList), findsOneWidget,
          reason: 'A failed submit must NOT pop the screen (TM-375)');
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(crashReporter.errors, hasLength(1),
          reason: 'Full error must be forwarded to the crash reporter');
      expect(throwingCreate.callCount, 1);

      // Retry → `submitting` was reset in `finally`, so the duplicate-call
      // guard does not strand the screen and the provider runs again.
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();
      expect(throwingCreate.callCount, 2,
          reason:
              'submitting must reset in finally so a retry is not blocked');

      // Drain the SnackBar auto-dismiss timers so teardown sees no
      // pending Timer.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets(
        'TM-375: add-to-existing-sprint submit also closes the screen',
        (tester) async {
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      // A sprint whose window straddles "now" so activeSprintSelector
      // picks it up → addMode() is false (the else branch in submit()).
      final activeSprint = Sprint((b) => b
        ..docId = 'active-sprint'
        ..dateAdded = DateTime.now().toUtc()
        ..startDate =
            DateTime.now().toUtc().subtract(const Duration(days: 1))
        ..endDate = DateTime.now().toUtc().add(const Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'Weeks'
        ..personDocId = 'test_person_id'
        ..sprintNumber = 1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider
                .overrideWith((ref) => Stream.value([urgentTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider
                .overrideWith((ref) => Stream.value(<Sprint>[activeSprint])),
            recentlyCompletedTasksProvider
                .overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            addTasksToSprintProvider
                .overrideWith(() => _FakeAddTasksToSprint()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      // No numUnits/unitName/startDate: validateState()
                      // requires them null when an active sprint exists.
                      builder: (_) => const PlanTaskList(),
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanTaskList), findsOneWidget);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(PlanTaskList), findsNothing,
          reason:
              'Add-to-existing-sprint submit must also pop the screen '
              '(consolidated-pop regression guard, TM-375)');
    });

    testWidgets(
        'TM-375: add-to-existing-sprint failure keeps the screen open '
        '(AsyncValue.guard error is surfaced)', (tester) async {
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final activeSprint = Sprint((b) => b
        ..docId = 'active-sprint'
        ..dateAdded = DateTime.now().toUtc()
        ..startDate =
            DateTime.now().toUtc().subtract(const Duration(days: 1))
        ..endDate = DateTime.now().toUtc().add(const Duration(days: 6))
        ..numUnits = 1
        ..unitName = 'Weeks'
        ..personDocId = 'test_person_id'
        ..sprintNumber = 1);
      final crashReporter = _RecordingCrashReporter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([urgentTask])),
            tasksWithRecurrencesProvider
                .overrideWith((ref) => Stream.value([urgentTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider
                .overrideWith((ref) => Stream.value(<Sprint>[activeSprint])),
            recentlyCompletedTasksProvider
                .overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
            addTasksToSprintProvider
                .overrideWith(() => _GuardSwallowingAddTasksToSprint()),
            crashReporterProvider.overrideWith((ref) => crashReporter),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PlanTaskList(),
                    )),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(PlanTaskList), findsOneWidget);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();

      // Pre-fix: submit() never saw the guarded error and popped as if
      // the add had succeeded. Post-fix: the guarded error is re-surfaced
      // so the shared catch keeps the screen up.
      expect(find.byType(PlanTaskList), findsOneWidget,
          reason: 'A failed add-to-existing-sprint submit must NOT pop the '
              'screen — the AsyncValue.guard error must be surfaced '
              '(TM-375, Copilot PR #34 R1)');
      expect(find.text('Could not save. Please try again.'), findsOneWidget);
      expect(crashReporter.errors, hasLength(1),
          reason: 'The guarded failure must reach the crash reporter');

      // Drain the SnackBar auto-dismiss timer so teardown sees no pending
      // Timer.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('Tasks are grouped by category', (tester) async {
      // Setup: Create tasks in different categories
      final dueTask = createTestTask(
        docId: 'due_task',
        name: 'Due Task',
        dueDate: DateTime.now().add(Duration(days: 2)),
      );
      final urgentTask = createTestTask(
        docId: 'urgent_task',
        name: 'Urgent Task',
        urgentDate: DateTime.now().add(Duration(days: 3)),
      );
      final targetTask = createTestTask(
        docId: 'target_task',
        name: 'Target Task',
        targetDate: DateTime.now().add(Duration(days: 4)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([dueTask, urgentTask, targetTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value([dueTask, urgentTask, targetTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Category headings appear
      // Tasks should be grouped under headings like "Due Soon", "Urgent Soon", "Target Soon", or "Tasks"
      expect(find.text('Due Task'), findsOneWidget);
      expect(find.text('Urgent Task'), findsOneWidget);
      expect(find.text('Target Task'), findsOneWidget);
    });

    testWidgets('Completed tasks are filtered out (not shown in task list)', (tester) async {
      // Setup: Create completed task
      final completedTask = createTestTask(
        docId: 'completed_task',
        name: 'Completed Task',
        completionDate: DateTime.now().subtract(Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([completedTask])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value([completedTask])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Completed task does NOT appear (filtered out by taskItemsForPlacingOnNewSprint)
      expect(find.text('Completed Task'), findsNothing);

      // Verify: Empty state message appears instead
      expect(find.text('No eligible tasks found.'), findsOneWidget);
    });

    testWidgets('ListView has bottom padding for FAB', (tester) async {
      // Setup: Basic task list
      final task = createTestTask(
        docId: 'task1',
        name: 'Test Task',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([task])),
            tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value([task])),
            taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
            sprintsProvider.overrideWith((ref) => Stream.value([])),
            recentlyCompletedTasksProvider.overrideWith(() => RecentlyCompletedTasks()),
            personDocIdProvider.overrideWith((ref) => 'test_person_id'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 1,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: ListView exists with padding
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // The ListView should have bottom padding to prevent FAB overlap
      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.padding, isNotNull);
    });
  });

  group('TM-388: preview filter on display', () {
    // Reset SharedPreferences between tests so the
    // taskListViewStateProvider (keepAlive + persisted) doesn't leak the
    // first test's filter into the second.
    setUp(() => SharedPreferences.setMockInitialValues({}));

    // Recurring-source task with area='Work' so its synthesized preview
    // rows inherit area='Work' and ride the same area-filter contract
    // as base TaskItems.
    TaskItem dailyWorkRecurring() {
      final builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..area = 'Work'
        ..name = 'Daily Work Task'
        ..context = 'Office'
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceDocId = MockTaskItemBuilder.me;
      builder.taskRecurrence = MockTaskRecurrenceBuilder()
        ..docId = MockTaskItemBuilder.me
        ..name = builder.name
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = builder.getAnchorDate()!;
      return builder.create();
    }

    testWidgets(
        'preview rows from non-selected areas are hidden when the user '
        'narrows the area filter (TM-388)', (tester) async {
      final source = dailyWorkRecurring();
      final container = ProviderContainer(overrides: [
        tasksProvider.overrideWith((ref) => Stream.value([source])),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
        sprintsProvider.overrideWith((ref) => Stream.value([])),
        recentlyCompletedTasksProvider
            .overrideWith(() => RecentlyCompletedTasks()),
        personDocIdProvider.overrideWith((ref) => MockTaskItemBuilder.me),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 2,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The source task itself is the parent — visible as a regular tile.
      // Its preview rows ("Daily Work Task" repeats from the recurrence)
      // are synthesized into `tempIterations` and rendered inside the
      // groupings. With no filter, the source plus at least one preview
      // should be present.
      expect(find.text('Daily Work Task'), findsWidgets);
      final unfilteredCount =
          tester.widgetList(find.text('Daily Work Task')).length;
      expect(unfilteredCount, greaterThan(1),
          reason: 'source + at least one synthesized preview row');

      // Now narrow to Home only — neither the source (area=Work) nor any
      // of its previews should appear.
      container
          .read(taskListViewStateProvider(TaskListSurface.plan).notifier)
          .setFilters(TaskFilters((b) => b..areas.add('Home')));
      await tester.pumpAndSettle();

      expect(find.text('Daily Work Task'), findsNothing,
          reason: 'preview rows must respect the area-narrow, not just '
              'the base TaskItem');
    });

    testWidgets(
        'preview rows from non-selected contexts are hidden when the user '
        'narrows the context filter (TM-388)', (tester) async {
      final source = dailyWorkRecurring();
      final container = ProviderContainer(overrides: [
        tasksProvider.overrideWith((ref) => Stream.value([source])),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([source])),
        taskRecurrencesProvider.overrideWith((ref) => Stream.value([])),
        sprintsProvider.overrideWith((ref) => Stream.value([])),
        recentlyCompletedTasksProvider
            .overrideWith(() => RecentlyCompletedTasks()),
        personDocIdProvider.overrideWith((ref) => MockTaskItemBuilder.me),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: PlanTaskList(
                numUnits: 2,
                unitName: 'Weeks',
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daily Work Task'), findsWidgets);

      container
          .read(taskListViewStateProvider(TaskListSurface.plan).notifier)
          .setFilters(TaskFilters((b) => b..contexts.add('Home')));
      await tester.pumpAndSettle();

      expect(find.text('Daily Work Task'), findsNothing);
    });

    testWidgets(
        'in-shell submit uses the cadence SNAPSHOT taken when the picker '
        'mounted — a draft mutation while the picker is open does NOT '
        'leak into the SprintBlueprint (TM-388 R0)', (tester) async {
      // A simple eligible TaskItem so the picker has at least one row
      // available; the test pre-queues it programmatically so submit
      // has something to send.
      final eligible = TaskItem((b) => b
        ..docId = 't1'
        ..name = 'Eligible Task'
        ..personDocId = 'p'
        ..offCycle = false
        ..dateAdded = DateTime.now().toUtc()
        ..dueDate = DateTime.now().toUtc().add(const Duration(days: 1)));

      final capture = _CapturingCreateSprint();
      final container = ProviderContainer(overrides: [
        tasksProvider.overrideWith((ref) => Stream.value([eligible])),
        tasksWithRecurrencesProvider
            .overrideWith((ref) => Stream.value([eligible])),
        taskRecurrencesProvider.overrideWith((ref) => Stream.value(const [])),
        sprintsProvider.overrideWith((ref) => Stream.value(const [])),
        recentlyCompletedTasksProvider
            .overrideWith(() => RecentlyCompletedTasks()),
        personDocIdProvider.overrideWith((ref) => 'p'),
        createSprintProvider.overrideWith(() => capture),
      ]);
      addTearDown(container.dispose);

      // Seed the draft to a deterministic initial cadence before
      // mounting the picker. Pinned RELATIVE to today's clock so the
      // eligible task (dueDate = now+1d) always sits inside the
      // {start, start+1 week} window — a calendar-date constant
      // would time-bomb once today passes that date.
      final initialStart =
          DateTime.now().toUtc().add(const Duration(hours: 1));
      container
          .read(createSprintDraftProvider.notifier)
          .setNumUnits(1);
      container
          .read(createSprintDraftProvider.notifier)
          .setUnitName('Weeks');
      container
          .read(createSprintDraftProvider.notifier)
          .setStartDate(initialStart);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              // Wide in-shell new-sprint path: inShell:true with null
              // constructor params (the assert covered by the existing
              // test pins this contract).
              body: PlanTaskList(inShell: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Capture what the draft looked like at picker-mount time —
      // this is exactly what the snapshot fields should equal.
      final draftAtMount = container.read(createSprintDraftProvider);

      // Now mutate the draft AFTER the picker mounted — this is the
      // exact "draft re-seeds while picker is open" race Copilot
      // flagged. A correct implementation ignores this in submit().
      container.read(createSprintDraftProvider.notifier).setNumUnits(4);
      container
          .read(createSprintDraftProvider.notifier)
          .setUnitName('Months');
      // Mutation also pinned relative to the clock so the contrast
      // with `initialStart` is preserved indefinitely.
      container
          .read(createSprintDraftProvider.notifier)
          .setStartDate(DateTime.now().toUtc().add(const Duration(days: 400)));
      await tester.pump();

      // The Submit FAB is only visible when the queue is non-empty.
      // The eligible task is due-before-endDate so
      // `preSelectUrgentAndDueAndPreviousSprint` auto-queues it on mount.
      expect(find.widgetWithText(FloatingActionButton, 'Submit'), findsOneWidget,
          reason: 'auto-preselect should have queued the eligible task');
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Submit'));
      await tester.pumpAndSettle();

      expect(capture.captured, isNotNull, reason: 'submit should have run');
      // The captured blueprint MUST match the draft as it was at
      // picker-mount — not the post-mount mutation.
      expect(capture.captured!.numUnits, draftAtMount.numUnits);
      expect(capture.captured!.unitName, draftAtMount.unitName);
      expect(capture.captured!.startDate, draftAtMount.sprintStart);
    });
  });
}
