// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for GoogleSignIn instance

@ProviderFor(googleSignIn)
final googleSignInProvider = GoogleSignInProvider._();

/// Provider for GoogleSignIn instance

final class GoogleSignInProvider
    extends $FunctionalProvider<GoogleSignIn, GoogleSignIn, GoogleSignIn>
    with $Provider<GoogleSignIn> {
  /// Provider for GoogleSignIn instance
  GoogleSignInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInHash();

  @$internal
  @override
  $ProviderElement<GoogleSignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleSignIn create(Ref ref) {
    return googleSignIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleSignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleSignIn>(value),
    );
  }
}

String _$googleSignInHash() => r'be6e657edfb1790d127cff1d3820a50c34e65011';

/// Provider for AuthService

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

/// Provider for AuthService

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Provider for AuthService
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'8d569cce6458aacd4ffbc0f356702b3b1416d63f';

/// Main auth state notifier - manages authentication flow

@ProviderFor(Auth)
final authProvider = AuthProvider._();

/// Main auth state notifier - manages authentication flow
final class AuthProvider extends $NotifierProvider<Auth, AuthState> {
  /// Main auth state notifier - manages authentication flow
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authHash() => r'88be8cccd1391733b17468cc190e558a911812bb';

/// Main auth state notifier - manages authentication flow

abstract class _$Auth extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
