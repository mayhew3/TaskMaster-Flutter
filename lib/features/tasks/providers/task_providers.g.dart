// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksHash() => r'0953d2f2b664c5ced681f70020caea55c13e67ef';

/// Stream of all tasks for the current user
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
String _$taskRecurrencesHash() => r'd7644d98f6db511ee653c2c8962565c8d12a1a46';

/// Stream of task recurrences for the current user
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
String _$taskHash() => r'4bf9d3ef4a5420abd7dcd9b2ddb4d6300c31109c';

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

/// Get a specific task by ID
///
/// Copied from [task].
@ProviderFor(task)
const taskProvider = TaskFamily();

/// Get a specific task by ID
///
/// Copied from [task].
class TaskFamily extends Family<TaskItem?> {
  /// Get a specific task by ID
  ///
  /// Copied from [task].
  const TaskFamily();

  /// Get a specific task by ID
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

/// Get a specific task by ID
///
/// Copied from [task].
class TaskProvider extends AutoDisposeProvider<TaskItem?> {
  /// Get a specific task by ID
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
