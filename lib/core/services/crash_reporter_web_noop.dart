import 'crash_reporter.dart';

/// Web no-op crash reporter. firebase_crashlytics has no web support;
/// this keeps app code (which reads `crashReporterProvider`) unchanged
/// while doing nothing on web. Imports no firebase_crashlytics.
class CrashReporterWebNoop implements CrashReporterBase {
  @override
  bool get isEnabled => false;

  @override
  Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setUserIdentifier(String personDocId) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
