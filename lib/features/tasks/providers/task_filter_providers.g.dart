// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShowCompleted)
final showCompletedProvider = ShowCompletedProvider._();

final class ShowCompletedProvider
    extends $NotifierProvider<ShowCompleted, bool> {
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

String _$showCompletedHash() => r'a97fbcdc4d50de6b90e1e1bf4bc98d692f1ee6a8';

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

String _$showScheduledHash() => r'c5bc4847684d69dff14560f99db1daafe15e4f84';

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

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
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

String _$searchQueryHash() => r'80f5a508547bee329989930ebc81e0179e667516';

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

/// Pre-filter Tasks-tab pool: surface-specific gates (hide family-shared,
/// hide active-sprint, retired removal) + the TM-323 recently-completed
/// merge + progressively-loaded older-completed batches — everything that
/// assembles the candidate list *before* the user's TaskFilters. Split out
/// (TM-382) so the sidebar can compute faceted counts by re-running
/// `applyTaskFilters` over this same pool with one filter axis cleared,
/// without duplicating this assembly.

@ProviderFor(tasksBasePool)
final tasksBasePoolProvider = TasksBasePoolProvider._();

/// Pre-filter Tasks-tab pool: surface-specific gates (hide family-shared,
/// hide active-sprint, retired removal) + the TM-323 recently-completed
/// merge + progressively-loaded older-completed batches — everything that
/// assembles the candidate list *before* the user's TaskFilters. Split out
/// (TM-382) so the sidebar can compute faceted counts by re-running
/// `applyTaskFilters` over this same pool with one filter axis cleared,
/// without duplicating this assembly.

final class TasksBasePoolProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Pre-filter Tasks-tab pool: surface-specific gates (hide family-shared,
  /// hide active-sprint, retired removal) + the TM-323 recently-completed
  /// merge + progressively-loaded older-completed batches — everything that
  /// assembles the candidate list *before* the user's TaskFilters. Split out
  /// (TM-382) so the sidebar can compute faceted counts by re-running
  /// `applyTaskFilters` over this same pool with one filter axis cleared,
  /// without duplicating this assembly.
  TasksBasePoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksBasePoolProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksBasePoolHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    return tasksBasePool(ref);
  }
}

String _$tasksBasePoolHash() => r'45976e158fc8452252acfed79f333d90a3708323';

/// Tasks visible on the Tasks tab — [tasksBasePoolProvider] run through
/// the user's TaskFilters via the shared pipeline (the canonical filter
/// step mirroring the pre-TM-359 inline logic plus the recently-completed
/// bypass).

@ProviderFor(filteredTasks)
final filteredTasksProvider = FilteredTasksProvider._();

/// Tasks visible on the Tasks tab — [tasksBasePoolProvider] run through
/// the user's TaskFilters via the shared pipeline (the canonical filter
/// step mirroring the pre-TM-359 inline logic plus the recently-completed
/// bypass).

final class FilteredTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Tasks visible on the Tasks tab — [tasksBasePoolProvider] run through
  /// the user's TaskFilters via the shared pipeline (the canonical filter
  /// step mirroring the pre-TM-359 inline logic plus the recently-completed
  /// bypass).
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

String _$filteredTasksHash() => r'd573c8ac8a66d6ea4e48c8ee2ae405217574b6bc';

/// Count of active (non-completed, non-retired) tasks.
/// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
/// recompute when a consumer reattaches.

@ProviderFor(activeTaskCount)
final activeTaskCountProvider = ActiveTaskCountProvider._();

/// Count of active (non-completed, non-retired) tasks.
/// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
/// recompute when a consumer reattaches.

final class ActiveTaskCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Count of active (non-completed, non-retired) tasks.
  /// TM-368: pure-derived from `tasksProvider` (keepAlive). Cheap to
  /// recompute when a consumer reattaches.
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

/// Count of completed (non-skipped, non-retired) tasks. See pre-TM-359
/// comment for the Firestore-aggregation rationale.

@ProviderFor(completedTaskCount)
final completedTaskCountProvider = CompletedTaskCountProvider._();

/// Count of completed (non-skipped, non-retired) tasks. See pre-TM-359
/// comment for the Firestore-aggregation rationale.

final class CompletedTaskCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Count of completed (non-skipped, non-retired) tasks. See pre-TM-359
  /// comment for the Firestore-aggregation rationale.
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

/// TM-359: grouped + sorted Tasks-tab tasks. Wraps `groupAndSortTasks`
/// with the per-surface TaskListView state.

@ProviderFor(groupedTasks)
final groupedTasksProvider = GroupedTasksProvider._();

/// TM-359: grouped + sorted Tasks-tab tasks. Wraps `groupAndSortTasks`
/// with the per-surface TaskListView state.

final class GroupedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskGroupResult>>,
          List<TaskGroupResult>,
          FutureOr<List<TaskGroupResult>>
        >
    with
        $FutureModifier<List<TaskGroupResult>>,
        $FutureProvider<List<TaskGroupResult>> {
  /// TM-359: grouped + sorted Tasks-tab tasks. Wraps `groupAndSortTasks`
  /// with the per-surface TaskListView state.
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
  $FutureProviderElement<List<TaskGroupResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskGroupResult>> create(Ref ref) {
    return groupedTasks(ref);
  }
}

String _$groupedTasksHash() => r'38ec61f1cd836f687e6e42e656fbf35b2789c31b';
