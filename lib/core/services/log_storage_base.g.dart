// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_storage_base.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(logStorageService)
final logStorageServiceProvider = LogStorageServiceProvider._();

final class LogStorageServiceProvider
    extends $FunctionalProvider<LogStorageBase, LogStorageBase, LogStorageBase>
    with $Provider<LogStorageBase> {
  LogStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logStorageServiceHash();

  @$internal
  @override
  $ProviderElement<LogStorageBase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogStorageBase create(Ref ref) {
    return logStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogStorageBase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogStorageBase>(value),
    );
  }
}

String _$logStorageServiceHash() => r'8679104ca0d7b1ee7e94ecb515bfcfc8b391bb02';
