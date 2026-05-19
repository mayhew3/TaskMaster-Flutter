// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_facet_counts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active-surface faceted counts. `plan` (the create-sprint flow) has no
/// app-level base pool — it's built from in-screen sprint-creation form
/// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
/// shows no count there); a faithful plan count is a tracked follow-up.

@ProviderFor(sidebarFacetCounts)
final sidebarFacetCountsProvider = SidebarFacetCountsFamily._();

/// Active-surface faceted counts. `plan` (the create-sprint flow) has no
/// app-level base pool — it's built from in-screen sprint-creation form
/// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
/// shows no count there); a faithful plan count is a tracked follow-up.

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
  /// Active-surface faceted counts. `plan` (the create-sprint flow) has no
  /// app-level base pool — it's built from in-screen sprint-creation form
  /// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
  /// shows no count there); a faithful plan count is a tracked follow-up.
  SidebarFacetCountsProvider._({
    required SidebarFacetCountsFamily super.from,
    required TaskListSurface super.argument,
  }) : super(
         retry: null,
         name: r'sidebarFacetCountsProvider',
         isAutoDispose: true,
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
    r'b3e7c235fbfadd855e611db20f363832b4bdd58b';

/// Active-surface faceted counts. `plan` (the create-sprint flow) has no
/// app-level base pool — it's built from in-screen sprint-creation form
/// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
/// shows no count there); a faithful plan count is a tracked follow-up.

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
        isAutoDispose: true,
      );

  /// Active-surface faceted counts. `plan` (the create-sprint flow) has no
  /// app-level base pool — it's built from in-screen sprint-creation form
  /// state — so it yields [SidebarFacetCounts.empty] (the sidebar then
  /// shows no count there); a faithful plan count is a tracked follow-up.

  SidebarFacetCountsProvider call(TaskListSurface surface) =>
      SidebarFacetCountsProvider._(argument: surface, from: this);

  @override
  String toString() => r'sidebarFacetCountsProvider';
}
