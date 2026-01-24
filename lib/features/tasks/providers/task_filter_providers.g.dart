// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTasksHash() => r'c03ee7d7f20ccf6b797957b92b72c631bf6f6896';

/// Filtered tasks based on visibility settings
///
/// Copied from [filteredTasks].
@ProviderFor(filteredTasks)
final filteredTasksProvider =
    AutoDisposeFutureProvider<List<TaskItem>>.internal(
      filteredTasks,
      name: r'filteredTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTasksRef = AutoDisposeFutureProviderRef<List<TaskItem>>;
String _$activeTaskCountHash() => r'2bebdf365f5d0aa271589aa7d69410a8f3c04e0b';

/// Count of active (non-completed, non-retired) tasks
///
/// Copied from [activeTaskCount].
@ProviderFor(activeTaskCount)
final activeTaskCountProvider = AutoDisposeProvider<int>.internal(
  activeTaskCount,
  name: r'activeTaskCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTaskCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTaskCountRef = AutoDisposeProviderRef<int>;
String _$completedTaskCountHash() =>
    r'bd2847dd544a5ff2aed5a726556b25ec29ca847e';

/// Count of completed tasks
///
/// Copied from [completedTaskCount].
@ProviderFor(completedTaskCount)
final completedTaskCountProvider = AutoDisposeProvider<int>.internal(
  completedTaskCount,
  name: r'completedTaskCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedTaskCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedTaskCountRef = AutoDisposeProviderRef<int>;
String _$groupedTasksHash() => r'd8ed7228a3c8e2c6413a4d25cabbaa4a1b639a4b';

/// Grouped and sorted tasks for the task list
///
/// Copied from [groupedTasks].
@ProviderFor(groupedTasks)
final groupedTasksProvider =
    AutoDisposeFutureProvider<List<TaskGroup>>.internal(
      groupedTasks,
      name: r'groupedTasksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupedTasksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupedTasksRef = AutoDisposeFutureProviderRef<List<TaskGroup>>;
String _$showCompletedHash() => r'4ff3e319b903af05cbce17b2f69eef4b9aed02c0';

/// Simple state providers for filter toggles
/// Using keepAlive: true to persist state across tab switches
///
/// Copied from [ShowCompleted].
@ProviderFor(ShowCompleted)
final showCompletedProvider = NotifierProvider<ShowCompleted, bool>.internal(
  ShowCompleted.new,
  name: r'showCompletedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showCompletedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowCompleted = Notifier<bool>;
String _$showScheduledHash() => r'0ebc352bb4c95ca8b3f91d32a6db6323f5d01a84';

/// See also [ShowScheduled].
@ProviderFor(ShowScheduled)
final showScheduledProvider = NotifierProvider<ShowScheduled, bool>.internal(
  ShowScheduled.new,
  name: r'showScheduledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showScheduledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowScheduled = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
