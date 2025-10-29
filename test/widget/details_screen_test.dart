import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/anchor_date.dart';
import 'package:taskmaster/models/task_date_type.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/details_screen.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';

import '../mocks/mock_notification_helper.dart';
import '../mocks/mock_timezone_helper.dart';

/// Widget Test: DetailsScreen
///
/// Tests the DetailsScreen widget - displays full task details in read-only view.
///
/// DetailsScreen is a Redux-connected widget that:
/// - Displays all task fields (name, dates, project, context, priority, etc.)
/// - Shows formatted dates with "time ago" context
/// - Displays recurrence information for recurring tasks
/// - Has delete button in AppBar
/// - Has edit FAB that navigates to AddEditScreen
/// - Uses DelayedCheckbox for task completion
///
/// NOTE: Navigation and action dispatch are tested in integration tests.
/// These widget tests focus on component rendering and data display.
void main() {
  group('DetailsScreen Widget Tests', () {
    late MockTimezoneHelper mockTimezoneHelper;
    late Store<AppState> testStore;

    setUp(() {
      mockTimezoneHelper = MockTimezoneHelper();
    });

    // Helper to wrap widget with proper theme
    Widget wrapWithMaterialApp(Widget child, Store<AppState> store) {
      return MaterialApp(
        theme: ThemeData(
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.all(Colors.blue),
          ),
        ),
        home: StoreProvider<AppState>(
          store: store,
          child: child,
        ),
      );
    }

    testWidgets('Displays "Task Item Details" title in AppBar', (tester) async {
      // Setup: Task in store
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Test Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      // Verify: AppBar title
      expect(find.text('Task Item Details'), findsOneWidget);
    });

    testWidgets('Displays delete button in AppBar', (tester) async {
      // Setup: Task in store
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Test Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      // Verify: Delete button exists
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byTooltip('Delete Task Item'), findsOneWidget);
    });

    testWidgets('Displays edit FAB', (tester) async {
      // Setup: Task in store
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Test Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      // Verify: Edit FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byTooltip('Edit Task Item'), findsOneWidget);
    });

    testWidgets('Displays task name as headline', (tester) async {
      // Setup: Task with specific name
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'My Important Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      // Verify: Task name appears as headline
      expect(find.text('My Important Task'), findsOneWidget);

      // Verify: It's styled as headline
      final textWidget = tester.widget<Text>(
        find.text('My Important Task')
      );
      expect(textWidget.style, isNotNull);
    });

    testWidgets('Displays ReadOnlyTaskField widgets', (tester) async {
      // Setup: Minimal task
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Test Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Screen renders with ListView containing fields
      expect(find.byType(ListView), findsOneWidget);
      // ReadOnlyTaskField widgets should be present
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Displays task with all fields populated', (tester) async {
      // Setup: Task with all fields
      final now = DateTime.now().toUtc();
      final taskItem = TaskItem((b) => b
        ..docId = 'task-full-123'
        ..dateAdded = now
        ..name = 'Full Task Details'
        ..project = 'Career'
        ..context = 'Office'
        ..priority = 5
        ..gamePoints = 10
        ..duration = 30
        ..startDate = now.add(Duration(days: 1))
        ..targetDate = now.add(Duration(days: 7))
        ..urgentDate = now.add(Duration(days: 14))
        ..dueDate = now.add(Duration(days: 21))
        ..description = 'Detailed task notes here'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-full-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Main field values appear (without extensive scrolling)
      expect(find.text('Full Task Details'), findsOneWidget);
      expect(find.text('Career'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('Displays task with minimal fields', (tester) async {
      // Setup: Task with only required fields
      final taskItem = TaskItem((b) => b
        ..docId = 'task-minimal-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Minimal Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-minimal-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Task name appears and screen renders
      expect(find.text('Minimal Task'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Displays recurrence info for recurring task', (tester) async {
      // Setup: Recurring task
      final now = DateTime.now().toUtc();
      final anchorDate = AnchorDate((b) => b
        ..dateValue = now
        ..dateType = TaskDateTypes.target);

      final taskRecurrence = TaskRecurrence((b) => b
        ..docId = 'recur-123'
        ..personDocId = 'person-123'
        ..name = 'Recurring Task'
        ..recurNumber = 2
        ..recurUnit = 'weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..anchorDate = anchorDate.toBuilder()
        ..dateAdded = now);

      final taskItem = TaskItem((b) => b
        ..docId = 'task-recurring-123'
        ..dateAdded = now
        ..name = 'Recurring Task'
        ..recurrenceDocId = 'recur-123'
        ..recurNumber = 2
        ..recurUnit = 'weeks'
        ..recurWait = false
        ..recurIteration = 1
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..taskRecurrences = ListBuilder<TaskRecurrence>([taskRecurrence])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-recurring-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Screen renders with recurring task
      // Recurrence logic is tested in integration/unit tests
      expect(find.text('Recurring Task'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Displays "No recurrence" for non-recurring task', (tester) async {
      // Setup: Non-recurring task
      final taskItem = TaskItem((b) => b
        ..docId = 'task-nonrecur-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Non-Recurring Task'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-nonrecur-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: "No recurrence" message appears
      expect(find.text('No recurrence.'), findsOneWidget);
    });

    testWidgets('Displays DelayedCheckbox for task completion', (tester) async {
      // Setup: Active task
      final taskItem = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task with Checkbox'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: DelayedCheckbox appears (uses a GestureDetector with Card)
      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Completed task shows checked checkbox', (tester) async {
      // Setup: Completed task
      final taskItem = TaskItem((b) => b
        ..docId = 'task-completed-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Completed Task'
        ..completionDate = DateTime.now().toUtc()
        ..personDocId = 'person-123'
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-completed-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: DelayedCheckbox shows done_outline icon for completed tasks
      expect(find.byIcon(Icons.done_outline), findsOneWidget);
    });

    testWidgets('Displays formatted date fields', (tester) async {
      // Setup: Task with due date
      final dueDate = DateTime.utc(2025, 10, 13, 14, 30);
      final taskItem = TaskItem((b) => b
        ..docId = 'task-dated-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task with Dates'
        ..dueDate = dueDate
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([taskItem])
          ..timezoneHelper = mockTimezoneHelper),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          DetailsScreen(taskItemId: 'task-dated-123'),
          testStore,
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Screen renders with task
      expect(find.text('Task with Dates'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      // Date formatting is tested in integration tests; here we just verify rendering
    });
  });
}
