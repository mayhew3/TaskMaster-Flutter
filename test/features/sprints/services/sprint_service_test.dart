import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/features/sprints/services/sprint_service.dart';
import 'package:taskmaster/models/sprint_blueprint.dart';

void main() {
  group('SprintService UTC Conversion Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SprintService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = SprintService(fakeFirestore);
    });

    test('sprint dates should be saved as UTC', () async {
      // Create sprint with local time Friday 4pm (isUtc = false)
      // This simulates a user selecting 4pm in their local timezone
      final localStartDate = DateTime(2024, 1, 12, 16, 0); // 4pm local, isUtc=false
      final localEndDate = DateTime(2024, 1, 19, 16, 0); // 4pm next Friday local

      expect(localStartDate.isUtc, isFalse, reason: 'Test setup: startDate should be local time');
      expect(localEndDate.isUtc, isFalse, reason: 'Test setup: endDate should be local time');

      final blueprint = SprintBlueprint(
        startDate: localStartDate,
        endDate: localEndDate,
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      // Create sprint
      final sprint = await service.createSprintWithTasks(
        sprintBlueprint: blueprint,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // Verify the sprint's dates are in UTC
      expect(sprint.startDate.isUtc, isTrue,
          reason: 'Sprint startDate should be stored as UTC');
      expect(sprint.endDate.isUtc, isTrue,
          reason: 'Sprint endDate should be stored as UTC');

      // Verify the absolute time is preserved correctly
      // When we call .toUtc() on a local DateTime, it converts to the same instant in UTC
      expect(sprint.startDate, equals(localStartDate.toUtc()),
          reason: 'Sprint startDate should equal the UTC conversion of local input');
      expect(sprint.endDate, equals(localEndDate.toUtc()),
          reason: 'Sprint endDate should equal the UTC conversion of local input');

      // Also verify what was actually written to Firestore
      final sprintDoc = await fakeFirestore.collection('sprints').doc(sprint.docId).get();
      final savedData = sprintDoc.data()!;

      // Firestore returns Timestamps. Timestamp.toDate() returns local time, but
      // the underlying value should match the UTC conversion of our input.
      final savedStartDate = (savedData['startDate'] as Timestamp).toDate();
      final savedEndDate = (savedData['endDate'] as Timestamp).toDate();

      // Verify the saved dates represent the same instant in time as our UTC conversion
      // Note: Timestamp.toDate() returns local time, so we compare millisecondsSinceEpoch
      expect(savedStartDate.millisecondsSinceEpoch,
          equals(localStartDate.toUtc().millisecondsSinceEpoch),
          reason: 'Firestore startDate should represent the same instant as UTC input');
      expect(savedEndDate.millisecondsSinceEpoch,
          equals(localEndDate.toUtc().millisecondsSinceEpoch),
          reason: 'Firestore endDate should represent the same instant as UTC input');
    });

    test('sprint end time comparison works correctly across timezone boundaries', () async {
      // This test verifies the core bug scenario:
      // User creates a sprint ending at Friday 4pm local (PST = UTC-8)
      // Without UTC conversion, the sprint would end at 8am local instead of 4pm

      // Simulate local time: Friday 4pm local
      final localEndDate = DateTime(2024, 1, 19, 16, 0); // 4pm local

      final blueprint = SprintBlueprint(
        startDate: DateTime(2024, 1, 12, 16, 0),
        endDate: localEndDate,
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      final sprint = await service.createSprintWithTasks(
        sprintBlueprint: blueprint,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // Simulate checking if sprint is still active at Friday 3pm local (one hour before end)
      final oneHourBeforeEnd = localEndDate.subtract(const Duration(hours: 1));
      final checkTimeUtc = oneHourBeforeEnd.toUtc();

      // Sprint should still be active (end time not yet reached)
      expect(checkTimeUtc.isBefore(sprint.endDate), isTrue,
          reason: 'Sprint should be active 1 hour before scheduled end time');

      // Simulate checking if sprint is completed at Friday 5pm local (one hour after end)
      final oneHourAfterEnd = localEndDate.add(const Duration(hours: 1));
      final checkTimeAfterUtc = oneHourAfterEnd.toUtc();

      // Sprint should be completed (end time passed)
      expect(checkTimeAfterUtc.isAfter(sprint.endDate), isTrue,
          reason: 'Sprint should be completed 1 hour after scheduled end time');
    });

    test('dateAdded is also saved as UTC', () async {
      // This verifies the existing correct behavior for dateAdded
      final blueprint = SprintBlueprint(
        startDate: DateTime(2024, 1, 12, 16, 0),
        endDate: DateTime(2024, 1, 19, 16, 0),
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      final sprint = await service.createSprintWithTasks(
        sprintBlueprint: blueprint,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // dateAdded should always be UTC
      expect(sprint.dateAdded.isUtc, isTrue,
          reason: 'Sprint dateAdded should be stored as UTC');
    });

    test('UTC sprint dates enable correct active/completed detection', () async {
      // This test verifies that sprints with UTC dates are correctly identified
      // as active or completed based on the current time.

      // Create a sprint that starts in the past and ends in the future (active)
      final now = DateTime.now();
      final activeBlueprintLocal = SprintBlueprint(
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 6)),
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      final activeSprint = await service.createSprintWithTasks(
        sprintBlueprint: activeBlueprintLocal,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // Verify active sprint detection logic would work
      final currentUtc = DateTime.now().toUtc();
      final isActive = activeSprint.startDate.isBefore(currentUtc) &&
          activeSprint.endDate.isAfter(currentUtc) &&
          activeSprint.closeDate == null;

      expect(isActive, isTrue,
          reason: 'Sprint starting yesterday and ending in 6 days should be active');

      // Create a sprint that ended in the past (completed)
      final completedBlueprintLocal = SprintBlueprint(
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      final completedSprint = await service.createSprintWithTasks(
        sprintBlueprint: completedBlueprintLocal,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // Verify completed sprint detection logic would work
      final isCompleted = currentUtc.isAfter(completedSprint.endDate);

      expect(isCompleted, isTrue,
          reason: 'Sprint that ended 7 days ago should be completed');
    });

    test('sprint with exact end time is detected correctly', () async {
      // Test edge case: what happens when we're right at the end time?
      // This verifies the fix prevents the ~8 hour offset bug

      // Create a sprint ending "now" (well, in 1 second to avoid race conditions)
      final now = DateTime.now();
      final almostEndedBlueprint = SprintBlueprint(
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(seconds: 1)),
        numUnits: 1,
        unitName: 'Weeks',
        personDocId: 'test-person',
      );

      final almostEndedSprint = await service.createSprintWithTasks(
        sprintBlueprint: almostEndedBlueprint,
        taskItems: [],
        taskItemRecurPreviews: [],
      );

      // The sprint should still be active (endDate is in the future by 1 second)
      final currentUtc = DateTime.now().toUtc();
      expect(almostEndedSprint.endDate.isAfter(currentUtc), isTrue,
          reason: 'Sprint ending in 1 second should still be active');

      // The absolute time should be preserved
      expect(almostEndedSprint.endDate.millisecondsSinceEpoch,
          equals(almostEndedBlueprint.endDate.toUtc().millisecondsSinceEpoch),
          reason: 'Sprint end time should match the original input after UTC conversion');
    });
  });
}
