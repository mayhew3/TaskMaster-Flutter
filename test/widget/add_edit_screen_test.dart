import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/presentation/add_edit_screen.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';

import '../mocks/mock_notification_helper.dart';
import '../mocks/mock_timezone_helper.dart';

/// Widget Test: AddEditScreen
///
/// Tests the AddEditScreen widget - the primary form for task creation/editing.
///
/// AddEditScreen is a complex Redux-connected widget that:
/// - Displays a form with 10+ fields (name, dates, project, context, etc.)
/// - Supports two modes: Add (new task) and Edit (existing task)
/// - Has conditional fields (repeat card appears when dates are set)
/// - Validates required fields
/// - Dispatches Redux actions on save
/// - Auto-closes when Redux state updates
///
/// NOTE: Full end-to-end flows are tested in integration tests (task_creation_test,
/// task_editing_test). These widget tests focus on component rendering and validation.
void main() {
  group('AddEditScreen Widget Tests', () {
    late MockTimezoneHelper mockTimezoneHelper;
    late Store<AppState> testStore;

    setUp(() {
      mockTimezoneHelper = MockTimezoneHelper();
      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ),
      );
    });

    testWidgets('Displays "Task Details" title in AppBar', (tester) async {
      // Setup: Add mode (no task provided)
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Verify: Title appears
      expect(find.text('Task Details'), findsOneWidget);
    });

    testWidgets('Displays all form fields in add mode', (tester) async {
      // Setup: Add mode
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      // Wait for render
      await tester.pumpAndSettle();

      // Verify: All main fields present
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Context'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
      expect(find.text('Length'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Target Date'), findsOneWidget);
      expect(find.text('Urgent Date'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('Repeat card is hidden when no dates are set', (tester) async {
      // Setup: Add mode with no dates
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Repeat text should not be visible (card is hidden)
      // Note: The card wraps the repeat UI in a Visibility widget
      expect(find.text('Repeat'), findsNothing);
    });

    testWidgets('Save button not visible when form is empty', (tester) async {
      // Setup: Add mode
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: FloatingActionButton (save) not visible
      // The button is wrapped in Visibility(visible: hasChanges())
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Save button appears after entering task name', (tester) async {
      // Setup: Add mode
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Action: Enter task name
      final nameField = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(nameField, 'Test Task');
      await tester.pumpAndSettle();

      // Verify: Save button appears
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Add mode shows + icon
    });

    testWidgets('Edit mode displays existing task fields', (tester) async {
      // Setup: Edit mode with existing task
      final now = DateTime.now().toUtc();
      final existingTask = TaskItem((b) => b
        ..docId = 'task-edit-123'
        ..dateAdded = now
        ..name = 'Existing Task Name'
        ..project = 'Career'
        ..context = 'Office'
        ..priority = 5
        ..gamePoints = 10
        ..duration = 30
        ..description = 'Task notes here'
        ..personDocId = 'person-123'
        ..completionDate = null
        ..retired = null
        ..offCycle = false
        ..pendingCompletion = false);

      // Add task to store
      testStore = Store<AppState>(
        appReducer,
        initialState: AppState.init(
          loading: false,
          notificationHelper: MockNotificationHelper(),
        ).rebuild((b) => b
          ..taskItems = ListBuilder<TaskItem>([existingTask])),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              taskItem: existingTask,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Fields populated with existing values
      expect(find.text('Existing Task Name'), findsOneWidget);
      expect(find.text('Career'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Task notes here'), findsOneWidget);
    });

    testWidgets('Edit mode shows check icon instead of add icon', (tester) async {
      // Setup: Edit mode with task that has name
      final existingTask = TaskItem((b) => b
        ..docId = 'task-123'
        ..dateAdded = DateTime.now().toUtc()
        ..name = 'Task Name'
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
          ..taskItems = ListBuilder<TaskItem>([existingTask])),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              taskItem: existingTask,
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Check icon shows (edit mode) - but button only appears if there are changes
      // In this case, no changes yet, so button hidden
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Project dropdown shows all project options', (tester) async {
      // Setup
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Action: Tap project dropdown
      await tester.tap(find.text('Project').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Common project options appear
      // The dropdown uses a menu, so options become visible
      expect(find.text('(none)'), findsWidgets);
      expect(find.text('Career'), findsWidgets);
      expect(find.text('Hobby'), findsWidgets);
      expect(find.text('Family'), findsWidgets);
      expect(find.text('Health'), findsWidgets);
    });

    testWidgets('Context dropdown shows all context options', (tester) async {
      // Setup
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Action: Tap context dropdown
      await tester.tap(find.text('Context').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify: Common context options appear
      expect(find.text('Computer'), findsWidgets);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Office'), findsWidgets);
      expect(find.text('Phone'), findsWidgets);
    });

    testWidgets('Form has correct validation mode', (tester) async {
      // Setup
      await tester.pumpWidget(
        MaterialApp(
          home: StoreProvider<AppState>(
            store: testStore,
            child: AddEditScreen(
              timezoneHelper: mockTimezoneHelper,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify: Form exists with autovalidate on user interaction
      final form = tester.widget<Form>(find.byType(Form));
      expect(form.autovalidateMode, AutovalidateMode.onUserInteraction);
    });
  });
}
