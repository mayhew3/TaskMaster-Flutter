// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$areasHash() => r'ffc967175ee6fabf65e31c956b938eee97b69ac6';

/// Stream of the current user's areas, sorted by sortOrder.
/// Streams from local Drift; SyncService keeps it in sync with Firestore.
///
/// Copied from [areas].
@ProviderFor(areas)
final areasProvider = StreamProvider<List<Area>>.internal(
  areas,
  name: r'areasProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$areasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AreasRef = StreamProviderRef<List<Area>>;
String _$areasWithDefaultsHash() => r'66be877245e62ce799946bb8256c90866101c380';

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
///
/// Copied from [AreasWithDefaults].
@ProviderFor(AreasWithDefaults)
final areasWithDefaultsProvider =
    NotifierProvider<AreasWithDefaults, AsyncValue<List<Area>>>.internal(
      AreasWithDefaults.new,
      name: r'areasWithDefaultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$areasWithDefaultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AreasWithDefaults = Notifier<AsyncValue<List<Area>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
