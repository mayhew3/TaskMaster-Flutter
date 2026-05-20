// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_task_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pre-filter Family-tab pool: the surface-specific gates only (drop
/// retired rows; `ownedByMeOnly` → tasks created by the current user).
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one axis cleared.
///
/// TM-368: pure-derived. Cheap to recompute on consumer remount.

@ProviderFor(familyBasePool)
final familyBasePoolProvider = FamilyBasePoolProvider._();

/// Pre-filter Family-tab pool: the surface-specific gates only (drop
/// retired rows; `ownedByMeOnly` → tasks created by the current user).
/// Split out (TM-382) so the sidebar can compute faceted counts by
/// re-running `applyTaskFilters` over this pool with one axis cleared.
///
/// TM-368: pure-derived. Cheap to recompute on consumer remount.

final class FamilyBasePoolProvider
    extends $FunctionalProvider<List<TaskItem>, List<TaskItem>, List<TaskItem>>
    with $Provider<List<TaskItem>> {
  /// Pre-filter Family-tab pool: the surface-specific gates only (drop
  /// retired rows; `ownedByMeOnly` → tasks created by the current user).
  /// Split out (TM-382) so the sidebar can compute faceted counts by
  /// re-running `applyTaskFilters` over this pool with one axis cleared.
  ///
  /// TM-368: pure-derived. Cheap to recompute on consumer remount.
  FamilyBasePoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'familyBasePoolProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$familyBasePoolHash();

  @$internal
  @override
  $ProviderElement<List<TaskItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskItem> create(Ref ref) {
    return familyBasePool(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskItem>>(value),
    );
  }
}

String _$familyBasePoolHash() => r'6ce4d7127abfa4dadc3d4dbd06bcf1cd4b00f774';

/// Family tab tasks after surface gates + the user's `TaskFilters`.
/// Everything except the two surface gates above (search / showCompleted
/// / showScheduled / recurrence / age / priority / points / due-status /
/// context / area) is delegated to `applyTaskFilters` so the Family tab
/// and the Tasks tab share a single filtering code path.

@ProviderFor(familyFilteredTasks)
final familyFilteredTasksProvider = FamilyFilteredTasksProvider._();

/// Family tab tasks after surface gates + the user's `TaskFilters`.
/// Everything except the two surface gates above (search / showCompleted
/// / showScheduled / recurrence / age / priority / points / due-status /
/// context / area) is delegated to `applyTaskFilters` so the Family tab
/// and the Tasks tab share a single filtering code path.

final class FamilyFilteredTasksProvider
    extends $FunctionalProvider<List<TaskItem>, List<TaskItem>, List<TaskItem>>
    with $Provider<List<TaskItem>> {
  /// Family tab tasks after surface gates + the user's `TaskFilters`.
  /// Everything except the two surface gates above (search / showCompleted
  /// / showScheduled / recurrence / age / priority / points / due-status /
  /// context / area) is delegated to `applyTaskFilters` so the Family tab
  /// and the Tasks tab share a single filtering code path.
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
    r'4f7366887aa067c9b382b697900e6cb02d0ff934';

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
