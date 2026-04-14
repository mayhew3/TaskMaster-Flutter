// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_task_items_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sprintAllTasksHash() => r'a5163f1ec5a57681c12ecc19ec45158ba221ee25';

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

/// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
/// with recurrences populated. Used by [sprintTaskItems] so that completed
/// tasks appear in the "Completed" section at the bottom of the list
/// (not just recently-completed ones).
///
/// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
/// loading), which broke the sprint screen's Completed section. This provider
/// bypasses that restriction via a direct Drift query scoped to the sprint's
/// task docIds, so the result set is bounded and cheap.
///
/// Copied from [sprintAllTasks].
@ProviderFor(sprintAllTasks)
const sprintAllTasksProvider = SprintAllTasksFamily();

/// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
/// with recurrences populated. Used by [sprintTaskItems] so that completed
/// tasks appear in the "Completed" section at the bottom of the list
/// (not just recently-completed ones).
///
/// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
/// loading), which broke the sprint screen's Completed section. This provider
/// bypasses that restriction via a direct Drift query scoped to the sprint's
/// task docIds, so the result set is bounded and cheap.
///
/// Copied from [sprintAllTasks].
class SprintAllTasksFamily extends Family<AsyncValue<List<TaskItem>>> {
  /// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
  /// with recurrences populated. Used by [sprintTaskItems] so that completed
  /// tasks appear in the "Completed" section at the bottom of the list
  /// (not just recently-completed ones).
  ///
  /// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
  /// loading), which broke the sprint screen's Completed section. This provider
  /// bypasses that restriction via a direct Drift query scoped to the sprint's
  /// task docIds, so the result set is bounded and cheap.
  ///
  /// Copied from [sprintAllTasks].
  const SprintAllTasksFamily();

  /// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
  /// with recurrences populated. Used by [sprintTaskItems] so that completed
  /// tasks appear in the "Completed" section at the bottom of the list
  /// (not just recently-completed ones).
  ///
  /// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
  /// loading), which broke the sprint screen's Completed section. This provider
  /// bypasses that restriction via a direct Drift query scoped to the sprint's
  /// task docIds, so the result set is bounded and cheap.
  ///
  /// Copied from [sprintAllTasks].
  SprintAllTasksProvider call(Sprint sprint) {
    return SprintAllTasksProvider(sprint);
  }

  @override
  SprintAllTasksProvider getProviderOverride(
    covariant SprintAllTasksProvider provider,
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
  String? get name => r'sprintAllTasksProvider';
}

/// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
/// with recurrences populated. Used by [sprintTaskItems] so that completed
/// tasks appear in the "Completed" section at the bottom of the list
/// (not just recently-completed ones).
///
/// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
/// loading), which broke the sprint screen's Completed section. This provider
/// bypasses that restriction via a direct Drift query scoped to the sprint's
/// task docIds, so the result set is bounded and cheap.
///
/// Copied from [sprintAllTasks].
class SprintAllTasksProvider extends AutoDisposeStreamProvider<List<TaskItem>> {
  /// Stream of all tasks assigned to a sprint — INCLUDING completed ones —
  /// with recurrences populated. Used by [sprintTaskItems] so that completed
  /// tasks appear in the "Completed" section at the bottom of the list
  /// (not just recently-completed ones).
  ///
  /// The base [tasksProvider] only streams incomplete tasks (TM-317 progressive
  /// loading), which broke the sprint screen's Completed section. This provider
  /// bypasses that restriction via a direct Drift query scoped to the sprint's
  /// task docIds, so the result set is bounded and cheap.
  ///
  /// Copied from [sprintAllTasks].
  SprintAllTasksProvider(Sprint sprint)
    : this._internal(
        (ref) => sprintAllTasks(ref as SprintAllTasksRef, sprint),
        from: sprintAllTasksProvider,
        name: r'sprintAllTasksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sprintAllTasksHash,
        dependencies: SprintAllTasksFamily._dependencies,
        allTransitiveDependencies:
            SprintAllTasksFamily._allTransitiveDependencies,
        sprint: sprint,
      );

  SprintAllTasksProvider._internal(
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
    Stream<List<TaskItem>> Function(SprintAllTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SprintAllTasksProvider._internal(
        (ref) => create(ref as SprintAllTasksRef),
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
  AutoDisposeStreamProviderElement<List<TaskItem>> createElement() {
    return _SprintAllTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintAllTasksProvider && other.sprint == sprint;
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
mixin SprintAllTasksRef on AutoDisposeStreamProviderRef<List<TaskItem>> {
  /// The parameter `sprint` of this provider.
  Sprint get sprint;
}

class _SprintAllTasksProviderElement
    extends AutoDisposeStreamProviderElement<List<TaskItem>>
    with SprintAllTasksRef {
  _SprintAllTasksProviderElement(super.provider);

  @override
  Sprint get sprint => (origin as SprintAllTasksProvider).sprint;
}

String _$sprintTaskItemsHash() => r'980e6584fc4f778fd82886a3d343ea8148b7ed51';

/// Provider for filtered tasks in the active sprint
///
/// Copied from [sprintTaskItems].
@ProviderFor(sprintTaskItems)
const sprintTaskItemsProvider = SprintTaskItemsFamily();

/// Provider for filtered tasks in the active sprint
///
/// Copied from [sprintTaskItems].
class SprintTaskItemsFamily extends Family<AsyncValue<List<TaskItem>>> {
  /// Provider for filtered tasks in the active sprint
  ///
  /// Copied from [sprintTaskItems].
  const SprintTaskItemsFamily();

  /// Provider for filtered tasks in the active sprint
  ///
  /// Copied from [sprintTaskItems].
  SprintTaskItemsProvider call(Sprint sprint) {
    return SprintTaskItemsProvider(sprint);
  }

  @override
  SprintTaskItemsProvider getProviderOverride(
    covariant SprintTaskItemsProvider provider,
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
  String? get name => r'sprintTaskItemsProvider';
}

/// Provider for filtered tasks in the active sprint
///
/// Copied from [sprintTaskItems].
class SprintTaskItemsProvider
    extends AutoDisposeFutureProvider<List<TaskItem>> {
  /// Provider for filtered tasks in the active sprint
  ///
  /// Copied from [sprintTaskItems].
  SprintTaskItemsProvider(Sprint sprint)
    : this._internal(
        (ref) => sprintTaskItems(ref as SprintTaskItemsRef, sprint),
        from: sprintTaskItemsProvider,
        name: r'sprintTaskItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sprintTaskItemsHash,
        dependencies: SprintTaskItemsFamily._dependencies,
        allTransitiveDependencies:
            SprintTaskItemsFamily._allTransitiveDependencies,
        sprint: sprint,
      );

  SprintTaskItemsProvider._internal(
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
    FutureOr<List<TaskItem>> Function(SprintTaskItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SprintTaskItemsProvider._internal(
        (ref) => create(ref as SprintTaskItemsRef),
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
  AutoDisposeFutureProviderElement<List<TaskItem>> createElement() {
    return _SprintTaskItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintTaskItemsProvider && other.sprint == sprint;
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
mixin SprintTaskItemsRef on AutoDisposeFutureProviderRef<List<TaskItem>> {
  /// The parameter `sprint` of this provider.
  Sprint get sprint;
}

class _SprintTaskItemsProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskItem>>
    with SprintTaskItemsRef {
  _SprintTaskItemsProviderElement(super.provider);

  @override
  Sprint get sprint => (origin as SprintTaskItemsProvider).sprint;
}

String _$showCompletedInSprintHash() =>
    r'67c243d224d05ac3af4a5f6c9580eb115c6b8536';

/// Provider for sprint filter settings
/// Using keepAlive to persist state across tab switches
///
/// Copied from [ShowCompletedInSprint].
@ProviderFor(ShowCompletedInSprint)
final showCompletedInSprintProvider =
    NotifierProvider<ShowCompletedInSprint, bool>.internal(
      ShowCompletedInSprint.new,
      name: r'showCompletedInSprintProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$showCompletedInSprintHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowCompletedInSprint = Notifier<bool>;
String _$showScheduledInSprintHash() =>
    r'bdc0ae9d43164417c196030c54d8fac7dda13884';

/// See also [ShowScheduledInSprint].
@ProviderFor(ShowScheduledInSprint)
final showScheduledInSprintProvider =
    NotifierProvider<ShowScheduledInSprint, bool>.internal(
      ShowScheduledInSprint.new,
      name: r'showScheduledInSprintProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$showScheduledInSprintHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowScheduledInSprint = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
