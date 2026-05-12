// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream of auth state changes from Firebase

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Stream of auth state changes from Firebase

final class AuthStateChangesProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Stream of auth state changes from Firebase
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'84fab4f3f575b01ddd57f9a521ff98da1b0cb8bb';

/// Current Firebase user (nullable)
/// This watches the auth notifier state for reactive updates

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Current Firebase user (nullable)
/// This watches the auth notifier state for reactive updates

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// Current Firebase user (nullable)
  /// This watches the auth notifier state for reactive updates
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'4a38060e451fad6af125832c104b9421a88ca74e';

/// Person doc ID from the auth state
/// Returns null if not authenticated or person not verified

@ProviderFor(personDocId)
final personDocIdProvider = PersonDocIdProvider._();

/// Person doc ID from the auth state
/// Returns null if not authenticated or person not verified

final class PersonDocIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Person doc ID from the auth state
  /// Returns null if not authenticated or person not verified
  PersonDocIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personDocIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personDocIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return personDocId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$personDocIdHash() => r'1788f77e4d3d9b2cecc4c3b39d56bc4af02ed732';

/// Whether the user is fully authenticated (signed in AND person verified)

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Whether the user is fully authenticated (signed in AND person verified)

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the user is fully authenticated (signed in AND person verified)
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'd363c5c0e10f30ab7cbac1a108ba9856e7c82a22';

/// Whether auth is still loading (initializing or authenticating)

@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = IsAuthLoadingProvider._();

/// Whether auth is still loading (initializing or authenticating)

final class IsAuthLoadingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether auth is still loading (initializing or authenticating)
  IsAuthLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthLoadingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthLoadingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthLoading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthLoadingHash() => r'9a8773be6bd5b2624945c1a2a29cdd738c862bcc';
