// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_task_items_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for sprint-screen filter settings.
/// TM-368 self-review: kept `keepAlive: true`. The pre-TM-368 contract was
/// "toggle persists across tab switches" — without keepAlive, auto-dispose
/// fires on consumer unmount and any user-toggled value silently resets
/// to the default the next time a sprint is opened. Defaults-on-first-
/// visit alone doesn't preserve that contract.

@ProviderFor(ShowCompletedInSprint)
final showCompletedInSprintProvider = ShowCompletedInSprintProvider._();

/// Provider for sprint-screen filter settings.
/// TM-368 self-review: kept `keepAlive: true`. The pre-TM-368 contract was
/// "toggle persists across tab switches" — without keepAlive, auto-dispose
/// fires on consumer unmount and any user-toggled value silently resets
/// to the default the next time a sprint is opened. Defaults-on-first-
/// visit alone doesn't preserve that contract.
final class ShowCompletedInSprintProvider
    extends $NotifierProvider<ShowCompletedInSprint, bool> {
  /// Provider for sprint-screen filter settings.
  /// TM-368 self-review: kept `keepAlive: true`. The pre-TM-368 contract was
  /// "toggle persists across tab switches" — without keepAlive, auto-dispose
  /// fires on consumer unmount and any user-toggled value silently resets
  /// to the default the next time a sprint is opened. Defaults-on-first-
  /// visit alone doesn't preserve that contract.
  ShowCompletedInSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showCompletedInSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showCompletedInSprintHash();

  @$internal
  @override
  ShowCompletedInSprint create() => ShowCompletedInSprint();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showCompletedInSprintHash() =>
    r'67c243d224d05ac3af4a5f6c9580eb115c6b8536';

/// Provider for sprint-screen filter settings.
/// TM-368 self-review: kept `keepAlive: true`. The pre-TM-368 contract was
/// "toggle persists across tab switches" — without keepAlive, auto-dispose
/// fires on consumer unmount and any user-toggled value silently resets
/// to the default the next time a sprint is opened. Defaults-on-first-
/// visit alone doesn't preserve that contract.

abstract class _$ShowCompletedInSprint extends $Notifier<bool> {
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

@ProviderFor(ShowScheduledInSprint)
final showScheduledInSprintProvider = ShowScheduledInSprintProvider._();

final class ShowScheduledInSprintProvider
    extends $NotifierProvider<ShowScheduledInSprint, bool> {
  ShowScheduledInSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showScheduledInSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showScheduledInSprintHash();

  @$internal
  @override
  ShowScheduledInSprint create() => ShowScheduledInSprint();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showScheduledInSprintHash() =>
    r'bdc0ae9d43164417c196030c54d8fac7dda13884';

abstract class _$ShowScheduledInSprint extends $Notifier<bool> {
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
/// TM-368: family provider keyed by Sprint. keepAlive would pin every
/// sprint a user has ever opened in this session into memory. Auto-dispose
/// releases the watch when the sprint screen unmounts.

@ProviderFor(sprintAllTasks)
final sprintAllTasksProvider = SprintAllTasksFamily._();

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
/// TM-368: family provider keyed by Sprint. keepAlive would pin every
/// sprint a user has ever opened in this session into memory. Auto-dispose
/// releases the watch when the sprint screen unmounts.

final class SprintAllTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          Stream<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $StreamProvider<List<TaskItem>> {
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
  /// TM-368: family provider keyed by Sprint. keepAlive would pin every
  /// sprint a user has ever opened in this session into memory. Auto-dispose
  /// releases the watch when the sprint screen unmounts.
  SprintAllTasksProvider._({
    required SprintAllTasksFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintAllTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintAllTasksHash();

  @override
  String toString() {
    return r'sprintAllTasksProvider'
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
    final argument = this.argument as Sprint;
    return sprintAllTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintAllTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintAllTasksHash() => r'7c8cba53d789b1e861a0b2d5700eb2e565c369a2';

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
/// TM-368: family provider keyed by Sprint. keepAlive would pin every
/// sprint a user has ever opened in this session into memory. Auto-dispose
/// releases the watch when the sprint screen unmounts.

final class SprintAllTasksFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TaskItem>>, Sprint> {
  SprintAllTasksFamily._()
    : super(
        retry: null,
        name: r'sprintAllTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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
  /// TM-368: family provider keyed by Sprint. keepAlive would pin every
  /// sprint a user has ever opened in this session into memory. Auto-dispose
  /// releases the watch when the sprint screen unmounts.

  SprintAllTasksProvider call(Sprint sprint) =>
      SprintAllTasksProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintAllTasksProvider';
}

/// Provider for filtered tasks in the active sprint.
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).

@ProviderFor(sprintTaskItems)
final sprintTaskItemsProvider = SprintTaskItemsFamily._();

/// Provider for filtered tasks in the active sprint.
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).

final class SprintTaskItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Provider for filtered tasks in the active sprint.
  /// TM-368: pure-derived family provider — auto-dispose for the same
  /// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).
  SprintTaskItemsProvider._({
    required SprintTaskItemsFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintTaskItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintTaskItemsHash();

  @override
  String toString() {
    return r'sprintTaskItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    final argument = this.argument as Sprint;
    return sprintTaskItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintTaskItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintTaskItemsHash() => r'3dc3a1da2c3dbcb8fb43711b546a4bbbf4f97aa6';

/// Provider for filtered tasks in the active sprint.
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).

final class SprintTaskItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaskItem>>, Sprint> {
  SprintTaskItemsFamily._()
    : super(
        retry: null,
        name: r'sprintTaskItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for filtered tasks in the active sprint.
  /// TM-368: pure-derived family provider — auto-dispose for the same
  /// reason as `sprintAllTasks` (per-sprint instances shouldn't pin in memory).

  SprintTaskItemsProvider call(Sprint sprint) =>
      SprintTaskItemsProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintTaskItemsProvider';
}
