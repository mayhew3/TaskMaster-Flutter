// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_color_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$areaColorsHash() => r'53e546fb504939fcb3cae1a30ca6f30a1e7be0c5';

/// Stable name → color mapping for the user's areas.
///
/// Built from `areasProvider`, which already streams areas sorted by
/// `sortOrder`. Each area's index in that list maps to a slot in
/// `TaskColors.areaPalette` — so the first N areas (where N ≤ palette
/// length) get distinct colors. Unknown / stale area strings fall back to
/// the hash-based `AreaColorHelper.colorForArea` at the call site.
///
/// Copied from [areaColors].
@ProviderFor(areaColors)
final areaColorsProvider = Provider<Map<String, Color>>.internal(
  areaColors,
  name: r'areaColorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$areaColorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AreaColorsRef = ProviderRef<Map<String, Color>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
