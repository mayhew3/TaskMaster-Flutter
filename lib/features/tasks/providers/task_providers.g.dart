// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksHash() => r'cb5697764d48e5a3906de47f58a0165159ae7067';

/// Stream of incomplete tasks for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
/// Completed tasks are loaded on demand via [OlderCompletedTasksBatches].
///
/// Copied from [tasks].
@ProviderFor(tasks)
final tasksProvider = AutoDisposeStreamProvider<List<TaskItem>>.internal(
  tasks,
  name: r'tasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksRef = AutoDisposeStreamProviderRef<List<TaskItem>>;
String _$taskRecurrencesHash() => r'c3d03c40cb17dc6353864bf8228dc7660b4f2ebb';

/// Stream of task recurrences for the current user.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
///
/// Copied from [taskRecurrences].
@ProviderFor(taskRecurrences)
final taskRecurrencesProvider =
    AutoDisposeStreamProvider<List<TaskRecurrence>>.internal(
      taskRecurrences,
      name: r'taskRecurrencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskRecurrencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRecurrencesRef = AutoDisposeStreamProviderRef<List<TaskRecurrence>>;
String _$tasksWithRecurrencesHash() =>
    r'd72795364dff685d329e5388e759bd36e526c01f';

/// Stream of tasks with their recurrences populated.
/// Combines the two Drift streams so recurrences are always linked on each emit.
///
/// Copied from [tasksWithRecurrences].
@ProviderFor(tasksWithRecurrences)
final tasksWithRecurrencesProvider = StreamProvider<List<TaskItem>>.internal(
  tasksWithRecurrences,
  name: r'tasksWithRecurrencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksWithRecurrencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksWithRecurrencesRef = StreamProviderRef<List<TaskItem>>;
String _$taskHash() => r'f6a858a1ee6af1e76006b0da24add92c64f33dea';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get a specific task by ID with recurrence populated.
/// Falls back to already-loaded older completed task batches if not found
/// in the base query. Does not fetch from Firestore by ID.
///
/// Copied from [task].
@ProviderFor(task)
const taskProvider = TaskFamily();

/// Get a specific task by ID with recurrence populated.
/// Falls back to already-loaded older completed task batches if not found
/// in the base query. Does not fetch from Firestore by ID.
///
/// Copied from [task].
class TaskFamily extends Family<TaskItem?> {
  /// Get a specific task by ID with recurrence populated.
  /// Falls back to already-loaded older completed task batches if not found
  /// in the base query. Does not fetch from Firestore by ID.
  ///
  /// Copied from [task].
  const TaskFamily();

  /// Get a specific task by ID with recurrence populated.
  /// Falls back to already-loaded older completed task batches if not found
  /// in the base query. Does not fetch from Firestore by ID.
  ///
  /// Copied from [task].
  TaskProvider call(String taskId) {
    return TaskProvider(taskId);
  }

  @override
  TaskProvider getProviderOverride(covariant TaskProvider provider) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskProvider';
}

/// Get a specific task by ID with recurrence populated.
/// Falls back to already-loaded older completed task batches if not found
/// in the base query. Does not fetch from Firestore by ID.
///
/// Copied from [task].
class TaskProvider extends AutoDisposeProvider<TaskItem?> {
  /// Get a specific task by ID with recurrence populated.
  /// Falls back to already-loaded older completed task batches if not found
  /// in the base query. Does not fetch from Firestore by ID.
  ///
  /// Copied from [task].
  TaskProvider(String taskId)
    : this._internal(
        (ref) => task(ref as TaskRef, taskId),
        from: taskProvider,
        name: r'taskProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskHash,
        dependencies: TaskFamily._dependencies,
        allTransitiveDependencies: TaskFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(TaskItem? Function(TaskRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TaskProvider._internal(
        (ref) => create(ref as TaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<TaskItem?> createElement() {
    return _TaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskRef on AutoDisposeProviderRef<TaskItem?> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskProviderElement extends AutoDisposeProviderElement<TaskItem?>
    with TaskRef {
  _TaskProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskProvider).taskId;
}

String _$tasksWithPendingStateHash() =>
    r'ef00338798a863ef28b0f36cd5743628fb821034';

/// Tasks with pending completion state merged in (optimistic UI overlay)
/// This provider overlays optimistic pending state on top of Firestore data
///
/// Copied from [tasksWithPendingState].
@ProviderFor(tasksWithPendingState)
final tasksWithPendingStateProvider =
    AutoDisposeFutureProvider<List<TaskItem>>.internal(
      tasksWithPendingState,
      name: r'tasksWithPendingStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tasksWithPendingStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksWithPendingStateRef = AutoDisposeFutureProviderRef<List<TaskItem>>;
String _$tasksForRecurrenceHash() =>
    r'4753667465c437f9fbc6a34e9b829ffe98cf01be';

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).
///
/// Copied from [tasksForRecurrence].
@ProviderFor(tasksForRecurrence)
const tasksForRecurrenceProvider = TasksForRecurrenceFamily();

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).
///
/// Copied from [tasksForRecurrence].
class TasksForRecurrenceFamily extends Family<AsyncValue<List<TaskItem>>> {
  /// Stream of all tasks for a specific recurrence, including retired ones.
  /// This shows the full history of a recurring task for debugging/inspection.
  /// Ordered by recurIteration descending (newest first).
  ///
  /// Copied from [tasksForRecurrence].
  const TasksForRecurrenceFamily();

  /// Stream of all tasks for a specific recurrence, including retired ones.
  /// This shows the full history of a recurring task for debugging/inspection.
  /// Ordered by recurIteration descending (newest first).
  ///
  /// Copied from [tasksForRecurrence].
  TasksForRecurrenceProvider call(String recurrenceDocId) {
    return TasksForRecurrenceProvider(recurrenceDocId);
  }

  @override
  TasksForRecurrenceProvider getProviderOverride(
    covariant TasksForRecurrenceProvider provider,
  ) {
    return call(provider.recurrenceDocId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksForRecurrenceProvider';
}

/// Stream of all tasks for a specific recurrence, including retired ones.
/// This shows the full history of a recurring task for debugging/inspection.
/// Ordered by recurIteration descending (newest first).
///
/// Copied from [tasksForRecurrence].
class TasksForRecurrenceProvider
    extends AutoDisposeStreamProvider<List<TaskItem>> {
  /// Stream of all tasks for a specific recurrence, including retired ones.
  /// This shows the full history of a recurring task for debugging/inspection.
  /// Ordered by recurIteration descending (newest first).
  ///
  /// Copied from [tasksForRecurrence].
  TasksForRecurrenceProvider(String recurrenceDocId)
    : this._internal(
        (ref) =>
            tasksForRecurrence(ref as TasksForRecurrenceRef, recurrenceDocId),
        from: tasksForRecurrenceProvider,
        name: r'tasksForRecurrenceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksForRecurrenceHash,
        dependencies: TasksForRecurrenceFamily._dependencies,
        allTransitiveDependencies:
            TasksForRecurrenceFamily._allTransitiveDependencies,
        recurrenceDocId: recurrenceDocId,
      );

  TasksForRecurrenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.recurrenceDocId,
  }) : super.internal();

  final String recurrenceDocId;

  @override
  Override overrideWith(
    Stream<List<TaskItem>> Function(TasksForRecurrenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksForRecurrenceProvider._internal(
        (ref) => create(ref as TasksForRecurrenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        recurrenceDocId: recurrenceDocId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TaskItem>> createElement() {
    return _TasksForRecurrenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForRecurrenceProvider &&
        other.recurrenceDocId == recurrenceDocId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, recurrenceDocId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksForRecurrenceRef on AutoDisposeStreamProviderRef<List<TaskItem>> {
  /// The parameter `recurrenceDocId` of this provider.
  String get recurrenceDocId;
}

class _TasksForRecurrenceProviderElement
    extends AutoDisposeStreamProviderElement<List<TaskItem>>
    with TasksForRecurrenceRef {
  _TasksForRecurrenceProviderElement(super.provider);

  @override
  String get recurrenceDocId =>
      (origin as TasksForRecurrenceProvider).recurrenceDocId;
}

String _$badSchemaTasksHash() => r'97f06982c32ba51ec0e4d3ca0021935a2c707b33';

/// Tracks tasks that failed Firestore deserialization.
/// Displayed in the UI with warning styling so the user knows something is wrong.
///
/// Copied from [BadSchemaTasks].
@ProviderFor(BadSchemaTasks)
final badSchemaTasksProvider =
    NotifierProvider<BadSchemaTasks, List<BadSchemaTask>>.internal(
      BadSchemaTasks.new,
      name: r'badSchemaTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$badSchemaTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BadSchemaTasks = Notifier<List<BadSchemaTask>>;
String _$recentlyCompletedTasksHash() =>
    r'675051dbe7288e9621e1228fa594044843efe866';

/// Tracks recently completed tasks to keep them visible temporarily
/// This matches Redux's recentlyCompleted state which prevents completed
/// tasks from immediately disappearing when filters are applied
///
/// Copied from [RecentlyCompletedTasks].
@ProviderFor(RecentlyCompletedTasks)
final recentlyCompletedTasksProvider =
    NotifierProvider<RecentlyCompletedTasks, List<TaskItem>>.internal(
      RecentlyCompletedTasks.new,
      name: r'recentlyCompletedTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentlyCompletedTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecentlyCompletedTasks = Notifier<List<TaskItem>>;
String _$recentlyCompletedIndicesHash() =>
    r'ac81ddea7cdcb29b0a2246151b752766ba67da2a';

/// Side table mapping recently-completed task docId → its index in the
/// Tasks tab base list (tasksProvider) at the moment of completion.
///
/// Used by filteredTasksProvider to re-insert just-completed tasks at their
/// original position instead of appending them to the end — otherwise a
/// completed task visibly jumps to the bottom of its group (TM-339 Tasks
/// tab follow-up). The Sprint screen has its own ordering mechanism based
/// on sprint.sprintAssignments and does not use this.
///
/// Copied from [RecentlyCompletedIndices].
@ProviderFor(RecentlyCompletedIndices)
final recentlyCompletedIndicesProvider =
    NotifierProvider<RecentlyCompletedIndices, Map<String, int>>.internal(
      RecentlyCompletedIndices.new,
      name: r'recentlyCompletedIndicesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentlyCompletedIndicesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecentlyCompletedIndices = Notifier<Map<String, int>>;
String _$pendingTasksHash() => r'ea9d1ef0dab3dee2f47eff55d7ff4a64b518c003';

/// Tracks tasks currently being completed (optimistic UI)
/// This enables immediate visual feedback (pending state) before Firestore confirms
///
/// Copied from [PendingTasks].
@ProviderFor(PendingTasks)
final pendingTasksProvider =
    NotifierProvider<PendingTasks, Map<String, TaskItem>>.internal(
      PendingTasks.new,
      name: r'pendingTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingTasks = Notifier<Map<String, TaskItem>>;
String _$olderCompletedTasksBatchesHash() =>
    r'ee78d57f7fb4917c44f2aa87da07fb29a4a0b9ae';

/// Progressively loads completed tasks using cursor-based pagination.
/// Triggered when the user enables "Show Completed".
/// Uses one-time fetches (not real-time listeners) in fixed-size batches.
///
/// Copied from [OlderCompletedTasksBatches].
@ProviderFor(OlderCompletedTasksBatches)
final olderCompletedTasksBatchesProvider =
    NotifierProvider<OlderCompletedTasksBatches, OlderCompletedState>.internal(
      OlderCompletedTasksBatches.new,
      name: r'olderCompletedTasksBatchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$olderCompletedTasksBatchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OlderCompletedTasksBatches = Notifier<OlderCompletedState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
