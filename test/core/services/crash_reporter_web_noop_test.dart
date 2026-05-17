import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaestro/core/services/crash_reporter.dart';
import 'package:taskmaestro/core/services/crash_reporter_web_noop.dart';

void main() {
  group('CrashReporterWebNoop', () {
    late CrashReporterBase reporter;

    setUp(() => reporter = CrashReporterWebNoop());

    test('is a CrashReporterBase', () {
      expect(reporter, isA<CrashReporterBase>());
    });

    test('isEnabled is always false', () {
      expect(reporter.isEnabled, isFalse);
    });

    test('all methods complete without throwing', () async {
      await expectLater(
        reporter.logError(Exception('x'), StackTrace.current,
            context: 'ctx', fatal: true),
        completes,
      );
      await expectLater(reporter.log('breadcrumb'), completes);
      await expectLater(reporter.setUserIdentifier('person1'), completes);
      await expectLater(reporter.setCustomKey('k', 'v'), completes);
    });
  });
}
