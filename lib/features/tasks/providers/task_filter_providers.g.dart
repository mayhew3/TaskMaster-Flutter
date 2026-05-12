// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Simple state providers for filter toggles
/// Using keepAlive: true to persist state across tab switches

@ProviderFor(ShowCompleted)
final showCompletedProvider = ShowCompletedProvider._();

/// Simple state providers for filter toggles
/// Using keepAlive: true to persist state across tab switches
final class ShowCompletedProvider
    extends $NotifierProvider<ShowCompleted, bool> {
  /// Simple state providers for filter toggles
  /// Using keepAlive: true to persist state across tab switches
  ShowCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showCompletedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showCompletedHash();

  @$internal
  @override
  ShowCompleted create() => ShowCompleted();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showCompletedHash() => r'a7c3485980d4e64d2b0945fd8a098070bd5fbffb';

/// Simple state providers for filter toggles
/// Using keepAlive: true to persist state across tab switches

abstract class _$ShowCompleted extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ShowScheduled)
final showScheduledProvider = ShowScheduledProvider._();

final class ShowScheduledProvider
    extends $NotifierProvider<ShowScheduled, bool> {
  ShowScheduledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showScheduledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showScheduledHash();

  @$internal
  @override
  ShowScheduled create() => ShowScheduled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showScheduledHash() => r'0ebc352bb4c95ca8b3f91d32a6db6323f5d01a84';

abstract class _$ShowScheduled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Text search query for filtering tasks by name

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// Text search query for filtering tasks by name
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Text search query for filtering tasks by name
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'652516df14d1f054c2015886d77c308ba15b0a58';

/// Text search query for filtering tasks by name

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Filtered tasks based on visibility settings

@ProviderFor(filteredTasks)
final filteredTasksProvider = FilteredTasksProvider._();

/// Filtered tasks based on visibility settings

final class FilteredTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Filtered tasks based on visibility settings
  FilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    return filteredTasks(ref);
  }
}

String _$filteredTasksHash() => r'da6b3bc5fd474016300c429559e04dec45cf97e8';

/// Count of active (non-completed, non-retired) tasks.
/// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
/// recompute when a consumer reattaches, so auto-dispose is correct here.

@ProviderFor(activeTaskCount)
final activeTaskCountProvider = ActiveTaskCountProvider._();

/// Count of active (non-completed, non-retired) tasks.
/// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
/// recompute when a consumer reattaches, so auto-dispose is correct here.

final class ActiveTaskCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Count of active (non-completed, non-retired) tasks.
  /// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
  /// recompute when a consumer reattaches, so auto-dispose is correct here.
  ActiveTaskCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTaskCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTaskCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeTaskCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeTaskCountHash() => r'2bebdf365f5d0aa271589aa7d69410a8f3c04e0b';

/// Count of completed (non-skipped, non-retired) tasks.
/// Uses Firestore aggregation for the total (too many to store locally),
/// then subtracts the local skipped count (always present since skip is local-first).
/// TM-368: Firestore aggregation cost matters per call, but the value is
/// only read by infrequently-visited screens (Manage Areas badges, profile
/// stats). Auto-dispose so the count doesn't sit cached when nothing's
/// reading it — the staleness penalty for keepAlive (count drifts as the
/// user completes tasks) is worse than the rebuild cost.

@ProviderFor(completedTaskCount)
final completedTaskCountProvider = CompletedTaskCountProvider._();

/// Count of completed (non-skipped, non-retired) tasks.
/// Uses Firestore aggregation for the total (too many to store locally),
/// then subtracts the local skipped count (always present since skip is local-first).
/// TM-368: Firestore aggregation cost matters per call, but the value is
/// only read by infrequently-visited screens (Manage Areas badges, profile
/// stats). Auto-dispose so the count doesn't sit cached when nothing's
/// reading it — the staleness penalty for keepAlive (count drifts as the
/// user completes tasks) is worse than the rebuild cost.

final class CompletedTaskCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of completed (non-skipped, non-retired) tasks.
  /// Uses Firestore aggregation for the total (too many to store locally),
  /// then subtracts the local skipped count (always present since skip is local-first).
  /// TM-368: Firestore aggregation cost matters per call, but the value is
  /// only read by infrequently-visited screens (Manage Areas badges, profile
  /// stats). Auto-dispose so the count doesn't sit cached when nothing's
  /// reading it — the staleness penalty for keepAlive (count drifts as the
  /// user completes tasks) is worse than the rebuild cost.
  CompletedTaskCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedTaskCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedTaskCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return completedTaskCount(ref);
  }
}

String _$completedTaskCountHash() =>
    r'cb5b1d8c3f28f87537a1a5e4a285b3f8bd6d37e6';

/// Grouped and sorted tasks for the task list

@ProviderFor(groupedTasks)
final groupedTasksProvider = GroupedTasksProvider._();

/// Grouped and sorted tasks for the task list

final class GroupedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskGroup>>,
          List<TaskGroup>,
          FutureOr<List<TaskGroup>>
        >
    with $FutureModifier<List<TaskGroup>>, $FutureProvider<List<TaskGroup>> {
  /// Grouped and sorted tasks for the task list
  GroupedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupedTasksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupedTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskGroup>> create(Ref ref) {
    return groupedTasks(ref);
  }
}

String _$groupedTasksHash() => r'73667166812c7d01cc9bedd439e71857b0609cf9';
