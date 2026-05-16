import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/firebase_providers.dart';
import 'analytics_service.dart';
import 'crash_reporter.dart';

part 'auth_service.g.dart';

/// Authentication state for the app
enum AuthStatus {
  /// Initial state, checking for existing session
  initial,
  /// User is authenticated and person verified
  authenticated,
  /// User is not authenticated (needs to sign in)
  unauthenticated,
  /// Authentication in progress
  authenticating,
  /// Person not found in Firestore (email not registered)
  personNotFound,
  /// Connection error (e.g., Firestore emulator not running)
  connectionError,
}

/// Complete auth state including user info and status
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.personDocId,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? personDocId;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.initial || status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? personDocId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      personDocId: personDocId ?? this.personDocId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, personDocId: $personDocId)';
  }
}

/// Maps a sign-in/verify error to the right terminal [AuthState].
/// Shared by the native and web completion paths so the connection-vs-
/// generic classification can't drift between them. A bounded-query
/// `TimeoutException` stringifies with "timeout" → connectionError, so
/// a stalled Firestore lookup degrades to the recoverable screen.
@visibleForTesting
AuthState classifyAuthError(Object error) {
  final s = error.toString().toLowerCase();
  if (s.contains('unavailable') ||
      s.contains('timeout') ||
      s.contains('econnrefused') ||
      s.contains('failed to connect')) {
    return const AuthState(
      status: AuthStatus.connectionError,
      errorMessage: 'Cannot connect to server. Please check your connection.',
    );
  }
  return AuthState(
    status: AuthStatus.unauthenticated,
    errorMessage: 'Sign in failed: $error',
  );
}

/// Outcome of re-checking the live Firebase session against the user a
/// web completion is committing for, across an `await` gap.
enum _Session { current, signedOut, switched }

/// Service class that handles authentication logic
class AuthService {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Attempt silent sign-in (for app restart)
  Future<GoogleSignInAccount?> trySilentSignIn() async {
    try {
      print('🔐 Attempting silent sign-in...');

      // attemptLightweightAuthentication returns Future<bool>, not the account
      // The authenticationEvents stream will emit the account if auth succeeds
      final success = await _googleSignIn.attemptLightweightAuthentication();
      print('🔐 Silent sign-in attempt result: $success');

      // Return null to indicate we're waiting for the authentication event
      // The actual account will come through the authenticationEvents stream
      return null;
    } on GoogleSignInException catch (e) {
      print('🔐 Google Sign In error: ${e.code.name} - ${e.description}');
      return null;
    } catch (e) {
      print('🔐 Unexpected error during silent sign-in: $e');
      return null;
    }
  }

  /// Manual sign-in (user clicked sign in button)
  Future<GoogleSignInAccount?> signIn() async {
    try {
      print('🔐 Starting manual sign-in...');
      final account = await _googleSignIn.authenticate(scopeHint: ['email']);
      print('🔐 Manual sign-in result: ${account.displayName ?? 'null'}');
      return account;
    } on GoogleSignInException catch (e) {
      print('🔐 Google Sign In error: ${e.code.name} - ${e.description}');
      rethrow;
    }
  }

  /// Web sign-in. google_sign_in 7.x has no programmatic
  /// `authenticate()` on web, so go straight through Firebase Auth's
  /// Google popup (the OAuth client is the one Firebase configures for
  /// the project's web app — no google_sign_in client-id meta tag
  /// needed). Returns the signed-in Firebase user.
  Future<User?> signInWithFirebasePopup() async {
    print('🔐 Web: starting Firebase Google popup sign-in...');
    final provider = GoogleAuthProvider()..addScope('email');
    final cred = await _firebaseAuth.signInWithPopup(provider);
    print('🔐 Web: Firebase popup sign-in result: ${cred.user?.email}');
    return cred.user;
  }

  /// Sign in to Firebase with Google account
  Future<UserCredential> signInToFirebase(GoogleSignInAccount account) async {
    print('🔐 Signing in to Firebase...');
    final authClient = _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes(['email']);

    if (authorization == null) {
      throw Exception('No authorization returned from Google');
    }

    final authentication = account.authentication;
    final idToken = authentication.idToken;

    if (idToken == null) {
      throw Exception('No idToken returned from Google');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    print('🔐 Firebase sign-in successful: ${userCredential.user?.email}');
    return userCredential;
  }

  /// Sign out from both Google and Firebase. On web there is no
  /// google_sign_in session to disconnect (auth goes through the
  /// Firebase popup) — just sign out of Firebase.
  Future<void> signOut() async {
    print('🔐 Signing out...');
    if (!kIsWeb) {
      await _googleSignIn.disconnect();
    }
    await _firebaseAuth.signOut();
    print('🔐 Sign out complete');
  }

  /// Get current Firebase user (synchronous check)
  User? get currentUser => _firebaseAuth.currentUser;
}

/// Platform gate for the auth path. Defaults to `kIsWeb` (compile-time
/// false under `flutter test`); overridable in tests so the web auth
/// flow can be exercised on the VM. Hand-written (not codegen) so it
/// adds no build_runner surface.
final targetIsWebProvider = Provider<bool>((ref) => kIsWeb);

/// Provider for GoogleSignIn instance
@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

/// Provider for AuthService
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}

/// Main auth state notifier - manages authentication flow
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  /// Email currently being processed by `_completeWebSignIn`, so the
  /// `authStateChanges` listener doesn't double-process the same user
  /// that the synchronous fast path (or a prior event) is already
  /// completing. Web-only.
  String? _webCompletingEmail;

  @override
  AuthState build() {
    // Start with initial state - will trigger initialization
    _initialize();
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _initialize() async {
    if (ref.read(targetIsWebProvider)) {
      await _initializeWeb();
      return;
    }
    try {
      print('🔐 Auth: Initializing...');

      // Initialize Google Sign In
      final googleSignIn = ref.read(googleSignInProvider);
      await googleSignIn.initialize();
      print('🔐 Auth: Google Sign In initialized');

      // Track whether we received an auth event
      var receivedAuthEvent = false;

      // Listen to authentication events stream for automatic session restoration
      googleSignIn.authenticationEvents.listen(
        (GoogleSignInAuthenticationEvent event) async {
          receivedAuthEvent = true;
          switch (event) {
            case GoogleSignInAuthenticationEventSignIn():
              print('🔐 Auth: Sign-in event - user: ${event.user.displayName}');
              await _completeSignIn(event.user);
            case GoogleSignInAuthenticationEventSignOut():
              print('🔐 Auth: Sign-out event');
              state = const AuthState(status: AuthStatus.unauthenticated);
          }
        },
        onError: (error) {
          receivedAuthEvent = true;
          print('🔐 Auth: Authentication event error: $error');
          state = AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Authentication error: $error',
          );
        },
      );

      // Trigger lightweight authentication to restore session
      // Wrap in try-catch in case the native code crashes
      try {
        await trySilentSignIn();
      } catch (e) {
        print('🔐 Auth: Silent sign-in threw exception: $e');
        // Continue - we'll fall through to unauthenticated state
      }

      // If no auth event was received after silent sign-in, user needs to sign in manually
      // Use a short delay to allow any pending auth events to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      if (!receivedAuthEvent && state.status == AuthStatus.initial) {
        print('🔐 Auth: No saved session found, prompting for sign-in');
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e, stackTrace) {
      print('🔐 Auth: Fatal error during initialization: $e');
      print('🔐 Auth: Stack trace: $stackTrace');
      // Fail gracefully - show sign-in screen
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Auth initialization failed: $e',
      );
    }
  }

  /// Attempt silent sign-in (called on app start)
  Future<void> trySilentSignIn() async {
    final service = ref.read(authServiceProvider);

    // Note: attemptLightweightAuthentication just triggers the auth attempt
    // The actual authentication result comes through authenticationEvents stream
    // We don't set state here - let the stream handle all state transitions
    await service.trySilentSignIn();

    print('🔐 Auth: Silent sign-in attempt completed, waiting for authentication events...');
  }

  /// Manual sign-in (user clicked button)
  Future<void> signIn() async {
    if (kIsWeb) {
      await _signInWeb();
      return;
    }
    final service = ref.read(authServiceProvider);

    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      final account = await service.signIn();
      if (account == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // Don't call _completeSignIn here - the authenticationEvents stream will handle it
      print('🔐 Auth: Manual sign-in successful, waiting for authentication event...');
    } on GoogleSignInException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed: ${e.description}',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed: $e',
      );
    }
  }

  /// Complete sign-in process after Google auth succeeds
  Future<void> _completeSignIn(GoogleSignInAccount account) async {
    final service = ref.read(authServiceProvider);

    try {
      // Sign in to Firebase
      final userCredential = await service.signInToFirebase(account);
      final user = userCredential.user;

      if (user == null || user.email == null) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Firebase sign in returned no user',
        );
        return;
      }

      // Verify person exists in Firestore
      final personDocId = await _verifyPerson(user.email!);

      if (personDocId == null) {
        // Person not found - but DON'T disconnect, let them try again
        // or use a different account
        print('🔐 Auth: Person not found for email ${user.email}');
        state = AuthState(
          status: AuthStatus.personNotFound,
          user: user,
          errorMessage: 'No account found for ${user.email}. Contact administrator.',
        );
        return;
      }

      // Success!
      print('🔐 Auth: Fully authenticated - user: ${user.email}, personDocId: $personDocId');
      await _associateUser(personDocId);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        personDocId: personDocId,
      );
    } catch (e) {
      print('🔐 Auth: Error during sign-in completion: $e');
      state = classifyAuthError(e);
    }
  }

  /// Best-effort: associate crashes/analytics with the user (anonymized
  /// — personDocId, not email). Never fatal: a telemetry failure (e.g.
  /// firebase_analytics misbehaving on web) must not get caught by the
  /// completion handler and misreported as a failed sign-in.
  Future<void> _associateUser(String personDocId) async {
    try {
      await ref.read(crashReporterProvider).setUserIdentifier(personDocId);
      await ref.read(analyticsServiceProvider).setUserIdentifier(personDocId);
    } catch (e) {
      print('🔐 Auth: user-identifier association failed (non-fatal): $e');
    }
  }

  // ── Web auth path (Firebase popup; google_sign_in is native-only) ──

  /// Web init: Firebase Auth persists the session itself, so restore
  /// from `currentUser` instead of google_sign_in silent sign-in.
  Future<void> _initializeWeb() async {
    // CRITICAL: `_initialize()` is called from the notifier's `build()`
    // (not awaited). Unlike the native path — whose first `state =` is
    // after `await googleSignIn.initialize()` — the web branches can
    // reach a `state =` with no preceding await, which would run
    // *synchronously during build()*; Riverpod then applies build()'s
    // return value (AuthStatus.initial) afterwards, clobbering it and
    // pinning the UI on the splash forever. Yield once so everything
    // below runs as a proper post-build state update.
    await Future<void>.delayed(Duration.zero);
    // The provider may have been disposed/invalidated during that gap
    // (`_initialize` is fire-and-forget from build(); keepAlive
    // providers are still disposed by ref.invalidate / container
    // teardown). Touching ref/state after disposal throws.
    if (!ref.mounted) return;
    try {
      print('🔐 Auth(web): Initializing...');
      final auth = ref.read(firebaseAuthProvider);

      // `authStateChanges()` is the source of truth (web restores the
      // session asynchronously — `currentUser` is frequently null at
      // startup until the first stream emit). Registered once, BEFORE
      // the fast-path read, cancelled on dispose (keepAlive providers
      // are still disposed by `ref.invalidate` / container teardown).
      //   - null  → only downgrade an established session (don't fight
      //             an in-flight sign-in; mid-verify is handled by the
      //             live re-check in `_completeWebSignIn`).
      //   - user  → run completion unless it's already the
      //             authenticated user or a completion for that email
      //             is in flight (covers async session restore AND a
      //             cross-tab account switch).
      final sub = auth.authStateChanges().listen((user) {
        if (!ref.mounted) return;
        if (user == null) {
          if (state.status == AuthStatus.authenticated) {
            state = const AuthState(status: AuthStatus.unauthenticated);
          }
          return;
        }
        if (user.email == _webCompletingEmail) return;
        if (state.status == AuthStatus.authenticated &&
            state.user?.email == user.email) {
          return;
        }
        _completeWebSignIn(user);
      });
      ref.onDispose(sub.cancel);

      // Fast path: if the session is already hydrated synchronously,
      // complete immediately rather than waiting for the stream. If
      // not, settle `unauthenticated` so the UI leaves the splash — a
      // later non-null `authStateChanges` event re-runs completion.
      final existing = auth.currentUser;
      if (existing != null && existing.email != null) {
        await _completeWebSignIn(existing);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e, stackTrace) {
      print('🔐 Auth(web): Fatal init error: $e');
      print('🔐 Auth(web): $stackTrace');
      if (!ref.mounted) return;
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Auth initialization failed: $e',
      );
    }
  }

  /// Web manual sign-in via the Firebase Google popup.
  Future<void> _signInWeb() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final service = ref.read(authServiceProvider);
      final user = await service.signInWithFirebasePopup();
      if (user == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      await _completeWebSignIn(user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed: $e',
      );
    }
  }

  /// Re-check the live Firebase session for a web completion that is
  /// about to commit a terminal state after an `await` gap. Caller must
  /// have confirmed `ref.mounted` first (this reads `ref`).
  _Session _recheckSession(User user) {
    final live = ref.read(firebaseAuthProvider).currentUser;
    if (live == null) return _Session.signedOut;
    if (live.email != user.email) return _Session.switched;
    return _Session.current;
  }

  /// Applied at EVERY post-async commit point in `_completeWebSignIn`
  /// (post-verify, post-telemetry, error path). Returns true if the
  /// caller must stop because the session changed under it:
  ///   - signedOut → commit `unauthenticated`.
  ///   - switched  → a newer different session is active; this is a
  ///     STALE completion → return WITHOUT touching state so it can't
  ///     clobber the newer user's authenticated/personNotFound state.
  bool _abortIfSessionChanged(User user) {
    switch (_recheckSession(user)) {
      case _Session.signedOut:
        print('🔐 Auth(web): signed out during async gap — aborting');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return true;
      case _Session.switched:
        print('🔐 Auth(web): account switched — discarding stale '
            'completion for ${user.email}');
        return true;
      case _Session.current:
        return false;
    }
  }

  /// Post-auth completion for web: the popup already signed the user
  /// into Firebase, so skip `signInToFirebase` and reuse the shared
  /// person-verification + state transitions.
  Future<void> _completeWebSignIn(User user) async {
    _webCompletingEmail = user.email;
    try {
      if (user.email == null) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Firebase sign in returned no email',
        );
        return;
      }
      final personDocId = await _verifyPerson(user.email!);
      if (!ref.mounted) return; // disposed during the verify await
      // A sign-out/account-switch during the verify await is ignored by
      // the listener (its guard needs status==authenticated, not yet
      // true); re-check before committing ANY post-verify terminal
      // state (personNotFound or authenticated).
      if (_abortIfSessionChanged(user)) return;
      if (personDocId == null) {
        print('🔐 Auth(web): Person not found for email ${user.email}');
        state = AuthState(
          status: AuthStatus.personNotFound,
          user: user,
          errorMessage:
              'No account found for ${user.email}. Contact administrator.',
        );
        return;
      }
      print('🔐 Auth(web): Fully authenticated - ${user.email}');
      await _associateUser(personDocId);
      if (!ref.mounted) return; // disposed during telemetry association
      // Telemetry association is another async gap — re-check before
      // finally committing `authenticated`.
      if (_abortIfSessionChanged(user)) return;
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        personDocId: personDocId,
      );
    } catch (e) {
      print('🔐 Auth(web): Error during sign-in completion: $e');
      if (!ref.mounted) return;
      // The verify threw after an async gap — don't let a stale
      // failure clobber a newer session either.
      if (_abortIfSessionChanged(user)) return;
      state = classifyAuthError(e);
    } finally {
      if (_webCompletingEmail == user.email) _webCompletingEmail = null;
    }
  }

  /// Verify person exists in Firestore and return their docId
  Future<String?> _verifyPerson(String email) async {
    print('🔐 Auth: Verifying person for email: $email');

    final firestore = ref.read(firestoreProvider);

    // For local emulator, test connection first
    const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');
    if (serverEnv == 'local') {
      try {
        print('🔐 Auth: Testing Firestore emulator connection...');
        await firestore
            .collection('_connection_test')
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 5));
        print('🔐 Auth: Firestore connection OK');
      } catch (e) {
        print('🔐 Auth: Firestore connection failed: $e');
        rethrow;
      }
    }

    // Bounded so a stalled Firestore connection (notably on web, where
    // there's no native socket-level failure to surface) becomes a
    // recoverable connectionError instead of an infinite "Signing In…".
    final snapshot = await firestore
        .collection('persons')
        .where('email', isEqualTo: email)
        .get()
        .timeout(const Duration(seconds: 15));

    return snapshot.docs.firstOrNull?.id;
  }

  /// Sign out
  Future<void> signOut() async {
    final service = ref.read(authServiceProvider);
    await service.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Retry after connection error
  Future<void> retry() async {
    if (state.user != null) {
      // We have a user, just need to verify person
      state = state.copyWith(status: AuthStatus.authenticating);
      try {
        final personDocId = await _verifyPerson(state.user!.email!);
        if (personDocId != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: state.user,
            personDocId: personDocId,
          );
        } else {
          state = AuthState(
            status: AuthStatus.connectionError,
            user: state.user,
            errorMessage: 'Still cannot connect. Please try again.',
          );
        }
      } catch (e) {
        // `_verifyPerson` is bounded by a 15s timeout; a timeout/throw
        // here must NOT bubble out of the Retry handler and strand the
        // UI in `authenticating`. Classify it and keep the user so the
        // connection-error screen's Retry stays usable.
        print('🔐 Auth: retry verify failed: $e');
        state = classifyAuthError(e).copyWith(user: state.user);
      }
    } else {
      // No user, try silent sign-in again
      await trySilentSignIn();
    }
  }
}
