// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crash_reporter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(crashReporter)
final crashReporterProvider = CrashReporterProvider._();

final class CrashReporterProvider
    extends
        $FunctionalProvider<
          CrashReporterBase,
          CrashReporterBase,
          CrashReporterBase
        >
    with $Provider<CrashReporterBase> {
  CrashReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crashReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crashReporterHash();

  @$internal
  @override
  $ProviderElement<CrashReporterBase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrashReporterBase create(Ref ref) {
    return crashReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrashReporterBase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrashReporterBase>(value),
    );
  }
}

String _$crashReporterHash() => r'b946d0d132d768a1185129e5475b757644376b1e';
