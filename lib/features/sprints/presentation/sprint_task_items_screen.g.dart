// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_task_items_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sprintTaskItemsHash() => r'ae15134672b276622cbf4e304d895fca126f23fa';

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
