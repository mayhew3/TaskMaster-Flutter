// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityServiceHash() =>
    r'a41855a7e07cfa28457d4a8747cbc16077f207b4';

/// See also [connectivityService].
@ProviderFor(connectivityService)
final connectivityServiceProvider = Provider<ConnectivityService>.internal(
  connectivityService,
  name: r'connectivityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityServiceRef = ProviderRef<ConnectivityService>;
String _$connectivityHash() => r'32630bbfecf8441f2a01254ece7feacbb8fce819';

/// Stream of `online: bool`. Emits the current state immediately, then
/// updates whenever connectivity changes.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = StreamProvider<bool>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = StreamProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
