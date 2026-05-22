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

/// Pre-filter sprint pool: the membership-resolved task set
/// (assignments + optimistic-pending overlay + recently-completed +
/// older-completed / firestore-roster when completed is visible),
/// retired rows dropped — everything *before* the user's TaskFilters.
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one filter axis
/// cleared, without duplicating this assembly.

@ProviderFor(sprintBasePool)
final sprintBasePoolProvider = SprintBasePoolFamily._();

/// Pre-filter sprint pool: the membership-resolved task set
/// (assignments + optimistic-pending overlay + recently-completed +
/// older-completed / firestore-roster when completed is visible),
/// retired rows dropped — everything *before* the user's TaskFilters.
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one filter axis
/// cleared, without duplicating this assembly.

final class SprintBasePoolProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Pre-filter sprint pool: the membership-resolved task set
  /// (assignments + optimistic-pending overlay + recently-completed +
  /// older-completed / firestore-roster when completed is visible),
  /// retired rows dropped — everything *before* the user's TaskFilters.
  /// Split out (TM-382) so the sidebar can compute faceted counts by
  /// re-running `applyTaskFilters` over this pool with one filter axis
  /// cleared, without duplicating this assembly.
  SprintBasePoolProvider._({
    required SprintBasePoolFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintBasePoolProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintBasePoolHash();

  @override
  String toString() {
    return r'sprintBasePoolProvider'
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
    return sprintBasePool(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintBasePoolProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintBasePoolHash() => r'51e7c15872b20cdee5dedfb376d8792ba2929709';

/// Pre-filter sprint pool: the membership-resolved task set
/// (assignments + optimistic-pending overlay + recently-completed +
/// older-completed / firestore-roster when completed is visible),
/// retired rows dropped — everything *before* the user's TaskFilters.
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one filter axis
/// cleared, without duplicating this assembly.

final class SprintBasePoolFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaskItem>>, Sprint> {
  SprintBasePoolFamily._()
    : super(
        retry: null,
        name: r'sprintBasePoolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pre-filter sprint pool: the membership-resolved task set
  /// (assignments + optimistic-pending overlay + recently-completed +
  /// older-completed / firestore-roster when completed is visible),
  /// retired rows dropped — everything *before* the user's TaskFilters.
  /// Split out (TM-382) so the sidebar can compute faceted counts by
  /// re-running `applyTaskFilters` over this pool with one filter axis
  /// cleared, without duplicating this assembly.

  SprintBasePoolProvider call(Sprint sprint) =>
      SprintBasePoolProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintBasePoolProvider';
}

/// Sprint task set (membership-resolved), with the user's TaskFilters
/// applied via the shared pipeline. Ordering is intentionally NOT
/// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
/// surface's group/sort axes (default: due-status grouping, urgency
/// sort) before anything renders, so any order this provider produced
/// would be discarded. (Pre-TM-359 this walked
/// `sprint.sprintAssignments` in order for the TM-339 stability
/// contract; that contract no longer holds at the UI level.)
///
/// TM-368: pure-derived family provider — auto-dispose for the same
/// reason as `sprintAllTasks`.

@ProviderFor(sprintTaskItems)
final sprintTaskItemsProvider = SprintTaskItemsFamily._();

/// Sprint task set (membership-resolved), with the user's TaskFilters
/// applied via the shared pipeline. Ordering is intentionally NOT
/// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
/// surface's group/sort axes (default: due-status grouping, urgency
/// sort) before anything renders, so any order this provider produced
/// would be discarded. (Pre-TM-359 this walked
/// `sprint.sprintAssignments` in order for the TM-339 stability
/// contract; that contract no longer holds at the UI level.)
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
  /// Sprint task set (membership-resolved), with the user's TaskFilters
  /// applied via the shared pipeline. Ordering is intentionally NOT
  /// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
  /// surface's group/sort axes (default: due-status grouping, urgency
  /// sort) before anything renders, so any order this provider produced
  /// would be discarded. (Pre-TM-359 this walked
  /// `sprint.sprintAssignments` in order for the TM-339 stability
  /// contract; that contract no longer holds at the UI level.)
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

String _$sprintTaskItemsHash() => r'e00562e4f3c0f4f01efc91f3bbbca53f39f782cf';

/// Sprint task set (membership-resolved), with the user's TaskFilters
/// applied via the shared pipeline. Ordering is intentionally NOT
/// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
/// surface's group/sort axes (default: due-status grouping, urgency
/// sort) before anything renders, so any order this provider produced
/// would be discarded. (Pre-TM-359 this walked
/// `sprint.sprintAssignments` in order for the TM-339 stability
/// contract; that contract no longer holds at the UI level.)
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

  /// Sprint task set (membership-resolved), with the user's TaskFilters
  /// applied via the shared pipeline. Ordering is intentionally NOT
  /// preserved here — `sprintGroupedTasks` re-buckets + sorts by the
  /// surface's group/sort axes (default: due-status grouping, urgency
  /// sort) before anything renders, so any order this provider produced
  /// would be discarded. (Pre-TM-359 this walked
  /// `sprint.sprintAssignments` in order for the TM-339 stability
  /// contract; that contract no longer holds at the UI level.)
  ///
  /// TM-368: pure-derived family provider — auto-dispose for the same
  /// reason as `sprintAllTasks`.

  SprintTaskItemsProvider call(Sprint sprint) =>
      SprintTaskItemsProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintTaskItemsProvider';
}

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
/// result is the bucketed view with most-pressing tasks first within
/// each bucket. The user can pick any other group/sort axis via the
/// View Options sheet.

@ProviderFor(sprintGroupedTasks)
final sprintGroupedTasksProvider = SprintGroupedTasksFamily._();

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
/// result is the bucketed view with most-pressing tasks first within
/// each bucket. The user can pick any other group/sort axis via the
/// View Options sheet.

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
  /// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
  /// result is the bucketed view with most-pressing tasks first within
  /// each bucket. The user can pick any other group/sort axis via the
  /// View Options sheet.
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
    r'f9e4495564bd9903a83f168a8003c6ebb69684f0';

/// Sprint tasks grouped + sorted via the shared pipeline. With the
/// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
/// result is the bucketed view with most-pressing tasks first within
/// each bucket. The user can pick any other group/sort axis via the
/// View Options sheet.

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
  /// sprint surface's defaults (groupAxis=dueStatus, sortAxis=urgency) the
  /// result is the bucketed view with most-pressing tasks first within
  /// each bucket. The user can pick any other group/sort axis via the
  /// View Options sheet.

  SprintGroupedTasksProvider call(Sprint sprint) =>
      SprintGroupedTasksProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintGroupedTasksProvider';
}
