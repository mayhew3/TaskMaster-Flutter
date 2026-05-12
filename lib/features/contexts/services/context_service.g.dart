// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contextService)
final contextServiceProvider = ContextServiceProvider._();

final class ContextServiceProvider
    extends $FunctionalProvider<ContextService, ContextService, ContextService>
    with $Provider<ContextService> {
  ContextServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contextServiceHash();

  @$internal
  @override
  $ProviderElement<ContextService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContextService create(Ref ref) {
    return contextService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContextService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContextService>(value),
    );
  }
}

String _$contextServiceHash() => r'f6b5f08f7c0dd7c40dff2025056e109439653a06';
