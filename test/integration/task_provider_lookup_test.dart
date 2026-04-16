import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/core/database/app_database.dart'
    hide Task, TaskRecurrence, Sprint, SprintAssignment;
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:drift/drift.dart' show Value;

/// Regression tests for TM-341: task(taskId) lookup fallbacks.
///
/// Verifies that the provider finds a task even when it is:
///   1. In recentlyCompletedTasksProvider but not in incomplete/batch lists.
///   2. In the local Drift DB (via taskFromDbProvider) but absent from all
///      in-memory providers — covers the force-quit + restart scenario.
void main() {
  final now = DateTime.utc(2026, 4, 15);
  const personDocId = 'test-person';

  TaskItem _makeTask(String docId, {DateTime? completionDate}) {
    return TaskItem((b) => b
      ..docId = docId
      ..name = 'Task $docId'
      ..personDocId = personDocId
      ..dateAdded = now
      ..completionDate = completionDate
      ..retired = null
      ..offCycle = false
      ..pendingCompletion = false);
  }

  /// Creates a container with the minimum overrides needed for task(taskId).
  /// [db] defaults to an empty in-memory database if not supplied.
  ProviderContainer _makeContainer({
    AppDatabase? db,
    List<Override> extra = const [],
  }) {
    final testDb = db ?? AppDatabase.forTesting(NativeDatabase.memory());
    return ProviderContainer(
      overrides: [
        personDocIdProvider.overrideWith((ref) => personDocId),
        databaseProvider.overrideWith((ref) {
          if (db == null) ref.onDispose(testDb.close);
          return testDb;
        }),
        // Always override the incomplete-task stream so tests don't need Firestore
        tasksWithRecurrencesProvider.overrideWith(
          (ref) => Stream.value(<TaskItem>[]),
        ),
        ...extra,
      ],
    );
  }

  group('task(taskId) — recentlyCompleted fallback (TM-341 Cause 1)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    /// The bug scenario: user completes a task in the current session.
    /// The task is no longer in the incomplete Drift stream, hasn't appeared in
    /// the older batches yet, but IS in recentlyCompletedTasksProvider.
    test('returns task from recentlyCompleted when not in incomplete or batches',
        () async {
      final completedTask = _makeTask('task-1', completionDate: now);
      final container = _makeContainer(db: db);
      addTearDown(container.dispose);

      // Add task to recentlyCompleted (as completeTask service does)
      container.read(recentlyCompletedTasksProvider.notifier).add(completedTask);

      // Wait for stream provider to settle
      await container.read(tasksWithRecurrencesProvider.future);

      final result = container.read(taskProvider('task-1'));
      expect(result, isNotNull,
          reason: 'task(taskId) must find a recently-completed task (TM-341 Cause 1)');
      expect(result!.docId, 'task-1');
    });

    test('returns null for a task that is not found anywhere', () async {
      final container = _makeContainer(db: db);
      addTearDown(container.dispose);

      // Establish subscription to bring all dependencies (including taskFromDb)
      // out of AsyncLoading before asserting null.
      final sub = container.listen<TaskItem?>(
        taskProvider('nonexistent'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Wait for the Drift stream to emit null for the nonexistent ID
      await container.read(taskFromDbProvider('nonexistent').future);

      final result = container.read(taskProvider('nonexistent'));
      expect(result, isNull);
    });
  });

  group('task(taskId) — Drift fallback (TM-341 Cause 3)', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    /// The force-quit scenario: task is in Drift with completionDate set, but
    /// recentlyCompleted is empty (cleared on restart) and batches haven't loaded.
    test(
        'returns task from Drift when absent from all in-memory providers',
        () async {
      // Insert a completed task into the test Drift DB
      await db.taskDao.upsertFromRemote(TasksCompanion(
        docId: const Value('task-drift'),
        name: const Value('Drift task'),
        personDocId: const Value(personDocId),
        dateAdded: Value(now),
        completionDate: Value(now),
        syncState: const Value('synced'),
        retired: const Value(null),
        offCycle: const Value(false),
      ));

      final container = _makeContainer(db: db);
      addTearDown(container.dispose);

      // recentlyCompleted is empty, batches are empty — only Drift has the task.

      // Listen to taskProvider to establish the subscription (which internally
      // watches taskFromDbProvider). Without an active subscription, the auto-
      // dispose stream provider would be GC'd between read calls.
      final sub = container.listen<TaskItem?>(
        taskProvider('task-drift'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Wait for the Drift stream to emit and propagate to taskProvider
      await container.read(taskFromDbProvider('task-drift').future);

      // Now taskFromDbProvider has a value; taskProvider recomputed via the watch
      final result = container.read(taskProvider('task-drift'));
      expect(result, isNotNull,
          reason: 'task(taskId) must find a completed task in Drift (TM-341 Cause 3)');
      expect(result!.docId, 'task-drift');
      expect(result.completionDate, isNotNull);
    });
  });
}
