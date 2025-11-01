import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase_providers.dart';

part 'auth_providers.g.dart';

@riverpod
GoogleSignIn googleSignIn(GoogleSignInRef ref) => GoogleSignIn.instance;

/// Stream of auth state changes
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

/// Current user (nullable)
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
}

/// Person doc ID from Firestore
@riverpod
Future<String?> personDocId(PersonDocIdRef ref) async {
  // Get current user directly from FirebaseAuth instead of waiting for stream
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;

  if (user == null) return null;

  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection('persons')
      .where('email', isEqualTo: user.email)
      .get();

  return snapshot.docs.firstOrNull?.id;
}
