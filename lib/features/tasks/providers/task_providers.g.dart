// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks tasks that failed Firestore deserialization.
/// Displayed in the UI with warning styling so the user knows something is wrong.

@ProviderFor(BadSchemaTasks)
final badSchemaTasksProvider = BadSchemaTasksProvider._();

/// Tracks tasks that failed Firestore deserialization.
/// Displayed in the UI with warning styling so the user knows something is wrong.
final class BadSchemaTasksProvider
    extends $NotifierProvider<BadSchemaTasks, List<BadSchemaTask>> {
  /// Tracks tasks that failed Firestore deserialization.
  /// Displayed in the UI with warning styling so the user knows something is wrong.
  BadSchemaTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'badSchemaTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$badSchemaTasksHash();

  @$internal
  @override
  BadSchemaTasks create() => BadSchemaTasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BadSchemaTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BadSchemaTask>>(value),
    );
  }
}

String _$badSchemaTasksHash() => r'97f06982c32ba51ec0e4d3ca0021935a2c707b33';

/// Tracks tasks that failed Firestore deserialization.
/// Displayed in the UI with warning styling so the user knows something is wrong.

abstract class _$BadSchemaTasks extends $Notifier<List<BadSchemaTask>> {
  List<BadSchemaTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<BadSchemaTask>, List<BadSchemaTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BadSchemaTask>, List<BadSchemaTask>>,
              List<BadSchemaTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Stream of incomplete tasks for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
/// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].

@ProviderFor(tasks)
final tasksProvider = TasksProvider._();

/// Stream of incomplete tasks for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
/// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].

final class TasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          Stream<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $StreamProvider<List<TaskItem>> {
  /// Stream of incomplete tasks for the current user.
  /// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
  /// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].
  TasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskItem>> create(Ref ref) {
    return tasks(ref);
  }
}

String _$tasksHash() => r'fd9a4a86f7d30f65c972459dddd0f14d2fbcb033';

/// Stream of active (non-retired) tasks across all members of the current
/// user's family (TM-335). Includes completed rows so the Family tab can
/// reveal them when "Show Completed" is on. Empty when the user is solo.

@ProviderFor(familyTasks)
final familyTasksProvider = FamilyTasksProvider._();

/// Stream of active (non-retired) tasks across all members of the current
/// user's family (TM-335). Includes completed rows so the Family tab can
/// reveal them when "Show Completed" is on. Empty when the user is solo.

final class FamilyTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          Stream<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $StreamProvider<List<TaskItem>> {
  /// Stream of active (non-retired) tasks across all members of the current
  /// user's family (TM-335). Includes completed rows so the Family tab can
  /// reveal them when "Show Completed" is on. Empty when the user is solo.
  FamilyTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskItem>> create(Ref ref) {
    return familyTasks(ref);
  }
}

String _$familyTasksHash() => r'19ee8ff23be068cbcbf6fe40573b15144f92e290';

/// Stream of task recurrences for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.

@ProviderFor(taskRecurrences)
final taskRecurrencesProvider = TaskRecurrencesProvider._();

/// Stream of task recurrences for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.

final class TaskRecurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskRecurrence>>,
          List<TaskRecurrence>,
          Stream<List<TaskRecurrence>>
        >
    with
        $FutureModifier<List<TaskRecurrence>>,
        $StreamProvider<List<TaskRecurrence>> {
  /// Stream of task recurrences for the current user.
  /// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
  TaskRecurrencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRecurrencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRecurrencesHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskRecurrence>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskRecurrence>> create(Ref ref) {
    return taskRecurrences(ref);
  }
}

String _$taskRecurrencesHash() => r'57d6beeb35ac4aae222bac6d7a8b68d4a39ff4d7';

/// Stream of tasks with their recurrences populated.
/// Combines the two Drift streams so recurrences are always linked on each emit.

@ProviderFor(tasksWithRecurrences)
final tasksWithRecurrencesProvider = TasksWithRecurrencesProvider._();

/// Stream of tasks with their recurrences populated.
/// Combines the two Drift streams so recurrences are always linked on each emit.

final class TasksWithRecurrencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          Stream<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $StreamProvider<List<TaskItem>> {
  /// Stream of tasks with their recurrences populated.
  /// Combines the two Drift streams so recurrences are always linked on each emit.
  TasksWithRecurrencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksWithRecurrencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksWithRecurrencesHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskItem>> create(Ref ref) {
    return tasksWithRecurrences(ref);
  }
}

String _$tasksWithRecurrencesHash() =>
    r'd72795364dff685d329e5388e759bd36e526c01f';

/// Get a specific task by ID with recurrence populated.
/// Searches four sources in priority order:
///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)

@ProviderFor(task)
final taskProvider = TaskFamily._();

/// Get a specific task by ID with recurrence populated.
/// Searches four sources in priority order:
///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)

final class TaskProvider
    extends $FunctionalProvider<TaskItem?, TaskItem?, TaskItem?>
    with $Provider<TaskItem?> {
  /// Get a specific task by ID with recurrence populated.
  /// Searches four sources in priority order:
  ///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
  ///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
  ///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
  ///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)
  TaskProvider._({
    required TaskFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskHash();

  @override
  String toString() {
    return r'taskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TaskItem?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskItem? create(Ref ref) {
    final argument = this.argument as String;
    return task(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskItem? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskItem?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskHash() => r'ca533fde28daff62ea0344eabae13071fd35cfc3';

/// Get a specific task by ID with recurrence populated.
/// Searches four sources in priority order:
///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)

final class TaskFamily extends $Family
    with $FunctionalFamilyOverride<TaskItem?, String> {
  TaskFamily._()
    : super(
        retry: null,
        name: r'taskProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Get a specific task by ID with recurrence populated.
  /// Searches four sources in priority order:
  ///   1. tasksWithRecurrencesProvider (incomplete tasks from Drift — fastest)
  ///   2. recentlyCompletedTasksProvider (just-completed tasks in this session)
  ///   3. olderCompletedTasksBatchesProvider (paginated completed tasks from Firestore)
  ///   4. taskFromDbProvider (direct Drift lookup — covers force-quit + restart)

  TaskProvider call(String taskId) =>
      TaskProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskProvider';
}

/// Stream of a single task directly from Drift by docId, with recurrence populated.
/// Has NO completionDate filter — returns completed tasks too.
/// Used as the ultimate fallback in [taskProvider] for cases where the task
/// exists in the local DB but is absent from all in-memory providers
/// (e.g., completed task after a force-quit + restart before any batches load).

@ProviderFor(taskFromDb)
final taskFromDbProvider = TaskFromDbFamily._();

/// Stream of a single task directly from Drift by docId, with recurrence populated.
/// Has NO completionDate filter — returns completed tasks too.
/// Used as the ultimate fallback in [taskProvider] for cases where the task
/// exists in the local DB but is absent from all in-memory providers
/// (e.g., completed task after a force-quit + restart before any batches load).

final class TaskFromDbProvider
    extends
        $FunctionalProvider<AsyncValue<TaskItem?>, TaskItem?, Stream<TaskItem?>>
    with $FutureModifier<TaskItem?>, $StreamProvider<TaskItem?> {
  /// Stream of a single task directly from Drift by docId, with recurrence populated.
  /// Has NO completionDate filter — returns completed tasks too.
  /// Used as the ultimate fallback in [taskProvider] for cases where the task
  /// exists in the local DB but is absent from all in-memory providers
  /// (e.g., completed task after a force-quit + restart before any batches load).
  TaskFromDbProvider._({
    required TaskFromDbFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskFromDbProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskFromDbHash();

  @override
  String toString() {
    return r'taskFromDbProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TaskItem?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<TaskItem?> create(Ref ref) {
    final argument = this.argument as String;
    return taskFromDb(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskFromDbProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskFromDbHash() => r'fce5da45d3bba89a7186b8251bd330c655e79aba';

/// Stream of a single task directly from Drift by docId, with recurrence populated.
/// Has NO completionDate filter — returns completed tasks too.
/// Used as the ultimate fallback in [taskProvider] for cases where the task
/// exists in the local DB but is absent from all in-memory providers
/// (e.g., completed task after a force-quit + restart before any batches load).

final class TaskFromDbFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TaskItem?>, String> {
  TaskFromDbFamily._()
    : super(
        retry: null,
        name: r'taskFromDbProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Stream of a single task directly from Drift by docId, with recurrence populated.
  /// Has NO completionDate filter — returns completed tasks too.
  /// Used as the ultimate fallback in [taskProvider] for cases where the task
  /// exists in the local DB but is absent from all in-memory providers
  /// (e.g., completed task after a force-quit + restart before any batches load).

  TaskFromDbProvider call(String taskId) =>
      TaskFromDbProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskFromDbProvider';
}

/// Tracks recently completed tasks to keep them visible temporarily
/// This matches Redux's recentlyCompleted state which prevents completed
/// tasks from immediately disappearing when filters are applied

@ProviderFor(RecentlyCompletedTasks)
final recentlyCompletedTasksProvider = RecentlyCompletedTasksProvider._();

/// Tracks recently completed tasks to keep them visible temporarily
/// This matches Redux's recentlyCompleted state which prevents completed
/// tasks from immediately disappearing when filters are applied
final class RecentlyCompletedTasksProvider
    extends $NotifierProvider<RecentlyCompletedTasks, List<TaskItem>> {
  /// Tracks recently completed tasks to keep them visible temporarily
  /// This matches Redux's recentlyCompleted state which prevents completed
  /// tasks from immediately disappearing when filters are applied
  RecentlyCompletedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyCompletedTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyCompletedTasksHash();

  @$internal
  @override
  RecentlyCompletedTasks create() => RecentlyCompletedTasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskItem>>(value),
    );
  }
}

String _$recentlyCompletedTasksHash() =>
    r'19b8ee5496eea5907e9cf17f63a95f7ad4f19ad1';

/// Tracks recently completed tasks to keep them visible temporarily
/// This matches Redux's recentlyCompleted state which prevents completed
/// tasks from immediately disappearing when filters are applied

abstract class _$RecentlyCompletedTasks extends $Notifier<List<TaskItem>> {
  List<TaskItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<TaskItem>, List<TaskItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TaskItem>, List<TaskItem>>,
              List<TaskItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Side table mapping recently-completed task docId → its index in the
/// Tasks tab base list (tasksProvider) at the moment of completion.
///
/// Used by filteredTasksProvider to re-insert just-completed tasks at their
/// original position instead of appending them to the end — otherwise a
/// completed task visibly jumps to the bottom of its group (TM-339 Tasks
/// tab follow-up). The Sprint screen has its own ordering mechanism based
/// on sprint.sprintAssignments and does not use this.

@ProviderFor(RecentlyCompletedIndices)
final recentlyCompletedIndicesProvider = RecentlyCompletedIndicesProvider._();

/// Side table mapping recently-completed task docId → its index in the
/// Tasks tab base list (tasksProvider) at the moment of completion.
///
/// Used by filteredTasksProvider to re-insert just-completed tasks at their
/// original position instead of appending them to the end — otherwise a
/// completed task visibly jumps to the bottom of its group (TM-339 Tasks
/// tab follow-up). The Sprint screen has its own ordering mechanism based
/// on sprint.sprintAssignments and does not use this.
final class RecentlyCompletedIndicesProvider
    extends $NotifierProvider<RecentlyCompletedIndices, Map<String, int>> {
  /// Side table mapping recently-completed task docId → its index in the
  /// Tasks tab base list (tasksProvider) at the moment of completion.
  ///
  /// Used by filteredTasksProvider to re-insert just-completed tasks at their
  /// original position instead of appending them to the end — otherwise a
  /// completed task visibly jumps to the bottom of its group (TM-339 Tasks
  /// tab follow-up). The Sprint screen has its own ordering mechanism based
  /// on sprint.sprintAssignments and does not use this.
  RecentlyCompletedIndicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyCompletedIndicesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyCompletedIndicesHash();

  @$internal
  @override
  RecentlyCompletedIndices create() => RecentlyCompletedIndices();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$recentlyCompletedIndicesHash() =>
    r'8d7175a3a9c853f0261863e9c1093b1acba10663';

/// Side table mapping recently-completed task docId → its index in the
/// Tasks tab base list (tasksProvider) at the moment of completion.
///
/// Used by filteredTasksProvider to re-insert just-completed tasks at their
/// original position instead of appending them to the end — otherwise a
/// completed task visibly jumps to the bottom of its group (TM-339 Tasks
/// tab follow-up). The Sprint screen has its own ordering mechanism based
/// on sprint.sprintAssignments and does not use this.

abstract class _$RecentlyCompletedIndices extends $Notifier<Map<String, int>> {
  Map<String, int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, int>, Map<String, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, int>, Map<String, int>>,
              Map<String, int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Tracks tasks currently being completed (optimistic UI)
/// This enables immediate visual feedback (pending state) before Firestore confirms

@ProviderFor(PendingTasks)
final pendingTasksProvider = PendingTasksProvider._();

/// Tracks tasks currently being completed (optimistic UI)
/// This enables immediate visual feedback (pending state) before Firestore confirms
final class PendingTasksProvider
    extends $NotifierProvider<PendingTasks, Map<String, TaskItem>> {
  /// Tracks tasks currently being completed (optimistic UI)
  /// This enables immediate visual feedback (pending state) before Firestore confirms
  PendingTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTasksHash();

  @$internal
  @override
  PendingTasks create() => PendingTasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TaskItem>>(value),
    );
  }
}

String _$pendingTasksHash() => r'7eb30a184c95dda88b9357f1cbc25c41ea636066';

/// Tracks tasks currently being completed (optimistic UI)
/// This enables immediate visual feedback (pending state) before Firestore confirms

abstract class _$PendingTasks extends $Notifier<Map<String, TaskItem>> {
  Map<String, TaskItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, TaskItem>, Map<String, TaskItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, TaskItem>, Map<String, TaskItem>>,
              Map<String, TaskItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Tasks with pending completion state merged in (optimistic UI overlay)
/// This provider overlays optimistic pending state on top of Firestore data

@ProviderFor(tasksWithPendingState)
final tasksWithPendingStateProvider = TasksWithPendingStateProvider._();

/// Tasks with pending completion state merged in (optimistic UI overlay)
/// This provider overlays optimistic pending state on top of Firestore data

final class TasksWithPendingStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Tasks with pending completion state merged in (optimistic UI overlay)
  /// This provider overlays optimistic pending state on top of Firestore data
  TasksWithPendingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksWithPendingStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksWithPendingStateHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    return tasksWithPendingState(ref);
  }
}

String _$tasksWithPendingStateHash() =>
    r'6c263901e0c9a668ae3dd53568f0d9e83a9daf14';

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).

@ProviderFor(tasksForRecurrence)
final tasksForRecurrenceProvider = TasksForRecurrenceFamily._();

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).

final class TasksForRecurrenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          Stream<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $StreamProvider<List<TaskItem>> {
  /// Stream of all tasks for a specific recurrence, including retired ones.
  /// This shows the full history of a recurring task for debugging/inspection.
  /// Ordered by recurIteration descending (newest first).
  TasksForRecurrenceProvider._({
    required TasksForRecurrenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tasksForRecurrenceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tasksForRecurrenceHash();

  @override
  String toString() {
    return r'tasksForRecurrenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskItem>> create(Ref ref) {
    final argument = this.argument as String;
    return tasksForRecurrence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForRecurrenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tasksForRecurrenceHash() =>
    r'8a37dacf5c6f0106991c2a05b1c1533e594969fe';

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).

final class TasksForRecurrenceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskItem>>, String> {
  TasksForRecurrenceFamily._()
    : super(
        retry: null,
        name: r'tasksForRecurrenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Stream of all tasks for a specific recurrence, including retired ones.
  /// This shows the full history of a recurring task for debugging/inspection.
  /// Ordered by recurIteration descending (newest first).

  TasksForRecurrenceProvider call(String recurrenceDocId) =>
      TasksForRecurrenceProvider._(argument: recurrenceDocId, from: this);

  @override
  String toString() => r'tasksForRecurrenceProvider';
}

/// Progressively loads completed tasks using cursor-based pagination.
/// Triggered when the user enables "Show Completed".
/// Uses one-time fetches (not real-time listeners) in fixed-size batches.

@ProviderFor(OlderCompletedTasksBatches)
final olderCompletedTasksBatchesProvider =
    OlderCompletedTasksBatchesProvider._();

/// Progressively loads completed tasks using cursor-based pagination.
/// Triggered when the user enables "Show Completed".
/// Uses one-time fetches (not real-time listeners) in fixed-size batches.
final class OlderCompletedTasksBatchesProvider
    extends $NotifierProvider<OlderCompletedTasksBatches, OlderCompletedState> {
  /// Progressively loads completed tasks using cursor-based pagination.
  /// Triggered when the user enables "Show Completed".
  /// Uses one-time fetches (not real-time listeners) in fixed-size batches.
  OlderCompletedTasksBatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'olderCompletedTasksBatchesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$olderCompletedTasksBatchesHash();

  @$internal
  @override
  OlderCompletedTasksBatches create() => OlderCompletedTasksBatches();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OlderCompletedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OlderCompletedState>(value),
    );
  }
}

String _$olderCompletedTasksBatchesHash() =>
    r'37015ced9f9d93417981df0692c6479872ebc3bb';

/// Progressively loads completed tasks using cursor-based pagination.
/// Triggered when the user enables "Show Completed".
/// Uses one-time fetches (not real-time listeners) in fixed-size batches.

abstract class _$OlderCompletedTasksBatches
    extends $Notifier<OlderCompletedState> {
  OlderCompletedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OlderCompletedState, OlderCompletedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OlderCompletedState, OlderCompletedState>,
              OlderCompletedState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
