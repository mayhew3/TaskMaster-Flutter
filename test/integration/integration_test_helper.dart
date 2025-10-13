import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/firestore_migrator.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/redux/actions/task_item_actions.dart';
import 'package:taskmaster/redux/app_state.dart';
import 'package:taskmaster/redux/middleware/store_sprint_middleware.dart';
import 'package:taskmaster/redux/middleware/store_task_items_middleware.dart';
import 'package:taskmaster/redux/presentation/home_screen.dart';
import 'package:taskmaster/redux/reducers/app_state_reducer.dart';
import 'package:taskmaster/task_repository.dart';

// Generate mocks for FirestoreMigrator
@GenerateMocks([])
class _MockFirestoreMigrator extends Mock implements FirestoreMigrator {}

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

    // Seed Firestore with initial data if provided
    if (initialTasks != null && initialTasks.isNotEmpty) {
      for (var task in initialTasks) {
        final json = task.toJson() as Map<String, dynamic>;
        json.remove('docId'); // Firestore will generate this
        await testFirestore.collection('tasks').add(json);
      }
    }

    if (initialSprints != null && initialSprints.isNotEmpty) {
      for (var sprint in initialSprints) {
        final json = sprint.toJson() as Map<String, dynamic>;
        json.remove('docId');
        await testFirestore.collection('sprints').add(json);
      }
    }

    if (initialRecurrences != null && initialRecurrences.isNotEmpty) {
      for (var recurrence in initialRecurrences) {
        final json = serializers.serializeWith(
          TaskRecurrence.serializer,
          recurrence,
        ) as Map<String, dynamic>;
        json.remove('docId');
        await testFirestore.collection('taskRecurrences').add(json);
      }
    }

    // Create person document
    await testFirestore.collection('persons').doc(testPersonDocId).set({
      'email': 'test@example.com',
      'name': 'Test User',
    });

    // Create real task repository with fake Firestore
    final taskRepository = TaskRepository(firestore: testFirestore);
    final navigatorKey = GlobalKey<NavigatorState>();
    final mockMigrator = _MockFirestoreMigrator();

    // Create store with real middleware and reducers
    final store = Store<AppState>(
      appReducer,
      initialState: AppState.init(loading: false).rebuild((b) => b
        ..personDocId = testPersonDocId
        ..taskItems = ListBuilder<TaskItem>()
        ..sprints = ListBuilder<Sprint>()
        ..taskRecurrences = ListBuilder<TaskRecurrence>()
        ..isLoading = false),
      middleware: [
        ...createStoreTaskItemsMiddleware(taskRepository, navigatorKey, mockMigrator),
        ...createStoreSprintsMiddleware(taskRepository),
      ],
    );

    // Dispatch load data action to initialize listeners
    store.dispatch(LoadDataAction());

    // Pump the app
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for initial render
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

  /// Wait for Firestore stream to emit data
  /// Use this after making Firestore changes to wait for Redux state to update
  static Future<void> waitForFirestoreUpdate(WidgetTester tester) async {
    // Wait for stream to process
    await Future.delayed(Duration(milliseconds: 100));
    // Pump to process the state update
    await tester.pump();
    // Wait for any animations/rebuilds
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
