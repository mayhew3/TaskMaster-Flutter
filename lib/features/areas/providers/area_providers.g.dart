// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-area task counts for the current user. Keyed by lowercased area
/// name; the value is the number of non-retired tasks (active + completed)
/// tagged with that area. Used by the Manage Areas screen to render small
/// count badges next to each row (TM-181 / TM-345).
///
/// Counts include completed tasks because "tasks that reference this area"
/// is what informs the user's "Remove from tasks?" decision when deleting
/// the catalog entry — the decision shouldn't change just because some of
/// those tasks have been ticked off.

@ProviderFor(areaTaskCounts)
final areaTaskCountsProvider = AreaTaskCountsProvider._();

/// Per-area task counts for the current user. Keyed by lowercased area
/// name; the value is the number of non-retired tasks (active + completed)
/// tagged with that area. Used by the Manage Areas screen to render small
/// count badges next to each row (TM-181 / TM-345).
///
/// Counts include completed tasks because "tasks that reference this area"
/// is what informs the user's "Remove from tasks?" decision when deleting
/// the catalog entry — the decision shouldn't change just because some of
/// those tasks have been ticked off.

final class AreaTaskCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          Stream<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $StreamProvider<Map<String, int>> {
  /// Per-area task counts for the current user. Keyed by lowercased area
  /// name; the value is the number of non-retired tasks (active + completed)
  /// tagged with that area. Used by the Manage Areas screen to render small
  /// count badges next to each row (TM-181 / TM-345).
  ///
  /// Counts include completed tasks because "tasks that reference this area"
  /// is what informs the user's "Remove from tasks?" decision when deleting
  /// the catalog entry — the decision shouldn't change just because some of
  /// those tasks have been ticked off.
  AreaTaskCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'areaTaskCountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$areaTaskCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, int>> create(Ref ref) {
    return areaTaskCounts(ref);
  }
}

String _$areaTaskCountsHash() => r'97d7699cf3f99398838b57698f9ca0e9997db4c7';

/// Stream of the current user's areas, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.

@ProviderFor(areas)
final areasProvider = AreasProvider._();

/// Stream of the current user's areas, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.

final class AreasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Area>>,
          List<Area>,
          Stream<List<Area>>
        >
    with $FutureModifier<List<Area>>, $StreamProvider<List<Area>> {
  /// Stream of the current user's areas, sorted by sortOrder.
  /// Streams from local Drift; SyncService keeps it in sync with Firestore.
  AreasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'areasProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$areasHash();

  @$internal
  @override
  $StreamProviderElement<List<Area>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Area>> create(Ref ref) {
    return areas(ref);
  }
}

String _$areasHash() => r'ffc967175ee6fabf65e31c956b938eee97b69ac6';

/// Lazily seeds [defaultAreaNames] on first read when the user has zero areas
/// AND the first server snapshot has confirmed they really do have zero.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background.
///
/// Two race conditions to avoid:
///   1. Existing user opens the picker before their server-side areas have
///      synced down → local list is empty → without an initial-pull gate, we
///      would seed defaults that then duplicate/conflict with their real
///      areas a few hundred milliseconds later. Fix: await
///      [SyncService.areasInitialPullComplete] before deciding to seed.
///   2. Sign-out → sign-in as a different brand-new user during the same app
///      session. Without per-user state, the "already attempted" flag stays
///      true and the new user gets no defaults. Fix: track a Set of
///      personDocIds we have seeded for, not a single bool.
///
/// Use this from the picker / management screen entry points, not from
/// background queries.

@ProviderFor(AreasWithDefaults)
final areasWithDefaultsProvider = AreasWithDefaultsProvider._();

/// Lazily seeds [defaultAreaNames] on first read when the user has zero areas
/// AND the first server snapshot has confirmed they really do have zero.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background.
///
/// Two race conditions to avoid:
///   1. Existing user opens the picker before their server-side areas have
///      synced down → local list is empty → without an initial-pull gate, we
///      would seed defaults that then duplicate/conflict with their real
///      areas a few hundred milliseconds later. Fix: await
///      [SyncService.areasInitialPullComplete] before deciding to seed.
///   2. Sign-out → sign-in as a different brand-new user during the same app
///      session. Without per-user state, the "already attempted" flag stays
///      true and the new user gets no defaults. Fix: track a Set of
///      personDocIds we have seeded for, not a single bool.
///
/// Use this from the picker / management screen entry points, not from
/// background queries.
final class AreasWithDefaultsProvider
    extends $NotifierProvider<AreasWithDefaults, AsyncValue<List<Area>>> {
  /// Lazily seeds [defaultAreaNames] on first read when the user has zero areas
  /// AND the first server snapshot has confirmed they really do have zero.
  /// Returns the same data as [areasProvider] but with the side effect of
  /// kicking off seeding in the background.
  ///
  /// Two race conditions to avoid:
  ///   1. Existing user opens the picker before their server-side areas have
  ///      synced down → local list is empty → without an initial-pull gate, we
  ///      would seed defaults that then duplicate/conflict with their real
  ///      areas a few hundred milliseconds later. Fix: await
  ///      [SyncService.areasInitialPullComplete] before deciding to seed.
  ///   2. Sign-out → sign-in as a different brand-new user during the same app
  ///      session. Without per-user state, the "already attempted" flag stays
  ///      true and the new user gets no defaults. Fix: track a Set of
  ///      personDocIds we have seeded for, not a single bool.
  ///
  /// Use this from the picker / management screen entry points, not from
  /// background queries.
  AreasWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'areasWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$areasWithDefaultsHash();

  @$internal
  @override
  AreasWithDefaults create() => AreasWithDefaults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Area>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Area>>>(value),
    );
  }
}

String _$areasWithDefaultsHash() => r'2423fead1edda7fc52d5c2f029c610dcfb55f509';

/// Lazily seeds [defaultAreaNames] on first read when the user has zero areas
/// AND the first server snapshot has confirmed they really do have zero.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background.
///
/// Two race conditions to avoid:
///   1. Existing user opens the picker before their server-side areas have
///      synced down → local list is empty → without an initial-pull gate, we
///      would seed defaults that then duplicate/conflict with their real
///      areas a few hundred milliseconds later. Fix: await
///      [SyncService.areasInitialPullComplete] before deciding to seed.
///   2. Sign-out → sign-in as a different brand-new user during the same app
///      session. Without per-user state, the "already attempted" flag stays
///      true and the new user gets no defaults. Fix: track a Set of
///      personDocIds we have seeded for, not a single bool.
///
/// Use this from the picker / management screen entry points, not from
/// background queries.

abstract class _$AreasWithDefaults extends $Notifier<AsyncValue<List<Area>>> {
  AsyncValue<List<Area>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Area>>, AsyncValue<List<Area>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Area>>, AsyncValue<List<Area>>>,
              AsyncValue<List<Area>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
