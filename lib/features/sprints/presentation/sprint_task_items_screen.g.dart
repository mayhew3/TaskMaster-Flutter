// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_task_items_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

/// Sprint task list in sprint-assignment order (TM-339), with the user's
/// TaskFilters applied via the shared pipeline.
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.

@ProviderFor(sprintTaskItems)
final sprintTaskItemsProvider = SprintTaskItemsFamily._();

/// Sprint task list in sprint-assignment order (TM-339), with the user's
/// TaskFilters applied via the shared pipeline.
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.

final class SprintTaskItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Sprint task list in sprint-assignment order (TM-339), with the user's
  /// TaskFilters applied via the shared pipeline.
  ///
  /// TM-368: pure-derived family provider — auto-dispose for the same
  /// reason as `sprintAllTasks`.
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

String _$sprintTaskItemsHash() => r'80ff1d40375b3f51946fd33fc07067f5de87c655';

/// Sprint task list in sprint-assignment order (TM-339), with the user's
/// TaskFilters applied via the shared pipeline.
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.

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

  /// Sprint task list in sprint-assignment order (TM-339), with the user's
  /// TaskFilters applied via the shared pipeline.
  ///
  /// TM-368: pure-derived family provider — auto-dispose for the same
  /// reason as `sprintAllTasks`.

  SprintTaskItemsProvider call(Sprint sprint) =>
      SprintTaskItemsProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintTaskItemsProvider';
}

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=none, sortAxis=dueStatus
/// sentinel) the result is a single bucket preserving sprint-assignment
/// order. If the user picks a non-default group axis via ViewOptionsSheet,
/// proper bucketing kicks in.

@ProviderFor(sprintGroupedTasks)
final sprintGroupedTasksProvider = SprintGroupedTasksFamily._();

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=none, sortAxis=dueStatus
/// sentinel) the result is a single bucket preserving sprint-assignment
/// order. If the user picks a non-default group axis via ViewOptionsSheet,
/// proper bucketing kicks in.

final class SprintGroupedTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskGroupResult>>,
          List<TaskGroupResult>,
          FutureOr<List<TaskGroupResult>>
        >
    with
        $FutureModifier<List<TaskGroupResult>>,
        $FutureProvider<List<TaskGroupResult>> {
  /// Sprint tasks grouped + sorted via the shared pipeline. With the
  /// sprint surface's defaults (groupAxis=none, sortAxis=dueStatus
  /// sentinel) the result is a single bucket preserving sprint-assignment
  /// order. If the user picks a non-default group axis via ViewOptionsSheet,
  /// proper bucketing kicks in.
  SprintGroupedTasksProvider._({
    required SprintGroupedTasksFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintGroupedTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintGroupedTasksHash();

  @override
  String toString() {
    return r'sprintGroupedTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TaskGroupResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskGroupResult>> create(Ref ref) {
    final argument = this.argument as Sprint;
    return sprintGroupedTasks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintGroupedTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintGroupedTasksHash() =>
    r'5fdfdc0ea16c796aa9df25dfe16438e4fb7c93b8';

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=none, sortAxis=dueStatus
/// sentinel) the result is a single bucket preserving sprint-assignment
/// order. If the user picks a non-default group axis via ViewOptionsSheet,
/// proper bucketing kicks in.

final class SprintGroupedTasksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaskGroupResult>>, Sprint> {
  SprintGroupedTasksFamily._()
    : super(
        retry: null,
        name: r'sprintGroupedTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Sprint tasks grouped + sorted via the shared pipeline. With the
  /// sprint surface's defaults (groupAxis=none, sortAxis=dueStatus
  /// sentinel) the result is a single bucket preserving sprint-assignment
  /// order. If the user picks a non-default group axis via ViewOptionsSheet,
  /// proper bucketing kicks in.

  SprintGroupedTasksProvider call(Sprint sprint) =>
      SprintGroupedTasksProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintGroupedTasksProvider';
}
