// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateChangesHash() => r'5f8861723c359af3f00d0995225ba1df8c413368';

/// Stream of auth state changes from Firebase
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'4c8cb60cef35a4fd001291434558037d6c85faf5';

/// Current Firebase user (nullable)
/// This watches the auth notifier state for reactive updates
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$personDocIdHash() => r'97beffdbed28e795901298ec645ab3e4ac71e1bf';

/// Person doc ID from the auth state
/// Returns null if not authenticated or person not verified
///
/// Copied from [personDocId].
@ProviderFor(personDocId)
final personDocIdProvider = AutoDisposeProvider<String?>.internal(
  personDocId,
  name: r'personDocIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personDocIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonDocIdRef = AutoDisposeProviderRef<String?>;
String _$isAuthenticatedHash() => r'003f7e85bfa5ae774792659ce771b5b59ebf04f8';

/// Whether the user is fully authenticated (signed in AND person verified)
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isAuthLoadingHash() => r'b9e25036f2f11d488204a6e453070e7f191b2292';

/// Whether auth is still loading (initializing or authenticating)
///
/// Copied from [isAuthLoading].
@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAuthLoading,
  name: r'isAuthLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthLoadingRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
