import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Wrapper around Firebase Analytics for consistent event tracking.
/// Disabled in debug mode — only reports in release/profile builds.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  /// Whether analytics collection is enabled.
  /// Always false in debug mode so local development doesn't pollute dashboards.
  bool get isEnabled => !kDebugMode;

  // ── User identity ──────────────────────────────────────────────────────────

  /// Associate analytics with a specific user (anonymized ID, not email/PII).
  Future<void> setUserIdentifier(String personDocId) async {
    if (!isEnabled) return;
    await _analytics.setUserId(id: personDocId);
  }

  // ── Task events ────────────────────────────────────────────────────────────

  /// Log when a new task is created.
  Future<void> logTaskCreated({bool hasRecurrence = false}) async {
    if (!isEnabled) return;
    await _analytics.logEvent(
      name: 'task_created',
      parameters: {'has_recurrence': hasRecurrence ? 1 : 0},
    );
  }

  /// Log when a task is completed or un-completed.
  Future<void> logTaskCompleted({required bool complete}) async {
    if (!isEnabled) return;
    await _analytics.logEvent(
      name: complete ? 'task_completed' : 'task_uncompleted',
    );
  }

  /// Log when a task is deleted.
  Future<void> logTaskDeleted() async {
    if (!isEnabled) return;
    await _analytics.logEvent(name: 'task_deleted');
  }

  // ── Sprint events ──────────────────────────────────────────────────────────

  /// Log when a new sprint is created.
  Future<void> logSprintCreated({required int taskCount}) async {
    if (!isEnabled) return;
    await _analytics.logEvent(
      name: 'sprint_created',
      parameters: {'task_count': taskCount},
    );
  }

  // ── Screen tracking ────────────────────────────────────────────────────────

  /// Log a screen view.
  Future<void> logScreenView(String screenName) async {
    if (!isEnabled) return;
    await _analytics.logScreenView(screenName: screenName);
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) =>
    AnalyticsService(FirebaseAnalytics.instance);
