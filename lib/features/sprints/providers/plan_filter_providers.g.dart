// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pre-filter task pool for the create-sprint (plan) surface (TM-388).
///
/// Mirrors `tasksBasePool` / `sprintBasePool`: the candidate TaskItem set
/// BEFORE the user's TaskFilters, so the sidebar can compute faceted
/// Area/Context counts by re-running `applyTaskFilters` over this same
/// pool with one axis cleared.
///
/// Produces exactly what `PlanTaskList.getBaseList` produces — the same
/// `task_selectors` family-exclusion + completion filters, against the
/// same `tasksWithRecurrencesProvider` source and the same
/// `createSprintEndDate` formula — so the counts can't drift from the
/// rendered list. This pool is `TaskItem`-only by design;
/// `applyTaskFilters` is built around `TaskItem`'s field shape, and the
/// synthesized recurrence-preview rows live in a sibling provider
/// (`planRecurrencePreviewsProvider`) that `sidebarFacetCounts._tallyPlan`
/// folds in separately — so picker + sidebar still both count previews,
/// just through different paths.

@ProviderFor(planBasePool)
final planBasePoolProvider = PlanBasePoolProvider._();

/// Pre-filter task pool for the create-sprint (plan) surface (TM-388).
///
/// Mirrors `tasksBasePool` / `sprintBasePool`: the candidate TaskItem set
/// BEFORE the user's TaskFilters, so the sidebar can compute faceted
/// Area/Context counts by re-running `applyTaskFilters` over this same
/// pool with one axis cleared.
///
/// Produces exactly what `PlanTaskList.getBaseList` produces — the same
/// `task_selectors` family-exclusion + completion filters, against the
/// same `tasksWithRecurrencesProvider` source and the same
/// `createSprintEndDate` formula — so the counts can't drift from the
/// rendered list. This pool is `TaskItem`-only by design;
/// `applyTaskFilters` is built around `TaskItem`'s field shape, and the
/// synthesized recurrence-preview rows live in a sibling provider
/// (`planRecurrencePreviewsProvider`) that `sidebarFacetCounts._tallyPlan`
/// folds in separately — so picker + sidebar still both count previews,
/// just through different paths.

final class PlanBasePoolProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Pre-filter task pool for the create-sprint (plan) surface (TM-388).
  ///
  /// Mirrors `tasksBasePool` / `sprintBasePool`: the candidate TaskItem set
  /// BEFORE the user's TaskFilters, so the sidebar can compute faceted
  /// Area/Context counts by re-running `applyTaskFilters` over this same
  /// pool with one axis cleared.
  ///
  /// Produces exactly what `PlanTaskList.getBaseList` produces — the same
  /// `task_selectors` family-exclusion + completion filters, against the
  /// same `tasksWithRecurrencesProvider` source and the same
  /// `createSprintEndDate` formula — so the counts can't drift from the
  /// rendered list. This pool is `TaskItem`-only by design;
  /// `applyTaskFilters` is built around `TaskItem`'s field shape, and the
  /// synthesized recurrence-preview rows live in a sibling provider
  /// (`planRecurrencePreviewsProvider`) that `sidebarFacetCounts._tallyPlan`
  /// folds in separately — so picker + sidebar still both count previews,
  /// just through different paths.
  PlanBasePoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planBasePoolProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planBasePoolHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    return planBasePool(ref);
  }
}

String _$planBasePoolHash() => r'b21ffe31516dd110adfcc051abbd93972f381833';

/// Synthesized recurrence-preview rows for the create-sprint picker
/// (TM-388). Generated from the same source set as `planBasePool`'s
/// parents (eligible recurring tasks), with the picker's window
/// projection. Read by the sidebar facet-count helper so previews
/// contribute to Area/Context counts alongside base TaskItems; the
/// picker reads it too so the displayed previews and the tallied
/// previews stay in sync.

@ProviderFor(planRecurrencePreviews)
final planRecurrencePreviewsProvider = PlanRecurrencePreviewsProvider._();

/// Synthesized recurrence-preview rows for the create-sprint picker
/// (TM-388). Generated from the same source set as `planBasePool`'s
/// parents (eligible recurring tasks), with the picker's window
/// projection. Read by the sidebar facet-count helper so previews
/// contribute to Area/Context counts alongside base TaskItems; the
/// picker reads it too so the displayed previews and the tallied
/// previews stay in sync.

final class PlanRecurrencePreviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItemRecurPreview>>,
          List<TaskItemRecurPreview>,
          FutureOr<List<TaskItemRecurPreview>>
        >
    with
        $FutureModifier<List<TaskItemRecurPreview>>,
        $FutureProvider<List<TaskItemRecurPreview>> {
  /// Synthesized recurrence-preview rows for the create-sprint picker
  /// (TM-388). Generated from the same source set as `planBasePool`'s
  /// parents (eligible recurring tasks), with the picker's window
  /// projection. Read by the sidebar facet-count helper so previews
  /// contribute to Area/Context counts alongside base TaskItems; the
  /// picker reads it too so the displayed previews and the tallied
  /// previews stay in sync.
  PlanRecurrencePreviewsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planRecurrencePreviewsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planRecurrencePreviewsHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItemRecurPreview>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItemRecurPreview>> create(Ref ref) {
    return planRecurrencePreviews(ref);
  }
}

String _$planRecurrencePreviewsHash() =>
    r'8f304f8c21dc67935e32374370b9df1c37203493';

/// Plan-surface tasks after the user's TaskFilters — the "normal" list
/// the sidebar reuses for the common case where the faceted axis isn't
/// narrowed (mirrors `filteredTasks` / `familyFilteredTasks`).

@ProviderFor(planFilteredTasks)
final planFilteredTasksProvider = PlanFilteredTasksProvider._();

/// Plan-surface tasks after the user's TaskFilters — the "normal" list
/// the sidebar reuses for the common case where the faceted axis isn't
/// narrowed (mirrors `filteredTasks` / `familyFilteredTasks`).

final class PlanFilteredTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskItem>>,
          List<TaskItem>,
          FutureOr<List<TaskItem>>
        >
    with $FutureModifier<List<TaskItem>>, $FutureProvider<List<TaskItem>> {
  /// Plan-surface tasks after the user's TaskFilters — the "normal" list
  /// the sidebar reuses for the common case where the faceted axis isn't
  /// narrowed (mirrors `filteredTasks` / `familyFilteredTasks`).
  PlanFilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planFilteredTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planFilteredTasksHash();

  @$internal
  @override
  $FutureProviderElement<List<TaskItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TaskItem>> create(Ref ref) {
    return planFilteredTasks(ref);
  }
}

String _$planFilteredTasksHash() => r'5b33ad08f5680f58f44e400d7288e06521423e27';
