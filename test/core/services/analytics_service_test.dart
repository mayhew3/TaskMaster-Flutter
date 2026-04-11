import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmaster/core/services/analytics_service.dart';

import 'analytics_service_test.mocks.dart';

/// Smoke tests for AnalyticsService.
/// Tests run in debug mode (`kDebugMode == true`), so these verify that
/// methods are no-ops and never touch FirebaseAnalytics.
/// Integration with real Analytics is verified manually in release builds.
@GenerateNiceMocks([MockSpec<FirebaseAnalytics>()])
void main() {
  group('AnalyticsService debug-mode behavior', () {
    late MockFirebaseAnalytics mockAnalytics;
    late AnalyticsService service;

    setUp(() {
      mockAnalytics = MockFirebaseAnalytics();
      service = AnalyticsService(mockAnalytics);
    });

    test('isEnabled returns false in debug mode', () {
      expect(service.isEnabled, false);
    });

    test('setUserIdentifier does not call Analytics in debug mode', () async {
      await service.setUserIdentifier('person-123');
      verifyNever(mockAnalytics.setUserId(id: anyNamed('id')));
    });

    test('logTaskCreated does not call Analytics in debug mode', () async {
      await service.logTaskCreated(hasRecurrence: true);
      verifyNever(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      ));
    });

    test('logTaskCompleted does not call Analytics in debug mode', () async {
      await service.logTaskCompleted(complete: true);
      verifyNever(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      ));
    });

    test('logTaskDeleted does not call Analytics in debug mode', () async {
      await service.logTaskDeleted();
      verifyNever(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      ));
    });

    test('logSprintCreated does not call Analytics in debug mode', () async {
      await service.logSprintCreated(taskCount: 5);
      verifyNever(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      ));
    });

    test('logScreenView does not call Analytics in debug mode', () async {
      await service.logScreenView('TaskList');
      verifyNever(mockAnalytics.logScreenView(
        screenName: anyNamed('screenName'),
      ));
    });
  });
}
