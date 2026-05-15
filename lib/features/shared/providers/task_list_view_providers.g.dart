// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_view_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
/// so Tasks / Family / Sprint / Plan each remember independent
/// selections. State is hydrated synchronously from
/// `TaskListViewStorage` (which reads from an already-loaded
/// `SharedPreferences`) and every mutator writes through.
///
/// `keepAlive: true` because the selections are stateful user data that
/// must survive consumer remounts (TM-368 policy). The notifier
/// shouldn't be auto-disposed.

@ProviderFor(TaskListViewState)
final taskListViewStateProvider = TaskListViewStateFamily._();

/// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
/// so Tasks / Family / Sprint / Plan each remember independent
/// selections. State is hydrated synchronously from
/// `TaskListViewStorage` (which reads from an already-loaded
/// `SharedPreferences`) and every mutator writes through.
///
/// `keepAlive: true` because the selections are stateful user data that
/// must survive consumer remounts (TM-368 policy). The notifier
/// shouldn't be auto-disposed.
final class TaskListViewStateProvider
    extends $NotifierProvider<TaskListViewState, TaskListView> {
  /// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
  /// so Tasks / Family / Sprint / Plan each remember independent
  /// selections. State is hydrated synchronously from
  /// `TaskListViewStorage` (which reads from an already-loaded
  /// `SharedPreferences`) and every mutator writes through.
  ///
  /// `keepAlive: true` because the selections are stateful user data that
  /// must survive consumer remounts (TM-368 policy). The notifier
  /// shouldn't be auto-disposed.
  TaskListViewStateProvider._({
    required TaskListViewStateFamily super.from,
    required TaskListSurface super.argument,
  }) : super(
         retry: null,
         name: r'taskListViewStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskListViewStateHash();

  @override
  String toString() {
    return r'taskListViewStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskListViewState create() => TaskListViewState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskListView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskListView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskListViewStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListViewStateHash() => r'c7143049b87db8c6fd8b6a2ed209bdf1bc3de530';

/// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
/// so Tasks / Family / Sprint / Plan each remember independent
/// selections. State is hydrated synchronously from
/// `TaskListViewStorage` (which reads from an already-loaded
/// `SharedPreferences`) and every mutator writes through.
///
/// `keepAlive: true` because the selections are stateful user data that
/// must survive consumer remounts (TM-368 policy). The notifier
/// shouldn't be auto-disposed.

final class TaskListViewStateFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskListViewState,
          TaskListView,
          TaskListView,
          TaskListView,
          TaskListSurface
        > {
  TaskListViewStateFamily._()
    : super(
        retry: null,
        name: r'taskListViewStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
  /// so Tasks / Family / Sprint / Plan each remember independent
  /// selections. State is hydrated synchronously from
  /// `TaskListViewStorage` (which reads from an already-loaded
  /// `SharedPreferences`) and every mutator writes through.
  ///
  /// `keepAlive: true` because the selections are stateful user data that
  /// must survive consumer remounts (TM-368 policy). The notifier
  /// shouldn't be auto-disposed.

  TaskListViewStateProvider call(TaskListSurface surface) =>
      TaskListViewStateProvider._(argument: surface, from: this);

  @override
  String toString() => r'taskListViewStateProvider';
}

/// Per-surface Group/Sort/Filter state. Family-keyed by [TaskListSurface]
/// so Tasks / Family / Sprint / Plan each remember independent
/// selections. State is hydrated synchronously from
/// `TaskListViewStorage` (which reads from an already-loaded
/// `SharedPreferences`) and every mutator writes through.
///
/// `keepAlive: true` because the selections are stateful user data that
/// must survive consumer remounts (TM-368 policy). The notifier
/// shouldn't be auto-disposed.

abstract class _$TaskListViewState extends $Notifier<TaskListView> {
  late final _$args = ref.$arg as TaskListSurface;
  TaskListSurface get surface => _$args;

  TaskListView build(TaskListSurface surface);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskListView, TaskListView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskListView, TaskListView>,
              TaskListView,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
