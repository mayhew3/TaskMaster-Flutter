// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_color_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stable name → color mapping for the user's areas.
///
/// Built from `areasProvider`, which already streams areas sorted by
/// `sortOrder`. Each area's index in that list maps to a slot in
/// `TaskColors.areaPalette` — so the first N areas (where N ≤ palette
/// length) get distinct colors. Unknown / stale area strings fall back to
/// the hash-based `AreaColorHelper.colorForArea` at the call site.

@ProviderFor(areaColors)
final areaColorsProvider = AreaColorsProvider._();

/// Stable name → color mapping for the user's areas.
///
/// Built from `areasProvider`, which already streams areas sorted by
/// `sortOrder`. Each area's index in that list maps to a slot in
/// `TaskColors.areaPalette` — so the first N areas (where N ≤ palette
/// length) get distinct colors. Unknown / stale area strings fall back to
/// the hash-based `AreaColorHelper.colorForArea` at the call site.

final class AreaColorsProvider
    extends
        $FunctionalProvider<
          Map<String, Color>,
          Map<String, Color>,
          Map<String, Color>
        >
    with $Provider<Map<String, Color>> {
  /// Stable name → color mapping for the user's areas.
  ///
  /// Built from `areasProvider`, which already streams areas sorted by
  /// `sortOrder`. Each area's index in that list maps to a slot in
  /// `TaskColors.areaPalette` — so the first N areas (where N ≤ palette
  /// length) get distinct colors. Unknown / stale area strings fall back to
  /// the hash-based `AreaColorHelper.colorForArea` at the call site.
  AreaColorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'areaColorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$areaColorsHash();

  @$internal
  @override
  $ProviderElement<Map<String, Color>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Color> create(Ref ref) {
    return areaColors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Color> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Color>>(value),
    );
  }
}

String _$areaColorsHash() => r'0d1d4641f341640952db166192542661c651f3a1';
