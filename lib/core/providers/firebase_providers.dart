import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  final instance = FirebaseFirestore.instance;

  // Only configure once - Firestore instance is a singleton
  // Settings will throw if called multiple times, so we don't need to worry
  // about reconfiguration

  return instance;
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;
