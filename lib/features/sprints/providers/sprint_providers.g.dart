// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sprint_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of the N most recent sprints for the current user, with assignments.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.

@ProviderFor(sprints)
final sprintsProvider = SprintsProvider._();

/// Stream of the N most recent sprints for the current user, with assignments.
/// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.

final class SprintsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sprint>>,
          List<Sprint>,
          Stream<List<Sprint>>
        >
    with $FutureModifier<List<Sprint>>, $StreamProvider<List<Sprint>> {
  /// Stream of the N most recent sprints for the current user, with assignments.
  /// Streams from the local Drift cache; SyncService keeps it in sync with Firestore.
  SprintsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sprintsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sprintsHash();

  @$internal
  @override
  $StreamProviderElement<List<Sprint>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Sprint>> create(Ref ref) {
    return sprints(ref);
  }
}

String _$sprintsHash() => r'a5b8b0697d9538c4840d0ed887c4a155a5f5e829';

/// Get active sprint (currently in progress)

@ProviderFor(activeSprint)
final activeSprintProvider = ActiveSprintProvider._();

/// Get active sprint (currently in progress)

final class ActiveSprintProvider
    extends $FunctionalProvider<Sprint?, Sprint?, Sprint?>
    with $Provider<Sprint?> {
  /// Get active sprint (currently in progress)
  ActiveSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSprintHash();

  @$internal
  @override
  $ProviderElement<Sprint?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Sprint? create(Ref ref) {
    return activeSprint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Sprint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Sprint?>(value),
    );
  }
}

String _$activeSprintHash() => r'3118e9182e9ca17fe088c02f779b01381e120aff';

/// Get last completed sprint

@ProviderFor(lastCompletedSprint)
final lastCompletedSprintProvider = LastCompletedSprintProvider._();

/// Get last completed sprint

final class LastCompletedSprintProvider
    extends $FunctionalProvider<Sprint?, Sprint?, Sprint?>
    with $Provider<Sprint?> {
  /// Get last completed sprint
  LastCompletedSprintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastCompletedSprintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastCompletedSprintHash();

  @$internal
  @override
  $ProviderElement<Sprint?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Sprint? create(Ref ref) {
    return lastCompletedSprint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Sprint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Sprint?>(value),
    );
  }
}

String _$lastCompletedSprintHash() =>
    r'6d724fc0ca8f7a0a1eb25c8988e63cf46a959e00';

/// Get sprints for a specific task

@ProviderFor(sprintsForTask)
final sprintsForTaskProvider = SprintsForTaskFamily._();

/// Get sprints for a specific task

final class SprintsForTaskProvider
    extends $FunctionalProvider<List<Sprint>, List<Sprint>, List<Sprint>>
    with $Provider<List<Sprint>> {
  /// Get sprints for a specific task
  SprintsForTaskProvider._({
    required SprintsForTaskFamily super.from,
    required TaskItem super.argument,
  }) : super(
         retry: null,
         name: r'sprintsForTaskProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintsForTaskHash();

  @override
  String toString() {
    return r'sprintsForTaskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Sprint>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Sprint> create(Ref ref) {
    final argument = this.argument as TaskItem;
    return sprintsForTask(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Sprint> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Sprint>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SprintsForTaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintsForTaskHash() => r'2c740cabd2bbc20170ab0421d94ceb0a2feaee78';

/// Get sprints for a specific task

final class SprintsForTaskFamily extends $Family
    with $FunctionalFamilyOverride<List<Sprint>, TaskItem> {
  SprintsForTaskFamily._()
    : super(
        retry: null,
        name: r'sprintsForTaskProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Get sprints for a specific task

  SprintsForTaskProvider call(TaskItem task) =>
      SprintsForTaskProvider._(argument: task, from: this);

  @override
  String toString() => r'sprintsForTaskProvider';
}

/// One-shot Firestore fetch of the sprint's full task roster — every task
/// referenced by a non-retired sprint assignment, regardless of completion
/// state. Backfills the cases the personal-tasks Drift listener misses:
/// the listener filters `completionDate isNull`, so a task completed in a
/// prior session on another device never lands in Drift. Without this
/// fetch the Sprint UI would silently hide such tasks even with
/// "Finished" toggled on (TM-361 manual-test #18 follow-up).
///
/// Bounded and cheap: one whereIn query per 30 docIds, results cached for
/// the session. Re-fetches when [sprint] changes (a new sprint instance
/// arrives from the assignments stream).

@ProviderFor(sprintRosterFirestore)
final sprintRosterFirestoreProvider = SprintRosterFirestoreFamily._();

/// One-shot Firestore fetch of the sprint's full task roster — every task
/// referenced by a non-retired sprint assignment, regardless of completion
/// state. Backfills the cases the personal-tasks Drift listener misses:
/// the listener filters `completionDate isNull`, so a task completed in a
/// prior session on another device never lands in Drift. Without this
/// fetch the Sprint UI would silently hide such tasks even with
/// "Finished" toggled on (TM-361 manual-test #18 follow-up).
///
/// Bounded and cheap: one whereIn query per 30 docIds, results cached for
/// the session. Re-fetches when [sprint] changes (a new sprint instance
/// arrives from the assignments stream).

final class SprintRosterFirestoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// One-shot Firestore fetch of the sprint's full task roster — every task
  /// referenced by a non-retired sprint assignment, regardless of completion
  /// state. Backfills the cases the personal-tasks Drift listener misses:
  /// the listener filters `completionDate isNull`, so a task completed in a
  /// prior session on another device never lands in Drift. Without this
  /// fetch the Sprint UI would silently hide such tasks even with
  /// "Finished" toggled on (TM-361 manual-test #18 follow-up).
  ///
  /// Bounded and cheap: one whereIn query per 30 docIds, results cached for
  /// the session. Re-fetches when [sprint] changes (a new sprint instance
  /// arrives from the assignments stream).
  SprintRosterFirestoreProvider._({
    required SprintRosterFirestoreFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintRosterFirestoreProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintRosterFirestoreHash();

  @override
  String toString() {
    return r'sprintRosterFirestoreProvider'
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
    return sprintRosterFirestore(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintRosterFirestoreProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintRosterFirestoreHash() =>
    r'408f6d60886d28d3928c97813ec7009cb8d1e629';

/// One-shot Firestore fetch of the sprint's full task roster — every task
/// referenced by a non-retired sprint assignment, regardless of completion
/// state. Backfills the cases the personal-tasks Drift listener misses:
/// the listener filters `completionDate isNull`, so a task completed in a
/// prior session on another device never lands in Drift. Without this
/// fetch the Sprint UI would silently hide such tasks even with
/// "Finished" toggled on (TM-361 manual-test #18 follow-up).
///
/// Bounded and cheap: one whereIn query per 30 docIds, results cached for
/// the session. Re-fetches when [sprint] changes (a new sprint instance
/// arrives from the assignments stream).

final class SprintRosterFirestoreFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TaskItem>>, Sprint> {
  SprintRosterFirestoreFamily._()
    : super(
        retry: null,
        name: r'sprintRosterFirestoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// One-shot Firestore fetch of the sprint's full task roster — every task
  /// referenced by a non-retired sprint assignment, regardless of completion
  /// state. Backfills the cases the personal-tasks Drift listener misses:
  /// the listener filters `completionDate isNull`, so a task completed in a
  /// prior session on another device never lands in Drift. Without this
  /// fetch the Sprint UI would silently hide such tasks even with
  /// "Finished" toggled on (TM-361 manual-test #18 follow-up).
  ///
  /// Bounded and cheap: one whereIn query per 30 docIds, results cached for
  /// the session. Re-fetches when [sprint] changes (a new sprint instance
  /// arrives from the assignments stream).

  SprintRosterFirestoreProvider call(Sprint sprint) =>
      SprintRosterFirestoreProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintRosterFirestoreProvider';
}

/// (completed, total) counts for the active-sprint banner. Merges the
/// Firestore roster (full sprint membership, includes cold completions)
/// with Drift state (live, reflects this session's completions). Drift
/// wins on docId conflicts so a just-completed task is counted correctly
/// even before the next Firestore round-trip.
///
/// Streams from the Drift watch on the sprint's task docIds so toggling
/// completion (or any other change to those rows) re-emits a fresh count
/// to the banner. Using `.first` here instead — as an earlier revision did
/// — pinned the count to the very first emission and the banner stayed
/// stale through subsequent toggles.

@ProviderFor(sprintCompletionCounts)
final sprintCompletionCountsProvider = SprintCompletionCountsFamily._();

/// (completed, total) counts for the active-sprint banner. Merges the
/// Firestore roster (full sprint membership, includes cold completions)
/// with Drift state (live, reflects this session's completions). Drift
/// wins on docId conflicts so a just-completed task is counted correctly
/// even before the next Firestore round-trip.
///
/// Streams from the Drift watch on the sprint's task docIds so toggling
/// completion (or any other change to those rows) re-emits a fresh count
/// to the banner. Using `.first` here instead — as an earlier revision did
/// — pinned the count to the very first emission and the banner stayed
/// stale through subsequent toggles.

final class SprintCompletionCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SprintCounts>,
          SprintCounts,
          Stream<SprintCounts>
        >
    with $FutureModifier<SprintCounts>, $StreamProvider<SprintCounts> {
  /// (completed, total) counts for the active-sprint banner. Merges the
  /// Firestore roster (full sprint membership, includes cold completions)
  /// with Drift state (live, reflects this session's completions). Drift
  /// wins on docId conflicts so a just-completed task is counted correctly
  /// even before the next Firestore round-trip.
  ///
  /// Streams from the Drift watch on the sprint's task docIds so toggling
  /// completion (or any other change to those rows) re-emits a fresh count
  /// to the banner. Using `.first` here instead — as an earlier revision did
  /// — pinned the count to the very first emission and the banner stayed
  /// stale through subsequent toggles.
  SprintCompletionCountsProvider._({
    required SprintCompletionCountsFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'sprintCompletionCountsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sprintCompletionCountsHash();

  @override
  String toString() {
    return r'sprintCompletionCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SprintCounts> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SprintCounts> create(Ref ref) {
    final argument = this.argument as Sprint;
    return sprintCompletionCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SprintCompletionCountsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sprintCompletionCountsHash() =>
    r'4efc6c94150fa37da57baaa8aaff8b5ed9c29120';

/// (completed, total) counts for the active-sprint banner. Merges the
/// Firestore roster (full sprint membership, includes cold completions)
/// with Drift state (live, reflects this session's completions). Drift
/// wins on docId conflicts so a just-completed task is counted correctly
/// even before the next Firestore round-trip.
///
/// Streams from the Drift watch on the sprint's task docIds so toggling
/// completion (or any other change to those rows) re-emits a fresh count
/// to the banner. Using `.first` here instead — as an earlier revision did
/// — pinned the count to the very first emission and the banner stayed
/// stale through subsequent toggles.

final class SprintCompletionCountsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SprintCounts>, Sprint> {
  SprintCompletionCountsFamily._()
    : super(
        retry: null,
        name: r'sprintCompletionCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// (completed, total) counts for the active-sprint banner. Merges the
  /// Firestore roster (full sprint membership, includes cold completions)
  /// with Drift state (live, reflects this session's completions). Drift
  /// wins on docId conflicts so a just-completed task is counted correctly
  /// even before the next Firestore round-trip.
  ///
  /// Streams from the Drift watch on the sprint's task docIds so toggling
  /// completion (or any other change to those rows) re-emits a fresh count
  /// to the banner. Using `.first` here instead — as an earlier revision did
  /// — pinned the count to the very first emission and the banner stayed
  /// stale through subsequent toggles.

  SprintCompletionCountsProvider call(Sprint sprint) =>
      SprintCompletionCountsProvider._(argument: sprint, from: this);

  @override
  String toString() => r'sprintCompletionCountsProvider';
}

/// Get tasks for a specific sprint.
/// Includes incomplete tasks from the base stream, recently completed tasks
/// (visible immediately after completion), and older completed tasks from the
/// on-demand batch when "Show Completed" is active (TM-341).

@ProviderFor(tasksForSprint)
final tasksForSprintProvider = TasksForSprintFamily._();

/// Get tasks for a specific sprint.
/// Includes incomplete tasks from the base stream, recently completed tasks
/// (visible immediately after completion), and older completed tasks from the
/// on-demand batch when "Show Completed" is active (TM-341).

final class TasksForSprintProvider
    extends $FunctionalProvider<List<TaskItem>, List<TaskItem>, List<TaskItem>>
    with $Provider<List<TaskItem>> {
  /// Get tasks for a specific sprint.
  /// Includes incomplete tasks from the base stream, recently completed tasks
  /// (visible immediately after completion), and older completed tasks from the
  /// on-demand batch when "Show Completed" is active (TM-341).
  TasksForSprintProvider._({
    required TasksForSprintFamily super.from,
    required Sprint super.argument,
  }) : super(
         retry: null,
         name: r'tasksForSprintProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tasksForSprintHash();

  @override
  String toString() {
    return r'tasksForSprintProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TaskItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskItem> create(Ref ref) {
    final argument = this.argument as Sprint;
    return tasksForSprint(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForSprintProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tasksForSprintHash() => r'e5a0615495ffeac984d2f9b2d4bb17c6d4104405';

/// Get tasks for a specific sprint.
/// Includes incomplete tasks from the base stream, recently completed tasks
/// (visible immediately after completion), and older completed tasks from the
/// on-demand batch when "Show Completed" is active (TM-341).

final class TasksForSprintFamily extends $Family
    with $FunctionalFamilyOverride<List<TaskItem>, Sprint> {
  TasksForSprintFamily._()
    : super(
        retry: null,
        name: r'tasksForSprintProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Get tasks for a specific sprint.
  /// Includes incomplete tasks from the base stream, recently completed tasks
  /// (visible immediately after completion), and older completed tasks from the
  /// on-demand batch when "Show Completed" is active (TM-341).

  TasksForSprintProvider call(Sprint sprint) =>
      TasksForSprintProvider._(argument: sprint, from: this);

  @override
  String toString() => r'tasksForSprintProvider';
}
