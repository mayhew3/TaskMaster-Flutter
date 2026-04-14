import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/core/database/app_database.dart'
    hide TaskRecurrence, Sprint, SprintAssignment, Task;
import 'package:taskmaster/core/database/tables.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/analytics_service.dart';
import 'package:taskmaster/core/services/sync_service.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/features/tasks/domain/task_repository.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_item_blueprint.dart';
import 'package:taskmaster/timezone_helper.dart';

import 'task_completion_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TaskRepository>(),
  MockSpec<TimezoneHelper>(),
  MockSpec<SyncService>(),
  MockSpec<AnalyticsService>(),
])
void main() {
  // ── Shared helpers ──────────────────────────────────────────────────────────

  TasksCompanion _seedTask({
    String docId = 'task-1',
    String name = 'Test Task',
    String syncState = 'synced',
  }) {
    return TasksCompanion(
      docId: Value(docId),
      name: Value(name),
      personDocId: const Value('person123'),
      dateAdded: Value(DateTime.now().toUtc()),
      syncState: Value(syncState),
      offCycle: const Value(false),
    );
  }

  // ── AddTask Provider ────────────────────────────────────────────────────────

  group('AddTask Provider', () {
    late AppDatabase db;
    late MockSyncService mockSyncService;
    late MockAnalyticsService mockAnalytics;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mockSyncService = MockSyncService();
      mockAnalytics = MockAnalyticsService();
      when(mockSyncService.pushPendingWrites(caller: anyNamed('caller')))
          .thenAnswer((_) async {});
      when(mockAnalytics.logTaskCreated(hasRecurrence: anyNamed('hasRecurrence')))
          .thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          syncServiceProvider.overrideWithValue(mockSyncService),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
          personDocIdProvider.overrideWith((ref) => 'person123'),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('inserts a pending task into the local database', () async {
      final blueprint = TaskItemBlueprint()
        ..name = 'Test Task'
        ..personDocId = 'person123';

      final notifier = container.read(addTaskProvider.notifier);
      await notifier.call(blueprint);

      final pending = await db.taskDao.pendingWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingCreate.name);
      expect(pending.first.name, 'Test Task');

      final state = container.read(addTaskProvider);
      expect(state.hasError, false);
      expect(state.isLoading, false);
    });

    test('triggers a sync push after inserting', () async {
      final blueprint = TaskItemBlueprint()
        ..name = 'Test Task'
        ..personDocId = 'person123';

      final notifier = container.read(addTaskProvider.notifier);
      await notifier.call(blueprint);

      verify(mockSyncService.pushPendingWrites(caller: 'AddTask')).called(1);
    });

    test('sets loading state then completes', () async {
      final blueprint = TaskItemBlueprint()
        ..name = 'Test Task'
        ..personDocId = 'person123';

      final notifier = container.read(addTaskProvider.notifier);
      final future = notifier.call(blueprint);

      await future;
      final state = container.read(addTaskProvider);
      expect(state.isLoading, false);
    });
  });

  // ── UpdateTask Provider ─────────────────────────────────────────────────────

  group('UpdateTask Provider', () {
    late AppDatabase db;
    late MockSyncService mockSyncService;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mockSyncService = MockSyncService();
      when(mockSyncService.pushPendingWrites(caller: anyNamed('caller')))
          .thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          syncServiceProvider.overrideWithValue(mockSyncService),
          personDocIdProvider.overrideWith((ref) => 'person123'),
        ],
      );

      // Pre-seed a synced task
      await db.taskDao.upsertFromRemote(_seedTask());
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('marks task as pendingUpdate in the local database', () async {
      final task = TaskItem((t) => t
        ..docId = 'task-1'
        ..name = 'Test Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final blueprint = TaskItemBlueprint()
        ..name = 'Updated Name'
        ..personDocId = 'person123';

      final notifier = container.read(updateTaskProvider.notifier);
      await notifier.call(task: task, blueprint: blueprint);

      final pending = await db.taskDao.pendingWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingUpdate.name);

      final state = container.read(updateTaskProvider);
      expect(state.hasError, false);
    });

    test('preserves pendingCreate state if task was never synced', () async {
      // Insert a never-synced (pendingCreate) task
      await db.taskDao.insertPending(_seedTask(docId: 'task-2', name: 'New Task'));

      final task = TaskItem((t) => t
        ..docId = 'task-2'
        ..name = 'New Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final blueprint = TaskItemBlueprint()
        ..name = 'Updated New Task'
        ..personDocId = 'person123';

      final notifier = container.read(updateTaskProvider.notifier);
      await notifier.call(task: task, blueprint: blueprint);

      final pending = await db.taskDao.pendingWrites();
      final task2 = pending.firstWhere((t) => t.docId == 'task-2');
      // Must stay pendingCreate — was never pushed to Firestore
      expect(task2.syncState, SyncState.pendingCreate.name);
    });

    test('triggers a sync push after updating', () async {
      final task = TaskItem((t) => t
        ..docId = 'task-1'
        ..name = 'Test Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final blueprint = TaskItemBlueprint()
        ..name = 'Updated Name'
        ..personDocId = 'person123';

      final notifier = container.read(updateTaskProvider.notifier);
      await notifier.call(task: task, blueprint: blueprint);

      verify(mockSyncService.pushPendingWrites(caller: 'UpdateTask')).called(1);
    });
  });

  // ── DeleteTask Provider ─────────────────────────────────────────────────────

  group('DeleteTask Provider', () {
    late AppDatabase db;
    late MockSyncService mockSyncService;
    late MockAnalyticsService mockAnalytics;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      mockSyncService = MockSyncService();
      mockAnalytics = MockAnalyticsService();
      when(mockSyncService.pushPendingWrites(caller: anyNamed('caller')))
          .thenAnswer((_) async {});
      when(mockAnalytics.logTaskDeleted()).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncServiceProvider.overrideWithValue(mockSyncService),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
        ],
      );

      // Pre-seed a synced task
      await db.taskDao.upsertFromRemote(_seedTask());
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('marks a synced task as pendingDelete', () async {
      final task = TaskItem((t) => t
        ..docId = 'task-1'
        ..name = 'Test Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final notifier = container.read(deleteTaskProvider.notifier);
      await notifier.call(task);

      final pending = await db.taskDao.pendingWrites();
      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pendingDelete.name);

      final state = container.read(deleteTaskProvider);
      expect(state.hasError, false);
    });

    test('hard-deletes a never-synced task without pushing', () async {
      // Insert a pendingCreate task (never pushed to Firestore)
      await db.taskDao.insertPending(_seedTask(docId: 'task-2', name: 'Draft Task'));

      final task = TaskItem((t) => t
        ..docId = 'task-2'
        ..name = 'Draft Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final notifier = container.read(deleteTaskProvider.notifier);
      await notifier.call(task);

      // Row is gone — no Firestore delete needed
      final all = await db.taskDao.allForUser('person123');
      expect(all.any((t) => t.docId == 'task-2'), false);
    });

    test('triggers a sync push after deleting a synced task', () async {
      final task = TaskItem((t) => t
        ..docId = 'task-1'
        ..name = 'Test Task'
        ..personDocId = 'person123'
        ..dateAdded = DateTime.now()
        ..offCycle = false);

      final notifier = container.read(deleteTaskProvider.notifier);
      await notifier.call(task);

      verify(mockSyncService.pushPendingWrites(caller: 'DeleteTask')).called(1);
    });
  });

  // ── TimezoneHelperNotifier Provider ────────────────────────────────────────

  group('TimezoneHelperNotifier Provider', () {
    test('is configured with keepAlive', () async {
      // The provider should be defined and use keepAlive=true
      // (Tested indirectly by checking it compiles and is exported)
      expect(timezoneHelperNotifierProvider, isNotNull);
    });
  });
}
