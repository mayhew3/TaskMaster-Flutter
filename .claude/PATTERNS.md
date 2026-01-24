# Riverpod Patterns for TaskMaster

This document contains common patterns and best practices for using Riverpod in TaskMaster.

---

## Provider Types Quick Reference

### @riverpod (Code Generation - Preferred)

**Use for:** Almost everything - it's the modern approach

```dart
// Simple provider (computed value)
@riverpod
String greeting(GreetingRef ref) {
  final name = ref.watch(userNameProvider);
  return 'Hello, $name!';
}

// Async provider (Future)
@riverpod
Future<User> user(UserRef ref, String userId) async {
  final repo = ref.watch(userRepositoryProvider);
  return await repo.getUser(userId);
}

// Stream provider
@riverpod
Stream<List<Task>> tasks(TasksRef ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTasks();
}

// Stateful provider (Notifier)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

### StateProvider (No Codegen)

**Use for:** Simple local UI state (filters, toggles)

```dart
final showCompletedProvider = StateProvider<bool>((ref) => false);

// In widget
final showCompleted = ref.watch(showCompletedProvider);
ref.read(showCompletedProvider.notifier).state = true;
```

---

## Common Patterns

### Pattern 1: Loading Data from Firestore

```dart
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) async* {
  // Get authenticated user
  final personDocId = await ref.watch(personDocIdProvider.future);
  if (personDocId == null) {
    yield [];
    return;
  }

  // Get Firestore instance
  final firestore = ref.watch(firestoreProvider);

  // Return stream
  yield* firestore
      .collection('tasks')
      .where('personDocId', isEqualTo: personDocId)
      .snapshots()
      .map((snapshot) => _deserializeTasks(snapshot.docs));
}
```

### Pattern 2: Filtering Data

```dart
// Base data provider
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) { ... }

// Filtered view
@riverpod
List<TaskItem> activeTasks(ActiveTasksRef ref) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((t) =>
      t.completionDate == null && t.retired == null
    ).toList(),
    orElse: () => [],
  );
}

// Parameterized filter
@riverpod
List<TaskItem> filteredTasks(
  FilteredTasksRef ref, {
  required bool showCompleted,
  required bool showScheduled,
}) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.where((task) {
      // Filter logic here
    }).toList(),
    orElse: () => [],
  );
}
```

### Pattern 3: Business Logic in Services

```dart
// Service class (pure business logic, no state management)
class TaskCompletionService {
  TaskCompletionService(this._repository);
  final TaskRepository _repository;

  Future<void> completeTask(TaskItem task) async {
    final blueprint = task.createBlueprint()
      ..completionDate = DateTime.now();

    await _repository.updateTask(task.docId, blueprint);
  }
}

// Provider for service
@riverpod
TaskCompletionService taskCompletionService(TaskCompletionServiceRef ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskCompletionService(repo);
}

// Controller for UI actions
@riverpod
class CompleteTask extends _$CompleteTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskCompletionServiceProvider);
      await service.completeTask(task);
    });
  }
}

// In widget
final completeTaskAsync = ref.watch(completeTaskProvider);

completeTaskAsync.when(
  data: (_) => Text('Done'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);

// Trigger action
ref.read(completeTaskProvider.notifier).call(task);
```

### Pattern 4: Combining Multiple Providers

```dart
@riverpod
TaskDetailViewModel taskDetailViewModel(
  TaskDetailViewModelRef ref,
  String taskId,
) {
  final task = ref.watch(taskProvider(taskId));
  final recurrences = ref.watch(taskRecurrencesProvider);
  final sprints = ref.watch(sprintsProvider);

  return TaskDetailViewModel(
    task: task,
    recurrence: recurrences.firstWhere(
      (r) => r.docId == task?.recurrenceDocId,
      orElse: () => null,
    ),
    sprints: sprints.where((s) =>
      s.sprintAssignments.any((sa) => sa.taskDocId == taskId)
    ).toList(),
  );
}
```

### Pattern 5: Watching Only What You Need (Performance)

```dart
// BAD: Rebuilds on any task change
@override
Widget build(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(tasksProvider);
  return Text('Count: ${tasks.length}');
}

// GOOD: Only rebuilds when count changes
@override
Widget build(BuildContext context, WidgetRef ref) {
  final taskCount = ref.watch(
    tasksProvider.select((async) => async.maybeWhen(
      data: (tasks) => tasks.length,
      orElse: () => 0,
    )),
  );
  return Text('Count: $taskCount');
}

// BETTER: Dedicated provider
@riverpod
int taskCount(TaskCountRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.length,
    orElse: () => 0,
  );
}
```

### Pattern 6: Navigation with go_router

```dart
// Define routes
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            path: 'tasks/:id',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return TaskDetailScreen(taskId: taskId);
            },
          ),
        ],
      ),
    ],
  );
}

// Navigate
context.push('/tasks/$taskId');
context.go('/');
context.pop();

// In MaterialApp
@override
Widget build(BuildContext context, WidgetRef ref) {
  final router = ref.watch(goRouterProvider);

  return MaterialApp.router(
    routerConfig: router,
  );
}
```

### Pattern 7: Error Handling

```dart
@riverpod
class UpdateTask extends _$UpdateTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task, TaskItemBlueprint blueprint) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateTask(task.docId, blueprint);
    });

    // Handle errors in UI
    if (state.hasError) {
      // Could dispatch to error notifier, show snackbar, etc.
      ref.read(errorNotifierProvider.notifier).add(state.error!);
    }
  }
}

// In widget
ref.listen(updateTaskProvider, (previous, next) {
  next.when(
    data: (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task updated')),
      );
    },
    error: (err, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $err'),
          backgroundColor: Colors.red,
        ),
      );
    },
    loading: () {},
  );
});
```

### Pattern 8: Dependency Injection

```dart
// Define interface
abstract class TaskRepository {
  Future<void> addTask(TaskItemBlueprint blueprint);
}

// Implement
class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<void> addTask(TaskItemBlueprint blueprint) async {
    // Implementation
  }
}

// Provide
@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreTaskRepository(firestore);
}

// Use in tests
test('can mock repository', () {
  final container = ProviderContainer(
    overrides: [
      taskRepositoryProvider.overrideWithValue(MockTaskRepository()),
    ],
  );

  // Test using mocked repo
});
```

### Pattern 9: Family Providers (Parameterized)

```dart
// Get individual task by ID
@riverpod
TaskItem? task(TaskRef ref, String taskId) {
  final tasksAsync = ref.watch(tasksProvider);

  return tasksAsync.maybeWhen(
    data: (tasks) => tasks.firstWhere(
      (t) => t.docId == taskId,
      orElse: () => null,
    ),
    orElse: () => null,
  );
}

// Usage
final task = ref.watch(taskProvider('task-123'));
```

### Pattern 10: Keeping Provider Alive

```dart
// By default, providers auto-dispose when no longer watched
// To keep alive (e.g., for cache):

@Riverpod(keepAlive: true)
Stream<List<TaskItem>> tasks(TasksRef ref) {
  // This will stay alive even when not watched
}

// Or selectively keep alive
@riverpod
Future<User> user(UserRef ref) async {
  // Keep this result cached for 5 minutes
  ref.cacheFor(Duration(minutes: 5));

  return await fetchUser();
}

// Helper extension
extension CacheForExtension on Ref {
  void cacheFor(Duration duration) {
    final timer = Timer(duration, () {
      invalidateSelf();
    });
    onDispose(() => timer.cancel());
  }
}
```

---

## Testing Patterns

### Unit Test

```dart
test('taskCount returns correct count', () {
  final container = ProviderContainer(
    overrides: [
      tasksProvider.overrideWith((ref) => Stream.value([
        TaskItem((b) => b..docId = '1'..name = 'Task 1'),
        TaskItem((b) => b..docId = '2'..name = 'Task 2'),
      ])),
    ],
  );

  expect(container.read(taskCountProvider), 2);
});
```

### Widget Test

```dart
testWidgets('displays task list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tasksProvider.overrideWith((ref) => Stream.value([
          TaskItem((b) => b..docId = '1'..name = 'Test Task'),
        ])),
      ],
      child: MaterialApp(home: TaskListScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Test Task'), findsOneWidget);
});
```

### Integration Test

```dart
void main() {
  testWidgets('complete task flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    // Tap checkbox
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Verify task completed
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
```

---

## Dos and Don'ts

### ✅ DO

- Use `@riverpod` annotation (code generation) for all providers
- Keep business logic in service classes, not providers
- Use `.select()` to optimize rebuilds
- Handle loading and error states with `AsyncValue`
- Write unit tests for business logic services
- Use family providers for parameterized data
- Dispose resources in `ref.onDispose()`

### ❌ DON'T

- Don't use `context.read()` or `context.watch()` - use `ref` in ConsumerWidget
- Don't put business logic directly in providers - use services
- Don't call `ref.read()` in build method - use `ref.watch()`
- Don't forget to handle loading/error states in UI
- Don't mix Redux and Riverpod for same feature - pick one
- Don't create new ProviderContainer per widget - use ProviderScope at root
- **Don't use `async*` with `ref.watch()` after `await` in stream providers** ⚠️ (see Common Gotchas below)

---

## Common Gotchas & Solutions

### ⚠️ Gotcha 1: Stream Providers with Async Dependencies

**Problem:** Using `async*` generators with `await ref.watch()` causes providers to not track dependencies properly.

**❌ WRONG:**
```dart
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) async* {
  final personDocId = await ref.watch(personDocIdProvider.future);
  // ❌ Riverpod can't track dependencies after await!

  final firestore = ref.watch(firestoreProvider);
  // ❌ Provider may not rebuild when firestore changes

  yield* firestore.collection('tasks').snapshots()...;
}
```

**Symptoms:**
- Blank screen / no data loading
- Provider stuck in loading state
- Data doesn't update when dependencies change
- Infinite rebuild loops

**✅ CORRECT:**
```dart
@riverpod
Stream<List<TaskItem>> tasks(TasksRef ref) {
  // ✅ Watch all dependencies synchronously FIRST
  final firestore = ref.watch(firestoreProvider);
  final personDocIdAsync = ref.watch(personDocIdProvider);

  // ✅ Handle async with .when() - returns Stream immediately
  return personDocIdAsync.when(
    data: (personDocId) {
      if (personDocId == null) return Stream.value([]);

      return firestore
          .collection('tasks')
          .where('personDocId', isEqualTo: personDocId)
          .snapshots()
          .map((snapshot) => ...);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}
```

**Key Points:**
- Stream providers should return `Stream<T>`, not use `async*`
- Watch all dependencies before any async operations
- Use `.when()` to handle `AsyncValue` dependencies
- Return a Stream immediately (even if it's `Stream.value([])`)

### ⚠️ Gotcha 2: Provider Auto-Dispose Causing Infinite Rebuilds

**Problem:** Singleton resources (like Firebase instances) being recreated on every rebuild.

**❌ WRONG:**
```dart
@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  final instance = FirebaseFirestore.instance;

  // ❌ This gets called every time provider recreates!
  instance.useFirestoreEmulator('127.0.0.1', 8085);
  instance.settings = const Settings(...);

  return instance;
}
```

**Symptoms:**
- Infinite console logs repeating the same message
- App performance degradation
- Emulator connection messages flooding logs

**✅ CORRECT:**
```dart
@Riverpod(keepAlive: true)  // ✅ Keep provider alive forever
FirebaseFirestore firestore(FirestoreRef ref) {
  // ✅ Only returns singleton, configuration done elsewhere (main.dart)
  return FirebaseFirestore.instance;
}

@Riverpod(keepAlive: true)  // ✅ Auth provider also needs keepAlive
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}
```

**Key Points:**
- Use `@Riverpod(keepAlive: true)` for singleton resources
- Configure Firebase in `main.dart` before `runApp()`
- Keep providers simple - just return the instance
- Auto-dispose is great for data providers, bad for singletons

### ⚠️ Gotcha 3: Missing Scaffold in Screen Widgets

**Problem:** Forgetting that screens need full Scaffold structure.

**❌ WRONG:**
```dart
class StatsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(  // ❌ No AppBar, drawer, bottomNav!
      child: Column(children: [...]),
    );
  }
}
```

**Symptoms:**
- Missing navigation bars
- No way to access drawer menu
- Screen looks broken / incomplete

**✅ CORRECT:**
```dart
class StatsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Stats')),
      body: Center(child: Column(children: [...])),
      drawer: TaskMainMenu(),
      bottomNavigationBar: TabSelector(),
    );
  }
}
```

**Key Points:**
- Always include full Scaffold structure for screens
- Match existing Redux screen layout exactly
- Include drawer and bottomNavigationBar for consistency

---

## Debugging Tips

### Print Provider Changes

```dart
class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[${provider.name ?? provider.runtimeType}] $newValue');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    print('[${provider.name ?? provider.runtimeType}] ERROR: $error');
  }
}

// In main.dart
runApp(
  ProviderScope(
    observers: [RiverpodLogger()],
    child: MyApp(),
  ),
);
```

### Use Riverpod DevTools

In Flutter DevTools, you can:
- See provider dependency graph
- Inspect provider state
- Manually trigger refreshes

Access via: DevTools → Riverpod tab

---

## Migration from Redux

### Redux → Riverpod Mapping

| Redux Concept | Riverpod Equivalent |
|---------------|---------------------|
| Store | ProviderScope |
| State | Provider value |
| Action | Method call on notifier |
| Reducer | Notifier's `build()` and methods |
| Middleware | Service class or `ref.listen()` |
| Selector | Computed provider or `.select()` |
| StoreConnector | ConsumerWidget + ref.watch() |
| ViewModel | Computed provider |

### Example Conversion

**Before (Redux):**
```dart
// Action
class UpdateTaskAction {
  final TaskItem task;
  UpdateTaskAction(this.task);
}

// Middleware
store.dispatch(UpdateTaskAction(task));

// Reducer
taskReducer = (state, action) {
  if (action is UpdateTaskAction) {
    return state.rebuild((b) => b..tasks.update(action.task));
  }
}

// Widget
StoreConnector<AppState, List<TaskItem>>(
  converter: (store) => store.state.tasks,
  builder: (context, tasks) => TaskList(tasks),
)
```

**After (Riverpod):**
```dart
// Provider
@riverpod
class UpdateTask extends _$UpdateTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task) async {
    state = AsyncValue.guard(() async {
      await ref.read(taskRepositoryProvider).updateTask(task);
    });
  }
}

// Widget
class TaskWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    return tasks.when(
      data: (tasks) => TaskList(tasks),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}

// Trigger update
ref.read(updateTaskProvider.notifier).call(task);
```

---

## Date/Time Handling Pattern

### ✅ Use Standard Dart APIs (Preferred)

For most date formatting and timezone conversion, use Dart's built-in APIs:

```dart
// Date formatting
final formatted = DateFormat('MM-dd-yyyy').format(dateTime.toLocal());
final time = DateFormat('hh:mm a').format(dateTime.toLocal());

// Time ago
final ago = timeago.format(dateTime, allowFromNow: true);

// Jiffy for advanced date manipulation
final jiffy = Jiffy.parseFromDateTime(dateTime.toLocal());
final relative = jiffy.fromNow(); // "2 days ago"
```

### ✅ Initialize Timezone in main() (For Notifications)

For `flutter_local_notifications.zonedSchedule()` which requires timezone support:

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database ONCE at startup
  tz.initializeTimeZones();
  final timezoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneName));

  await Firebase.initializeApp(...);
  runApp(MyApp());
}

// Later in NotificationHelper
final localTime = tz.TZDateTime.from(scheduledTime, tz.local);
await plugin.zonedSchedule(id, title, body, localTime, ...);
```

### ❌ Avoid Async Providers for Singletons

**Don't** create async providers for one-time initialization:

```dart
// ❌ BAD - Creates complexity
@Riverpod(keepAlive: true)
Future<TimezoneHelper> timezoneHelper(ref) async {
  return await TimezoneHelper.createLocal();
}

// Requires nested .when() blocks everywhere
return timezoneHelperAsync.when(
  data: (helper) {
    return tasksAsync.when(...);
  },
  loading: () => ...,
  error: () => ...,
);
```

**Do** initialize in `main()` instead:

```dart
// ✅ GOOD - Initialize once at startup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependency();
  runApp(MyApp());
}

// Screens stay simple
return tasksAsync.when(
  data: (tasks) => TaskList(tasks),
  loading: () => ...,
  error: () => ...,
);
```

### Benefits

1. **Simpler Code** - No nested async handling
2. **Better Performance** - One-time initialization
3. **Standard Pattern** - Follows Flutter best practices
4. **Easier Testing** - Dependencies initialized before tests

---

## Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)

## Questions?

Add them to `.claude/QUESTIONS.md` and we'll address them!
