// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contextIconLookupHash() => r'133ddec96404ffe736741badb7a42c05df383c62';

/// Lowercased name → catalog `iconName` lookup map for the current user's
/// contexts. Built once per `contextsProvider` emission, then read by every
/// task card's meta row so each card avoids rebuilding its own copy of the
/// map on every render. Returns null entries for catalog rows whose icon
/// hasn't been assigned (Tier 1 user-created contexts default to no icon).
///
/// Copied from [contextIconLookup].
@ProviderFor(contextIconLookup)
final contextIconLookupProvider =
    AutoDisposeProvider<Map<String, String?>>.internal(
      contextIconLookup,
      name: r'contextIconLookupProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contextIconLookupHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContextIconLookupRef = AutoDisposeProviderRef<Map<String, String?>>;
String _$contextTaskCountsHash() => r'213a71b8879316cc1a7c337252aadb73ab2b86c0';

/// Per-context task counts for the current user. Keyed by lowercased
/// context name; the value is the number of non-retired tasks (active +
/// completed) tagged with that context. Used by the Manage Contexts screen
/// to render count badges (TM-181). See `areaTaskCountsProvider` for the
/// rationale behind including completed tasks.
///
/// Copied from [contextTaskCounts].
@ProviderFor(contextTaskCounts)
final contextTaskCountsProvider =
    AutoDisposeStreamProvider<Map<String, int>>.internal(
      contextTaskCounts,
      name: r'contextTaskCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contextTaskCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContextTaskCountsRef = AutoDisposeStreamProviderRef<Map<String, int>>;
String _$contextsHash() => r'f0847afa0fcde25775538380dc77b77adbd1f434';

/// Stream of the current user's contexts, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.
///
/// Copied from [contexts].
@ProviderFor(contexts)
final contextsProvider = StreamProvider<List<Context>>.internal(
  contexts,
  name: r'contextsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contextsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContextsRef = StreamProviderRef<List<Context>>;
String _$contextsWithDefaultsHash() =>
    r'a7c321456f784c2f41053929cd377d9736de2557';

/// Lazily seeds [defaultContextSeeds] on first read when the user has zero
/// contexts AND the first server snapshot has confirmed they really do have
/// zero. Mirrors `AreasWithDefaults` (TM-345) — see that provider for the
/// detailed rationale around the two race conditions (initial-pull gate and
/// per-personDocId tracking).
///
/// Copied from [ContextsWithDefaults].
@ProviderFor(ContextsWithDefaults)
final contextsWithDefaultsProvider =
    NotifierProvider<ContextsWithDefaults, AsyncValue<List<Context>>>.internal(
      ContextsWithDefaults.new,
      name: r'contextsWithDefaultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contextsWithDefaultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContextsWithDefaults = Notifier<AsyncValue<List<Context>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
