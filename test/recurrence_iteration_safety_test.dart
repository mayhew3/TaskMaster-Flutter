import 'package:taskmaster/helpers/recurrence_helper.dart';
import 'package:taskmaster/models/sprint_display_task.dart';
import 'package:taskmaster/models/task_item_recur_preview.dart';
import 'package:test/test.dart';

import 'mocks/mock_data_builder.dart';
import 'mocks/mock_recurrence_builder.dart';

/// Tests for the safety limit on recurrence iteration generation.
///
/// The `addNextIterations` method in PlanTaskList and SprintPlanningScreen
/// recursively generates future task iterations. This test verifies that
/// the same iteration pattern (using RecurrenceHelper.createNextIteration)
/// terminates correctly with a depth limit, preventing infinite loops from
/// corrupted data or date calculation bugs.
void main() {
  /// Simulates the same recursion pattern as addNextIterations in
  /// plan_task_list.dart and sprint_planning_screen.dart, with the
  /// same depth limit of 365.
  List<TaskItemRecurPreview> simulateAddNextIterations(
    SprintDisplayTask newest,
    DateTime endDate, {
    int maxDepth = 365,
  }) {
    List<TaskItemRecurPreview> collector = [];

    void recurse(SprintDisplayTask current, int depth) {
      if (depth >= maxDepth) {
        return;
      }
      TaskItemRecurPreview nextIteration =
          RecurrenceHelper.createNextIteration(current, DateTime.now());
      var willBeUrgentOrDue = nextIteration.isDueBefore(endDate) ||
          nextIteration.isUrgentBefore(endDate);
      var willBeTargetOrStart = nextIteration.isTargetBefore(endDate) ||
          nextIteration.isScheduledBefore(endDate);

      if (willBeUrgentOrDue || willBeTargetOrStart) {
        collector.add(nextIteration);
        recurse(nextIteration, depth + 1);
      }
    }

    recurse(newest, 0);
    return collector;
  }

  group('Recurrence iteration safety limit', () {
    test('daily recurrence within normal range generates expected iterations', () {
      // Use a builder that has daily recurrence
      var builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceDocId = MockTaskItemBuilder.me;

      // Create a task recurrence with daily interval
      builder.taskRecurrence = MockTaskRecurrenceBuilderHelper.daily(builder);
      var task = builder.create();

      var endDate = DateTime.now().toUtc().add(Duration(days: 30));
      var iterations = simulateAddNextIterations(task, endDate);

      // Daily task over 30 days should generate a reasonable number of iterations
      // (not exactly 30 due to date offset logic, but well under 365)
      expect(iterations.length, lessThan(365));
      expect(iterations.length, greaterThan(0));
    });

    test('safety limit caps iterations at 365', () {
      // Create a daily recurring task with a very far-out end date (3 years)
      var builder = MockTaskItemBuilder.withDates()
        ..withDueDateAnchor()
        ..recurNumber = 1
        ..recurUnit = 'Days'
        ..recurWait = false
        ..recurIteration = 1
        ..recurrenceDocId = MockTaskItemBuilder.me;

      builder.taskRecurrence = MockTaskRecurrenceBuilderHelper.daily(builder);
      var task = builder.create();

      // End date 3 years out would generate ~1095 daily iterations without the limit
      var endDate = DateTime.now().toUtc().add(Duration(days: 1095));
      var iterations = simulateAddNextIterations(task, endDate);

      // Safety limit should cap at exactly 365 iterations (depth 0 through 364)
      expect(iterations.length, equals(365));
    });

    test('weekly recurrence for 1 year stays well under safety limit', () {
      // Standard weekly task, 1 year window
      var task = MockTaskItemBuilder
          .withDates()
          .withDueDateAnchor()
          .withRecur(recurWait: false)
          .create();

      var endDate = DateTime.now().toUtc().add(Duration(days: 365));
      var iterations = simulateAddNextIterations(task, endDate);

      // 6-week recurrence over 1 year = ~8-9 iterations, well under limit
      expect(iterations.length, lessThan(20));
      expect(iterations.length, greaterThan(0));
    });
  });
}

/// Helper to create daily recurrence builders for testing
class MockTaskRecurrenceBuilderHelper {
  static MockTaskRecurrenceBuilder daily(MockTaskItemBuilder builder) {
    var anchorDate = builder.getAnchorDate()!;
    return MockTaskRecurrenceBuilder()
      ..docId = MockTaskItemBuilder.me
      ..name = builder.name
      ..recurNumber = 1
      ..recurUnit = 'Days'
      ..recurWait = false
      ..recurIteration = 1
      ..anchorDate = anchorDate;
  }
}
