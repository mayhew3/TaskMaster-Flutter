import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/stats_counter.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';

import '../mocks/mock_notification_helper.dart';

/// Widget Test: StatsCounter (Redux-Connected Widget)
///
/// This demonstrates how to test widgets that use Redux/StoreConnector.
///
/// Testing Strategy for Redux Widgets:
/// 1. Create a test Redux store with specific data
/// 2. Wrap the widget in StoreProvider with the test store
/// 3. Pump the widget tree
/// 4. Verify the widget renders correct output based on store state
///
/// This tests BOTH:
/// - The Redux connection (StoreConnector + ViewModel)
/// - The widget rendering logic
///
/// StatsCounter displays:
/// - Number of completed tasks (tasks with completionDate != null)
/// - Number of active tasks (tasks with completionDate == null)
void main() {
  group('StatsCounter Redux Widget Tests', () {
    /// Helper to create a test store with tasks
    Store<AppState> createTestStore({
      List<TaskItem>? tasks,
    }) {
      return Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder(tasks ?? [])
          ..personDocId = 'test-person-123'
          ..isLoading = false
          ..tasksLoading = false),
      );
    }

    /// Helper to pump widget with Redux store
    Future<void> pumpStatsCounterWithStore(
      WidgetTester tester,
      Store<AppState> store,
    ) async {
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: StatsCounter(),
          ),
        ),
      );
      // Wait for StoreConnector to build
      await tester.pump();
    }

    testWidgets('Displays zero for both counts when no tasks exist', (tester) async {
      // Setup: Create store with no tasks
      final store = createTestStore(tasks: []);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: Both counts are 0
      expect(find.text('Completed Tasks'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2)); // 0 completed, 0 active
      expect(find.text('Active Tasks'), findsOneWidget);
    });

    testWidgets('Displays correct count for only active tasks', (tester) async {
      // Setup: Create 3 active tasks (no completion date)
      final now = DateTime.now().toUtc();
      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = now
          ..name = 'Active Task 1'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-2'
          ..dateAdded = now
          ..name = 'Active Task 2'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-3'
          ..dateAdded = now
          ..name = 'Active Task 3'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      final store = createTestStore(tasks: tasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: 0 completed, 3 active
      expect(find.text('Completed Tasks'), findsOneWidget);
      expect(find.text('Active Tasks'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // 0 completed
      expect(find.text('3'), findsOneWidget); // 3 active
    });

    testWidgets('Displays correct count for only completed tasks', (tester) async {
      // Setup: Create 5 completed tasks
      final now = DateTime.now().toUtc();
      final tasks = List.generate(
        5,
        (index) => TaskItem((b) => b
          ..docId = 'task-$index'
          ..dateAdded = now
          ..name = 'Completed Task $index'
          ..personDocId = 'test-person-123'
          ..completionDate = now // Tasks are completed
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      );

      final store = createTestStore(tasks: tasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: 5 completed, 0 active
      expect(find.text('5'), findsOneWidget); // 5 completed
      expect(find.text('0'), findsOneWidget); // 0 active
    });

    testWidgets('Displays correct counts for mixed active and completed tasks', (tester) async {
      // Setup: 7 active tasks + 3 completed tasks = 10 total
      final now = DateTime.now().toUtc();

      final activeTasks = List.generate(
        7,
        (index) => TaskItem((b) => b
          ..docId = 'active-$index'
          ..dateAdded = now
          ..name = 'Active Task $index'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      );

      final completedTasks = List.generate(
        3,
        (index) => TaskItem((b) => b
          ..docId = 'completed-$index'
          ..dateAdded = now
          ..name = 'Completed Task $index'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      );

      final allTasks = [...activeTasks, ...completedTasks];
      final store = createTestStore(tasks: allTasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: 3 completed, 7 active
      expect(find.text('3'), findsOneWidget); // 3 completed
      expect(find.text('7'), findsOneWidget); // 7 active
    });

    testWidgets('Retired tasks are still counted as active by selector', (tester) async {
      // Setup: 2 active, 1 retired (retired still counts if no completionDate)
      // Note: The selectors only check completionDate, not retired status
      final now = DateTime.now().toUtc();

      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = now
          ..name = 'Active Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-2'
          ..dateAdded = now
          ..name = 'Another Active Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        TaskItem((b) => b
          ..docId = 'task-3'
          ..dateAdded = now
          ..name = 'Retired Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = 'archived'
          ..retiredDate = now
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      final store = createTestStore(tasks: tasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: 3 active (selectors don't filter retired tasks)
      expect(find.text('0'), findsOneWidget); // 0 completed
      expect(find.text('3'), findsOneWidget); // 3 active (includes retired)
    });

    testWidgets('Widget has correct structure with AppBar and body', (tester) async {
      // Setup: Store with some tasks
      final now = DateTime.now().toUtc();
      final tasks = [
        TaskItem((b) => b
          ..docId = 'task-1'
          ..dateAdded = now
          ..name = 'Task'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      ];

      final store = createTestStore(tasks: tasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: Widget structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Stats'), findsWidgets); // AppBar title (may appear in drawer too)
      expect(find.byType(Column), findsWidgets); // Body layout (multiple columns)
    });

    testWidgets('Displays large numbers correctly', (tester) async {
      // Setup: Store with many tasks
      final now = DateTime.now().toUtc();

      final activeTasks = List.generate(
        42,
        (index) => TaskItem((b) => b
          ..docId = 'active-$index'
          ..dateAdded = now
          ..name = 'Active Task $index'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      );

      final completedTasks = List.generate(
        158,
        (index) => TaskItem((b) => b
          ..docId = 'completed-$index'
          ..dateAdded = now
          ..name = 'Completed Task $index'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
      );

      final allTasks = [...activeTasks, ...completedTasks];
      final store = createTestStore(tasks: allTasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: Large numbers display correctly
      expect(find.text('158'), findsOneWidget); // 158 completed
      expect(find.text('42'), findsOneWidget); // 42 active
    });

    testWidgets('ViewModel selectors correctly filter tasks', (tester) async {
      // Setup: Complex mix of tasks with different states
      final now = DateTime.now().toUtc();

      final tasks = [
        // Active task
        TaskItem((b) => b
          ..docId = 'task-active'
          ..dateAdded = now
          ..name = 'Active'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Completed task
        TaskItem((b) => b
          ..docId = 'task-completed'
          ..dateAdded = now
          ..name = 'Completed'
          ..personDocId = 'test-person-123'
          ..completionDate = now
          ..retired = null
          ..offCycle = false
          ..pendingCompletion = false),
        // Retired task (should not count)
        TaskItem((b) => b
          ..docId = 'task-retired'
          ..dateAdded = now
          ..name = 'Retired'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = 'archived'
          ..offCycle = false
          ..pendingCompletion = false),
        // OffCycle but active (should count as active)
        TaskItem((b) => b
          ..docId = 'task-offcycle'
          ..dateAdded = now
          ..name = 'Off Cycle'
          ..personDocId = 'test-person-123'
          ..completionDate = null
          ..retired = null
          ..offCycle = true
          ..pendingCompletion = false),
      ];

      final store = createTestStore(tasks: tasks);

      // Build: Pump widget with store
      await pumpStatsCounterWithStore(tester, store);

      // Verify: Correct filtering
      // 1 completed, 3 active (offCycle and retired both count - selector only checks completionDate)
      expect(find.text('1'), findsOneWidget); // 1 completed
      expect(find.text('3'), findsOneWidget); // 3 active (includes offCycle + retired)
    });
  });
}
