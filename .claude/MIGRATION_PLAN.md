# TaskMaster Redux → Riverpod Migration Plan

**Goal:** Modernize architecture from Redux + built_value to Riverpod + Freezed while maintaining app functionality.

**Timeline:** 2-3 weeks testing + 3-6 months incremental migration (app remains functional throughout)

**Risk Level:** LOW - Comprehensive testing + incremental approach with feature flags

---

## ⚠️ PREREQUISITE: Testing Phase

**Before starting any migration work, complete the testing plan in `.claude/TESTING_PLAN.md`.**

### Why Test First?

During migration, you'll be:
- Rewriting state management (Redux → Riverpod)
- Changing data models (built_value → Freezed)
- Refactoring business logic (middleware → services)
- Updating navigation (manual → go_router)

**Without tests:** You'll have no way to know if you broke something.
**With tests:** You'll catch regressions immediately.

### Testing Requirements Before Migration

**MUST HAVE (2 weeks):**
- ✅ 5+ critical path integration tests
  - Task CRUD flow
  - Recurring task completion
  - Sprint creation
  - Authentication
  - Snooze functionality
- ✅ 15+ screen widget tests
  - Add/Edit task screen
  - Task list screen
  - Task details screen
  - Sprint planning screens
  - Home/navigation screen
- ✅ All tests passing consistently
- ✅ >70% code coverage on critical paths

**OPTIONAL (1-2 additional weeks):**
- Redux middleware tests
- Reducer tests
- Repository tests

**See `.claude/TESTING_PLAN.md` for complete details and implementation guide.**

### Current Test Status

Record your baseline here after running tests:

```bash
flutter test

# Record results:
Total tests: 101
Passing: 101
Coverage: ~30% (mostly unit tests)
Missing: Integration tests, screen tests, Redux layer tests
```

Once testing phase complete, proceed to Phase 0 below.

---

## Strategy Overview

### Core Principles
1. ✅ **No Big Bang Rewrite** - Migrate feature by feature
2. ✅ **Redux and Riverpod Coexist** - Both can run simultaneously
3. ✅ **Always Shippable** - Every phase results in working app
4. ✅ **Test Coverage First** - Ensure tests exist before migration
5. ✅ **New Features in Riverpod** - Stop expanding Redux immediately

### Success Metrics
- [ ] Reduce total Dart files by 30-40%
- [ ] Build time reduction: Target 50% faster `build_runner` execution
- [ ] Test execution time: Target 30% faster
- [ ] Developer experience: New features take 50% less boilerplate

---

## Phase 0: Preparation (Week 1 - After Testing Complete)

### 0.1 Add Dependencies

**pubspec.yaml changes:**
```yaml
dependencies:
  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Models (replacing built_value)
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0  # Already have this

  # Navigation (replacing manual GlobalKey)
  go_router: ^14.6.2

dev_dependencies:
  # Code generation
  riverpod_generator: ^2.6.2
  freezed: ^2.5.7
  build_runner: ^2.4.13  # Already have this
  json_serializable: ^6.5.4  # Already have this

  # Testing
  mockito: ^5.4.4  # Already have this
```

Run: `flutter pub get`

### 0.2 Set Up Code Generation Config

**build.yaml** (create if doesn't exist):
```yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          # Generate .g.dart files in same directory
          riverpod_generator: true

      freezed:
        options:
          # Don't generate .freezed.dart in build directory
          build_to: source
```

### 0.3 Create Directory Structure

```bash
lib/
  ├── core/
  │   ├── providers/          # Global Riverpod providers
  │   ├── services/           # Business logic services
  │   └── router/             # go_router configuration
  ├── features/
  │   ├── tasks/
  │   │   ├── data/           # Repositories, DTOs
  │   │   ├── domain/         # Models, interfaces
  │   │   ├── presentation/   # Screens, widgets
  │   │   └── providers/      # Feature-specific providers
  │   ├── sprints/
  │   └── auth/
  └── redux/                  # Legacy - will be deleted in Phase 3
```

Create: `mkdir -p lib/core/providers lib/core/services lib/core/router lib/features/tasks/{data,domain,presentation,providers}`

### 0.4 Document Current State

Create baseline metrics:
```bash
# Count Redux files
find lib/redux -name "*.dart" | wc -l

# Measure build time
time flutter pub run build_runner build --delete-conflicting-outputs

# Run tests for baseline timing
time flutter test
```

Record these in `.claude/METRICS.md` for comparison later.

---

## Phase 1: Foundation (Weeks 2-3)

### 1.1 Set Up Riverpod Foundation

**lib/main.dart** - Wrap app with ProviderScope:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... existing Firebase setup ...

  runApp(
    ProviderScope(  // ADD THIS
      child: TaskMasterApp(),
    ),
  );
}
```

### 1.2 Create Core Providers

**lib/core/providers/firebase_providers.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  final instance = FirebaseFirestore.instance;

  // Match your existing configuration
  const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');
  if (serverEnv == 'local') {
    instance.useFirestoreEmulator('127.0.0.1', 8085);
    instance.settings = const Settings(persistenceEnabled: false);
  } else {
    instance.settings = const Settings(
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  return instance;
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;
```

**lib/core/providers/auth_providers.dart:**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase_providers.dart';

part 'auth_providers.g.dart';

@riverpod
GoogleSignIn googleSignIn(GoogleSignInRef ref) => GoogleSignIn.instance;

// Stream of auth state changes
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

// Current user (nullable)
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
}

// Person doc ID from Firestore
@riverpod
Future<String?> personDocId(PersonDocIdRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection('persons')
      .where('email', isEqualTo: user.email)
      .get();

  return snapshot.docs.firstOrNull?.id;
}
```

Generate code: `flutter pub run build_runner build --delete-conflicting-outputs`

### 1.3 Create Repository Interfaces

**lib/features/tasks/domain/task_repository.dart:**
```dart
import 'package:built_collection/built_collection.dart';
import '../../../models/task_item.dart';
import '../../../models/task_item_blueprint.dart';
import '../../../models/task_recurrence.dart';

/// Abstract repository - can be implemented by Firestore, mock, or other
abstract class TaskRepository {
  /// Watch all tasks for a person (real-time stream)
  Stream<List<TaskItem>> watchTasks(String personDocId);

  /// Watch task recurrences for a person
  Stream<List<TaskRecurrence>> watchRecurrences(String personDocId);

  /// Add a new task
  Future<void> addTask(TaskItemBlueprint blueprint);

  /// Update existing task and optionally its recurrence
  Future<({TaskItem taskItem, TaskRecurrence? recurrence})> updateTaskAndRecurrence(
    String taskItemDocId,
    TaskItemBlueprint blueprint,
  );

  /// Soft delete a task
  Future<void> deleteTask(TaskItem taskItem);
}
```

**lib/features/tasks/data/firestore_task_repository.dart:**
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/task_repository.dart';
import '../../../task_repository.dart' as legacy;

part 'firestore_task_repository.g.dart';

/// Adapter: wraps existing TaskRepository for now
class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._legacyRepo);

  final legacy.TaskRepository _legacyRepo;

  @override
  Stream<List<TaskItem>> watchTasks(String personDocId) {
    // For now, we'll implement this in Phase 2
    // This is just the interface
    throw UnimplementedError('Implement in Phase 2');
  }

  @override
  Future<void> addTask(TaskItemBlueprint blueprint) async {
    return _legacyRepo.addTask(blueprint);
  }

  @override
  Future<({TaskItem taskItem, TaskRecurrence? recurrence})>
      updateTaskAndRecurrence(String taskItemDocId, TaskItemBlueprint blueprint) {
    return _legacyRepo.updateTaskAndRecurrence(taskItemDocId, blueprint);
  }

  @override
  Future<void> deleteTask(TaskItem taskItem) async {
    return _legacyRepo.deleteTask(taskItem);
  }

  @override
  Stream<List<TaskRecurrence>> watchRecurrences(String personDocId) {
    throw UnimplementedError('Implement in Phase 2');
  }
}

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  final legacyRepo = legacy.TaskRepository(firestore: firestore);
  return FirestoreTaskRepository(legacyRepo);
}
```

### 1.4 Set Up go_router

**lib/core/router/app_router.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_providers.dart';
import '../../redux/presentation/home_screen.dart';
import '../../redux/presentation/sign_in.dart';
import '../../redux/presentation/load_failed.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authState),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => SignInScreen(),
      ),
      GoRoute(
        path: '/load-failed',
        name: 'loadFailed',
        builder: (context, state) => LoadFailedScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnLoginPage) {
        return '/login';
      }

      if (isAuthenticated && isOnLoginPage) {
        return '/';
      }

      return null; // No redirect needed
    },
  );
}

/// Helper to refresh router when stream emits
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

**lib/app.dart** - Update to use go_router (optional for now, or keep both):
```dart
// Keep existing MaterialApp for now, we'll switch in Phase 2
// This is just documenting what it will look like

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

class TaskMasterApp extends ConsumerWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'TaskMaster 3000',
      theme: taskMasterTheme,
      routerConfig: router,
    );
  }
}
*/
```

### 1.5 Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output:** `.g.dart` files for all providers

### 1.6 Verify Setup

Run app - should work identically to before. Redux is still handling everything, we've just added infrastructure.

```bash
flutter run
flutter test  # All tests should still pass
```

---

## Phase 2: Parallel Implementation (Weeks 4-8)

**Strategy:** Implement Riverpod versions alongside Redux. Use feature flags to switch between them.

### 2.1 Convert First Model to Freezed

Let's start with **TaskRecurrence** (simpler than TaskItem):

**lib/features/tasks/domain/models/task_recurrence_freezed.dart:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/anchor_date.dart';

part 'task_recurrence_freezed.freezed.dart';
part 'task_recurrence_freezed.g.dart';

@freezed
class TaskRecurrenceFreezed with _$TaskRecurrenceFreezed {
  const TaskRecurrenceFreezed._();

  const factory TaskRecurrenceFreezed({
    required String docId,
    required DateTime dateAdded,
    required String personDocId,

    String? name,
    String? description,
    String? project,
    String? context,

    int? urgency,
    int? priority,
    int? duration,
    int? gamePoints,

    int? recurNumber,
    String? recurUnit,
    bool? recurWait,

    AnchorDate? anchorDate,
    int? recurIteration,

    String? retired,
    DateTime? retiredDate,
  }) = _TaskRecurrenceFreezed;

  factory TaskRecurrenceFreezed.fromJson(Map<String, dynamic> json) =>
      _$TaskRecurrenceFreezedFromJson(json);

  // Migration helper: convert from built_value
  factory TaskRecurrenceFreezed.fromLegacy(TaskRecurrence legacy) {
    return TaskRecurrenceFreezed(
      docId: legacy.docId,
      dateAdded: legacy.dateAdded,
      personDocId: legacy.personDocId,
      name: legacy.name,
      description: legacy.description,
      project: legacy.project,
      context: legacy.context,
      urgency: legacy.urgency,
      priority: legacy.priority,
      duration: legacy.duration,
      gamePoints: legacy.gamePoints,
      recurNumber: legacy.recurNumber,
      recurUnit: legacy.recurUnit,
      recurWait: legacy.recurWait,
      anchorDate: legacy.anchorDate,
      recurIteration: legacy.recurIteration,
      retired: legacy.retired,
      retiredDate: legacy.retiredDate,
    );
  }

  // Convert to built_value (for gradual migration)
  TaskRecurrence toLegacy() {
    // Implementation to convert back
    return TaskRecurrence((b) => b
      ..docId = docId
      ..dateAdded = dateAdded
      // ... etc
    );
  }
}
```

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### 2.2 Implement Stream Providers

**lib/features/tasks/providers/task_providers.dart:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/task_item.dart';
import '../../../models/task_recurrence.dart';
import '../../../models/serializers.dart';

part 'task_providers.g.dart';

/// Stream of all tasks for the current user
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) async* {
  final personDocId = await ref.watch(personDocIdProvider.future);
  if (personDocId == null) {
    yield [];
    return;
  }

  final firestore = ref.watch(firestoreProvider);
  final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));

  yield* firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .where(
        Filter.or(
          Filter('completionDate', isNull: true),
          Filter('completionDate', isGreaterThan: sevenDaysAgo),
        ),
      )
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final json = doc.data();
          json['docId'] = doc.id;
          return serializers.deserializeWith(TaskItem.serializer, json)!;
        }).toList();
      });
}

/// Stream of task recurrences for the current user
@riverpod
Stream<List<TaskRecurrence>> taskRecurrences(TaskRecurrencesRef ref) async* {
  final personDocId = await ref.watch(personDocIdProvider.future);
  if (personDocId == null) {
    yield [];
    return;
  }

  final firestore = ref.watch(firestoreProvider);

  yield* firestore
      .collection('taskRecurrences')
      .where('personDocId', isEqualTo: personDocId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final json = doc.data();
          json['docId'] = doc.id;
          return serializers.deserializeWith(
            TaskRecurrence.serializer,
            json,
          )!;
        }).toList();
      });
}

/// Filtered tasks based on visibility settings
@riverpod
List<TaskItem> filteredTasks(
  FilteredTasksRef ref, {
  bool showCompleted = false,
  bool showScheduled = true,
}) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) {
      return tasks.where((task) {
        if (task.retired != null) return false;

        final completedPredicate =
            task.completionDate == null || showCompleted;
        final scheduledPredicate =
            task.startDate == null ||
            task.startDate!.isBefore(DateTime.now()) ||
            showScheduled;

        return completedPredicate && scheduledPredicate;
      }).toList();
    },
    orElse: () => [],
  );
}

/// Get a specific task by ID
@riverpod
TaskItem? task(TaskRef ref, String taskId) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) => t.docId == taskId).firstOrNull,
    orElse: () => null,
  );
}
```

### 2.3 Create Business Logic Service

**lib/core/services/task_completion_service.dart:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/tasks/domain/task_repository.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../models/task_item.dart';
import '../../models/task_item_recur_preview.dart';
import '../../helpers/recurrence_helper.dart';

part 'task_completion_service.g.dart';

class TaskCompletionResult {
  const TaskCompletionResult({
    required this.completedTask,
    this.nextRecurrence,
  });

  final TaskItem completedTask;
  final TaskItem? nextRecurrence;
}

class TaskCompletionService {
  TaskCompletionService(this._repository);

  final TaskRepository _repository;

  Future<TaskCompletionResult> completeTask({
    required TaskItem task,
    required List<TaskItem> allTasks,
    required bool complete,
  }) async {
    final completionDate = complete ? DateTime.timestamp() : null;

    final blueprint = task.createBlueprint()
      ..completionDate = completionDate;

    TaskItem? nextScheduledTask;

    // Create next recurrence if needed
    if (task.recurrence != null &&
        completionDate != null &&
        !_hasNextIteration(task, allTasks)) {
      final nextPreview = RecurrenceHelper.createNextIteration(
        task,
        completionDate,
      );

      // Add the new task
      await _repository.addTask(nextPreview.toBlueprint());

      // We'll get the added task from the stream
    }

    // Update the completed task
    final result = await _repository.updateTaskAndRecurrence(
      task.docId,
      blueprint,
    );

    return TaskCompletionResult(
      completedTask: result.taskItem,
      nextRecurrence: nextScheduledTask,
    );
  }

  bool _hasNextIteration(TaskItem task, List<TaskItem> allTasks) {
    final recurIteration = task.recurIteration;
    if (recurIteration == null) return false;

    return allTasks.any((ti) =>
        ti.recurrenceDocId == task.recurrenceDocId &&
        ti.recurIteration != null &&
        ti.recurIteration! > recurIteration);
  }
}

@riverpod
TaskCompletionService taskCompletionService(TaskCompletionServiceRef ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskCompletionService(repository);
}

/// Controller for completing tasks
@riverpod
class CompleteTask extends _$CompleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task, {required bool complete}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskCompletionServiceProvider);
      final allTasks = await ref.read(tasksProvider.future);

      await service.completeTask(
        task: task,
        allTasks: allTasks,
        complete: complete,
      );
    });
  }
}
```

### 2.4 Create Riverpod Version of First Screen

Let's convert the **Stats Counter** screen first (simplest):

**lib/features/stats/presentation/stats_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Stats')),
      body: tasksAsync.when(
        data: (tasks) {
          final activeTasks = tasks.where((t) =>
            t.completionDate == null && t.retired == null).length;
          final completedTasks = tasks.where((t) =>
            t.completionDate != null).length;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(
                  label: 'Active Tasks',
                  count: activeTasks,
                  color: Colors.blue,
                ),
                SizedBox(height: 16),
                _StatCard(
                  label: 'Completed Tasks',
                  count: completedTasks,
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
```

### 2.5 Feature Flag System

**lib/core/feature_flags.dart:**
```dart
class FeatureFlags {
  static const bool useRiverpodForStats =
      bool.fromEnvironment('USE_RIVERPOD_STATS', defaultValue: false);

  static const bool useRiverpodForTasks =
      bool.fromEnvironment('USE_RIVERPOD_TASKS', defaultValue: false);

  static const bool useGoRouter =
      bool.fromEnvironment('USE_GO_ROUTER', defaultValue: false);
}
```

**Usage:**
```dart
// In home_screen.dart
Widget build(BuildContext context) {
  if (FeatureFlags.useRiverpodForStats) {
    return StatsScreen();  // New Riverpod version
  } else {
    return StatsCounter();  // Old Redux version
  }
}
```

**Testing:**
```bash
# Test with new Riverpod stats
flutter run --dart-define=USE_RIVERPOD_STATS=true

# Test with old Redux (default)
flutter run
```

### 2.6 Deliverable: Side-by-Side Comparison

At end of Phase 2, you have:
- ✅ Stats screen working in both Redux and Riverpod
- ✅ Task data available via Riverpod providers
- ✅ Feature flags to toggle between implementations
- ✅ All tests still passing

Compare code:
- Redux: `lib/redux/presentation/stats_counter.dart` + ViewModel + Selectors (~150 lines)
- Riverpod: `lib/features/stats/presentation/stats_screen.dart` (~80 lines)

---

## Phase 3: Full Migration (Weeks 9-16)

### 3.1 Convert Screens One by One

**Priority Order:**
1. ✅ Stats (done in Phase 2)
2. Task List Screen
3. Task Detail Screen
4. Sprint Planning Screen
5. Add/Edit Task Screen

For each screen:
1. Create Riverpod providers for that screen's data
2. Extract business logic to service classes
3. Create new UI using ConsumerWidget
4. Add feature flag
5. Test both versions
6. Switch default to Riverpod
7. Delete Redux version after 1 sprint

### 3.2 Convert Task List Screen

**lib/features/tasks/presentation/task_list_screen.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../providers/task_filter_provider.dart';
import 'widgets/task_list_item.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch filter settings
    final showCompleted = ref.watch(showCompletedProvider);
    final showScheduled = ref.watch(showScheduledProvider);

    // Watch filtered tasks
    final filteredTasks = ref.watch(
      filteredTasksProvider(
        showCompleted: showCompleted,
        showScheduled: showScheduled,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          _FilterButton(),
        ],
      ),
      body: filteredTasks.isEmpty
          ? _EmptyState()
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskListItem(task: task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add task screen
          context.push('/tasks/new');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class _FilterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: Icon(Icons.filter_list),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: CheckboxListTile(
            title: Text('Show Completed'),
            value: ref.watch(showCompletedProvider),
            onChanged: (value) {
              ref.read(showCompletedProvider.notifier).state = value ?? false;
            },
          ),
        ),
        PopupMenuItem(
          child: CheckboxListTile(
            title: Text('Show Scheduled'),
            value: ref.watch(showScheduledProvider),
            onChanged: (value) {
              ref.read(showScheduledProvider.notifier).state = value ?? true;
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No tasks', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          Text('Tap + to add a task'),
        ],
      ),
    );
  }
}
```

**lib/features/tasks/providers/task_filter_provider.dart:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_filter_provider.g.dart';

// Simple state providers for filter toggles
@riverpod
class ShowCompleted extends _$ShowCompleted {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class ShowScheduled extends _$ShowScheduled {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
```

**lib/features/tasks/presentation/widgets/task_list_item.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/task_item.dart';
import '../../../../core/services/task_completion_service.dart';

class TaskListItem extends ConsumerWidget {
  const TaskListItem({super.key, required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.completionDate != null;

    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: (value) {
          ref.read(completeTaskProvider.notifier).call(
            task,
            complete: value ?? false,
          );
        },
      ),
      title: Text(
        task.name,
        style: isCompleted
            ? TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: task.description != null
          ? Text(task.description!)
          : null,
      trailing: task.isUrgent() || task.isPastDue()
          ? Icon(Icons.warning, color: Colors.red)
          : null,
      onTap: () {
        // Navigate to detail screen
        context.push('/tasks/${task.docId}');
      },
    );
  }
}
```

### 3.3 Testing Strategy

**Unit Tests:**
```dart
// test/features/tasks/providers/task_providers_test.dart
void main() {
  test('filteredTasks excludes retired tasks', () async {
    final container = ProviderContainer(
      overrides: [
        tasksProvider.overrideWith((ref) => Stream.value([
          TaskItem((b) => b
            ..docId = '1'
            ..name = 'Active'
            ..retired = null),
          TaskItem((b) => b
            ..docId = '2'
            ..name = 'Retired'
            ..retired = '2'),
        ])),
      ],
    );

    final filtered = container.read(
      filteredTasksProvider(showCompleted: true, showScheduled: true),
    );

    expect(filtered.length, 1);
    expect(filtered.first.name, 'Active');
  });
}
```

**Widget Tests:**
```dart
// test/features/tasks/presentation/task_list_screen_test.dart
void main() {
  testWidgets('displays tasks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([
            TaskItem((b) => b
              ..docId = '1'
              ..name = 'Test Task'),
          ])),
        ],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);
  });
}
```

### 3.4 Delete Redux Code

Once ALL screens are migrated and tested:

```bash
# Backup first!
git checkout -b backup-redux

# Delete Redux directory
rm -rf lib/redux

# Delete built_value models (if fully migrated to Freezed)
# Keep for now if still using in some places

# Update pubspec.yaml - remove:
# - redux
# - flutter_redux
# - redux_logging
# - built_value (if fully migrated)
# - built_collection (if fully migrated)

flutter pub get
```

### 3.5 Clean Up Generated Files

```bash
# Remove old .g.dart files from built_value if migrated to Freezed
find lib -name "*.g.dart" -path "*/models/*" -delete

# Regenerate only Freezed/Riverpod files
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Phase 4: Optimization (Weeks 17-18)

### 4.1 Performance Tuning

**Add selective rebuilds:**
```dart
// Before: Rebuilds entire list
@override
Widget build(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(tasksProvider);
  return ListView.builder(...);
}

// After: Only rebuild when specific task changes
@override
Widget build(BuildContext context, WidgetRef ref) {
  final taskIds = ref.watch(tasksProvider.select((async) =>
    async.maybeWhen(
      data: (tasks) => tasks.map((t) => t.docId).toList(),
      orElse: () => <String>[],
    ),
  ));

  return ListView.builder(
    itemCount: taskIds.length,
    itemBuilder: (context, index) {
      return TaskListItemById(taskId: taskIds[index]);
    },
  );
}

class TaskListItemById extends ConsumerWidget {
  const TaskListItemById({required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider(taskId));
    if (task == null) return SizedBox();
    return TaskListItem(task: task);
  }
}
```

### 4.2 Add Persistence

**lib/core/providers/shared_preferences_provider.dart:**
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_preferences_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

// Persist filter settings
@riverpod
class PersistedShowCompleted extends _$PersistedShowCompleted {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool('show_completed') ?? false;
  }

  Future<void> toggle() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    state = AsyncValue.data(!state.value!);
    await prefs.setBool('show_completed', state.value!);
  }
}
```

### 4.3 Add DevTools

**lib/main.dart:**
```dart
void main() async {
  // ... Firebase setup ...

  runApp(
    ProviderScope(
      observers: [
        if (kDebugMode) RiverpodLogger(), // Log provider changes
      ],
      child: TaskMasterApp(),
    ),
  );
}

class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[RIVERPOD] ${provider.name ?? provider.runtimeType}: $newValue');
  }
}
```

### 4.4 Measure Improvements

Run same metrics from Phase 0:

```bash
# File count
find lib -name "*.dart" | wc -l

# Build time
time flutter pub run build_runner build --delete-conflicting-outputs

# Test time
time flutter test

# App bundle size
flutter build apk --analyze-size
```

Record in `.claude/METRICS.md` and compare.

---

## Migration Testing Checklist

During and after migration:

- [ ] All pre-migration tests still passing (101+ tests)
- [ ] All critical path integration tests passing
- [ ] All screen widget tests passing
- [ ] All screens work in Riverpod version
- [ ] Feature flag can toggle between old/new (during migration)
- [ ] New Riverpod tests added for migrated code
- [ ] Manual QA on physical device
- [ ] Performance metrics improved
- [ ] No memory leaks (use DevTools memory profiler)
- [ ] Redux code deleted
- [ ] Documentation updated

**Test count target:** 150+ tests (101 existing + 50+ new)

---

## Risk Mitigation

### Risk: Breaking Changes During Migration

**Mitigation:**
- Use feature flags - can instantly rollback
- Keep Redux working until screen fully migrated
- Comprehensive test coverage before migrating each screen

### Risk: Firestore Stream Performance

**Mitigation:**
- Use `.select()` to minimize rebuilds
- Consider paginated queries for large task lists
- Monitor with Firebase Performance Monitoring

### Risk: Team Unfamiliarity with Riverpod

**Mitigation:**
- Pair programming for first few screens
- Code reviews focus on Riverpod patterns
- Document patterns in `.claude/PATTERNS.md` (create this)

### Risk: Increased Build Times (from Freezed)

**Mitigation:**
- Use `build_runner watch` during development
- Only generate when needed, not on every change
- Consider using records for simple models

---

## Rollback Plan

If something goes catastrophically wrong:

```bash
# Immediate rollback
git checkout main  # Or last working commit
flutter clean
flutter pub get
flutter run

# Partial rollback (keep infrastructure, revert screen)
# Just change feature flag back to false
```

---

## Success Criteria

Migration is complete when:

1. ✅ All screens use Riverpod (no Redux code remaining)
2. ✅ Build time reduced by 40%+
3. ✅ Test time reduced by 30%+
4. ✅ New feature takes 50% less boilerplate
5. ✅ No regressions in functionality
6. ✅ Team feels confident with new patterns

---

## Post-Migration Improvements

After migration, consider:

1. **Offline-First Architecture** - Use Hive/Drift for local DB
2. **GraphQL** - Consider if Firebase is still best fit
3. **Modularization** - Split into feature packages
4. **CI/CD** - Automate testing and deployment
5. **Crash Reporting** - Sentry or Firebase Crashlytics
6. **Analytics** - Understand how users use the app

---

## Next Steps

1. **Review this plan** and `.claude/TESTING_PLAN.md`
2. **Complete testing phase first** (see TESTING_PLAN.md)
   - Write critical path integration tests
   - Write screen widget tests
   - Achieve >70% coverage
3. **Create migration branch** after tests pass: `git checkout -b feat/riverpod-migration`
4. **Start Phase 0** (setup) from this document
5. **Schedule weekly check-ins** to assess progress
6. **Update plans** as you learn new patterns

**DO NOT SKIP THE TESTING PHASE!** Migration without tests is extremely risky.

Questions? Add them to `.claude/QUESTIONS.md` and I'll help answer!
