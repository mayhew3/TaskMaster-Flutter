// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the currently active tab index
/// Using keepAlive to persist across widget rebuilds

@ProviderFor(ActiveTabIndex)
final activeTabIndexProvider = ActiveTabIndexProvider._();

/// Provider for the currently active tab index
/// Using keepAlive to persist across widget rebuilds
final class ActiveTabIndexProvider
    extends $NotifierProvider<ActiveTabIndex, int> {
  /// Provider for the currently active tab index
  /// Using keepAlive to persist across widget rebuilds
  ActiveTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTabIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTabIndexHash();

  @$internal
  @override
  ActiveTabIndex create() => ActiveTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeTabIndexHash() => r'6c4eacc95d7ebcad9c8a5473612512600d1792e3';

/// Provider for the currently active tab index
/// Using keepAlive to persist across widget rebuilds

abstract class _$ActiveTabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Derived [NavDestination] for the currently-active tab.
///
/// Mirrors the `liveNavItems` layout built inline in `riverpod_app.dart`:
///
///   - inFamily   : [Plan(0), Tasks(1), Family(2), Stats(3)]
///   - !inFamily  : [Plan(0), Tasks(1), Stats(2)]
///
/// Out-of-range indices fall through to [NavDestination.stats] —
/// `ActiveTabIndex.clampToLayout` should keep the index in range, so
/// this branch is defensive.
///
/// Centralises the index → destination mapping so layout-aware callers
/// outside the sidebar (TM-384's sidebar Add Task button + the docked
/// editor pane, which need to know if the Family tab is active so new
/// tasks default to family-shared) don't each re-derive it and silently
/// drift if the layout changes.

@ProviderFor(activeNavDestination)
final activeNavDestinationProvider = ActiveNavDestinationProvider._();

/// Derived [NavDestination] for the currently-active tab.
///
/// Mirrors the `liveNavItems` layout built inline in `riverpod_app.dart`:
///
///   - inFamily   : [Plan(0), Tasks(1), Family(2), Stats(3)]
///   - !inFamily  : [Plan(0), Tasks(1), Stats(2)]
///
/// Out-of-range indices fall through to [NavDestination.stats] —
/// `ActiveTabIndex.clampToLayout` should keep the index in range, so
/// this branch is defensive.
///
/// Centralises the index → destination mapping so layout-aware callers
/// outside the sidebar (TM-384's sidebar Add Task button + the docked
/// editor pane, which need to know if the Family tab is active so new
/// tasks default to family-shared) don't each re-derive it and silently
/// drift if the layout changes.

final class ActiveNavDestinationProvider
    extends $FunctionalProvider<NavDestination, NavDestination, NavDestination>
    with $Provider<NavDestination> {
  /// Derived [NavDestination] for the currently-active tab.
  ///
  /// Mirrors the `liveNavItems` layout built inline in `riverpod_app.dart`:
  ///
  ///   - inFamily   : [Plan(0), Tasks(1), Family(2), Stats(3)]
  ///   - !inFamily  : [Plan(0), Tasks(1), Stats(2)]
  ///
  /// Out-of-range indices fall through to [NavDestination.stats] —
  /// `ActiveTabIndex.clampToLayout` should keep the index in range, so
  /// this branch is defensive.
  ///
  /// Centralises the index → destination mapping so layout-aware callers
  /// outside the sidebar (TM-384's sidebar Add Task button + the docked
  /// editor pane, which need to know if the Family tab is active so new
  /// tasks default to family-shared) don't each re-derive it and silently
  /// drift if the layout changes.
  ActiveNavDestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeNavDestinationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeNavDestinationHash();

  @$internal
  @override
  $ProviderElement<NavDestination> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NavDestination create(Ref ref) {
    return activeNavDestination(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavDestination value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavDestination>(value),
    );
  }
}

String _$activeNavDestinationHash() =>
    r'fea0eb413e287b50237a8b208ef25f4ffa18de20';
