import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../timezone_helper.dart';

part 'firebase_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(FirestoreRef ref) {
  final instance = FirebaseFirestore.instance;

  // Only configure once - Firestore instance is a singleton
  // Settings will throw if called multiple times, so we don't need to worry
  // about reconfiguration

  return instance;
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;

/// Access the TimezoneHelper instance
/// This is a workaround to access the Redux AppState's timezoneHelper
/// In a full Riverpod migration, this would be managed differently
@Riverpod(keepAlive: true)
TimezoneHelper timezoneHelper(TimezoneHelperRef ref) {
  // For now, we'll create a new instance
  // TODO: In full migration, manage timezone initialization properly
  return TimezoneHelper();
}
