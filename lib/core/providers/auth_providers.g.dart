// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$googleSignInHash() => r'66470fcc88b53a1d4566b7b94f89028a0aab7158';

/// See also [googleSignIn].
@ProviderFor(googleSignIn)
final googleSignInProvider = AutoDisposeProvider<GoogleSignIn>.internal(
  googleSignIn,
  name: r'googleSignInProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$googleSignInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoogleSignInRef = AutoDisposeProviderRef<GoogleSignIn>;
String _$authStateChangesHash() => r'386ea079ca75ac54d471519e1565d88b5c2efc08';

/// Stream of auth state changes
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
String _$currentUserHash() => r'3990b21ef659d1ef778efb351d535ee600ebe211';

/// Current user (nullable)
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
String _$personDocIdHash() => r'63010f2033a20ca5ad900a9c297da79bf535251d';

/// Person doc ID from Firestore
///
/// Copied from [personDocId].
@ProviderFor(personDocId)
final personDocIdProvider = AutoDisposeFutureProvider<String?>.internal(
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
typedef PersonDocIdRef = AutoDisposeFutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
