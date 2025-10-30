import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/firestore_migrator.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/store_sprint_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/task_repository.dart';

import '../mocks/mock_notification_helper.dart';
import '../mocks/mock_timezone_helper.dart';

// Generate mocks for FirestoreMigrator and auth
@GenerateMocks([])
class _MockFirestoreMigrator extends Mock implements FirestoreMigrator {}
class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class _MockUserCredential extends Mock implements UserCredential {}
class _MockUser extends Mock implements User {}

/// Helper class for integration tests
/// Provides utilities for setting up test environment with mocked Firebase
class IntegrationTestHelper {
  /// Create a test app with full Redux store and real task repository
  static Future<void> pumpApp(
    WidgetTester tester, {
    List<TaskItem>? initialTasks,
    List<Sprint>? initialSprints,
    List<TaskRecurrence>? initialRecurrences,
    String? personDocId,
    FirebaseFirestore? firestore,
  }) async {
    // Use provided Firestore or create a fake one
    final testFirestore = firestore ?? FakeFirebaseFirestore();
    final testPersonDocId = personDocId ?? 'test-person-123';

    // Note: We'll seed data directly into Redux state instead of Firestore
    // to avoid triggering continuous stream emissions that slow down tests

    // Create person document
    await testFirestore.collection('persons').doc(testPersonDocId).set({
      'email': 'test@example.com',
      'name': 'Test User',
    });

    // Create real task repository with fake Firestore
    final taskRepository = TaskRepository(firestore: testFirestore);
    final navigatorKey = GlobalKey<NavigatorState>();
    final mockMigrator = _MockFirestoreMigrator();

    // Create mock auth objects for appIsReady() check
    final mockUser = _MockUser();
    final mockUserCredential = _MockUserCredential();
    final mockGoogleAccount = _MockGoogleSignInAccount();

    // Use mock TimezoneHelper to avoid platform channel initialization
    final timezoneHelper = MockTimezoneHelper();

    // Set up mock user credential to return mock user
    when(mockUserCredential.user).thenReturn(mockUser);

    // Create store with real middleware and reducers
    // Use mock notification helper to avoid platform initialization errors
    final initialState = AppState.init(
      loading: false,
      notificationHelper: MockNotificationHelper(),
    );

    // Set active tab to Tasks tab (index 1) for task-focused tests
    final tasksTab = initialState.allNavItems[1];

    // Link recurrences to tasks (like reducers do)
    final recurrencesList = initialRecurrences ?? [];
    final tasksWithRecurrences = (initialTasks ?? []).map((task) {
      if (task.recurrenceDocId != null) {
        final recurrence = recurrencesList.where((r) => r.docId == task.recurrenceDocId).singleOrNull;
        if (recurrence != null) {
          return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
        }
      }
      return task;
    }).toList();

    // Seed data directly into Redux state (not Firestore) for fast tests
    final store = Store<AppState>(
      appReducer,
      initialState: initialState.rebuild((b) => b
        ..personDocId = testPersonDocId
        ..currentUser = mockGoogleAccount
        ..firebaseUser = mockUserCredential
        ..timezoneHelper = timezoneHelper
        ..activeTab = tasksTab.toBuilder()
        ..taskItems = ListBuilder<TaskItem>(tasksWithRecurrences)
        ..sprints = ListBuilder<Sprint>(initialSprints ?? [])
        ..taskRecurrences = ListBuilder<TaskRecurrence>(recurrencesList)
        ..tasksLoading = false
        ..sprintsLoading = false
        ..taskRecurrencesLoading = false
        ..isLoading = false),
      middleware: [
        // Include middleware but don't start listeners - tests just verify rendering
        ...createStoreTaskItemsMiddleware(taskRepository, navigatorKey, mockMigrator, null),
        ...createStoreSprintsMiddleware(taskRepository),
      ],
    );

    // Don't dispatch LoadDataAction - it starts Firestore listeners that never settle
    // Tests verify UI rendering with seeded data, not real-time sync

    // Pump the app with proper theme for tests
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(Colors.blue),
            ),
          ),
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for initial render - single pump is enough since data is pre-seeded
    await tester.pump();
  }

  /// Create a minimal Redux store for testing
  static Store<AppState> createMinimalStore({
    List<TaskItem>? tasks,
    List<Sprint>? sprints,
    List<TaskRecurrence>? recurrences,
    String? personDocId,
  }) {
    return Store<AppState>(
      appReducer,
      initialState: AppState.init(loading: false).rebuild((b) => b
        ..taskItems = ListBuilder(tasks ?? [])
        ..sprints = ListBuilder(sprints ?? [])
        ..taskRecurrences = ListBuilder(recurrences ?? [])
        ..personDocId = personDocId ?? 'test-person-123'
        ..isLoading = false),
    );
  }

  /// Wait for widget rebuild (data is pre-seeded, no async operations)
  static Future<void> waitForRender(WidgetTester tester) async {
    // Just pump once - data is already in Redux state
    await tester.pump();
  }

  /// Find text that contains the given substring (useful for dynamic text)
  static Finder findTextContaining(String substring) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains(substring),
    );
  }

}

/// Extension for common test assertions
extension IntegrationTestAssertions on WidgetTester {
  /// Assert that text appears on screen
  void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Assert that text appears multiple times
  void expectTextMultiple(String text, int count) {
    expect(find.text(text), findsNWidgets(count));
  }

  /// Assert that text does not appear
  void expectNoText(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Assert that widget type exists
  void expectWidget<T>() {
    expect(find.byType(T), findsOneWidget);
  }
}
