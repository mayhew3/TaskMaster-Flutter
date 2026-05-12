// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SyncStatusController)
final syncStatusControllerProvider = SyncStatusControllerProvider._();

final class SyncStatusControllerProvider
    extends $NotifierProvider<SyncStatusController, SyncStatus> {
  SyncStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusControllerHash();

  @$internal
  @override
  SyncStatusController create() => SyncStatusController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusControllerHash() =>
    r'e1220486970aa2d29675e4af9dffa33539022b5e';

abstract class _$SyncStatusController extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatus, SyncStatus>,
              SyncStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
