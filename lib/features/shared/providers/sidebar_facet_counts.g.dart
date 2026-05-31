// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_facet_counts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active-surface faceted counts.
///
/// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
/// no-op, so that facet's source list equals the body's already-computed
/// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
/// `sprintTaskItems`, which the on-screen list already built) instead of
/// re-running `applyTaskFilters`, and only pay the extra pass over the
/// pre-filter base pool for an axis that IS narrowed. Common case (no
/// area/context filter selected): zero extra filter passes, no base-pool
/// recompute — just an O(n) tally. `keepAlive` so switching back to a
/// surface reuses the cached counts.
///
/// `plan` (the create-sprint flow) draws from [planBasePoolProvider] —
/// the create-sprint cadence draft lifted into Riverpod (TM-388) — so it
/// computes faithful counts like the other three surfaces.

@ProviderFor(sidebarFacetCounts)
final sidebarFacetCountsProvider = SidebarFacetCountsFamily._();

/// Active-surface faceted counts.
///
/// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
/// no-op, so that facet's source list equals the body's already-computed
/// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
/// `sprintTaskItems`, which the on-screen list already built) instead of
/// re-running `applyTaskFilters`, and only pay the extra pass over the
/// pre-filter base pool for an axis that IS narrowed. Common case (no
/// area/context filter selected): zero extra filter passes, no base-pool
/// recompute — just an O(n) tally. `keepAlive` so switching back to a
/// surface reuses the cached counts.
///
/// `plan` (the create-sprint flow) draws from [planBasePoolProvider] —
/// the create-sprint cadence draft lifted into Riverpod (TM-388) — so it
/// computes faithful counts like the other three surfaces.

final class SidebarFacetCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SidebarFacetCounts>,
          SidebarFacetCounts,
          FutureOr<SidebarFacetCounts>
        >
    with
        $FutureModifier<SidebarFacetCounts>,
        $FutureProvider<SidebarFacetCounts> {
  /// Active-surface faceted counts.
  ///
  /// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
  /// no-op, so that facet's source list equals the body's already-computed
  /// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
  /// `sprintTaskItems`, which the on-screen list already built) instead of
  /// re-running `applyTaskFilters`, and only pay the extra pass over the
  /// pre-filter base pool for an axis that IS narrowed. Common case (no
  /// area/context filter selected): zero extra filter passes, no base-pool
  /// recompute — just an O(n) tally. `keepAlive` so switching back to a
  /// surface reuses the cached counts.
  ///
  /// `plan` (the create-sprint flow) draws from [planBasePoolProvider] —
  /// the create-sprint cadence draft lifted into Riverpod (TM-388) — so it
  /// computes faithful counts like the other three surfaces.
  SidebarFacetCountsProvider._({
    required SidebarFacetCountsFamily super.from,
    required TaskListSurface super.argument,
  }) : super(
         retry: null,
         name: r'sidebarFacetCountsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sidebarFacetCountsHash();

  @override
  String toString() {
    return r'sidebarFacetCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SidebarFacetCounts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SidebarFacetCounts> create(Ref ref) {
    final argument = this.argument as TaskListSurface;
    return sidebarFacetCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SidebarFacetCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sidebarFacetCountsHash() =>
    r'455b5d68ef117f225f9ad6474e9cc41886db7d29';

/// Active-surface faceted counts.
///
/// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
/// no-op, so that facet's source list equals the body's already-computed
/// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
/// `sprintTaskItems`, which the on-screen list already built) instead of
/// re-running `applyTaskFilters`, and only pay the extra pass over the
/// pre-filter base pool for an axis that IS narrowed. Common case (no
/// area/context filter selected): zero extra filter passes, no base-pool
/// recompute — just an O(n) tally. `keepAlive` so switching back to a
/// surface reuses the cached counts.
///
/// `plan` (the create-sprint flow) draws from [planBasePoolProvider] —
/// the create-sprint cadence draft lifted into Riverpod (TM-388) — so it
/// computes faithful counts like the other three surfaces.

final class SidebarFacetCountsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SidebarFacetCounts>,
          TaskListSurface
        > {
  SidebarFacetCountsFamily._()
    : super(
        retry: null,
        name: r'sidebarFacetCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Active-surface faceted counts.
  ///
  /// Perf (TM-382): clearing an axis that the user has NOT narrowed is a
  /// no-op, so that facet's source list equals the body's already-computed
  /// visible list — reuse it (`filteredTasks` / `familyFilteredTasks` /
  /// `sprintTaskItems`, which the on-screen list already built) instead of
  /// re-running `applyTaskFilters`, and only pay the extra pass over the
  /// pre-filter base pool for an axis that IS narrowed. Common case (no
  /// area/context filter selected): zero extra filter passes, no base-pool
  /// recompute — just an O(n) tally. `keepAlive` so switching back to a
  /// surface reuses the cached counts.
  ///
  /// `plan` (the create-sprint flow) draws from [planBasePoolProvider] —
  /// the create-sprint cadence draft lifted into Riverpod (TM-388) — so it
  /// computes faithful counts like the other three surfaces.

  SidebarFacetCountsProvider call(TaskListSurface surface) =>
      SidebarFacetCountsProvider._(argument: surface, from: this);

  @override
  String toString() => r'sidebarFacetCountsProvider';
}
