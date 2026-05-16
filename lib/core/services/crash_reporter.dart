import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crash_reporter.g.dart';

/// Platform-agnostic crash-reporting surface. The native implementation
/// ([CrashReporter]) forwards to Firebase Crashlytics; the web build
/// uses [CrashReporterWebNoop] (firebase_crashlytics has no web support).
abstract class CrashReporterBase {
  bool get isEnabled;
  Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  });
  Future<void> log(String message);
  Future<void> setUserIdentifier(String personDocId);
  Future<void> setCustomKey(String key, Object value);
}

/// Wrapper around Firebase Crashlytics for consistent error reporting.
/// Disabled in debug mode — only reports in release/profile builds.
class CrashReporter implements CrashReporterBase {
  final FirebaseCrashlytics _crashlytics;

  CrashReporter(this._crashlytics);

  /// Whether crash collection is enabled.
  /// Always false in debug mode so local development doesn't pollute the dashboard.
  @override
  bool get isEnabled => !kDebugMode;

  /// Report a non-fatal error with optional context.
  @override
  Future<void> logError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    if (!isEnabled) {
      debugPrint('❌ [CrashReporter.debug] $error${context != null ? " ($context)" : ""}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
      return;
    }
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: context,
      fatal: fatal,
    );
  }

  /// Add a breadcrumb log entry that will be attached to the next crash report.
  @override
  Future<void> log(String message) async {
    if (!isEnabled) return;
    await _crashlytics.log(message);
  }

  /// Associate crashes with a specific user (anonymized ID, not email/PII).
  @override
  Future<void> setUserIdentifier(String personDocId) async {
    if (!isEnabled) return;
    await _crashlytics.setUserIdentifier(personDocId);
  }

  /// Set a custom key/value pair attached to subsequent crash reports.
  @override
  Future<void> setCustomKey(String key, Object value) async {
    if (!isEnabled) return;
    await _crashlytics.setCustomKey(key, value);
  }
}

@Riverpod(keepAlive: true)
CrashReporterBase crashReporter(Ref ref) =>
    CrashReporter(FirebaseCrashlytics.instance);
