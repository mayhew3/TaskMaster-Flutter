import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/firestore_migrator.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/store_sprint_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaster/features/tasks/presentation/stats_screen.dart';
import 'package:taskmaster/features/sprints/presentation/sprint_task_items_screen.dart';
import 'package:taskmaster/features/sprints/presentation/new_sprint_screen.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/redux/containers/planning_home.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../mocks/mock_notification_helper.dart';
import '../mocks/mock_timezone_helper.dart';

// Generate mocks for FirestoreMigrator and auth
@GenerateMocks([])
class _MockFirestoreMigrator extends Mock implements FirestoreMigrator {}
class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class _MockUserCredential extends Mock implements UserCredential {}
class _MockUser extends Mock implements User {}

// Test helper for TimezoneHelperNotifier
class _TestTimezoneHelperNotifier extends TimezoneHelperNotifier {
  @override
  Future<TimezoneHelper> build() async {
    // In tests, return the mock immediately without async initialization
    return MockTimezoneHelper();
  }
}

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

    // Seed initial tasks into Firestore (needed for save/update operations and auto-close)
    for (final task in (initialTasks ?? [])) {
      await testFirestore.collection('tasks').doc(task.docId).set({
        'name': task.name,
        'personDocId': task.personDocId,
        'dateAdded': task.dateAdded.toIso8601String(),
        'offCycle': task.offCycle ?? false,
        'pendingCompletion': task.pendingCompletion ?? false,
      });
    }

    // Seed initial recurrences into Firestore
    for (final recurrence in (initialRecurrences ?? [])) {
      await testFirestore.collection('taskRecurrences').doc(recurrence.docId).set({
        'name': recurrence.name,
        'personDocId': recurrence.personDocId,
        'recurNumber': recurrence.recurNumber,
        'recurUnit': recurrence.recurUnit,
      });
    }

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
    // Wrap with both ProviderScope (for Riverpod) and StoreProvider (for Redux)
    // to support migration period where both systems coexist
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override Firestore provider to use test instance
          firestoreProvider.overrideWithValue(testFirestore),
          // Override auth providers with test data
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          // Don't override task/recurrence providers - let them watch Firestore naturally
          // This allows auto-close logic to work when tasks are saved
          sprintsProvider.overrideWith((ref) => Stream.value(initialSprints ?? [])),
          // Override timezone helper notifier to immediately return mock
          timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
        ],
        child: StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(Colors.blue),
              ),
            ),
            home: _TestAuthenticatedHome(),
          ),
        ),
      ),
    );

    // Wait for initial render and async providers to complete
    // Using pumpAndSettle() to wait for Future providers (tasksWithRecurrencesProvider, etc.)
    await tester.pumpAndSettle();
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

  /// Create a test app with Riverpod providers reading from live Firestore
  /// This allows tests to work with real Firestore updates instead of static data
  static Future<void> pumpAppWithLiveFirestore(
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

    // Create person document
    await testFirestore.collection('persons').doc(testPersonDocId).set({
      'email': 'test@example.com',
      'name': 'Test User',
    });

    // Seed initial data into Firestore (not Redux)
    if (initialTasks != null) {
      for (final task in initialTasks) {
        await testFirestore.collection('tasks').doc(task.docId).set({
          'dateAdded': task.dateAdded,
          'name': task.name,
          'personDocId': task.personDocId,
          'offCycle': task.offCycle,
          'pendingCompletion': task.pendingCompletion,
          if (task.description != null) 'description': task.description,
          if (task.project != null) 'project': task.project,
          if (task.context != null) 'context': task.context,
          if (task.completionDate != null) 'completionDate': task.completionDate,
          if (task.retired != null) 'retired': task.retired,
          if (task.startDate != null) 'startDate': task.startDate,
          if (task.targetDate != null) 'targetDate': task.targetDate,
          if (task.dueDate != null) 'dueDate': task.dueDate,
          if (task.urgentDate != null) 'urgentDate': task.urgentDate,
          if (task.recurrenceDocId != null) 'recurrenceDocId': task.recurrenceDocId,
          if (task.recurIteration != null) 'recurIteration': task.recurIteration,
          if (task.recurNumber != null) 'recurNumber': task.recurNumber,
          if (task.recurUnit != null) 'recurUnit': task.recurUnit,
          if (task.recurWait != null) 'recurWait': task.recurWait,
        });
      }
    }

    if (initialSprints != null) {
      for (final sprint in initialSprints) {
        await testFirestore.collection('sprints').doc(sprint.docId).set({
          'sprintNumber': sprint.sprintNumber,
          'startDate': sprint.startDate,
          'endDate': sprint.endDate,
          'personDocId': sprint.personDocId,
        });
      }
    }

    if (initialRecurrences != null) {
      for (final recurrence in initialRecurrences) {
        await testFirestore.collection('taskRecurrences').doc(recurrence.docId).set({
          'personDocId': recurrence.personDocId,
          'name': recurrence.name,
          'recurNumber': recurrence.recurNumber,
          'recurUnit': recurrence.recurUnit,
          'dateAdded': recurrence.dateAdded,
          if (recurrence.recurWait != null) 'recurWait': recurrence.recurWait,
          if (recurrence.recurIteration != null) 'recurIteration': recurrence.recurIteration,
          if (recurrence.anchorDate != null) 'anchorDate': {
            'dateValue': recurrence.anchorDate!.dateValue,
            'dateType': recurrence.anchorDate!.dateType.label,
          },
        });
      }
    }

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
    final initialState = AppState.init(
      loading: false,
      notificationHelper: MockNotificationHelper(),
    );

    // Set active tab to Tasks tab (index 1) for task-focused tests
    final tasksTab = initialState.allNavItems[1];

    // Create Redux store (for compatibility during migration)
    final store = Store<AppState>(
      appReducer,
      initialState: initialState.rebuild((b) => b
        ..personDocId = testPersonDocId
        ..currentUser = mockGoogleAccount
        ..firebaseUser = mockUserCredential
        ..timezoneHelper = timezoneHelper
        ..activeTab = tasksTab.toBuilder()
        ..tasksLoading = false
        ..sprintsLoading = false
        ..taskRecurrencesLoading = false
        ..isLoading = false),
      middleware: [
        ...createStoreTaskItemsMiddleware(taskRepository, navigatorKey, mockMigrator, null),
        ...createStoreSprintsMiddleware(taskRepository),
      ],
    );

    // Create initial data lists for provider overrides (used for initial render)
    // The providers will still read from Firestore for subsequent updates
    final initialTasksList = initialTasks ?? [];
    final initialSprintsList = initialSprints ?? [];
    final initialRecurrencesList = initialRecurrences ?? [];

    // Pump the app with Riverpod providers that emit initial data then read from Firestore
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override Firestore provider to use test instance
          firestoreProvider.overrideWithValue(testFirestore),
          // Override auth providers with test data
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          // Override data providers with streams that emit initial data first
          // then continue reading from Firestore
          tasksProvider.overrideWith((ref) {
            final firestore = ref.watch(firestoreProvider);
            final personDocId = ref.watch(personDocIdProvider);
            if (personDocId == null) return Stream.value(<TaskItem>[]);

            final firestoreStream = firestore
                .collection('tasks')
                .where('personDocId', isEqualTo: personDocId)
                .where('retired', isNull: true)
                .snapshots()
                .map<List<TaskItem>>((snapshot) {
                  return snapshot.docs.map((doc) {
                    final json = doc.data();
                    json['docId'] = doc.id;
                    return TaskItem.fromJson(json);
                  }).toList();
                });
            // Start with initial data, then switch to Firestore stream
            return firestoreStream.startWith(initialTasksList);
          }),
          sprintsProvider.overrideWith((ref) {
            final firestore = ref.watch(firestoreProvider);
            final personDocId = ref.watch(personDocIdProvider);
            if (personDocId == null) return Stream.value(<Sprint>[]);

            final firestoreStream = firestore
                .collection('sprints')
                .where('personDocId', isEqualTo: personDocId)
                .snapshots()
                .map<List<Sprint>>((snapshot) {
                  return snapshot.docs.map((doc) {
                    final json = doc.data();
                    json['docId'] = doc.id;
                    return serializers.deserializeWith(Sprint.serializer, json)!;
                  }).toList();
                });
            return firestoreStream.startWith(initialSprintsList);
          }),
          taskRecurrencesProvider.overrideWith((ref) {
            final firestore = ref.watch(firestoreProvider);
            final personDocId = ref.watch(personDocIdProvider);
            if (personDocId == null) return Stream.value(<TaskRecurrence>[]);

            final firestoreStream = firestore
                .collection('taskRecurrences')
                .where('personDocId', isEqualTo: personDocId)
                .snapshots()
                .map<List<TaskRecurrence>>((snapshot) {
                  return snapshot.docs.map((doc) {
                    final json = doc.data();
                    json['docId'] = doc.id;
                    return TaskRecurrence.fromJson(json);
                  }).toList();
                });
            return firestoreStream.startWith(initialRecurrencesList);
          }),
          // Override tasksWithRecurrencesProvider to avoid infinite rebuild loop
          // when tasks or recurrences streams emit
          tasksWithRecurrencesProvider.overrideWith((ref) async {
            final tasks = await ref.watch(tasksProvider.future);
            final recurrences = await ref.watch(taskRecurrencesProvider.future);

            // Link tasks with their recurrences
            return tasks.map((task) {
              if (task.recurrenceDocId != null) {
                final recurrence = recurrences
                    .where((r) => r.docId == task.recurrenceDocId)
                    .firstOrNull;
                if (recurrence != null) {
                  return task.rebuild((t) => t..recurrence = recurrence.toBuilder());
                }
              }
              return task;
            }).toList();
          }),
          // Override timezone helper notifier to immediately return mock
          timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
        ],
        child: StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(Colors.blue),
              ),
            ),
            home: _TestAuthenticatedHome(),
          ),
        ),
      ),
    );

    // Wait for initial render and Firestore streams to load
    await tester.pumpAndSettle();
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

/// Test version of authenticated home screen with tab navigation
/// Mimics the production _AuthenticatedHome from riverpod_app.dart
class _TestAuthenticatedHome extends StatefulWidget {
  const _TestAuthenticatedHome();

  @override
  State<_TestAuthenticatedHome> createState() => _TestAuthenticatedHomeState();
}

class _TestAuthenticatedHomeState extends State<_TestAuthenticatedHome> {
  int _selectedIndex = 1; // Start on Tasks tab (index 1) for test compatibility
  late final List<TopNavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = [
      TopNavItem.init(
        label: 'Plan',
        icon: Icons.assignment,
        widgetGetter: () => PlanningHome(),
      ),
      TopNavItem.init(
        label: 'Tasks',
        icon: Icons.list,
        widgetGetter: () => const TaskListScreen(),
      ),
      TopNavItem.init(
        label: 'Stats',
        icon: Icons.show_chart,
        widgetGetter: () => const StatsScreen(),
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _navItems[_selectedIndex].widgetGetter();

    return Column(
      children: [
        Expanded(child: currentScreen),
        NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabSelected,
          destinations: _navItems.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ],
    );
  }
}
