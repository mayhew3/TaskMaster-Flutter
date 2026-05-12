// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expanded_task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. TM-361 promoted this to `keepAlive: true` so the
/// notifier survives transient widget unmount/remount under Riverpod 4
/// (e.g. during tab swaps when no consumer is currently mounted). The
/// expansion state therefore persists across tab swaps; reset it
/// explicitly when that's not desired.

@ProviderFor(ExpandedTask)
final expandedTaskProvider = ExpandedTaskProvider._();

/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. TM-361 promoted this to `keepAlive: true` so the
/// notifier survives transient widget unmount/remount under Riverpod 4
/// (e.g. during tab swaps when no consumer is currently mounted). The
/// expansion state therefore persists across tab swaps; reset it
/// explicitly when that's not desired.
final class ExpandedTaskProvider
    extends $NotifierProvider<ExpandedTask, String?> {
  /// Tracks which task card (if any) is currently expanded inline.
  ///
  /// Accordion semantics: at most one card is expanded at a time across all
  /// task lists. TM-361 promoted this to `keepAlive: true` so the
  /// notifier survives transient widget unmount/remount under Riverpod 4
  /// (e.g. during tab swaps when no consumer is currently mounted). The
  /// expansion state therefore persists across tab swaps; reset it
  /// explicitly when that's not desired.
  ExpandedTaskProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expandedTaskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expandedTaskHash();

  @$internal
  @override
  ExpandedTask create() => ExpandedTask();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$expandedTaskHash() => r'c988fac9523edc6d649583215cb4efa0c33a49fc';

/// Tracks which task card (if any) is currently expanded inline.
///
/// Accordion semantics: at most one card is expanded at a time across all
/// task lists. TM-361 promoted this to `keepAlive: true` so the
/// notifier survives transient widget unmount/remount under Riverpod 4
/// (e.g. during tab swaps when no consumer is currently mounted). The
/// expansion state therefore persists across tab swaps; reset it
/// explicitly when that's not desired.

abstract class _$ExpandedTask extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
