// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(logStorageService)
final logStorageServiceProvider = LogStorageServiceProvider._();

final class LogStorageServiceProvider
    extends
        $FunctionalProvider<
          LogStorageService,
          LogStorageService,
          LogStorageService
        >
    with $Provider<LogStorageService> {
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
  $ProviderElement<LogStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LogStorageService create(Ref ref) {
    return logStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogStorageService>(value),
    );
  }
}

String _$logStorageServiceHash() => r'1e3c42e8f6ff8e87f77721aa59ea51433f76d2ca';
