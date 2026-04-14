import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/core/services/crash_reporter.dart';

import 'crash_reporter_test.mocks.dart';

/// Smoke tests for CrashReporter.
/// Tests run in debug mode (`kDebugMode == true`), so these verify that
/// methods are no-ops and never touch FirebaseCrashlytics.
/// Integration with real Crashlytics is verified manually in release builds.
@GenerateNiceMocks([MockSpec<FirebaseCrashlytics>()])
void main() {
  group('CrashReporter debug-mode behavior', () {
    late MockFirebaseCrashlytics mockCrashlytics;
    late CrashReporter reporter;

    setUp(() {
      mockCrashlytics = MockFirebaseCrashlytics();
      reporter = CrashReporter(mockCrashlytics);
    });

    test('isEnabled returns false in debug mode', () {
      expect(reporter.isEnabled, false);
    });

    test('logError does not call Crashlytics in debug mode', () async {
      await reporter.logError(
        Exception('test'),
        StackTrace.current,
        context: 'unit test',
      );
      verifyNever(mockCrashlytics.recordError(
        any,
        any,
        reason: anyNamed('reason'),
        fatal: anyNamed('fatal'),
      ));
    });

    test('log does not call Crashlytics in debug mode', () async {
      await reporter.log('breadcrumb');
      verifyNever(mockCrashlytics.log(any));
    });

    test('setUserIdentifier does not call Crashlytics in debug mode', () async {
      await reporter.setUserIdentifier('user-123');
      verifyNever(mockCrashlytics.setUserIdentifier(any));
    });

    test('setCustomKey does not call Crashlytics in debug mode', () async {
      await reporter.setCustomKey('foo', 'bar');
      verifyNever(mockCrashlytics.setCustomKey(any, any));
    });
  });
}
