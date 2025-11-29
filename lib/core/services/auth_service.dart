import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/firebase_providers.dart';

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
      final result = _googleSignIn.attemptLightweightAuthentication();

      if (result is Future<GoogleSignInAccount?>) {
        final account = await result;
        print('🔐 Silent sign-in result: ${account?.displayName ?? 'null'}');
        return account;
      }
      return result as GoogleSignInAccount?;
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
      print('🔐 Manual sign-in result: ${account?.displayName ?? 'null'}');
      return account;
    } on GoogleSignInException catch (e) {
      print('🔐 Google Sign In error: ${e.code.name} - ${e.description}');
      rethrow;
    }
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

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    print('🔐 Signing out...');
    await _googleSignIn.disconnect();
    await _firebaseAuth.signOut();
    print('🔐 Sign out complete');
  }

  /// Get current Firebase user (synchronous check)
  User? get currentUser => _firebaseAuth.currentUser;
}

/// Provider for GoogleSignIn instance
@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(GoogleSignInRef ref) => GoogleSignIn.instance;

/// Provider for AuthService
@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}

/// Main auth state notifier - manages authentication flow
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    // Start with initial state - will trigger initialization
    _initialize();
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _initialize() async {
    print('🔐 Auth: Initializing...');

    // Initialize Google Sign In
    final googleSignIn = ref.read(googleSignInProvider);
    await googleSignIn.initialize();
    print('🔐 Auth: Google Sign In initialized');

    // Try silent sign-in
    await trySilentSignIn();
  }

  /// Attempt silent sign-in (called on app start)
  Future<void> trySilentSignIn() async {
    final service = ref.read(authServiceProvider);

    state = state.copyWith(status: AuthStatus.authenticating);

    final account = await service.trySilentSignIn();
    if (account == null) {
      print('🔐 Auth: Silent sign-in failed, user needs to sign in manually');
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    await _completeSignIn(account);
  }

  /// Manual sign-in (user clicked button)
  Future<void> signIn() async {
    final service = ref.read(authServiceProvider);

    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      final account = await service.signIn();
      if (account == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      await _completeSignIn(account);
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
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        personDocId: personDocId,
      );
    } catch (e) {
      print('🔐 Auth: Error during sign-in completion: $e');

      // Check if this is a connection error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unavailable') ||
          errorStr.contains('timeout') ||
          errorStr.contains('econnrefused') ||
          errorStr.contains('failed to connect')) {
        state = AuthState(
          status: AuthStatus.connectionError,
          errorMessage: 'Cannot connect to server. Please check your connection.',
        );
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Sign in failed: $e',
        );
      }
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

    final snapshot = await firestore
        .collection('persons')
        .where('email', isEqualTo: email)
        .get();

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
    } else {
      // No user, try silent sign-in again
      await trySilentSignIn();
    }
  }
}
