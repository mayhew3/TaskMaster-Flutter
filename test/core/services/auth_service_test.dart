import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/providers/firebase_providers.dart';
import 'package:taskmaestro/core/services/analytics_service.dart';
import 'package:taskmaestro/core/services/auth_service.dart';
import 'package:taskmaestro/core/services/crash_reporter.dart';
import 'package:taskmaestro/core/services/crash_reporter_web_noop.dart';

/// Minimal hand fakes — firebase_auth_mocks is not a dependency and the
/// web auth path only touches `currentUser` + `authStateChanges()`.
class _FakeUser implements User {
  _FakeUser(this._email);
  final String? _email;
  @override
  String? get email => _email;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseAuth implements FirebaseAuth {
  _FakeFirebaseAuth(this._user);
  final User? _user;
  @override
  User? get currentUser => _user;
  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(_user);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopAnalytics implements AnalyticsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

/// `authProvider` is a sync Notifier whose `_initialize()` runs async off
/// `build()`. Resolve once it leaves the loading states (the post-build
/// defer regression manifests as never leaving `initial` → this times
/// out and the test fails, which is the point).
Future<AuthState> _awaitAuthSettled(ProviderContainer container) {
  final completer = Completer<AuthState>();
  final sub = container.listen<AuthState>(authProvider, (prev, next) {
    if (completer.isCompleted) return;
    if (next.status == AuthStatus.initial ||
        next.status == AuthStatus.authenticating) {
      return;
    }
    completer.complete(next);
  }, fireImmediately: true);
  return completer.future
      .timeout(const Duration(seconds: 5))
      .whenComplete(sub.close);
}

ProviderContainer _webContainer({
  required FirebaseAuth auth,
  required FakeFirebaseFirestore firestore,
}) {
  return ProviderContainer(
    overrides: [
      targetIsWebProvider.overrideWithValue(true),
      firebaseAuthProvider.overrideWithValue(auth),
      firestoreProvider.overrideWithValue(firestore),
      crashReporterProvider.overrideWithValue(CrashReporterWebNoop()),
      analyticsServiceProvider.overrideWithValue(_NoopAnalytics()),
    ],
  );
}

void main() {
  group('classifyAuthError', () {
    test('connection-ish errors → connectionError', () {
      for (final e in [
        Exception('FirebaseException: unavailable'),
        TimeoutException('Future not completed'),
        Exception('Failed to connect to server'),
        Exception('ECONNREFUSED 127.0.0.1:8085'),
      ]) {
        final s = classifyAuthError(e);
        expect(s.status, AuthStatus.connectionError,
            reason: 'for $e');
      }
    });

    test('generic error → unauthenticated with message', () {
      final s = classifyAuthError(Exception('boom'));
      expect(s.status, AuthStatus.unauthenticated);
      expect(s.errorMessage, contains('Sign in failed'));
    });
  });

  group('Auth web path', () {
    test(
        'C3 regression: persisted session resolves to authenticated '
        '(not clobbered to initial post-build)', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection('persons')
          .add({'email': 'me@example.com'});
      final container = _webContainer(
        auth: _FakeFirebaseAuth(_FakeUser('me@example.com')),
        firestore: firestore,
      );
      addTearDown(container.dispose);

      final settled = await _awaitAuthSettled(container);

      expect(settled.status, AuthStatus.authenticated);
      expect(settled.personDocId, isNotNull);
    });

    test('I5: known Firebase user but no person doc → personNotFound',
        () async {
      final firestore = FakeFirebaseFirestore(); // no persons seeded
      final container = _webContainer(
        auth: _FakeFirebaseAuth(_FakeUser('ghost@example.com')),
        firestore: firestore,
      );
      addTearDown(container.dispose);

      final settled = await _awaitAuthSettled(container);

      expect(settled.status, AuthStatus.personNotFound);
    });

    test('no persisted session → unauthenticated', () async {
      final container = _webContainer(
        auth: _FakeFirebaseAuth(null),
        firestore: FakeFirebaseFirestore(),
      );
      addTearDown(container.dispose);

      final settled = await _awaitAuthSettled(container);

      expect(settled.status, AuthStatus.unauthenticated);
    });
  });
}
