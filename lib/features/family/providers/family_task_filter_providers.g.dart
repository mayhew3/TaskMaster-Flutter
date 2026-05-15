// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Family tab tasks after surface-specific gates + the user's `TaskFilters`.
///
/// Surface gates applied here (not part of the shared pipeline):
/// - drop retired rows.
/// - `ownedByMeOnly` filters to tasks created by the current user.
///
/// Everything else (search / showCompleted / showScheduled / recurrence /
/// age / priority / points / due-status / context / area) is delegated to
/// `applyTaskFilters` so the Family tab and the Tasks tab share a single
/// filtering code path.
///
/// TM-368: pure-derived. Cheap to recompute on consumer remount.

@ProviderFor(familyFilteredTasks)
final familyFilteredTasksProvider = FamilyFilteredTasksProvider._();

/// Family tab tasks after surface-specific gates + the user's `TaskFilters`.
///
/// Surface gates applied here (not part of the shared pipeline):
/// - drop retired rows.
/// - `ownedByMeOnly` filters to tasks created by the current user.
///
/// Everything else (search / showCompleted / showScheduled / recurrence /
/// age / priority / points / due-status / context / area) is delegated to
/// `applyTaskFilters` so the Family tab and the Tasks tab share a single
/// filtering code path.
///
/// TM-368: pure-derived. Cheap to recompute on consumer remount.

final class FamilyFilteredTasksProvider
    extends $FunctionalProvider<List<TaskItem>, List<TaskItem>, List<TaskItem>>
    with $Provider<List<TaskItem>> {
  /// Family tab tasks after surface-specific gates + the user's `TaskFilters`.
  ///
  /// Surface gates applied here (not part of the shared pipeline):
  /// - drop retired rows.
  /// - `ownedByMeOnly` filters to tasks created by the current user.
  ///
  /// Everything else (search / showCompleted / showScheduled / recurrence /
  /// age / priority / points / due-status / context / area) is delegated to
  /// `applyTaskFilters` so the Family tab and the Tasks tab share a single
  /// filtering code path.
  ///
  /// TM-368: pure-derived. Cheap to recompute on consumer remount.
  FamilyFilteredTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyFilteredTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyFilteredTasksHash();

  @$internal
  @override
  $ProviderElement<List<TaskItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskItem> create(Ref ref) {
    return familyFilteredTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskItem>>(value),
    );
  }
}

String _$familyFilteredTasksHash() =>
    r'96e1b954249b20aff439dc0fe1e016256eec60cf';

/// Grouped + sorted Family tab tasks, routed through `groupAndSortTasks`.
///
/// TM-368: pure-derived. `areasProvider` is read only when the active
/// group axis is `area` — otherwise this provider doesn't transitively
/// force a Drift open in tests that don't override the areas stream.

@ProviderFor(familyGroupedTasks)
final familyGroupedTasksProvider = FamilyGroupedTasksProvider._();

/// Grouped + sorted Family tab tasks, routed through `groupAndSortTasks`.
///
/// TM-368: pure-derived. `areasProvider` is read only when the active
/// group axis is `area` — otherwise this provider doesn't transitively
/// force a Drift open in tests that don't override the areas stream.

final class FamilyGroupedTasksProvider
    extends
        $FunctionalProvider<
          List<TaskGroupResult>,
          List<TaskGroupResult>,
          List<TaskGroupResult>
        >
    with $Provider<List<TaskGroupResult>> {
  /// Grouped + sorted Family tab tasks, routed through `groupAndSortTasks`.
  ///
  /// TM-368: pure-derived. `areasProvider` is read only when the active
  /// group axis is `area` — otherwise this provider doesn't transitively
  /// force a Drift open in tests that don't override the areas stream.
  FamilyGroupedTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyGroupedTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyGroupedTasksHash();

  @$internal
  @override
  $ProviderElement<List<TaskGroupResult>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TaskGroupResult> create(Ref ref) {
    return familyGroupedTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskGroupResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskGroupResult>>(value),
    );
  }
}

String _$familyGroupedTasksHash() =>
    r'fc3eaee22aa871f1f5c5e76d4c585aa2bffe62d1';
