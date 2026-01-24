// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sprintsHash() => r'a70a881e5ce1dfade2333d5f180f5de56a3fb5f4';

/// Stream of all sprints for the current user
///
/// Copied from [sprints].
@ProviderFor(sprints)
final sprintsProvider = StreamProvider<List<Sprint>>.internal(
  sprints,
  name: r'sprintsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sprintsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SprintsRef = StreamProviderRef<List<Sprint>>;
String _$activeSprintHash() => r'a15226739e7e5120f69612a4abbdb07cda498219';

/// Get active sprint (currently in progress)
///
/// Copied from [activeSprint].
@ProviderFor(activeSprint)
final activeSprintProvider = AutoDisposeProvider<Sprint?>.internal(
  activeSprint,
  name: r'activeSprintProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSprintHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSprintRef = AutoDisposeProviderRef<Sprint?>;
String _$lastCompletedSprintHash() =>
    r'f12c70cff3df9442690c81e2c23756ba043fa202';

/// Get last completed sprint
///
/// Copied from [lastCompletedSprint].
@ProviderFor(lastCompletedSprint)
final lastCompletedSprintProvider = AutoDisposeProvider<Sprint?>.internal(
  lastCompletedSprint,
  name: r'lastCompletedSprintProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastCompletedSprintHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastCompletedSprintRef = AutoDisposeProviderRef<Sprint?>;
String _$sprintsForTaskHash() => r'75cb2317e396f901a25d85ca7f324ef73bab6bae';

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

/// Get sprints for a specific task
///
/// Copied from [sprintsForTask].
@ProviderFor(sprintsForTask)
const sprintsForTaskProvider = SprintsForTaskFamily();

/// Get sprints for a specific task
///
/// Copied from [sprintsForTask].
class SprintsForTaskFamily extends Family<List<Sprint>> {
  /// Get sprints for a specific task
  ///
  /// Copied from [sprintsForTask].
  const SprintsForTaskFamily();

  /// Get sprints for a specific task
  ///
  /// Copied from [sprintsForTask].
  SprintsForTaskProvider call(TaskItem task) {
    return SprintsForTaskProvider(task);
  }

  @override
  SprintsForTaskProvider getProviderOverride(
    covariant SprintsForTaskProvider provider,
  ) {
    return call(provider.task);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sprintsForTaskProvider';
}

/// Get sprints for a specific task
///
/// Copied from [sprintsForTask].
class SprintsForTaskProvider extends AutoDisposeProvider<List<Sprint>> {
  /// Get sprints for a specific task
  ///
  /// Copied from [sprintsForTask].
  SprintsForTaskProvider(TaskItem task)
    : this._internal(
        (ref) => sprintsForTask(ref as SprintsForTaskRef, task),
        from: sprintsForTaskProvider,
        name: r'sprintsForTaskProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sprintsForTaskHash,
        dependencies: SprintsForTaskFamily._dependencies,
        allTransitiveDependencies:
            SprintsForTaskFamily._allTransitiveDependencies,
        task: task,
      );

  SprintsForTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.task,
  }) : super.internal();

  final TaskItem task;

  @override
  Override overrideWith(
    List<Sprint> Function(SprintsForTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SprintsForTaskProvider._internal(
        (ref) => create(ref as SprintsForTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        task: task,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Sprint>> createElement() {
    return _SprintsForTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintsForTaskProvider && other.task == task;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, task.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SprintsForTaskRef on AutoDisposeProviderRef<List<Sprint>> {
  /// The parameter `task` of this provider.
  TaskItem get task;
}

class _SprintsForTaskProviderElement
    extends AutoDisposeProviderElement<List<Sprint>>
    with SprintsForTaskRef {
  _SprintsForTaskProviderElement(super.provider);

  @override
  TaskItem get task => (origin as SprintsForTaskProvider).task;
}

String _$tasksForSprintHash() => r'9a23175d6d631443a6f1efb1ef91af5a9a21681a';

/// Get tasks for a specific sprint
///
/// Copied from [tasksForSprint].
@ProviderFor(tasksForSprint)
const tasksForSprintProvider = TasksForSprintFamily();

/// Get tasks for a specific sprint
///
/// Copied from [tasksForSprint].
class TasksForSprintFamily extends Family<List<TaskItem>> {
  /// Get tasks for a specific sprint
  ///
  /// Copied from [tasksForSprint].
  const TasksForSprintFamily();

  /// Get tasks for a specific sprint
  ///
  /// Copied from [tasksForSprint].
  TasksForSprintProvider call(Sprint sprint) {
    return TasksForSprintProvider(sprint);
  }

  @override
  TasksForSprintProvider getProviderOverride(
    covariant TasksForSprintProvider provider,
  ) {
    return call(provider.sprint);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksForSprintProvider';
}

/// Get tasks for a specific sprint
///
/// Copied from [tasksForSprint].
class TasksForSprintProvider extends AutoDisposeProvider<List<TaskItem>> {
  /// Get tasks for a specific sprint
  ///
  /// Copied from [tasksForSprint].
  TasksForSprintProvider(Sprint sprint)
    : this._internal(
        (ref) => tasksForSprint(ref as TasksForSprintRef, sprint),
        from: tasksForSprintProvider,
        name: r'tasksForSprintProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksForSprintHash,
        dependencies: TasksForSprintFamily._dependencies,
        allTransitiveDependencies:
            TasksForSprintFamily._allTransitiveDependencies,
        sprint: sprint,
      );

  TasksForSprintProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sprint,
  }) : super.internal();

  final Sprint sprint;

  @override
  Override overrideWith(
    List<TaskItem> Function(TasksForSprintRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksForSprintProvider._internal(
        (ref) => create(ref as TasksForSprintRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sprint: sprint,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<TaskItem>> createElement() {
    return _TasksForSprintProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForSprintProvider && other.sprint == sprint;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sprint.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksForSprintRef on AutoDisposeProviderRef<List<TaskItem>> {
  /// The parameter `sprint` of this provider.
  Sprint get sprint;
}

class _TasksForSprintProviderElement
    extends AutoDisposeProviderElement<List<TaskItem>>
    with TasksForSprintRef {
  _TasksForSprintProviderElement(super.provider);

  @override
  Sprint get sprint => (origin as TasksForSprintProvider).sprint;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
