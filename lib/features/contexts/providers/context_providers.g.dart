// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lowercased name → catalog `iconName` lookup map for the current user's
/// contexts. Built once per `contextsProvider` emission, then read by every
/// task card's meta row so each card avoids rebuilding its own copy of the
/// map on every render. Returns null entries for catalog rows whose icon
/// hasn't been assigned (Tier 1 user-created contexts default to no icon).

@ProviderFor(contextIconLookup)
final contextIconLookupProvider = ContextIconLookupProvider._();

/// Lowercased name → catalog `iconName` lookup map for the current user's
/// contexts. Built once per `contextsProvider` emission, then read by every
/// task card's meta row so each card avoids rebuilding its own copy of the
/// map on every render. Returns null entries for catalog rows whose icon
/// hasn't been assigned (Tier 1 user-created contexts default to no icon).

final class ContextIconLookupProvider
    extends
        $FunctionalProvider<
          Map<String, String?>,
          Map<String, String?>,
          Map<String, String?>
        >
    with $Provider<Map<String, String?>> {
  /// Lowercased name → catalog `iconName` lookup map for the current user's
  /// contexts. Built once per `contextsProvider` emission, then read by every
  /// task card's meta row so each card avoids rebuilding its own copy of the
  /// map on every render. Returns null entries for catalog rows whose icon
  /// hasn't been assigned (Tier 1 user-created contexts default to no icon).
  ContextIconLookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextIconLookupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextIconLookupHash();

  @$internal
  @override
  $ProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String?> create(Ref ref) {
    return contextIconLookup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String?>>(value),
    );
  }
}

String _$contextIconLookupHash() => r'57ee26d7ec0f5fc8ccfa59a497989c7f6a28eb5b';

/// Per-context task counts for the current user. Keyed by lowercased
/// context name; the value is the number of non-retired tasks (active +
/// completed) tagged with that context. Used by the Manage Contexts screen
/// to render count badges (TM-181). See `areaTaskCountsProvider` for the
/// rationale behind including completed tasks.

@ProviderFor(contextTaskCounts)
final contextTaskCountsProvider = ContextTaskCountsProvider._();

/// Per-context task counts for the current user. Keyed by lowercased
/// context name; the value is the number of non-retired tasks (active +
/// completed) tagged with that context. Used by the Manage Contexts screen
/// to render count badges (TM-181). See `areaTaskCountsProvider` for the
/// rationale behind including completed tasks.

final class ContextTaskCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          Stream<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $StreamProvider<Map<String, int>> {
  /// Per-context task counts for the current user. Keyed by lowercased
  /// context name; the value is the number of non-retired tasks (active +
  /// completed) tagged with that context. Used by the Manage Contexts screen
  /// to render count badges (TM-181). See `areaTaskCountsProvider` for the
  /// rationale behind including completed tasks.
  ContextTaskCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextTaskCountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextTaskCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, int>> create(Ref ref) {
    return contextTaskCounts(ref);
  }
}

String _$contextTaskCountsHash() => r'f16c524c3ebaf429d00826bcf76d06bf8e929ba1';

/// Stream of the current user's contexts, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.

@ProviderFor(contexts)
final contextsProvider = ContextsProvider._();

/// Stream of the current user's contexts, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.

final class ContextsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Context>>,
          List<Context>,
          Stream<List<Context>>
        >
    with $FutureModifier<List<Context>>, $StreamProvider<List<Context>> {
  /// Stream of the current user's contexts, sorted by sortOrder.
  /// Streams from local Drift; SyncService keeps it in sync with Firestore.
  ContextsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextsHash();

  @$internal
  @override
  $StreamProviderElement<List<Context>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Context>> create(Ref ref) {
    return contexts(ref);
  }
}

String _$contextsHash() => r'f0847afa0fcde25775538380dc77b77adbd1f434';

/// Lazily seeds [defaultContextSeeds] on first read when the user has zero
/// contexts AND the first server snapshot has confirmed they really do have
/// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
/// detailed rationale around the two race conditions (initial-pull gate and
/// per-personDocId tracking).

@ProviderFor(ContextsWithDefaults)
final contextsWithDefaultsProvider = ContextsWithDefaultsProvider._();

/// Lazily seeds [defaultContextSeeds] on first read when the user has zero
/// contexts AND the first server snapshot has confirmed they really do have
/// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
/// detailed rationale around the two race conditions (initial-pull gate and
/// per-personDocId tracking).
final class ContextsWithDefaultsProvider
    extends $NotifierProvider<ContextsWithDefaults, AsyncValue<List<Context>>> {
  /// Lazily seeds [defaultContextSeeds] on first read when the user has zero
  /// contexts AND the first server snapshot has confirmed they really do have
  /// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
  /// detailed rationale around the two race conditions (initial-pull gate and
  /// per-personDocId tracking).
  ContextsWithDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextsWithDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextsWithDefaultsHash();

  @$internal
  @override
  ContextsWithDefaults create() => ContextsWithDefaults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Context>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Context>>>(value),
    );
  }
}

String _$contextsWithDefaultsHash() =>
    r'676f893a3177a4b3a704b2a92cc58a48683e92a9';

/// Lazily seeds [defaultContextSeeds] on first read when the user has zero
/// contexts AND the first server snapshot has confirmed they really do have
/// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
/// detailed rationale around the two race conditions (initial-pull gate and
/// per-personDocId tracking).

abstract class _$ContextsWithDefaults
    extends $Notifier<AsyncValue<List<Context>>> {
  AsyncValue<List<Context>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Context>>, AsyncValue<List<Context>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Context>>, AsyncValue<List<Context>>>,
              AsyncValue<List<Context>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
