import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:taskmaster/core/database/app_database.dart'
    hide TaskRecurrence, Sprint, SprintAssignment, Task;
import 'package:taskmaster/core/database/converters.dart';
import 'package:taskmaster/core/providers/auth_providers.dart';
import 'package:taskmaster/core/providers/connectivity_provider.dart';
import 'package:taskmaster/core/providers/database_provider.dart';
import 'package:taskmaster/core/providers/firebase_providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmaster/core/providers/notification_providers.dart';
import 'package:taskmaster/core/services/analytics_service.dart';
import 'package:taskmaster/core/services/notification_helper_impl.dart';
import 'package:taskmaster/core/services/task_completion_service.dart';
import 'package:taskmaster/features/sprints/providers/sprint_providers.dart';
import 'package:taskmaster/features/tasks/providers/task_providers.dart';
import 'package:taskmaster/features/tasks/presentation/task_list_screen.dart';
import 'package:taskmaster/features/tasks/presentation/stats_screen.dart';
import 'package:taskmaster/models/serializers.dart';
import 'package:taskmaster/models/sprint.dart';
import 'package:taskmaster/models/task_item.dart';
import 'package:taskmaster/models/task_recurrence.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/features/shared/presentation/planning_home.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../mocks/mock_timezone_helper.dart';

/// No-op notification helper for tests. The production helper calls
/// `FlutterLocalNotificationsPlugin.initialize()` which requires platform
/// setup not available in unit/widget tests, and the in-app notifier paths
/// (AddTask / UpdateTask / SnoozeTask / CompleteTask) all fire-and-forget
/// `updateNotificationForTask` post-write. Overriding the provider with this
/// stub keeps those calls quiet.
class _NoopNotificationHelper extends NotificationHelperImpl {
  _NoopNotificationHelper() : super(plugin: FlutterLocalNotificationsPlugin());

  @override
  Future<void> updateNotificationForTask(taskItem) async {}
  @override
  Future<void> syncNotificationForTasksAndSprint(tasks, sprint) async {}
  @override
  Future<void> cancelAllNotifications() async {}
  @override
  Future<void> cancelNotificationsForTaskId(String taskId) async {}
}

/// No-op analytics service for tests — avoids FirebaseAnalytics initialization.
class _StubAnalyticsService implements AnalyticsService {
  @override
  bool get isEnabled => false;

  @override
  Future<void> setUserIdentifier(String personDocId) async {}

  @override
  Future<void> logTaskCreated({bool hasRecurrence = false}) async {}

  @override
  Future<void> logTaskCompleted({required bool complete}) async {}

  @override
  Future<void> logTaskDeleted() async {}

  @override
  Future<void> logSprintCreated({required int taskCount}) async {}

  @override
  Future<void> logScreenView(String screenName) async {}
}

// Test helper for TimezoneHelperNotifier
class _TestTimezoneHelperNotifier extends TimezoneHelperNotifier {
  // Override build to return mock immediately without platform channel initialization
  @override
  Future<TimezoneHelper> build() async {
    return MockTimezoneHelper();
  }
}

/// Helper class for integration tests
/// Provides utilities for setting up test environment with mocked Firebase
class IntegrationTestHelper {
  /// Create a test app with Riverpod providers
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

    // Create person document
    await testFirestore.collection('persons').doc(testPersonDocId).set({
      'email': 'test@example.com',
      'name': 'Test User',
    });

    final navigatorKey = GlobalKey<NavigatorState>();

    // Link recurrences to tasks
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

    // Pump the app with Riverpod providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override Firestore provider to use test instance
          firestoreProvider.overrideWithValue(testFirestore),
          // Override auth providers with test data
          personDocIdProvider.overrideWith((ref) => testPersonDocId),
          // Override task/recurrence providers with test data
          tasksProvider.overrideWith((ref) => Stream.value(tasksWithRecurrences)),
          tasksWithRecurrencesProvider.overrideWith((ref) => Stream.value(tasksWithRecurrences)),
          taskRecurrencesProvider.overrideWith((ref) => Stream.value(recurrencesList)),
          sprintsProvider.overrideWith((ref) => Stream.value(initialSprints ?? [])),
          // Override timezone helper notifier to immediately return mock
          timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
          notificationHelperProvider.overrideWithValue(_NoopNotificationHelper()),
        ],
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
    );

    // Wait for initial render and async providers to complete
    await tester.pumpAndSettle();
  }

  /// Wait for widget rebuild
  static Future<void> waitForRender(WidgetTester tester) async {
    await tester.pump();
  }

  /// Create a test app with a hybrid read/write architecture:
  ///
  /// - **Reads** come from fakeFirestore streams (task/recurrence/sprint
  ///   providers are overridden to stream directly from Firestore). This
  ///   avoids Drift's 0-duration stream-cleanup timers, which cause
  ///   "pending timer" failures in flutter_test's post-test invariant check.
  /// - **Writes** go to an in-memory Drift DB (via `databaseProvider`
  ///   override), then SyncService pushes them to fakeFirestore, whose
  ///   streams then emit the change to the read-side providers.
  ///
  /// The explicit `ProviderContainer` lets us pre-warm `connectivityProvider`
  /// before any widget renders, so `SyncService.pushPendingWrites` sees
  /// `online == true` and doesn't short-circuit its offline-check.
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

    // Seed initial data into fakeFirestore — this is what the read-side
    // provider overrides stream from.
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
          'recurWait': recurrence.recurWait,
          'recurIteration': recurrence.recurIteration,
          'anchorDate': {
            'dateValue': recurrence.anchorDate.dateValue,
            'dateType': recurrence.anchorDate.dateType.label,
          },
        });
      }
    }

    // In-memory Drift DB for write-side operations (AddTask, UpdateTask, etc.)
    // Also seeded with the same initial data so that UpdateTask can find
    // existing rows to mark pendingUpdate.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    if (initialTasks != null) {
      for (final task in initialTasks) {
        await db.taskDao.upsertFromRemote(taskItemToCompanion(task));
      }
    }
    if (initialRecurrences != null) {
      for (final recurrence in initialRecurrences) {
        await db.taskRecurrenceDao
            .upsertFromRemote(taskRecurrenceToCompanion(recurrence));
      }
    }
    if (initialSprints != null) {
      for (final sprint in initialSprints) {
        await db.sprintDao.upsertSprintFromRemote(sprintToCompanion(sprint));
        for (final assignment in sprint.sprintAssignments) {
          await db.sprintDao
              .upsertAssignmentFromRemote(sprintAssignmentToCompanion(assignment));
        }
      }
    }

    // Explicit ProviderContainer lets us pre-warm connectivityProvider before
    // widgets render, ensuring SyncService.pushPendingWrites sees online=true.
    final container = ProviderContainer(
      overrides: [
        // Firestore
        firestoreProvider.overrideWithValue(testFirestore),
        // Auth
        personDocIdProvider.overrideWith((ref) => testPersonDocId),
        // Drift DB — write-side only
        databaseProvider.overrideWithValue(db),
        // Analytics stub
        analyticsServiceProvider.overrideWith((ref) => _StubAnalyticsService()),
        // Notification helper stub (real one needs platform plugin init)
        notificationHelperProvider.overrideWithValue(_NoopNotificationHelper()),
        // Always online — SyncService.pushPendingWrites checks this
        connectivityProvider.overrideWith((ref) => Stream.value(true)),

        // Read-side overrides: stream from fakeFirestore instead of Drift,
        // so no Drift stream subscriptions exist when the widget tree is
        // torn down (no pending cleanup timers).
        tasksProvider.overrideWith((ref) {
          final fs = ref.watch(firestoreProvider);
          final pid = ref.watch(personDocIdProvider);
          if (pid == null) return Stream.value(<TaskItem>[]);
          return fs
              .collection('tasks')
              .where('personDocId', isEqualTo: pid)
              .where('retired', isNull: true)
              .where('completionDate', isNull: true)
              .snapshots()
              .map((snap) => snap.docs
                  .map((doc) {
                    final json = doc.data()..['docId'] = doc.id;
                    return TaskItem.fromJson(json);
                  })
                  .toList());
        }),
        taskRecurrencesProvider.overrideWith((ref) {
          final fs = ref.watch(firestoreProvider);
          final pid = ref.watch(personDocIdProvider);
          if (pid == null) return Stream.value(<TaskRecurrence>[]);
          return fs
              .collection('taskRecurrences')
              .where('personDocId', isEqualTo: pid)
              .snapshots()
              .map((snap) => snap.docs
                  .map((doc) {
                    final json = doc.data()..['docId'] = doc.id;
                    return TaskRecurrence.fromJson(json);
                  })
                  .toList());
        }),
        tasksWithRecurrencesProvider.overrideWith((ref) {
          final fs = ref.watch(firestoreProvider);
          final pid = ref.watch(personDocIdProvider);
          if (pid == null) return Stream.value(<TaskItem>[]);
          final tasksStream = fs
              .collection('tasks')
              .where('personDocId', isEqualTo: pid)
              .where('retired', isNull: true)
              .where('completionDate', isNull: true)
              .snapshots()
              .map((snap) => snap.docs
                  .map((doc) {
                    final json = doc.data()..['docId'] = doc.id;
                    return TaskItem.fromJson(json);
                  })
                  .toList());
          final recurrencesStream = fs
              .collection('taskRecurrences')
              .where('personDocId', isEqualTo: pid)
              .snapshots()
              .map((snap) => snap.docs
                  .map((doc) {
                    final json = doc.data()..['docId'] = doc.id;
                    return TaskRecurrence.fromJson(json);
                  })
                  .toList());
          return Rx.combineLatest2<List<TaskItem>, List<TaskRecurrence>,
              List<TaskItem>>(
            tasksStream,
            recurrencesStream,
            (tasks, recurrences) {
              final recurrenceMap = {for (final r in recurrences) r.docId: r};
              return tasks.map((task) {
                if (task.recurrenceDocId != null) {
                  final r = recurrenceMap[task.recurrenceDocId];
                  if (r != null) {
                    return task.rebuild((b) => b..recurrence = r.toBuilder());
                  }
                }
                return task;
              }).toList();
            },
          );
        }),
        sprintsProvider.overrideWith((ref) {
          final fs = ref.watch(firestoreProvider);
          final pid = ref.watch(personDocIdProvider);
          if (pid == null) return Stream.value(<Sprint>[]);
          return fs
              .collection('sprints')
              .where('personDocId', isEqualTo: pid)
              .snapshots()
              .map((snap) => snap.docs
                  .map((doc) {
                    final json = doc.data()..['docId'] = doc.id;
                    return serializers.deserializeWith(Sprint.serializer, json)!;
                  })
                  .toList());
        }),

        // Timezone helper mock
        timezoneHelperNotifierProvider.overrideWith(() => _TestTimezoneHelperNotifier()),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    // Pre-warm connectivityProvider so SyncService.pushPendingWrites sees
    // online=true the first time it's read (during a task save).
    await container.read(connectivityProvider.future);

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
    );

    // Wait for initial render and Firestore streams to emit their first values
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
