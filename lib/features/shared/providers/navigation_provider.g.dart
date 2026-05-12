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

String _$activeTabIndexHash() => r'd3d4f95a4e73044a18c15efe435caa19cd3a3a87';

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
