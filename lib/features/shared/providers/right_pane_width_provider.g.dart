// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'right_pane_width_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pixel width the right pane should occupy in the current frame
/// (TM-385). Used by `_buildWideShell`'s `SizedBox(width: ...)`
/// wrapping `RightPaneContainer`.
///
/// Width is dynamic only for [RightPaneMode.viewOptions]; every other
/// mode uses the fixed [kRightPaneWidth] (380dp) that pre-TM-385
/// hard-coded.
///
/// View Options sizing:
///   - **Collapsed** (the per-surface `viewOptionsCollapsed` flag is
///     true): pane shrinks to [kViewOptionsHandleWidth] (44dp), making
///     room for the center list. The handle widget renders inside.
///   - **Expanded**: pane width is `lerp(min, max, ratio)` where the
///     ratio is the per-surface persisted value in `[0, 1]`. Default
///     ratio = 1.0 lands at [kViewOptionsExpandedMax].
///
/// The width is per-surface (Tasks remembers its width independently
/// from Plan), so tab-switching while in `.viewOptions` swaps both
/// the panel contents AND the width — desirable: a user who prefers
/// a wider panel on the Tasks tab can also prefer a narrower one on
/// Plan, and both stay sticky.
///
/// Stats tab has no list surface, so the width falls back to
/// [kRightPaneWidth] (defensive — the View Options button isn't
/// rendered on Stats anyway, so this branch should be unreachable in
/// production).
///
/// ## Why this lives in its own file
///
/// Combines reads from `selected_task_providers` (`rightPaneProvider`)
/// and `navigation_provider` (`activeNavDestinationProvider`).
/// `navigation_provider` already depends on `selected_task_providers`
/// (for `RightPane`, `SelectedTask`, `ExpandedTask`); if this provider
/// lived in `selected_task_providers` it would have to import
/// `navigation_provider` and complete a Dart import cycle. The third
/// file breaks the cycle without forcing either side to know about
/// the other.

@ProviderFor(rightPaneWidth)
final rightPaneWidthProvider = RightPaneWidthProvider._();

/// Pixel width the right pane should occupy in the current frame
/// (TM-385). Used by `_buildWideShell`'s `SizedBox(width: ...)`
/// wrapping `RightPaneContainer`.
///
/// Width is dynamic only for [RightPaneMode.viewOptions]; every other
/// mode uses the fixed [kRightPaneWidth] (380dp) that pre-TM-385
/// hard-coded.
///
/// View Options sizing:
///   - **Collapsed** (the per-surface `viewOptionsCollapsed` flag is
///     true): pane shrinks to [kViewOptionsHandleWidth] (44dp), making
///     room for the center list. The handle widget renders inside.
///   - **Expanded**: pane width is `lerp(min, max, ratio)` where the
///     ratio is the per-surface persisted value in `[0, 1]`. Default
///     ratio = 1.0 lands at [kViewOptionsExpandedMax].
///
/// The width is per-surface (Tasks remembers its width independently
/// from Plan), so tab-switching while in `.viewOptions` swaps both
/// the panel contents AND the width — desirable: a user who prefers
/// a wider panel on the Tasks tab can also prefer a narrower one on
/// Plan, and both stay sticky.
///
/// Stats tab has no list surface, so the width falls back to
/// [kRightPaneWidth] (defensive — the View Options button isn't
/// rendered on Stats anyway, so this branch should be unreachable in
/// production).
///
/// ## Why this lives in its own file
///
/// Combines reads from `selected_task_providers` (`rightPaneProvider`)
/// and `navigation_provider` (`activeNavDestinationProvider`).
/// `navigation_provider` already depends on `selected_task_providers`
/// (for `RightPane`, `SelectedTask`, `ExpandedTask`); if this provider
/// lived in `selected_task_providers` it would have to import
/// `navigation_provider` and complete a Dart import cycle. The third
/// file breaks the cycle without forcing either side to know about
/// the other.

final class RightPaneWidthProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Pixel width the right pane should occupy in the current frame
  /// (TM-385). Used by `_buildWideShell`'s `SizedBox(width: ...)`
  /// wrapping `RightPaneContainer`.
  ///
  /// Width is dynamic only for [RightPaneMode.viewOptions]; every other
  /// mode uses the fixed [kRightPaneWidth] (380dp) that pre-TM-385
  /// hard-coded.
  ///
  /// View Options sizing:
  ///   - **Collapsed** (the per-surface `viewOptionsCollapsed` flag is
  ///     true): pane shrinks to [kViewOptionsHandleWidth] (44dp), making
  ///     room for the center list. The handle widget renders inside.
  ///   - **Expanded**: pane width is `lerp(min, max, ratio)` where the
  ///     ratio is the per-surface persisted value in `[0, 1]`. Default
  ///     ratio = 1.0 lands at [kViewOptionsExpandedMax].
  ///
  /// The width is per-surface (Tasks remembers its width independently
  /// from Plan), so tab-switching while in `.viewOptions` swaps both
  /// the panel contents AND the width — desirable: a user who prefers
  /// a wider panel on the Tasks tab can also prefer a narrower one on
  /// Plan, and both stay sticky.
  ///
  /// Stats tab has no list surface, so the width falls back to
  /// [kRightPaneWidth] (defensive — the View Options button isn't
  /// rendered on Stats anyway, so this branch should be unreachable in
  /// production).
  ///
  /// ## Why this lives in its own file
  ///
  /// Combines reads from `selected_task_providers` (`rightPaneProvider`)
  /// and `navigation_provider` (`activeNavDestinationProvider`).
  /// `navigation_provider` already depends on `selected_task_providers`
  /// (for `RightPane`, `SelectedTask`, `ExpandedTask`); if this provider
  /// lived in `selected_task_providers` it would have to import
  /// `navigation_provider` and complete a Dart import cycle. The third
  /// file breaks the cycle without forcing either side to know about
  /// the other.
  RightPaneWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rightPaneWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rightPaneWidthHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return rightPaneWidth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$rightPaneWidthHash() => r'1d6736a38c4d01ce3e09f01fddce45fec7b45a12';
