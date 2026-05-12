import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import 'firebase_providers.dart';

part 'auth_providers.g.dart';

/// Stream of auth state changes from Firebase
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

/// Current Firebase user (nullable)
/// This watches the auth notifier state for reactive updates
@Riverpod(keepAlive: true)
User? currentUser(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
}

/// Person doc ID from the auth state
/// Returns null if not authenticated or person not verified
@Riverpod(keepAlive: true)
String? personDocId(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.personDocId;
}

/// Whether the user is fully authenticated (signed in AND person verified)
@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
}

/// Whether auth is still loading (initializing or authenticating)
@Riverpod(keepAlive: true)
bool isAuthLoading(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
}
