import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crash_reporter.g.dart';

/// Wrapper around Firebase Crashlytics for consistent error reporting.
/// Disabled in debug mode — only reports in release/profile builds.
class CrashReporter {
  final FirebaseCrashlytics _crashlytics;

  CrashReporter(this._crashlytics);

  /// Whether crash collection is enabled.
  /// Always false in debug mode so local development doesn't pollute the dashboard.
  bool get isEnabled => !kDebugMode;

  /// Report a non-fatal error with optional context.
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
  Future<void> log(String message) async {
    if (!isEnabled) return;
    await _crashlytics.log(message);
  }

  /// Associate crashes with a specific user (anonymized ID, not email/PII).
  Future<void> setUserIdentifier(String personDocId) async {
    if (!isEnabled) return;
    await _crashlytics.setUserIdentifier(personDocId);
  }

  /// Set a custom key/value pair attached to subsequent crash reports.
  Future<void> setCustomKey(String key, Object value) async {
    if (!isEnabled) return;
    await _crashlytics.setCustomKey(key, value);
  }
}

@Riverpod(keepAlive: true)
CrashReporter crashReporter(Ref ref) =>
    CrashReporter(FirebaseCrashlytics.instance);
