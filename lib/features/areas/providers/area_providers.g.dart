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
String _$areasWithDefaultsHash() => r'e6cfcdfaf299ccf14f857229a12c4b618b8bd33b';

/// Lazily seeds [defaultAreaNames] on first read if the user has zero areas.
/// Returns the same data as [areasProvider] but with the side effect of
/// kicking off seeding in the background. Idempotent: only seeds once per
/// session (the in-memory `_seedAttempted` flag is reset only by hot restart).
///
/// Use this from the picker / management screen entry points, not from
/// background queries — those should use [areasProvider] directly to avoid
/// triggering a seed on a transient empty state during initial pull.
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
